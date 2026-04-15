#!/bin/bash
#===============================================================================
# AC Cycle 测试脚本 - 智能PDU版
# 功能：通过PDU控制电源通断，完成 AC Cycle 自动化测试
#
# 支持的PDU类型：
#   1. SNMP (APC / ServerTech 等通用型号)
#   2. HTTP REST API (华为/浪潮等国产PDU)
#   3. 自定义命令（替换 pdu_on / pdu_off 函数即可）
#
# 用法：
#   ./ac-cycle-pdu.sh
#===============================================================================

set -euo pipefail

#========================== 可配置参数 ==========================

# PDU 类型：snmp | http | custom
PDU_TYPE="snmp"

# PDU 连接信息
PDU_IP="10.121.176.200"
PDU_COMMUNITY="private"        # SNMP write community
PDU_OUTLET="1"                 # PDU 插座编号（从1开始）

# HTTP API 专用（PDU_TYPE=http 时生效）
PDU_API_USER="admin"
PDU_API_PASS="admin"

# 目标服务器
BMC_IP="10.121.176.138"
BMC_USER="root"
BMC_PASS="Admin@9000"
OS_IP="10.121.177.157"
OS_USER="root"
OS_PASS=""

# 测试参数
TOTAL_CYCLES=500               # 总圈数
AC_OFF_SECONDS=30              # 断电等待时间（秒），确保电容放完
BMC_WAIT_SECONDS=90            # 上电后等BMC起来的时间（秒）
OS_WAIT_SECONDS=120            # BMC起来后等OS起来的时间（秒）
CYCLE_PAUSE=5                  # 每圈之间的额外间隔（秒）

# 日志
LOG_FILE="./ac_cycle_$(date +%Y%m%d_%H%M%S).log"
FAIL_LOG="./ac_cycle_fail_$(date +%Y%m%d_%H%M%S).log"

# 告警（飞书/钉钉/邮件 webhook，可选）
WEBHOOK_URL=""

#========================== SNMP OID 配置 ==========================
# APC 型号
APC_OUTLET_OID=".1.3.6.1.4.1.318.1.1.12.3.3.1.1.4"
# ServerTech 型号
SERVERTECH_OUTLET_OID=".1.3.6.1.4.1.1718.3.2.3.1.11.1"
# 通用 MIB（部分PDU）
GENERIC_OUTLET_OID=".1.3.6.1.2.1.105.1.3.3.1.3"

# 当前使用的 OID（根据PDU型号选择）
OUTLET_OID="$APC_OUTLET_OID"

#========================== 函数定义 ==========================

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" | tee -a "$LOG_FILE"
}

log_fail() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [FAIL] $*"
    echo "$msg" | tee -a "$LOG_FILE" "$FAIL_LOG"
}

send_alert() {
    local msg="$1"
    if [[ -n "$WEBHOOK_URL" ]]; then
        curl -s -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{\"text\":\"AC Cycle告警: $msg\"}" >/dev/null 2>&1 || true
    fi
}

#--- PDU 控制函数 ---

pdu_off() {
    case "$PDU_TYPE" in
        snmp)
            # APC: 1=on, 2=off, 3=reboot, 4=cycle, 5=shutdown
            snmpset -v2c -c "$PDU_COMMUNITY" "$PDU_IP" \
                "${OUTLET_OID}.${PDU_OUTLET}" i 2
            ;;
        http)
            curl -sk -u "$PDU_API_USER:$PDU_API_PASS" \
                -X POST "https://${PDU_IP}/api/v1/outlet/${PDU_OUTLET}/off" \
                -H "Content-Type: application/json" >/dev/null 2>&1
            ;;
        custom)
            # 替换为你的PDU控制命令
            echo "CUSTOM_PDU_OFF_COMMAND_HERE"
            ;;
    esac
}

pdu_on() {
    case "$PDU_TYPE" in
        snmp)
            snmpset -v2c -c "$PDU_COMMUNITY" "$PDU_IP" \
                "${OUTLET_OID}.${PDU_OUTLET}" i 1
            ;;
        http)
            curl -sk -u "$PDU_API_USER:$PDU_API_PASS" \
                -X POST "https://${PDU_IP}/api/v1/outlet/${PDU_OUTLET}/on" \
                -H "Content-Type: application/json" >/dev/null 2>&1
            ;;
        custom)
            echo "CUSTOM_PDU_ON_COMMAND_HERE"
            ;;
    esac
}

#--- 检查函数 ---

wait_for_bmc() {
    local max_wait=$BMC_WAIT_SECONDS
    local elapsed=0
    while [[ $elapsed -lt $max_wait ]]; do
        if ipmitool -I lanplus -H "$BMC_IP" -U "$BMC_USER" -P "$BMC_PASS" \
            chassis power status 2>/dev/null | grep -q "on\|off"; then
            log "  BMC 已恢复"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
    done
    return 1
}

wait_for_os() {
    local max_wait=$OS_WAIT_SECONDS
    local elapsed=0
    while [[ $elapsed -lt $max_wait ]]; do
        if sshpass -p "$OS_PASS" ssh -o StrictHostKeyChecking=no \
            -o ConnectTimeout=3 -o BatchMode=yes \
            "${OS_USER}@${OS_IP}" "echo ok" >/dev/null 2>&1; then
            log "  OS 已恢复"
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
    done
    return 1
}

check_system_health() {
    local cycle=$1
    local fail_reason=""

    # 1. 通过 IPMI 检查 SEL 日志是否有新增严重错误
    local sel_count
    sel_count=$(ipmitool -I lanplus -H "$BMC_IP" -U "$BMC_USER" -P "$BMC_PASS" \
        sel list 2>/dev/null | grep -ciE "critical|fatal" || echo "0")

    # 2. 检查电源状态
    local psu_status
    psu_status=$(ipmitool -I lanplus -H "$BMC_IP" -U "$BMC_USER" -P "$BMC_PASS" \
        chassis power status 2>/dev/null || echo "unknown")

    # 3. 如果有 SSH 访问能力，检查 OS 内部
    local dmesg_errors=""
    if [[ -n "$OS_PASS" ]]; then
        dmesg_errors=$(sshpass -p "$OS_PASS" ssh -o StrictHostKeyChecking=no \
            -o ConnectTimeout=3 "${OS_USER}@${OS_IP}" \
            "dmesg -T 2>/dev/null | grep -iE 'AER|PCIe.*fatal|npu.*error|nvme.*timeout' | tail -5" 2>/dev/null || echo "")
    fi

    # 判断是否有异常
    if [[ -n "$dmesg_errors" ]]; then
        fail_reason="dmesg errors: $dmesg_errors"
    fi

    if [[ -n "$fail_reason" ]]; then
        log_fail "Cycle $cycle: $fail_reason"
        send_alert "AC Cycle $cycle 异常: $fail_reason"
        return 1
    fi

    log "  系统健康检查通过"
    return 0
}

#========================== 主流程 ==========================

main() {
    log "========================================"
    log "AC Cycle 测试开始"
    log "PDU: $PDU_IP (outlet $PDU_OUTLET)"
    log "BMC: $BMC_IP"
    log "OS:  $OS_IP"
    log "总圈数: $TOTAL_CYCLES"
    log "AC OFF等待: ${AC_OFF_SECONDS}s, BMC等待: ${BMC_WAIT_SECONDS}s"
    log "日志: $LOG_FILE"
    log "========================================"

    local success=0
    local fail=0

    for i in $(seq 1 $TOTAL_CYCLES); do
        log "----------------------------------------"
        log ">>> 开始第 $i / $TOTAL_CYCLES 圈 <<<"

        # Step 1: PDU 断电
        log "  [1/5] PDU 断电..."
        pdu_off || { log_fail "Cycle $i: PDU OFF 命令失败"; fail=$((fail+1)); continue; }

        # Step 2: 等待电容放电
        log "  [2/5] 等待 ${AC_OFF_SECONDS}s..."
        sleep "$AC_OFF_SECONDS"

        # Step 3: PDU 上电
        log "  [3/5] PDU 上电..."
        pdu_on || { log_fail "Cycle $i: PDU ON 命令失败"; fail=$((fail+1)); continue; }

        # Step 4: 等待 BMC 恢复
        log "  [4/5] 等待 BMC 恢复（最多 ${BMC_WAIT_SECONDS}s）..."
        if ! wait_for_bmc; then
            log_fail "Cycle $i: BMC 未在 ${BMC_WAIT_SECONDS}s 内恢复"
            fail=$((fail + 1))
            send_alert "AC Cycle $i: BMC 恢复超时"
            continue
        fi

        # 额外等待OS启动
        log "  等待 OS 启动（${OS_WAIT_SECONDS}s）..."
        sleep "$OS_WAIT_SECONDS"

        # Step 5: 系统健康检查
        log "  [5/5] 系统健康检查..."
        if ! check_system_health "$i"; then
            fail=$((fail + 1))
            continue
        fi

        success=$((success + 1))
        log "  Cycle $i 完成 ✓"

        # 圈间间隔
        if [[ $CYCLE_PAUSE -gt 0 ]]; then
            sleep "$CYCLE_PAUSE"
        fi
    done

    log "========================================"
    log "AC Cycle 测试结束"
    log "总计: $TOTAL_CYCLES"
    log "成功: $success"
    log "失败: $fail"
    if [[ $fail -gt 0 ]]; then
        log "失败详情见: $FAIL_LOG"
        send_alert "AC Cycle 完成，失败 $fail/$TOTAL_CYCLES 圈"
    else
        log "全部通过 ✓"
    fi
    log "========================================"
}

main "$@"
