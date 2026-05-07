# 通知式热插拔测试（Notify-plug-unplug-Fio）操作手册

## 一、概述

### 1.1 用途

Linux 下 NVMe SSD 通知式热插拔压力测试脚本。与批量热插拔不同，本脚本通过 **PCI 插槽电源控制**实现软件断电，配合物理拔插完成热插拔测试。

### 1.2 与批量热插拔的区别

| 对比项 | 批量热插拔（plug-unplug-safe） | 通知式热插拔（Notify） |
|--------|-------------------------------|------------------------|
| 拔盘方式 | 纯物理拔盘，脚本等待 | 软件断电 + 提示物理拔盘 |
| 断电机制 | 无，完全靠人工 | `/sys/bus/pci/slots/X/power` 下电 |
| 指示灯 | 无关联 | 断电后绿灯熄灭，可确认断电成功 |
| 槽位识别 | 无要求 | 需提前识别磁盘与 PCI Slot 映射关系 |
| 适用平台 | 任何支持 NVMe 热插拔的平台 | 需支持 ACPI PCI Hotplug Slots |

### 1.3 核心流程

```
分区 -> UUID绑定 -> 预采集日志 -> 创建MD5源文件
-> 循环N轮：
     FIO压测 -> 软件断电所有PCI插槽 -> 提示拔盘 -> 倒计时
     -> 提示插回 -> 等待绿灯亮起 -> 按Enter -> 检测识别 -> MD5校验 -> 清理FIO
-> 最终日志采集（dmesg/SEL/SMART/topology）
```

### 1.4 系统盘排除

脚本自动排除系统盘（默认 `/dev/nvme5n1`），不参与分区、MD5、FIO、热插拔。

## 二、前置条件

### 2.1 硬件要求

- 支持 ACPI PCI Hotplug Slots 的平台
- NVMe SSD 位于可热插拔的 PCIe 插槽上
- 系统盘不在被测插槽中

### 2.2 软件依赖

```bash
yum install -y fio smartmontools ipmitool util-linux parted e2fsprogs nvme-cli
```

### 2.3 关键：PCI Hotplug Slots 支持

确认系统存在 `/sys/bus/pci/slots/` 目录且有有效的 address 文件：

```bash
# 检查插槽列表
ls /sys/bus/pci/slots/

# 检查每个插槽的 address 和 power
for s in /sys/bus/pci/slots/*/; do
    echo "Slot: $(basename $s) | Address: $(cat ${s}address) | Power: $(cat ${s}power)"
done
```

如果 `/sys/bus/pci/slots/` 为空或没有 address 文件，**不能使用本脚本**，改用批量热插拔脚本。

### 2.4 Slot 映射调试

首次在新机器上运行，建议先运行调试脚本验证映射：

```bash
bash debug-slot-mapping.sh
```

确认所有磁盘都能正确匹配到 PCI 插槽。如果某个磁盘未找到对应插槽，检查输出中的 resolved 路径是否正确。

## 三、文件说明

### 3.1 核心文件

| 文件 | 说明 |
|------|------|
| `Notify-plug-unplug-Fio.sh` | 主控制脚本（分区/UUID/循环/日志） |
| `debug-slot-mapping.sh` | 调试工具（仅首次使用需要） |

### 3.2 子脚本

| 文件 | 说明 |
|------|------|
| `1-fenqu.sh` | 磁盘分区（p1: 10G ext4, p2: 剩余空间） |
| `UUID.sh` | UUID 绑定到 fstab |
| `2-check-start.sh` | 测试前日志采集（dmesg/SEL/topology） |
| `3-md5.sh` | 创建 MD5 源文件（直接写入挂载点） |
| `fio.sh` | FIO 压力测试配置 |
| `4-check-md5.sh` | MD5 校验 |
| `5-check-log.sh` | 最终日志采集 |

### 3.3 运行时文件

| 文件 | 说明 |
|------|------|
| `round-meta.txt` | 本轮元信息 |
| `loop-record.txt` | 手动操作时间戳记录 |

## 四、使用指南

### 4.1 快速开始

```bash
cd /root/Notify-plug-unplug-Fio
chmod +x *.sh

# 首次使用：先运行调试脚本验证映射
bash debug-slot-mapping.sh

# 试跑 1 轮
CYCLES=1 bash Notify-plug-unplug-Fio.sh

# 正式跑 10 轮
CYCLES=10 bash Notify-plug-unplug-Fio.sh
```

### 4.2 自定义参数

```bash
# 跑 5 轮，拔盘等待 20s
CYCLES=5 PULL_WAIT_SECONDS=20 bash Notify-plug-unplug-Fio.sh
```

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `CYCLES` | 10 | 循环次数 |
| `PULL_WAIT_SECONDS` | 30 | 断电后等待时间 |
| `DISK_DETECT_TIMEOUT` | 30 | 磁盘识别超时时间 |

### 4.3 输出目录

每次运行创建：`runs/时间戳/`

日志文件结构与批量热插拔脚本相同。

## 五、操作流程

### 5.1 准备阶段（全自动）

脚本自动执行：
1. **分区**：所有 DUT 盘创建 p1(10G ext4) + p2(剩余)
2. **UUID 绑定**：p1 分区挂载到 `/mnt/nvmeXn1p1`
3. **预采集日志**：dmesg/SEL/拓扑信息
4. **创建 MD5 源文件**：生成 1GB 随机文件直接写入挂载点，记录 MD5

### 5.2 热插拔循环（人工参与）

每轮循环流程示例：

```
===== 热插拔循环 1/10 =====
[FIO] 启动压力测试，预计运行 420s

[断电] 批量关闭 PCI 插槽电源...
  关闭插槽 0-2
  关闭插槽 0-14
  关闭插槽 0-8
  ...

============================================
  所有硬盘已断电（绿色指示灯应已熄灭）
  请拔出所有 DUT 硬盘
  等待 30s 后提示插回
============================================
  等待: 30s ... (倒计时)
  等待: 完成

============================================
  请将所有 DUT 硬盘插回对应插槽
  等待硬盘绿色指示灯全部亮起后
  按 Enter 键继续
============================================
[按 Enter]

[检测] 等待所有盘被系统识别...
[OK] /dev/nvme0n1 已识别，耗时 2s
[OK] /dev/nvme10n1 已识别，耗时 3s
...
Step 6: md5 check (loop 1)
[FIO] 清理本轮 FIO 进程...
```

**你需要做的**：
1. 断电后，等待绿色指示灯熄灭，拔出所有 DUT 盘
2. 等待倒计时结束
3. 看到插回提示后，插入所有 DUT 盘
4. **等待绿色指示灯全部亮起**
5. 按 Enter 键继续
6. 脚本自动检测识别 + MD5 校验

### 5.3 结束阶段（全自动）

- 采集最终 dmesg/SEL/SMART/topology
- 生成对比报告

## 六、Slot 映射原理

### 6.1 映射关系

脚本自动从 sysfs 推导磁盘 -> PCI Slot 映射：

```
/dev/nvme0n1
  -> /sys/block/nvme0n1/device (symlink)
  -> readlink -f 解析完整路径
  -> /sys/.../pci0000:06/0000:06:04.0/0000:09:00.0/nvme/nvme0
  -> 取 /nvme/ 之前的最后一个 BDF: 0000:09:00.0
  -> 去掉 .0: 0000:09:00
  -> 与 /sys/bus/pci/slots/*/address 比对
  -> 匹配成功: slot 0-2
```

### 6.2 已知映射（当前机器）

| 磁盘 | PCI Device | Slot |
|------|-----------|------|
| nvme0 | 0000:09:00 | 0-2 |
| nvme1 | 0000:e5:00 | 0-13 |
| nvme2 | 0000:0a:00 | 0-3 |
| nvme3 | 0000:e4:00 | 0-12 |
| nvme4 | 0000:c8:00 | 0-6 |
| nvme6 | 0000:07:00 | 0 |
| nvme7 | 0000:e7:00 | 0-15 |
| nvme8 | 0000:cb:00 | 0-9 |
| nvme9 | 0000:08:00 | 0-1 |
| nvme10 | 0000:e6:00 | 0-14 |
| nvme11 | 0000:ca:00 | 0-8 |

**注意**：不同机器的 BDF 分配可能不同，必须在新机器上重新验证。

### 6.3 手动验证 Slot 断电

```bash
# 验证单个插槽断电（以 nvme0 -> slot 0-2 为例）
nvme list                              # 确认 nvme0 存在
echo 0 > /sys/bus/pci/slots/0-2/power  # 下电
nvme list                              # 确认 nvme0 消失
echo 1 > /sys/bus/pci/slots/0-2/power  # 上电
nvme list                              # 确认 nvme0 恢复
```

## 七、结果判定

### 7.1 正常现象

- 所有步骤无报错退出
- MD5 校验全部通过
- dmesg 无持续 AER 错误（短暂的 Uncorrected Non-Fatal 在热插拔中属正常）
- 所有磁盘断电后消失，上电后恢复

### 7.2 需要关注的情况

- **部分盘断电后仍存在**：PCIe 链路可能不支持热断电
- **盘断电后无法恢复**：可能是硬件保护机制，需 AC 重启恢复
- **MD5 校验失败**：数据损坏
- **dmesg device recovery failed 反复出现**：链路不稳定

### 7.3 需要立即停下的情况

- 所有磁盘映射匹配失败（脚本启动时全报警告）
- 系统盘被误操作
- `mount -a` 大量报错
- MD5 连续校验失败

## 八、异常恢复

### 8.1 中止测试

```bash
# Ctrl+C 中止脚本
pkill -9 fio
```

### 8.2 恢复所有 PCI 插槽电源

```bash
# 确保所有插槽恢复供电
for s in /sys/bus/pci/slots/*/; do
    echo 1 > "${s}power" 2>/dev/null || true
done
```

### 8.3 清理环境

```bash
# 卸载挂载点
umount /mnt/nvme* 2>/dev/null

# 清理 fstab
cp /etc/fstab /etc/fstab.bak.$(date +%F)
sed -i '/nvme.*nvme/d' /etc/fstab
sed -i '/nvme.*UUID/d' /etc/fstab

# 清除分区表
for d in /dev/nvme*n1; do
  [ "$d" = "/dev/nvme5n1" ] && continue
  sgdisk --zap-all "$d" 2>/dev/null || true
  wipefs -a "$d" 2>/dev/null || true
done

lsblk
```

## 九、移植到新机器

### 9.1 步骤

1. **确认 PCI Hotplug Slots 支持**：`ls /sys/bus/pci/slots/` 不为空
2. **确认系统盘**：`lsblk` 查看
3. **修改系统盘变量**：主脚本中 `SYSTEM_DISK="/dev/nvme5n1"` 改为实际值
4. **运行调试脚本**：`bash debug-slot-mapping.sh` 验证所有磁盘映射
5. **手动验证单个插槽断电/恢复**
6. **`CYCLES=1` 试跑验证**

### 9.2 子脚本同步修改

所有子脚本中的 `SYSTEM_DISK` 变量需与主脚本保持一致：
- `3-md5.sh`
- `4-check-md5.sh`

## 十、注意事项

- **首次使用必须运行 `debug-slot-mapping.sh` 验证映射**
- **断电后必须确认绿色指示灯熄灭再拔盘**
- **插回后必须等待绿色指示灯全部亮起再按 Enter**
- 测试前确认 `/etc/fstab` 无旧测试条目
- 根分区需有足够空间（建议 > 5GB）
- 不同机器的 BDF 分配不同，映射关系不可直接复制
- 如果 `/sys/bus/pci/slots/` 不可用，改用批量热插拔脚本
