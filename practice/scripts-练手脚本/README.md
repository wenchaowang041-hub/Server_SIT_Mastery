# 练手脚本索引

按测试类别分类存放，每个子目录独立一种测试场景。

## 目录结构

```
scripts-练手脚本/
├── fio/          # 存储性能测试
├── hotplug/      # 热插拔测试
├── cycle/        # 稳定性循环测试
├── stress/       # 压力测试
├── check/        # 检查/诊断工具
├── network/      # 网络配置工具
└── legacy/       # 旧版本归档
```

## 各目录说明

### fio/ — 存储性能测试
| 文件 | 说明 |
|------|------|
| `nvme_fio_unified.sh` | Linux 统一 FIO 测试脚本（主用） |
| `nvme_fio_unified.ps1` | Windows PowerShell FIO 测试 |
| `nvme_fio_unified_guide.md` | 使用手册 |

### hotplug/ — 热插拔测试
| 文件 | 说明 |
|------|------|
| `plug-unplug-safe/` | **安全版**（主用），自动排除系统盘，半自动流程 |
| `nvme_hotplug_scripts/` | 旧版，指定 DUT 盘逐轮执行 |

### cycle/ — 稳定性循环测试
| 文件 | 说明 |
|------|------|
| `cycle_manager.py` | Python 版 Cycle 测试管理 |
| `cycle_autorun.sh` | Shell 版自动运行 |
| `ac-cycle-pdu.sh` | 智能 PDU 控制 AC Cycle |
| `cycle_suite/` | Python 模块库（collector/diffing/manager 等） |
| `cycle_suite_guide.md` | cycle_suite 使用文档 |
| `cycle_rc_local_guide.md` | rc.local 部署指南 |

### stress/ — 压力测试
| 文件 | 说明 |
|------|------|
| `stress_12h_kunpeng.sh` | 鲲鹏平台 12 小时压力测试 |

### check/ — 检查/诊断工具
| 文件 | 说明 |
|------|------|
| `check_pcie.py` | PCIe 设备自动清点 |
| `fru-info.sh` | FRU 信息批量查询/编辑（支持表格输出） |
| `ipmi-sel-monitor.sh` | SEL 日志实时监控/导出 |

### network/ — 网络配置工具
| 文件 | 说明 |
|------|------|
| `static-ip-setup.sh` | 静态 IP 一键配置/修复 eno1-endvnic 冲突 |

### legacy/ — 旧版本归档
以下脚本已被统一入口替代，保留仅用于历史参考：
- `nvme_fio_auto_test.sh/ps1` → 被 `fio/nvme_fio_unified.sh` 替代
- `nvme_multi_device_fio.sh` → 被 `fio/nvme_fio_unified.sh` 替代

## 使用建议

- NVMe FIO 压测 → `fio/nvme_fio_unified.sh`
- NVMe 热插拔 → `hotplug/plug-unplug-safe/auto-plug-unplug-fio-safe.sh`
- AC Cycle → `cycle/ac-cycle-pdu.sh`
- Reboot/DC Cycle → `cycle/cycle_manager.py`
- FRU 查询 → `check/fru-info.sh -k "PSU" --table`
- SEL 监控 → `check/ipmi-sel-monitor.sh -c`
- 静态 IP → `network/static-ip-setup.sh --fix-eno1`
- PCIe 清点 → `check/check_pcie.py`
