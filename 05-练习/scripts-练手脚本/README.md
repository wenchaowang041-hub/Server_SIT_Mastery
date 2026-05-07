# 练手脚本索引

按测试类别分类存放，每个子目录对应一种测试场景。

## 目录结构

```text
scripts-练手脚本/
|- fio/       存储性能测试
|- hotplug/   热插拔测试
|- cycle/     稳定性循环测试
|- stress/    压力测试
|- check/     检查与诊断工具
|- network/   网络配置工具
`- legacy/    已归档旧版本
```

## 各目录说明

### `fio/`

| 文件 | 说明 |
|------|------|
| `nvme_fio_unified.sh` | Linux 统一 FIO 测试脚本，主入口 |
| `nvme_fio_unified.ps1` | Windows PowerShell FIO 测试脚本 |
| `nvme_fio_unified_guide.md` | 使用手册 |

### `hotplug/`

| 文件 | 说明 |
|------|------|
| `plug-unplug-safe/` | 安全版主流程，优先使用 |
| `Notify-plug-unplug-Fio/` | 带提示交互的热插拔流程 |
| `nvme_hotplug_scripts/` | 历史版本，按指定 DUT 盘逐轮执行 |

### `cycle/`

| 文件 | 说明 |
|------|------|
| `cycle_manager.py` | Cycle 测试管理入口 |
| `cycle_autorun.sh` | Shell 自动运行入口 |
| `ac-cycle-pdu.sh` | 通过 PDU 控制 AC Cycle |
| `cycle_suite/` | collector、diffing、manager 等模块 |
| `cycle_suite_guide.md` | cycle_suite 使用文档 |
| `cycle_rc_local_guide.md` | rc.local 部署指南 |

### `stress/`

| 文件 | 说明 |
|------|------|
| `stress_12h_kunpeng.sh` | 鲲鹏平台 12 小时压力测试 |

### `check/`

| 文件 | 说明 |
|------|------|
| `check_pcie.py` | PCIe 设备自动清点 |
| `fru-info.sh` | FRU 信息批量查询和表格输出 |
| `ipmi-sel-monitor.sh` | SEL 日志实时监控和导出 |
| `bmc_sel_check.js` | BMC SEL 日志快速检查脚本 |
| `baseline_collect.sh` | 基准配置信息一键收集（软件/工具/部件规格与预填表） |

### `network/`

| 文件 | 说明 |
|------|------|
| `static-ip-setup.sh` | 静态 IP 配置和 `eno1-endvnic` 冲突修复 |
| `dhcp-enable.sh` | DHCP 快速启用脚本 |

### `legacy/`

以下脚本已被统一入口替代，仅保留作历史参考：

- `nvme_fio_auto_test.sh/ps1` 已被 `fio/nvme_fio_unified.sh` 替代
- `nvme_multi_device_fio.sh` 已被 `fio/nvme_fio_unified.sh` 替代

## 使用建议

- NVMe FIO 压测：`fio/nvme_fio_unified.sh`
- NVMe 热插拔：`hotplug/plug-unplug-safe/auto-plug-unplug-fio-safe.sh`
- AC Cycle：`cycle/ac-cycle-pdu.sh`
- Reboot/DC Cycle：`cycle/cycle_manager.py`
- FRU 查询：`check/fru-info.sh -k "PSU" --table`
- SEL 监控：`check/ipmi-sel-monitor.sh -c`
- BMC SEL 快查：`check/bmc_sel_check.js`
- 基准配置收集：`check/baseline_collect.sh`
- 静态 IP：`network/static-ip-setup.sh --fix-eno1`
- PCIe 清点：`check/check_pcie.py`
