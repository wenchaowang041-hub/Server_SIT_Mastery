# Plug-UnPlug 安全版操作手册

## 适用场景

这套脚本用于 Linux 下 NVMe 暴力热插拔测试。

当前版本适合两种模式：

- 默认模式：`config.sh` 中 `DUTS=()`，表示除系统盘外的所有 NVMe 都作为 DUT
- 指定模式：在 `config.sh` 中手工填写指定 DUT

## 当前脚本目录

- `config.sh`
- `common.sh`
- `auto-plug-unplug-fio-safe.sh`
- `1-fenqu-safe.sh`
- `UUID-safe.sh`
- `2-check-start-safe.sh`
- `3-md5-safe.sh`
- `fio-safe.sh`
- `4-check-md5-safe.sh`
- `5-check-log-safe.sh`

## 当前机器说明

在你这台机器上，系统盘已经固定确认为：

```bash
/dev/nvme5n1
```

这块盘不会参与：

- 分区
- UUID 绑定
- MD5 文件生成
- `fio`
- 热插拔循环
- 结束检查

## 当前默认配置

`config.sh` 现在建议保持：

```bash
DUTS=()
```

这表示：

- 自动把除 `/dev/nvme5n1` 外的所有 NVMe 盘都作为 DUT

如果以后只想测指定盘，再改成：

```bash
DUTS=(
  "/dev/nvme2n1"
  "/dev/nvme3n1"
)
```

## 执行前检查

先确认：

- 你在 `root` 下执行
- `fio`、`smartctl`、`ipmitool`、`findmnt`、`lsblk` 已安装
- `/etc/fstab` 中没有旧的测试盘挂载条目
- 除系统盘外的 DUT 允许被重新分区和压测

## 执行前验证

先加载公共函数：

```bash
source /root/plug-unplug-safe/common.sh
```

确认系统盘：

```bash
get_system_disks
```

预期输出：

```bash
/dev/nvme5n1
```

确认 DUT：

```bash
list_dut_disks
```

如果 `DUTS=()`，预期是除 `nvme5n1` 外的所有 NVMe。

确认非 DUT 盘：

```bash
list_non_dut_nvmes
```

如果 `DUTS=()`，预期这里不输出内容。

建议现场完整验证顺序直接执行：

```bash
source /root/plug-unplug-safe/common.sh
get_system_disks
list_dut_disks
list_non_dut_nvmes
```

判断标准：

- `get_system_disks` 必须输出 `/dev/nvme5n1`
- `list_dut_disks` 必须不包含 `/dev/nvme5n1`
- 当 `DUTS=()` 时，`list_non_dut_nvmes` 应为空

## 执行命令

先试跑 1 轮：

```bash
cd /root/plug-unplug-safe
chmod +x *.sh
CYCLES=1 bash auto-plug-unplug-fio-safe.sh
```

正式跑多轮时，例如 10 轮：

```bash
CYCLES=10 bash auto-plug-unplug-fio-safe.sh
```

如果要自定义等待时间：

```bash
CYCLES=10 PULL_WAIT_SECONDS=30 INSERT_WAIT_SECONDS=6 bash auto-plug-unplug-fio-safe.sh
```

## 脚本自动执行顺序

脚本会自动按以下顺序执行：

1. `1-fenqu-safe.sh`
2. `UUID-safe.sh`
3. `mount -a`
4. `2-check-start-safe.sh`
5. `3-md5-safe.sh`
6. `fio-safe.sh`
7. 循环执行热插拔
8. `5-check-log-safe.sh`

## 你现场只需要做的动作

脚本跑到热插拔阶段后，你只需要：

1. 按提示拔出当前盘
2. 等脚本倒计时结束
3. 按提示慢插回去
4. 等脚本倒计时结束
5. 脚本会自动做 `MD5` 校验

## 热插拔循环说明

### 当 `DUTS=()` 时

脚本会按所有非系统盘顺序逐块提示你拔插。

例如你当前机器会按类似下面顺序进行：

- `nvme0n1`
- `nvme10n1`
- `nvme11n1`
- `nvme1n1`
- `nvme2n1`
- `nvme3n1`
- `nvme4n1`
- `nvme6n1`
- `nvme7n1`
- `nvme8n1`
- `nvme9n1`

如果 `CYCLES=1`，就按上面每块盘各做 1 次。

如果 `CYCLES=10`，就整套顺序做 10 轮。

### 当 `DUTS` 指定盘时

脚本只会按指定盘顺序提示你拔插。

## 关键日志

每次运行会创建：

```bash
runs/时间戳目录
```

重要日志文件包括：

- `01-fenqu.log`
- `02-uuid.log`
- `03-check-start.log`
- `04-md5-create.log`
- `05-fio-start.log`
- `06-check-md5-loopX-盘名.log`
- `07-check-log.log`
- `loop-record.txt`
- `round-meta.txt`

## round-meta.txt 内容

会记录：

- 本轮目录
- 循环次数
- 拔盘等待时间
- 回插等待时间
- 系统盘
- DUT 列表
- 其他盘列表

## 如何判断当前流程是否正常

### 到“提示拔盘”为止算正常的现象

- `Step 1` 完成所有 DUT 分区
- 系统盘没有被分区
- `Step 2` 执行完成且 `mount -a` 没报致命错误
- `Step 3` 能输出 `fdisk` 和 `smart` 信息
- `Step 4` 没有 `mount/cp/md5sum` 报错
- `Step 5` 没有 `fio` 启动失败报错
- 脚本成功进入 “Now you may PULL OUT ...”

### 需要立即停下的情况

- 出现系统盘 `/dev/nvme5n1` 被分区或被加入 DUT
- `mount -a` 大量报错
- `fio` 报找不到设备或权限错误
- `4-check-md5-safe.sh` 连续校验失败

## 当前推荐操作

今天现场推荐先这样执行：

```bash
cd /root/plug-unplug-safe
source /root/plug-unplug-safe/common.sh
get_system_disks
list_dut_disks
CYCLES=1 bash auto-plug-unplug-fio-safe.sh
```

确认整轮跑通后，再决定是否上 `CYCLES=10`。

## 中止测试后的恢复流程

如果现场因为无法确认物理盘位、定位灯不可用或其他原因不能继续做热插拔，建议按下面步骤恢复环境。

### 1. 中止总控脚本

如果脚本正停在等待你拔盘或插盘的位置，直接按：

```bash
Ctrl+C
```

### 2. 停止 `fio`

```bash
pkill fio
ps -ef | grep fio
```

如果还有残留进程，可执行：

```bash
pkill -9 fio
```

### 3. 卸载测试挂载点

```bash
umount /mnt/nvme_hotplug/* 2>/dev/null
umount /mnt/nvme* 2>/dev/null
```

### 4. 清理 `/etc/fstab` 中的测试挂载项

先备份：

```bash
cp /etc/fstab /etc/fstab.bak.$(date +%F_%H%M%S)
```

再批量删除测试挂载项：

```bash
grep -vE '/mnt/nvme_hotplug/|/mnt/nvme[0-9]+n1p1' /etc/fstab > /etc/fstab.clean
cp /etc/fstab.clean /etc/fstab
rm -f /etc/fstab.clean
```

验证：

```bash
mount -a
grep nvme /etc/fstab
```

预期：

- `mount -a` 不报错
- `grep nvme /etc/fstab` 无测试挂载项输出

### 5. 记录本轮中止原因

进入本轮日志目录，例如：

```bash
cd /root/plug-unplug-safe/runs/2026-04-10_100635
```

写入中止说明：

```bash
echo "[STOP] Unable to identify physical DUT because local locate LED is unavailable. Test stopped after preparation steps." >> loop-record.txt
```

### 6. 如需彻底恢复，清除非系统盘测试分区

先确认系统盘为：

```bash
/dev/nvme5n1
```

然后清除除系统盘外所有 NVMe 的测试分区：

```bash
for d in /dev/nvme*n1; do
  [ "$d" = "/dev/nvme5n1" ] && continue
  wipefs -a "$d"
  parted -s "$d" mklabel gpt
done
partprobe
lsblk
```

执行后预期：

- `nvme5n1` 保留系统分区
- 其他 NVMe 盘仅显示为裸盘，不再有 `p1/p2`

### 7. 恢复完成的判定标准

满足以下条件即可视为恢复完成：

- `fio` 已停止
- `/etc/fstab` 无测试挂载项
- 测试挂载点已卸载
- 系统盘 `nvme5n1` 正常
- 其他非系统盘已清除测试分区，或至少不再被挂载

### 8. 下次重新开始

环境恢复后，下次可以直接重新从头执行：

```bash
cd /root/plug-unplug-safe
CYCLES=1 bash auto-plug-unplug-fio-safe.sh
```
