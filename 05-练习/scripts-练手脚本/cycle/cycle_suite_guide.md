# Cycle Manager 使用手册

适用脚本：

- `practice/scripts-练手脚本/cycle_manager.py`

配套模块目录：

- `practice/scripts-练手脚本/cycle_suite/`

## 1. 脚本用途

`cycle_manager.py` 用于统一管理服务器循环类测试，支持以下三种模式：

- `reboot`
- `dc`
- `ac`

适合用于：

- 重启循环测试
- DC 掉电循环测试
- AC 上下电循环测试
- 每轮前后信息快照采集与差异对比

## 2. 解决了什么问题

相比原先分散的 `reboot.py`、`main.py`、`main-1.py` 等脚本，这套新结构解决了以下问题：

- 统一入口，不再分散执行
- 统一参数模型，现场更容易操作
- 统一日志目录，不再散落在多个脚本里
- 统一快照采集与轮次计数
- 统一支持 `AC / DC / reboot`

## 3. 日志与目录结构

脚本默认日志目录：

```bash
/root/cycle_logs
```

主要子目录：

- `snapshots/`：每轮系统快照
- `compare/`：前后轮次差异对比结果
- `counts/`：各模式执行计数

主日志文件：

- `cycle_manager.log`

## 4. 支持的模式

### 4.1 reboot 模式

用于操作系统内直接执行重启命令。

典型命令：

```bash
python3 cycle_manager.py --mode reboot
```

默认执行命令：

```bash
reboot
```

如需自定义：

```bash
python3 cycle_manager.py --mode reboot --reboot-cmd "systemctl reboot"
```

### 4.2 dc 模式

用于执行 DC power cycle。

典型命令：

```bash
python3 cycle_manager.py --mode dc
```

默认执行命令：

```bash
ipmitool power cycle
```

如需自定义：

```bash
python3 cycle_manager.py --mode dc --dc-cmd "ipmitool chassis power cycle"
```

### 4.3 ac 模式

用于执行 AC 下电再上电。

该模式必须同时提供：

- `--ac-off-cmd`
- `--ac-on-cmd`

示例：

```bash
python3 cycle_manager.py --mode ac --ac-off-cmd "ipmitool power off" --ac-on-cmd "ipmitool power on"
```

如果现场是通过 PDU 控制 AC，上述命令可以替换成实际 PDU 工具命令。

## 5. health-only 模式

如果只想采集当前系统快照，不执行任何重启/掉电动作，可以使用：

```bash
python3 cycle_manager.py --mode dc --health-only
```

说明：

- `mode` 仍然需要指定
- 此时只会采集快照并记录计数
- 不会执行 `reboot`、`power cycle` 或 `power off/on`

## 6. 执行前等待时间

默认在执行动作前会等待 `10` 秒。

可以通过以下参数调整：

```bash
--wait-before-action 10
```

例如：

```bash
python3 cycle_manager.py --mode dc --wait-before-action 30
```

## 7. AC 模式专用等待时间

AC 模式下，默认执行完 `off` 命令后等待 `15` 秒再执行 `on`。

可通过参数调整：

```bash
--ac-off-wait 15
```

例如：

```bash
python3 cycle_manager.py --mode ac \
  --ac-off-cmd "ipmitool power off" \
  --ac-on-cmd "ipmitool power on" \
  --ac-off-wait 30
```

## 8. 每轮会采集什么信息

默认采集：

- `lscpu`
- `free -h`
- `lsblk`
- `findmnt`
- `ip link`
- `lspci -nn`
- `dmesg -T --level=warn,err,crit,alert,emerg`

如果环境存在相关命令，还会附加采集：

- `nvme list`
- `ipmitool sensor list`
- `ipmitool sel elist`
- `ipmitool fru`
- `dmidecode -t memory`
- 网卡 `ethtool` 信息

## 9. 快照对比逻辑

每轮采集完成后，会自动与上一轮同模式快照对比。

例如：

- `dc_001`
- `dc_002`

会生成类似：

```bash
/root/cycle_logs/compare/dc_001_to_002.log
```

如果没有上一轮快照，则本轮只采集不对比。

## 10. 轮次计数逻辑

轮次计数按模式分别统计。

例如：

- `reboot.count`
- `dc.count`
- `ac.count`

互不影响。

## 11. 推荐现场用法

### 11.1 首次验证脚本是否可用

```bash
python3 cycle_manager.py --mode dc --health-only
```

先确认：

- `/root/cycle_logs` 是否生成
- `snapshots/` 是否有新目录
- `cycle_manager.log` 是否有执行记录

### 11.2 执行 reboot 循环测试

```bash
python3 cycle_manager.py --mode reboot
```

### 11.3 执行 DC cycle 测试

```bash
python3 cycle_manager.py --mode dc
```

### 11.4 执行 AC cycle 测试

```bash
python3 cycle_manager.py --mode ac --ac-off-cmd "ipmitool power off" --ac-on-cmd "ipmitool power on"
```

## 12. 推荐查看的结果文件

首先看：

```bash
cat /root/cycle_logs/cycle_manager.log
```

然后看：

```bash
ls /root/cycle_logs/snapshots
ls /root/cycle_logs/compare
```

如果要看某轮快照内容：

```bash
ls /root/cycle_logs/snapshots/dc_001
```

如果要看差异结果：

```bash
cat /root/cycle_logs/compare/dc_001_to_002.log
```

## 13. 注意事项

- `reboot`、`dc`、`ac` 都属于会中断系统运行的操作，正式执行前先确认现场风险
- `ac` 模式下必须确认 `off/on` 命令真正对应同一台目标设备
- `health-only` 适合首次验证，不适合代替真实循环测试
- 如果现场依赖 BMC、PDU、厂商工具，优先使用已验证过的命令

## 14. 建议结论记录方式

每次循环测试建议至少记录：

- 测试模式：`reboot / dc / ac`
- 轮次
- 执行动作命令
- 快照目录
- 差异文件
- 是否发现设备变化
- 是否发现告警、掉盘、链路变化、FRU 变化、SEL 变化

## 15. 当前建议

实际现场使用顺序建议如下：

1. 先执行一次 `--health-only`
2. 再执行单轮 `dc` 或 `reboot`
3. 确认日志和对比结果正常后，再进入正式循环测试
