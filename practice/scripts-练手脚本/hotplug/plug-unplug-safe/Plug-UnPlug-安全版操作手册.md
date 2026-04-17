# 批量热插拔测试（plug-unplug-safe）操作手册

## 一、概述

### 1.1 用途

Linux 下 NVMe SSD 批量热插拔压力测试脚本，用于验证：
- 热插拔过程中的数据完整性（MD5 校验）
- 反复拔插后的 PCIe 链路稳定性（AER 错误检测）
- 带 FIO 压力测试时的热插拔可靠性

### 1.2 核心流程

```
分区 -> UUID绑定 -> 预采集日志 -> 创建MD5源文件
-> 循环N轮：
     FIO压测 -> 提示拔所有盘 -> 倒计时 -> 提示插回 -> 检测识别 -> MD5校验 -> 清理FIO
-> 最终日志采集（dmesg/SEL/SMART/topology）
```

### 1.3 工作模式

| 模式 | 说明 | 配置 |
|------|------|------|
| 自动模式（推荐） | 自动识别除系统盘外所有 NVMe 盘 | `config.sh` 中 `DUTS=()` |
| 指定模式 | 只测试指定的磁盘 | `config.sh` 中填写具体盘符 |

## 二、前置条件

### 2.1 硬件要求

- NVMe SSD（支持热插拔的平台）
- 确认系统盘（不会被测试影响）
- 足够的物理空间操作硬盘

### 2.2 软件依赖

```bash
# 需要安装的工具
yum install -y fio smartmontools ipmitool util-linux parted e2fsprogs
```

确认命令可用：
```bash
which fio smartctl ipmitool lsblk lsscsi nvme findmnt sgdisk wipefs
```

### 2.3 系统盘确认

**当前机器系统盘**：`/dev/nvme5n1`

如需移植到其他机器，修改 `common.sh` 中的 `get_system_disks()` 函数：
```bash
get_system_disks() {
    echo /dev/nvmeXn1  # 改为实际的系统盘
}
```

### 2.4 执行前检查

```bash
# 1. 确认在 root 下执行
whoami

# 2. 确认 /etc/fstab 无旧测试条目
grep nvme /etc/fstab

# 3. 确认 DUT 允许被重新分区和压测

# 4. 加载公共函数验证环境
cd /root/plug-unplug-safe
source common.sh
get_system_disks        # 应输出系统盘
list_dut_disks          # 应输出所有 DUT 盘
```

## 三、文件说明

### 3.1 核心文件

| 文件 | 说明 |
|------|------|
| `config.sh` | 配置文件（系统盘/DUT列表） |
| `common.sh` | 公共函数库（磁盘识别/wait_for_disk） |
| `auto-plug-unplug-fio-safe.sh` | 主控制脚本 |

### 3.2 子脚本

| 文件 | 说明 |
|------|------|
| `1-fenqu-safe.sh` | 磁盘分区（p1: 10G ext4, p2: 剩余空间） |
| `UUID-safe.sh` | UUID 绑定到 fstab |
| `2-check-start-safe.sh` | 测试前日志采集（dmesg/SEL/topology） |
| `3-md5-safe.sh` | 创建 MD5 源文件并拷贝到 p1 分区 |
| `fio-safe.sh` | FIO 压力测试配置 |
| `4-check-md5-safe.sh` | MD5 校验 |
| `5-check-log-safe.sh` | 最终日志采集（dmesg/SEL/SMART/topology） |
| `9-cleanup-safe.sh` | 清理测试环境 |

### 3.3 运行时文件

| 文件 | 说明 |
|------|------|
| `round-meta.txt` | 本轮元信息（循环数/等待时间/系统盘/DUT列表） |
| `loop-record.txt` | 手动操作记录（拔插时间戳） |

## 四、使用指南

### 4.1 快速开始

```bash
cd /root/plug-unplug-safe
chmod +x *.sh

# 试跑 1 轮验证
CYCLES=1 bash auto-plug-unplug-fio-safe.sh

# 正式跑 10 轮
CYCLES=10 bash auto-plug-unplug-fio-safe.sh
```

### 4.2 自定义参数

```bash
# 跑 10 轮，拔盘等待 30s
CYCLES=10 PULL_WAIT_SECONDS=30 bash auto-plug-unplug-fio-safe.sh
```

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `CYCLES` | 10 | 循环次数 |
| `PULL_WAIT_SECONDS` | 10 | 拔盘后等待时间 |
| `INSERT_WAIT_SECONDS` | 30 | 插回后等待时间 |
| `FIO_RUNTIME` | 自动计算 | FIO 运行时长（一般不需手动设） |

### 4.3 输出目录

每次运行创建独立目录：`runs/时间戳/`

关键日志文件：
```
runs/2026-04-17_103742/
├── round-meta.txt          # 本轮元信息
├── loop-record.txt         # 手动操作记录
├── 01-fenqu.log            # 分区日志
├── 02-uuid.log             # UUID绑定日志
├── 03-check-start.log      # 预采集日志
├── 04-md5-create.log       # MD5源文件创建日志
├── 05-fio-loop1.log        # FIO日志（每轮一个）
├── 06-check-md5-loop1.log  # MD5校验日志（每轮一个）
├── 07-check-log.log        # 最终日志
├── dmesg-before.log        # 测试前dmesg
├── dmesg-after.log         # 测试后dmesg
├── sel-before.log          # 测试前SEL
├── sel-after.log           # 测试后SEL
├── topology-before.log     # 测试前拓扑
├── topology-after.log      # 测试后拓扑
├── smart-begin-*.log       # SMART健康日志
└── smart-finish-*.log      # SMART健康日志
```

## 五、操作流程

### 5.1 准备阶段（全自动）

脚本自动执行：
1. **分区**：所有 DUT 盘创建 p1(10G ext4) + p2(剩余)
2. **UUID 绑定**：p1 分区挂载到 `/mnt/nvmeXn1p1`
3. **预采集日志**：dmesg/SEL/拓扑信息
4. **创建 MD5 源文件**：生成 1GB 随机文件，记录 MD5

### 5.2 热插拔循环（人工参与）

每轮循环流程：

```
===== Hotplug loop 1/10 =====
[FIO] 启动压力测试，预计运行 420s
Now you may PULL OUT all DUT disks: /dev/nvme0n1 /dev/nvme1n1 ...
Press Enter to continue...  <- 拔完所有盘后按 Enter
Pull wait: 10s              <- 倒计时等待
Now you may INSERT all DUT disks slowly.
Press Enter to continue...  <- 插回所有盘后按 Enter
[检测] 等待所有盘被系统识别...
[OK] /dev/nvme0n1 已识别，耗时 2s
...
Step 6: md5 check (loop 1)  <- 自动 MD5 校验
[FIO] 清理本轮 FIO 进程...
```

**你需要做的**：
1. 看到 "PULL OUT" 提示后，拔出所有 DUT 盘
2. 按 Enter 确认
3. 等待倒计时结束
4. 看到 "INSERT" 提示后，插回所有 DUT 盘
5. 按 Enter 确认
6. 脚本自动检测识别 + MD5 校验

### 5.3 结束阶段（全自动）

- 采集最终 dmesg/SEL/SMART/topology
- 生成对比报告

## 六、结果判定

### 6.1 正常现象

- 所有步骤无报错退出
- MD5 校验全部通过
- dmesg 无 AER 错误（或仅有短暂的 Uncorrected Non-Fatal）
- SEL 无新增 Drive Fault 事件

### 6.2 需要关注的情况

- **MD5 校验失败**：数据损坏，需排查
- **盘未识别**：`wait_for_disk` 超时，可能是硬件或链路问题
- **dmesg 大量 AER 错误**：PCIe 链路不稳定
- **SEL Drive Fault**：背板/控制器检测到异常

### 6.3 需要立即停下的情况

- 系统盘被误分区
- `mount -a` 大量报错
- `fio` 报找不到设备或权限错误
- MD5 连续校验失败

## 七、异常恢复

### 7.1 中止测试

```bash
# Ctrl+C 中止脚本
# 清理残留 FIO 进程
pkill -9 fio
```

### 7.2 清理环境

```bash
cd /root/plug-unplug-safe
bash 9-cleanup-safe.sh
```

或手动清理：
```bash
# 1. 卸载挂载点
umount /mnt/nvme* 2>/dev/null

# 2. 清理 fstab
cp /etc/fstab /etc/fstab.bak.$(date +%F)
sed -i '/nvme.*nvme/d' /etc/fstab
sed -i '/nvme.*UUID/d' /etc/fstab

# 3. 清除分区表（排除系统盘）
for d in /dev/nvme*n1; do
  [ "$d" = "/dev/nvme5n1" ] && continue
  sgdisk --zap-all "$d" 2>/dev/null || true
  wipefs -a "$d" 2>/dev/null || true
done

# 4. 确认
lsblk
```

## 八、移植到新机器

### 8.1 步骤

1. 确认系统盘：`lsblk` 或 `findmnt /` 查看
2. 修改 `common.sh` 中的 `get_system_disks()` 函数
3. （可选）修改 `config.sh` 中的 `DUTS=()` 为自动模式或指定模式
4. 确认所有子脚本中的 `SYSTEM_DISK` 变量一致
5. 安装依赖工具
6. `CYCLES=1` 试跑验证

### 8.2 示例：新机器系统盘为 nvme0n1

```bash
# common.sh
get_system_disks() {
    echo /dev/nvme0n1
}
```

所有子脚本中的 `SYSTEM_DISK` 同步改为 `"/dev/nvme0n1"`。

## 九、注意事项

- 测试前确认 `/etc/fstab` 无旧测试条目
- FIO 会在 p2 分区上运行，确保 p2 有足够空间
- 根分区需有足够空间存放日志（建议 > 5GB）
- 测试过程中不要手动挂载/卸载测试盘
- 如果测试中途中止，必须执行清理流程后再重新跑
