#!/bin/bash
#===============================================================================
# 网卡 DHCP 启用脚本
# 功能：将指定网卡的 ifcfg 配置改为 DHCP + ONBOOT=yes，重启网络获取 IP
#
# 用法：
#   ./dhcp-enable.sh eno1            # 启用 eno1 的 DHCP
#   ./dhcp-enable.sh eno5 myusb      # 把 eno5 改名 myusb 并启用 DHCP
#===============================================================================

set -euo pipefail

IFCFG_DIR="/etc/sysconfig/network-scripts"

usage() {
    cat << 'EOF'
用法: dhcp-enable.sh <旧网卡名> [新网卡名]

示例:
  dhcp-enable.sh eno1               # 启用 eno1 DHCP, 保持原名
  dhcp-enable.sh eno5 usb0          # 把 eno5 改为 usb0 并启用 DHCP
EOF
    exit 0
}

if [[ $# -lt 1 ]]; then
    usage
fi

OLD_IFACE="$1"
NEW_IFACE="${2:-$OLD_IFACE}"
IFCFG_FILE="$IFCFG_DIR/ifcfg-${OLD_IFACE}"

#========================== 主流程 ==========================

echo "=== 网卡 DHCP 启用 ==="
echo "旧网卡: $OLD_IFACE"
echo "新网卡: $NEW_IFACE"
echo ""

# 1. 检查原配置文件是否存在
if [[ ! -f "$IFCFG_FILE" ]]; then
    echo "[错误] 配置文件不存在: $IFCFG_FILE"
    echo ""
    echo "可用的 ifcfg 文件:"
    ls "$IFCFG_DIR"/ifcfg-* 2>/dev/null || echo "  无"
    exit 1
fi

echo "当前配置:"
cat "$IFCFG_FILE"
echo ""

# 2. 如果改了网卡名，需要重命名配置文件
if [[ "$OLD_IFACE" != "$NEW_IFACE" ]]; then
    echo "[1] 重命名配置文件: ifcfg-${OLD_IFACE} -> ifcfg-${NEW_IFACE}"
    mv "$IFCFG_FILE" "$IFCFG_DIR/ifcfg-${NEW_IFACE}"
    IFCFG_FILE="$IFCFG_DIR/ifcfg-${NEW_IFACE}"
fi

# 3. 修改关键参数
echo "[2] 修改配置:"
sed -i 's/^BOOTPROTO=.*/BOOTPROTO=dhcp/' "$IFCFG_FILE"
sed -i 's/^ONBOOT=.*/ONBOOT=yes/' "$IFCFG_FILE"
sed -i "s/^DEVICE=.*/DEVICE=${NEW_IFACE}/" "$IFCFG_FILE"
sed -i "s/^NAME=.*/NAME=${NEW_IFACE}/" "$IFCFG_FILE"

# 清理可能残留的静态 IP 配置
sed -i '/^IPADDR=/d' "$IFCFG_FILE"
sed -i '/^NETMASK=/d' "$IFCFG_FILE"
sed -i '/^GATEWAY=/d' "$IFCFG_FILE"

echo "修改后配置:"
cat "$IFCFG_FILE"
echo ""

# 4. 应用配置
echo "[3] 应用配置..."

# 先停掉旧的 NM 连接
nmcli con down "$OLD_IFACE" 2>/dev/null || true
nmcli con down "$NEW_IFACE" 2>/dev/null || true

# 重新加载
nmcli connection reload

# 启动
nmcli con up "$NEW_IFACE"

echo ""
echo "[4] 等待 DHCP..."
sleep 5

# 5. 验证
echo "=== 验证结果 ==="
ip addr show "$NEW_IFACE" 2>/dev/null | grep "inet " || echo "[警告] $NEW_IFACE 未获取到 IP"
ip route | grep default
echo ""
echo "完成！"
