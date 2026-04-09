# Plug-UnPlug 安全版操作手册

## 目的

这套脚本用于 Linux 下 NVMe 热插拔测试的半自动执行。脚本会自动排除系统盘，你只需要按提示人工拔盘和插盘。

## 文件

- `auto-plug-unplug-fio-safe.sh`
- `common.sh`
- `1-fenqu-safe.sh`
- `UUID-safe.sh`
- `2-check-start-safe.sh`
- `3-md5-safe.sh`
- `fio-safe.sh`
- `4-check-md5-safe.sh`
- `5-check-log-safe.sh`

## 使用前确认

- 使用 `root` 执行
- `fio`、`smartctl`、`ipmitool`、`findmnt`、`lsblk` 已安装
- `/etc/fstab` 中没有旧的待测盘挂载条目
- 除系统盘外，其余 NVMe 允许被分区和压测

## 系统盘排除

脚本会自动识别以下挂载点背后的底层磁盘：

- `/`
- `/boot`
- `/boot/efi`

识别出的底层盘会被排除，不参与：

- 分区
- UUID 绑定
- MD5 文件生成
- `fio`
- MD5 校验
- 收尾检查

## 执行命令

上传目录到 Linux 后执行：

```bash
cd /root/Notify-plug-unplug-Fio
chmod +x *.sh
bash auto-plug-unplug-fio-safe.sh
```

如果只想先试 1 轮：

```bash
CYCLES=1 bash auto-plug-unplug-fio-safe.sh
```

如果想自定义等待时间：

```bash
CYCLES=10 PULL_WAIT_SECONDS=30 INSERT_WAIT_SECONDS=6 bash auto-plug-unplug-fio-safe.sh
```

## 执行顺序

脚本会自动按以下顺序执行：

1. `1-fenqu-safe.sh`
2. `UUID-safe.sh`
3. `mount -a`
4. `2-check-start-safe.sh`
5. `3-md5-safe.sh`
6. `fio-safe.sh`
7. 循环执行热插拔
8. `5-check-log-safe.sh`

## 热插拔循环

每一轮循环中脚本会：

1. 提示你可以拔盘
2. 记录操作时间
3. 自动等待 `PULL_WAIT_SECONDS`
4. 提示你慢插回去
5. 自动等待 `INSERT_WAIT_SECONDS`
6. 自动执行 `4-check-md5-safe.sh`

默认循环 10 次。

## 日志目录

脚本会自动创建：

```bash
runs/时间戳目录
```

每轮日志包括：

- `01-fenqu.log`
- `02-uuid.log`
- `03-check-start.log`
- `04-md5-create.log`
- `05-fio-start.log`
- `06-check-md5-loopX.log`
- `07-check-log.log`
- `loop-record.txt`
- `round-meta.txt`

## 现场建议

- 先用 `CYCLES=1` 试通一轮
- 确认输出中的 `System disk excluded` 正确
- 确认 `Test disks` 里不包含系统盘
- 试通后再跑正式轮次
