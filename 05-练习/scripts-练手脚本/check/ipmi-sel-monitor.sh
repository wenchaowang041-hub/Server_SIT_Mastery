#!/bin/bash
#===============================================================================
# IPMI SEL 日志监控工具
# 功能：实时监控 / 一次性采集 SEL 日志，过滤严重错误
#
# 用法：
#   ./ipmi-sel-monitor.sh              # 一次性采集当前 SEL 日志
#   ./ipmi-sel-monitor.sh -c           # 实时连续监控（有新增告警即打印）
#   ./ipmi-sel-monitor.sh -f critical  # 只查 Critical 级别
#   ./ipmi-sel-monitor.sh -f warning   # 只查 Warning 级别
#   ./ipmi-sel-monitor.sh -k "PCIe"    # 按关键词过滤
#   ./ipmi-sel-monitor.sh --since-id 10 # 只显示 ID > 10 的新条目
#   ./ipmi-sel-monitor.sh --export     # 导出为文件
#===============================================================================

set -euo pipefail

#========================== 可配置 ==========================

BMC_IP=""
BMC_USER="root"
BMC_PASS=""

# 日志级别过滤：all | critical | warning | ok
FILTER_LEVEL="all"

# 关键词过滤
KEYWORD=""

# 起始 ID（只看比这个大的新条目）
SINCE_ID=""

# 连续监控间隔（秒）
MONITOR_INTERVAL=10

# 导出
EXPORT=false
EXPORT_FILE="./sel_export_$(date +%Y%m%d_%H%M%S).log"

#========================== 参数解析 ==========================

ACTION="once"  # once | continuous

usage() {
    cat << 'EOF'
用法: ipmi-sel-monitor.sh [选项]

选项:
  -c                  连续监控模式（实时打印新增 SEL）
  -f LEVEL            过滤级别: all | critical | warning | ok
  -k "关键词"          按关键词过滤（如 "PCIe"、"Temp"、"Power"）
  --since-id NUM      只显示 ID > NUM 的条目
  --export            导出结果为文件
  --bmc IP            指定 BMC IP（默认本地）
  --user USER         BMC 用户名（默认 root）
  --pass PASS         BMC 密码
  -h                  显示帮助

示例:
  ipmi-sel-monitor.sh                        # 本地一次性采集
  ipmi-sel-monitor.sh -c                     # 实时监控
  ipmi-sel-monitor.sh -f critical            # 只看 Critical
  ipmi-sel-monitor.sh -k "PCIe" --export     # 过滤 PCIe 相关并导出
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c)            ACTION="continuous"; shift ;;
        -f)            FILTER_LEVEL="$2"; shift 2 ;;
        -k)            KEYWORD="$2"; shift 2 ;;
        --since-id)    SINCE_ID="$2"; shift 2 ;;
        --export)      EXPORT=true; shift ;;
        --bmc)         BMC_IP="$2"; shift 2 ;;
        --user)        BMC_USER="$2"; shift 2 ;;
        --pass)        BMC_PASS="$2"; shift 2 ;;
        -h|--help)     usage ;;
        *)             echo "未知参数: $1"; usage ;;
    esac
done

#========================== 函数定义 ==========================

# 构建 ipmitool 命令前缀
ipmi_cmd() {
    if [[ -n "$BMC_IP" ]]; then
        echo "ipmitool -I lanplus -H $BMC_IP -U $BMC_USER -P $BMC_PASS $*"
    else
        echo "ipmitool $*"
    fi
}

# 获取 SEL 原始内容
get_sel() {
    eval "$(ipmi_cmd sel list)" 2>/dev/null || echo ""
}

# 过滤日志
filter_sel() {
    local sel_content="$1"

    # 按级别过滤
    case "$FILTER_LEVEL" in
        critical) sel_content=$(echo "$sel_content" | grep -i "critical\|fatal" || true) ;;
        warning)  sel_content=$(echo "$sel_content" | grep -i "warning\|non-critical" || true) ;;
        ok)       sel_content=$(echo "$sel_content" | grep -i " ok \|recovered" || true) ;;
    esac

    # 按关键词过滤
    if [[ -n "$KEYWORD" ]]; then
        sel_content=$(echo "$sel_content" | grep -i "$KEYWORD" || true)
    fi

    # 按起始 ID 过滤
    if [[ -n "$SINCE_ID" ]]; then
        sel_content=$(echo "$sel_content" | awk -v min_id="$SINCE_ID" '{
            match($0, /^[0-9a-fA-F]+/);
            hex = substr($0, RSTART, RLENGTH);
            # 简单十进制比较（十六进制转十进制）
            cmd = "printf \"%d\" 0x" hex;
            cmd | getline dec_id;
            close(cmd);
            if (dec_id+0 > min_id+0) print;
        }')
    fi

    echo "$sel_content"
}

# 一次性采集
do_once() {
    echo "=== SEL 日志采集 ==="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    if [[ -n "$BMC_IP" ]]; then
        echo "BMC: $BMC_IP"
    else
        echo "BMC: 本地"
    fi
    echo "过滤: 级别=$FILTER_LEVEL, 关键词=${KEYWORD:-无}, 起始ID=${SINCE_ID:-无}"
    echo "----------------------------------------"

    local sel
    sel=$(get_sel)

    if [[ -z "$sel" ]]; then
        echo "[空] SEL 日志为空或无法读取"
        return
    fi

    local filtered
    filtered=$(filter_sel "$sel")

    if [[ -z "$filtered" ]]; then
        echo "[空] 过滤后无匹配条目"
    else
        echo "$filtered"
    fi

    if $EXPORT; then
        echo "$filtered" > "$EXPORT_FILE"
        echo ""
        echo "已导出到: $EXPORT_FILE"
    fi
}

# 连续监控
do_monitor() {
    echo "=== SEL 连续监控 ==="
    echo "间隔: ${MONITOR_INTERVAL}s"
    echo "按 Ctrl+C 停止"
    echo "----------------------------------------"

    local last_count
    last_count=$(get_sel | wc -l)

    while true; do
        sleep "$MONITOR_INTERVAL"

        local current_sel
        current_sel=$(get_sel)
        local current_count
        current_count=$(echo "$current_sel" | wc -l)

        if [[ "$current_count" -gt "$last_count" ]]; then
            local new_count=$((current_count - last_count))
            echo "[$(date '+%H:%M:%S')] 新增 $new_count 条 SEL 记录:"

            # 只打印新增部分
            local new_entries
            new_entries=$(echo "$current_sel" | tail -n "$new_count")
            local filtered_new
            filtered_new=$(filter_sel "$new_entries")

            if [[ -n "$filtered_new" ]]; then
                echo "$filtered_new"
                echo ""
            else
                echo "  (过滤后无匹配)"
                echo ""
            fi

            last_count=$current_count
        fi
    done
}

#========================== 主流程 ==========================

case "$ACTION" in
    once)      do_once ;;
    continuous) do_monitor ;;
esac
