# rc.local 循环启动使用手册

适用脚本：

- `practice/scripts-练手脚本/cycle_manager.py`
- `practice/scripts-练手脚本/cycle_autorun.sh`

## 1. 目的

用于通过 `rc.local` 在系统每次启动后自动继续执行循环测试，适合：

- `DC cycle` 循环测试
- `reboot` 循环测试
- `AC cycle` 循环测试

典型场景：

- 每次系统起来后自动执行下一轮
- 不需要人工登录后再手动敲一次命令
- 达到指定轮数后自动停止

## 2. 推荐方案

推荐不要直接把长命令写进 `/etc/rc.local`，而是通过包装脚本：

- `cycle_autorun.sh`

这样好处是：

- 参数更清晰
- 更容易修改
- 更容易切换 `dc / ac / reboot`

## 3. 先手动验证

先在系统里确认脚本能单独执行：

```bash
python3 cycle_manager.py --mode dc --max-cycles 3
```

或者：

```bash
bash cycle_autorun.sh
```

确认：

- `/root/cycle_logs` 正常生成
- `counts/dc.count` 正常累加
- `snapshots/`、`compare/` 正常生成

## 4. 环境变量控制方式

`cycle_autorun.sh` 支持通过环境变量控制：

- `CYCLE_MODE`
- `MAX_CYCLES`
- `WAIT_BEFORE_ACTION`
- `REBOOT_CMD`
- `DC_CMD`
- `AC_OFF_CMD`
- `AC_ON_CMD`
- `AC_OFF_WAIT`

例如：

```bash
export CYCLE_MODE=dc
export MAX_CYCLES=10
export WAIT_BEFORE_ACTION=10
```

## 5. rc.local 示例

### 5.1 DC cycle 循环 10 轮

`/etc/rc.local` 里可写：

```bash
#!/bin/bash
export CYCLE_MODE=dc
export MAX_CYCLES=10
export WAIT_BEFORE_ACTION=10
/root/cycle_autorun.sh >> /root/cycle_autorun.log 2>&1
exit 0
```

### 5.2 reboot 循环 20 轮

```bash
#!/bin/bash
export CYCLE_MODE=reboot
export MAX_CYCLES=20
export WAIT_BEFORE_ACTION=10
export REBOOT_CMD="reboot"
/root/cycle_autorun.sh >> /root/cycle_autorun.log 2>&1
exit 0
```

### 5.3 AC cycle 循环

```bash
#!/bin/bash
export CYCLE_MODE=ac
export MAX_CYCLES=5
export AC_OFF_CMD="ipmitool power off"
export AC_ON_CMD="ipmitool power on"
export AC_OFF_WAIT=20
/root/cycle_autorun.sh >> /root/cycle_autorun.log 2>&1
exit 0
```

## 6. 部署步骤

假设你把脚本放在 `/root/`：

```bash
chmod +x /root/cycle_autorun.sh
chmod +x /etc/rc.local
```

确认 `rc-local` 服务已启用：

```bash
systemctl enable rc-local
systemctl start rc-local
systemctl status rc-local
```

如果系统没有 `rc-local` 服务，需要先补 `rc-local.service`。

## 7. 自动停止逻辑

脚本通过：

```bash
--max-cycles
```

控制最大轮数。

行为是：

- 当前计数 `< max_cycles`：继续执行
- 当前计数 `>= max_cycles`：直接退出，不再继续

例如：

- `MAX_CYCLES=10`
- 当 `dc.count` 已到 `10`
- 下次系统启动时，脚本会检测到已达上限并停止

## 8. 日志怎么看

主日志：

```bash
cat /root/cycle_logs/cycle_manager.log
```

如果通过 `rc.local` 重定向了包装日志：

```bash
cat /root/cycle_autorun.log
```

轮次计数：

```bash
cat /root/cycle_logs/counts/dc.count
cat /root/cycle_logs/counts/reboot.count
cat /root/cycle_logs/counts/ac.count
```

## 9. 推荐的现场使用方式

### DC cycle 推荐

1. 先手动执行一次 `--health-only`
2. 再手动执行一次 `dc`
3. 确认日志正常后，再挂 `rc.local`

### reboot 推荐

1. 先确认系统自启动流程正常
2. 再挂 `rc.local`
3. 确保网络、日志目录、Python 路径都稳定

## 10. 注意事项

- `rc.local` 是开机即执行，命令不要写错
- `AC cycle` 场景必须确认 `AC_OFF_CMD` 和 `AC_ON_CMD` 真的是同一台设备的电源控制
- 正式长循环前，先做 2 到 3 轮验证
- 如果你还要保留人工单轮测试，直接继续用 `cycle_manager.py` 即可，不冲突
