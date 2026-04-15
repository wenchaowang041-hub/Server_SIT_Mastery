#!/bin/bash
#===============================================================================
# FRU 批量查询工具
# 功能：批量查询指定 FRU 设备的详细信息，支持按关键词筛选和格式化输出
#
# 用法：
#   ./fru-info.sh                    # 列出所有 FRU 设备
#   ./fru-info.sh -l                 # 列表所有 FRU（简要信息）
#   ./fru-info.sh -a                 # 打印所有 FRU 详细信息
#   ./fru-info.sh -i 26              # 查询指定 ID 的 FRU
#   ./fru-info.sh -k "M2"            # 按关键词筛选 FRU
#   ./fru-info.sh -k "PSU" -f serial # 只查 PSU 的序列号
#   ./fru-info.sh -k "PSU" --table   # 表格格式输出 PSU 信息
#   ./fru-info.sh -e 26 field b 0 "iSoftStone123"  # 编辑指定 FRU 字段
#
# 字段说明：
#   field c = Chassis 区域
#   field b = Board 区域
#   field p = Product 区域
#   field i = Internal 区域
#===============================================================================

set -euo pipefail

#========================== 参数解析 ==========================

ACTION="list"           # list | detail | keyword | edit
FRU_ID=""
KEYWORD=""
FIELDS=""
TABLE=false

usage() {
    cat << 'EOF'
用法: fru-info.sh [选项]

选项:
  -l              列表所有 FRU 设备（简要）
  -a              打印所有 FRU 详细信息
  -i ID           查询指定 FRU ID 的详细信息
  -k "关键词"     按关键词筛选 FRU（如 "PSU"、"M2"、"Fan"）
  -f "字段"       配合 -k 使用，只查特定字段（如 "serial"、"mfg"、"product"）
  --table         配合 -k 使用，以表格格式输出
  -e ID 参数...   编辑指定 FRU（例: -e 26 field b 0 "NewValue"）
  -h              显示帮助

示例:
  fru-info.sh -k "M2"                     # 查询 M2 相关 FRU
  fru-info.sh -k "PSU" --table            # 表格显示所有 PSU 信息
  fru-info.sh -i 26                       # 查看 ID 26 的详细 FRU
  fru-info.sh -e 26 field b 0 "iSoftStone" # 编辑 ID 26 的 Board Mfg 字段
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l)       ACTION="list_all"; shift ;;
        -a)       ACTION="all_detail"; shift ;;
        -i)       ACTION="detail"; FRU_ID="$2"; shift 2 ;;
        -k)       ACTION="keyword"; KEYWORD="$2"; shift 2 ;;
        -f)       FIELDS="$2"; shift 2 ;;
        --table)  TABLE=true; shift ;;
        -e)       ACTION="edit"; shift; EDIT_ARGS=("$@"); break ;;
        -h|--help) usage ;;
        *)        echo "未知参数: $1"; usage ;;
    esac
done

#========================== 函数定义 ==========================

# 列出所有 FRU 设备（简要）
list_fru() {
    echo "=== FRU 设备列表 ==="
    ipmitool fru list
}

# 打印指定 FRU 的详细信息
print_fru_detail() {
    local id=$1
    echo "=== FRU ID $id ==="
    ipmitool fru print "$id" 2>/dev/null || echo "  [读取失败]"
    echo ""
}

# 按关键词筛选 FRU
keyword_search() {
    local keyword="$1"
    echo "=== 搜索关键词: $keyword ==="

    # 获取匹配的 FRU ID
    local ids
    ids=$(ipmitool fru list 2>/dev/null | grep -i "$keyword" | grep -oP 'ID \K[0-9]+')

    if [[ -z "$ids" ]]; then
        echo "未找到匹配的 FRU 设备"
        return 1
    fi

    if $TABLE; then
        # 表格格式输出
        printf "%-6s | %-25s | %-20s | %-20s | %-20s | %-20s\n" \
            "ID" "Description" "Board Mfg" "Product Name" "S/N" "P/N"
        printf "%-6s-+-%-25s-+-%-20s-+-%-20s-+-%-20s-+-%-20s\n" \
            "------" "-------------------------" "--------------------" "--------------------" "--------------------" "--------------------"

        for id in $ids; do
            local desc mfg product serial part
            desc=$(ipmitool fru list 2>/dev/null | grep -i "$keyword" | grep "ID $id " | sed 's/.*Description : //')
            local fru_out
            fru_out=$(ipmitool fru print "$id" 2>/dev/null || echo "")
            mfg=$(echo "$fru_out" | grep "Board Mfg" | head -1 | awk -F: '{gsub(/^[ \t]+/, "", $2); print $2}')
            product=$(echo "$fru_out" | grep "Product Name" | awk -F: '{gsub(/^[ \t]+/, "", $2); print $2}')
            serial=$(echo "$fru_out" | grep "Product Serial" | awk -F: '{gsub(/^[ \t]+/, "", $2); print $2}')
            part=$(echo "$fru_out" | grep "Product Part" | awk -F: '{gsub(/^[ \t]+/, "", $2); print $2}')
            printf "%-6s | %-25s | %-20s | %-20s | %-20s | %-20s\n" \
                "$id" "${desc:--}" "${mfg:--}" "${product:--}" "${serial:--}" "${part:--}"
        done
    else
        for id in $ids; do
            if [[ -n "$FIELDS" ]]; then
                echo "--- FRU ID $id ---"
                ipmitool fru print "$id" 2>/dev/null | grep -i "$FIELDS"
            else
                print_fru_detail "$id"
            fi
        done
    fi
}

# 编辑 FRU 字段（带安全确认）
edit_fru() {
    local id="$1"
    shift
    echo "=== FRU 编辑确认 ==="
    echo "目标: FRU ID $id"

    # 先打印当前值
    echo "当前值:"
    ipmitool fru print "$id" 2>/dev/null || { echo "读取 FRU 失败"; exit 1; }

    echo ""
    echo "修改命令: ipmitool fru edit $id $*"
    echo ""
    read -p "确认执行？(y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "已取消"
        exit 0
    fi

    echo "执行中..."
    ipmitool fru edit "$id" "$@"
    echo ""
    echo "修改后:"
    ipmitool fru print "$id" 2>/dev/null
}

#========================== 主流程 ==========================

case "$ACTION" in
    list_all)
        list_fru
        ;;
    all_detail)
        local_ids=$(ipmitool fru list 2>/dev/null | grep -oP 'ID \K[0-9]+' || echo "")
        if [[ -z "$local_ids" ]]; then
            echo "未找到任何 FRU 设备"
            exit 1
        fi
        for id in $local_ids; do
            print_fru_detail "$id"
        done
        ;;
    detail)
        print_fru_detail "$FRU_ID"
        ;;
    keyword)
        keyword_search "$KEYWORD"
        ;;
    edit)
        edit_fru "${EDIT_ARGS[@]}"
        ;;
    *)
        # 默认行为：列表
        list_fru
        echo ""
        echo "提示: 使用 -h 查看更多用法"
        ;;
esac
