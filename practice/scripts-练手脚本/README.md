# 脚本目录索引

## 当前主用脚本

- [nvme_fio_unified.sh](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/nvme_fio_unified.sh)
- [nvme_fio_unified.ps1](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/nvme_fio_unified.ps1)
- [nvme_fio_unified_guide.md](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/nvme_fio_unified_guide.md)
- [cycle_manager.py](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/cycle_manager.py)
- [cycle_autorun.sh](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/cycle_autorun.sh)
- [cycle_suite_guide.md](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/cycle_suite_guide.md)
- [cycle_rc_local_guide.md](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/cycle_rc_local_guide.md)
- [stress_12h_kunpeng.sh](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/stress_12h_kunpeng.sh)
- [check_pcie.py](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/check_pcie.py)
- [nvme_hotplug_scripts](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/nvme_hotplug_scripts)
- [nvme_hotplug_scripts/run-hotplug-test.sh](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/nvme_hotplug_scripts/run-hotplug-test.sh)

## 历史脚本

以下脚本已被统一入口替代，保留在 `legacy/` 仅用于历史参考和旧结果追溯：

- [legacy/nvme_fio_auto_test.sh](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/legacy/nvme_fio_auto_test.sh)
- [legacy/nvme_fio_auto_test.ps1](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/legacy/nvme_fio_auto_test.ps1)
- [legacy/nvme_fio_auto_test_guide.md](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/legacy/nvme_fio_auto_test_guide.md)
- [legacy/nvme_multi_device_fio.sh](/C:/Users/王文超/Desktop/Servre_SIT_Mastery/practice/scripts-练手脚本/legacy/nvme_multi_device_fio.sh)

## 使用建议

- 新的 NVMe 压测优先使用 `nvme_fio_unified.sh`
- Windows PowerShell 下优先使用 `nvme_fio_unified.ps1`
- Day19 的 PCIe 清点练习使用 `check_pcie.py`
- NVMe 热插拔现场脚本与执行手册统一收口在 `nvme_hotplug_scripts/`
- `run-hotplug-test.sh` 是 NVMe 热插拔的统一执行入口
- 只有在复盘旧命令或追溯历史行为时，再回看 `legacy/`
# Hotplug Toolkit

- `nvme_hotplug_scripts/`
  说明: 按指定 DUT 盘执行的 NVMe 热插拔脚本与手册，适合按拓扑分组做测试。
  入口: `nvme_hotplug_scripts/run-hotplug-test.sh`
  手册: `NVMe热插拔测试通用详细执行手册.md`、`下午现场执行手册.md`

- `plug-unplug-safe/`
  说明: 基于 Plug-UnPlug 流程整理的安全版半自动工具，自动排除系统盘，适合现场按提示人工插拔。
  入口: `plug-unplug-safe/auto-plug-unplug-fio-safe.sh`
  手册: `plug-unplug-safe/Plug-UnPlug-安全版操作手册.md`

- 选择建议
  如果你需要按两块指定 DUT、按拓扑逐轮执行，优先用 `nvme_hotplug_scripts/`。
  如果你需要沿用 Plug-UnPlug 的分步习惯，并希望脚本自动串联流程，优先用 `plug-unplug-safe/`。
