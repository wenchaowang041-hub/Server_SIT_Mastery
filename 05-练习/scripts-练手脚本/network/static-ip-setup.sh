#!/bin/bash
#===============================================================================
# 静态 IP 配置辅助工具
# 功能：诊断网卡状态、配置静态 IP、解决 endvnic/eno1 冲突等问题
#
# 用法：
#   ./static-ip-setup.sh              # 诊断当前网络状态
#   ./static-ip-setup.sh -s           # 交互式设置静态 IP
#   ./static-ip-setup.sh --set IP/CIDR GATEWAY DNS1,DNS2 IFACE
#   ./static-ip-setup.sh --fix-eno1   # 修复 eno1/endvnic 冲突
#   ./static-ip-setup.sh --revert     # 恢复 DHCP
#===============================================================================

set -euo pipefail

#========================== 参数解析 ==========================

ACTION="diagnose"
IP_ADDR=""
GATEWAY=""
DNS=""
IFACE=""

usage() {
    cat << 'EOF'
用法: static-ip-setup.sh [选项]

选项:
  -s, --setup           交互式设置静态 IP
  --set IP GW DNS IF    直接设置静态 IP
                        例: --set 10.121.177.157/23 10.121.176.1 10.10.10.113 eno1
  --fix-eno1            修复 eno1/endvnic IP 冲突（华为鲲鹏平台常见）
  --revert IFACE        恢复指定网卡为 DHCP
  -d, --diagnose        诊断当前网络状态（默认）
  -h, --help            显示帮助

常见问题:
  1. eno1 和 endvnic 都有同一个 IP → 用 --fix-eno1
  2. eno1 的 NM 连接绑定到 --（设备不可用）→ 用 --fix-eno1
  3. 想快速设置静态 IP → 用 --set 或 -s
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--setup)     ACTION="interactive"; shift ;;
        --set)          ACTION="set"; IP_ADDR="$2"; GATEWAY="$3"; DNS="$4"; IFACE="$5"; shift 5 ;;
        --fix-eno1)     ACTION="fix_eno1"; shift ;;
        --revert)       ACTION="revert"; IFACE="$2"; shift 2 ;;
        -d|--diagnose)  ACTION="diagnose"; shift ;;
        -h|--help)      usage ;;
        *)              echo "未知参数: $1"; usage ;;
    esac
done

#========================== 函数定义 ==========================

# 诊断当前网络状态
diagnose() {
    echo "========================================"
    echo "  网络诊断报告"
    echo "========================================"
    echo ""

    echo "=== 网卡状态 ==="
    ip -o addr show | grep -v "scope host\|scope link"
    echo ""

    echo "=== 网卡连接状态 ==="
    nmcli device status 2>/dev/null || echo "nmcli 不可用"
    echo ""

    echo "=== NM 连接列表 ==="
    nmcli con show 2>/dev/null || echo "nmcli 不可用"
    echo ""

    echo "=== 默认路由 ==="
    ip route | grep default || echo "无默认路由"
    echo ""

    echo "=== 重复 IP 检测 ==="
    local dup_ips
    dup_ips=$(ip -o addr show | grep -v "scope host\|scope link" | awk '{print $4}' | sort | uniq -d)
    if [[ -n "$dup_ips" ]]; then
        echo "[警告] 以下 IP 被多个网卡使用:"
        echo "$dup_ips"
        echo ""
        echo "这会导致路由冲突！建议执行: $0 --fix-eno1"
    else
        echo "[正常] 无重复 IP"
    fi
    echo ""

    echo "=== 外网连通性 ==="
    local gw
    gw=$(ip route | grep default | head -1 | awk '{print $3}')
    if [[ -n "$gw" ]]; then
        if ping -c 2 -W 2 "$gw" >/dev/null 2>&1; then
            echo "[正常] 网关 $gw 可达"
        else
            echo "[警告] 网关 $gw 不可达"
        fi
    fi
    echo ""
}

# 交互式设置静态 IP
interactive_setup() {
    echo "=== 静态 IP 配置 ==="
    echo ""

    # 列出可用网卡
    echo "可用网卡:"
    ip -o link show | awk -F': ' '{print $2}' | grep -v "^lo" | while read -r iface; do
        local state
        state=$(ip link show "$iface" | grep -o "state [A-Z]*" || echo "DOWN")
        echo "  $iface ($state)"
    done
    echo ""

    read -p "选择网卡: " IFACE
    read -p "IP 地址 (如 10.121.177.157/23): " IP_ADDR
    read -p "网关 (如 10.121.176.1): " GATEWAY
    read -p "DNS (如 10.10.10.113,10.16.10.6): " DNS

    echo ""
    echo "确认配置:"
    echo "  网卡: $IFACE"
    echo "  IP:   $IP_ADDR"
    echo "  网关: $GATEWAY"
    echo "  DNS:  $DNS"
    read -p "确认执行？(y/N): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "已取消"
        exit 0
    fi

    set_static_ip
}

# 设置静态 IP（绕过 NM 直接配置）
set_static_ip() {
    echo "正在配置 $IFACE..."

    # 1. 先停用可能冲突的 NM 连接
    local nm_con
    nm_con=$(nmcli con show --active 2>/dev/null | grep -w "$IFACE" | awk '{print $1}' || true)
    if [[ -n "$nm_con" ]]; then
        echo "停用 NM 连接: $nm_con"
        nmcli con down "$nm_con" 2>/dev/null || true
    fi

    # 2. 刷新并设置静态 IP
    ip addr flush dev "$IFACE"
    ip addr add "$IP_ADDR" dev "$IFACE"

    # 3. 设置默认路由（先删旧的）
    ip route del default 2>/dev/null || true
    ip route add default via "$GATEWAY" dev "$IFACE"

    # 4. 设置 DNS
    if [[ -n "$DNS" ]]; then
        local dns_file="/etc/resolv.conf"
        echo "# Static DNS" > "$dns_file"
        IFS=',' read -ra dns_arr <<< "$DNS"
        for d in "${dns_arr[@]}"; do
            echo "nameserver $d" >> "$dns_file"
        done
    fi

    # 5. 写入持久化配置
    local nm_dir="/etc/NetworkManager/system-connections"
    if [[ -d "$nm_dir" ]]; then
        cat > "$nm_dir/${IFACE}-static.nmconnection" << NMEOF
[connection]
id=${IFACE}-static
type=ethernet
interface-name=${IFACE}

[ipv4]
method=manual
address1=${IP_ADDR},${GATEWAY}
dns=${DNS//,/;};

[ipv6]
method=auto
NMEOF
        chmod 600 "$nm_dir/${IFACE}-static.nmconnection"
        nmcli connection reload 2>/dev/null || true
    fi

    # 6. 写入 ifcfg 备用
    local ifcfg_dir="/etc/sysconfig/network-scripts"
    if [[ -d "$ifcfg_dir" ]]; then
        local ip_part="${IP_ADDR%/*}"
        local cidr="${IP_ADDR#*/}"
        local mask
        mask=$(python3 -c "print('.'.join([str((0xffffffff << (32 - int('$cidr'))) >> i & 0xff) for i in [24,16,8,0]]))" 2>/dev/null || echo "255.255.254.0")
        cat > "$ifcfg_dir/ifcfg-${IFACE}" << IFEOF
DEVICE=${IFACE}
BOOTPROTO=none
ONBOOT=yes
TYPE=Ethernet
IPADDR=${ip_part}
NETMASK=${mask}
GATEWAY=${GATEWAY}
DNS1=${DNS%%,*}
NM_CONTROLLED=no
IFEOF
    fi

    echo ""
    echo "配置完成！验证:"
    ip addr show "$IFACE" | grep inet
    ip route | grep default
}

# 修复 eno1/endvnic 冲突（华为鲲鹏平台）
fix_eno1() {
    echo "=== 修复 eno1/endvnic 冲突 ==="
    echo ""

    # 1. 检查当前状态
    local eno1_ip endvnic_ip
    eno1_ip=$(ip -o addr show dev eno1 2>/dev/null | grep "inet " | awk '{print $4}' || echo "")
    endvnic_ip=$(ip -o addr show dev endvnic 2>/dev/null | grep "inet " | awk '{print $4}' || echo "")

    echo "eno1 IP:    ${eno1_ip:-无}"
    echo "endvnic IP: ${endvnic_ip:-无}"
    echo ""

    if [[ "$eno1_ip" == "$endvnic_ip" && -n "$eno1_ip" ]]; then
        echo "[发现冲突] 两个网卡使用相同 IP: $eno1_ip"
        echo "正在修复..."
        echo ""

        # 停用 endvnic 的 NM 连接
        echo "[1] 停用 endvnic NM 连接"
        nmcli con down endvnic 2>/dev/null || true
        nmcli con modify endvnic connection.autoconnect no 2>/dev/null || true

        # 清除 endvnic IP
        echo "[2] 清除 endvnic IP"
        ip addr flush dev endvnic 2>/dev/null || true

        # 确保 eno1 持有 IP
        echo "[3] 确认 eno1 持有 IP"
        if [[ -z "$eno1_ip" ]]; then
            echo "[警告] eno1 没有 IP，需要手动设置"
            read -p "为 eno1 设置 IP (如 10.121.177.157/23): " IP_ADDR
            ip addr add "$IP_ADDR" dev eno1
            eno1_ip="$IP_ADDR"
        fi

        # 设置默认路由到 eno1
        echo "[4] 设置默认路由到 eno1"
        local gw
        gw=$(ip route | grep default | head -1 | awk '{print $3}')
        if [[ -n "$gw" ]]; then
            ip route del default 2>/dev/null || true
            ip route add default via "$gw" dev eno1
        fi

        echo ""
        echo "修复完成！验证:"
        ip addr show eno1 | grep inet
        ip addr show endvnic | grep inet || echo "  endvnic 无 IP (正确)"
    else
        echo "[正常] 未发现 IP 冲突"
    fi
}

# 恢复 DHCP
revert_dhcp() {
    if [[ -z "$IFACE" ]]; then
        echo "用法: $0 --revert <网卡名>"
        exit 1
    fi

    echo "恢复 $IFACE 为 DHCP..."
    ip addr flush dev "$IFACE"

    # 删除 NM 静态配置
    rm -f "/etc/NetworkManager/system-connections/${IFACE}-static.nmconnection"
    rm -f "/etc/sysconfig/network-scripts/ifcfg-${IFACE}"

    nmcli connection reload 2>/dev/null || true
    nmcli con up "$IFACE" 2>/dev/null || true
    dhclient "$IFACE" 2>/dev/null || true

    echo "完成！"
    ip addr show "$IFACE" | grep inet
}

#========================== 主流程 ==========================

case "$ACTION" in
    diagnose)    diagnose ;;
    interactive) interactive_setup ;;
    set)         set_static_ip ;;
    fix_eno1)    fix_eno1 ;;
    revert)      revert_dhcp ;;
esac
