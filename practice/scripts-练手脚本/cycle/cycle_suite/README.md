# cycle_suite

统一的服务器循环测试脚本结构，支持：

- `reboot`
- `dc cycle`
- `ac cycle`

目录职责：

- `manager.py`：统一入口和参数解析
- `collectors.py`：系统快照采集
- `diffing.py`：前后快照差异对比
- `actions.py`：具体动作执行
- `counters.py`：按模式计数
- `logging_utils.py`：统一日志输出
- `paths.py`：统一路径定义

运行示例：

```bash
python3 cycle_manager.py --mode reboot
python3 cycle_manager.py --mode dc
python3 cycle_manager.py --mode ac --ac-off-cmd "ipmitool power off" --ac-on-cmd "ipmitool power on"
python3 cycle_manager.py --mode dc --health-only
```
