# SIT 测试常用命令速查

> 记不住正常，收藏这份就够了。按场景分类，直接复制粘贴。

---

## 一、FRU 信息查询/修改

```bash
# 列出所有 FRU 设备
ipmitool fru list

# 查询指定 ID 的详细信息
ipmitool fru print <ID>
# 例：查看 M2 转接板
ipmitool fru print 26

# 按关键词筛选
ipmitool fru list | grep -i psu
ipmitool fru list | grep -i M2
ipmitool fru list | grep -i fan

# 批量打印所有 PSU
for id in 3 4 12 13 14 15 16 17; do
  echo "=== ID $id ==="
  ipmitool fru print $id
done

# 修改 FRU 字段（带安全确认）
# 格式: ipmitool fru edit <ID> field <区域> 0 "新值"
# 区域: c=Chassis, b=Board, p=Product, i=Internal
ipmitool fru edit 26 field b 0 "iSoftStone123"
```

## 二、IPMI / SEL 日志

```bash
# 查看系统事件日志
ipmitool sel list
ipmitool sel elist          # 带详细描述

# 只看 Critical 级别
ipmitool sel list | grep -i critical

# 按关键词过滤
ipmitool sel list | grep -i PCIe
ipmitool sel list | grep -i temp

# 查看 SEL 统计（多少条、剩余空间）
ipmitool sel info

# 清除 SEL（谨慎操作）
ipmitool sel clear

# 通过 BMC 远程执行（加 -H -U -P）
ipmitool -I lanplus -H 10.121.176.138 -U root -P Admin@9000 sel list

# 电源控制
ipmitool chassis power status
ipmitool chassis power on
ipmitool chassis power off
ipmitool chassis power cycle
```

## 三、PCIe 设备检查

```bash
# 列出所有 PCIe 设备
lspci

# 只列设备名（不带地址）
lspci | awk -F': ' '{print $2}'

# 查看指定设备的详细信息
lspci -s <BUS:DEV.FUNC> -vvv
# 例: lspci -s 01:00.0 -vvv

# 查看 PCIe 链路速度/宽度
lspci | grep -i switch
lspci | grep -i nvme

# 检查 AER 错误（PCIe 高级错误报告）
lspci -vvv | grep -i AER

# Python 自动清点
python3 check_pcie.py
```

## 四、网络配置

### 诊断
```bash
# 查看所有网卡和 IP
ip addr
ip -o addr show

# 查看路由
ip route
ip route | grep default

# 查看网卡连接状态
ethtool <网卡> | grep "Link detected"

# 25G 光口检查 FEC 模式
ethtool --show-fec eno5
```

### 配置
```bash
# 查看 NM 连接列表
nmcli con show
nmcli device status

# 设置静态 IP（临时，重启丢失）
ip addr flush dev eno1
ip addr add 10.121.177.157/23 dev eno1
ip route add default via 10.121.176.1 dev eno1

# NM 方式设置（持久化）
nmcli con modify <连接名> ipv4.method manual
nmcli con modify <连接名> ipv4.addresses 10.121.177.157/23
nmcli con modify <连接名> ipv4.gateway 10.121.176.1
nmcli con modify <连接名> ipv4.dns "10.10.10.113,10.16.10.6"
nmcli con up <连接名>

# 修复 endvnic 冲突
nmcli con down endvnic
nmcli con modify endvnic connection.autoconnect no

# 查看 DNS
cat /etc/resolv.conf
```

### FEC 修复（25G 光口）
```bash
ethtool --set-fec eno5 encoding rs
ethtool --set-fec eno5 encoding baser
ethtool --set-fec eno5 encoding off
```

## 五、存储 / NVMe

```bash
# 列出 NVMe 设备
lsblk
nvme list

# 查看 NVMe 详细信息
nvme id-ctrl /dev/nvme0
nvme id-ctrl /dev/nvme0 | grep -i model
nvme id-ctrl /dev/nvme0 | grep -i serial

# 查看 RAID 信息
MegaCli64 -LDInfo -Lall -aALL
MegaCli64 -PDList -aALL

# 查看 RAID 热备盘状态
MegaCli64 -PDList -aALL | grep -i spare

# 设置热备盘（Enclosure:Slot）
MegaCli64 -PDHSP -Set -PhysDrv [32:0] -a0

# 查看 Rebuild 进度
MegaCli64 -PDRbld -ShowProg -PhysDrv [32:0] -a0
```

## 六、FIO 性能测试

```bash
# 顺序读（带宽）
fio --name=seq-read --filename=/dev/nvme0n1 --direct=1 --bs=1M \
    --size=10G --numjobs=1 --iodepth=64 --rw=read --runtime=60 \
    --group_reporting --output=fio_seq_read.log

# 顺序写（带宽）
fio --name=seq-write --filename=/dev/nvme0n1 --direct=1 --bs=1M \
    --size=10G --numjobs=1 --iodepth=64 --rw=write --runtime=60 \
    --group_reporting --output=fio_seq_write.log

# 随机读（IOPS）
fio --name=rand-read --filename=/dev/nvme0n1 --direct=1 --bs=4k \
    --size=10G --numjobs=4 --iodepth=32 --rw=randread --runtime=60 \
    --group_reporting --output=fio_rand_read.log

# 随机写（IOPS）
fio --name=rand-write --filename=/dev/nvme0n1 --direct=1 --bs=4k \
    --size=10G --numjobs=4 --iodepth=32 --rw=randwrite --runtime=60 \
    --group_reporting --output=fio_rand_write.log

# 混合读写（70/30）
fio --name=mix --filename=/dev/nvme0n1 --direct=1 --bs=4k \
    --size=10G --numjobs=4 --iodepth=32 --rw=randrw --rwmixread=70 \
    --runtime=60 --group_reporting --output=fio_mix.log
```

## 七、Cycle 测试

```bash
# Reboot 循环（500圈）
# 通过 rc.local 实现
echo "for i in \$(seq 1 500); do reboot; done" >> /etc/rc.local

# AC Cycle（PDU 控制）
./ac-cycle-pdu.sh

# DC Cycle（BMC 控制）
ipmitool chassis power cycle
sleep 90
ipmitool chassis power on
```

## 八、系统诊断

```bash
# 查看内核错误日志
dmesg | grep -iE "error|fail|aer|fatal"
dmesg -T | grep -iE "error|fail" | tail -20

# 查看系统资源
free -h
df -h
top -bn1 | head -20

# 查看 CPU 信息
lscpu
cat /proc/cpuinfo | grep "model name" | head -1

# 查看温度传感器
ipmitool sdr list | grep -i temp
ipmitool sdr type temperature

# 查看风扇转速
ipmitool sdr list | grep -i fan

# 查看电源状态
ipmitool sdr list | grep -i "PSU\|Power"

# 查看系统启动时间
uptime
who -b
```

## 九、dmesg 常见告警含义

| 告警 | 含义 | 严重程度 |
|------|------|---------|
| `BAR 14 failed to assign` | PCIe 设备 BAR 空间分配失败 | 中（常见，不一定影响功能） |
| `VPD access failed` | VPD 信息读取失败 | 低（不影响运行） |
| `AER: PCIe Bus Error` | PCIe 高级错误报告 | 高（需要关注） |
| `nvme: controller reset` | NVMe 控制器复位 | 高 |
| `npu core error` | NPU 核心错误 | 致命 |
| `I/O error, dev sda` | 磁盘 I/O 错误 | 致命 |

## 十、常用快捷键/技巧

```bash
# 命令历史记录
history | grep ipmitool     # 查找历史执行过的命令
!<数字>                      # 执行 history 中对应编号的命令
Ctrl+R                       # 交互式搜索历史命令

# 后台运行测试
nohup ./test.sh > test.log 2>&1 &

# 实时查看日志
tail -f test.log
tail -f /var/log/messages | grep -i error
```

---

> **更新记录**
> - 2026-04-15: 初始版本，基于日常使用频率整理
