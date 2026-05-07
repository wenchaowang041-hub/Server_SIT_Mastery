# 项目总览

> 4 个服务器硬件测试项目的完整文档索引

---

## 项目列表

| # | 项目 | 平台 | 大小 | 核心内容 |
|---|------|------|------|----------|
| 1 | [金丝雀](./01-金丝雀项目总结.md) | Kunpeng 920 + 昇腾NPU | 21GB | 0SW/2SW/4SW交换板测试、NVMe测试、自动化DC/Reboot、NPU压测 |
| 2 | [磐鹿](./02-磐鹿项目总结.md) | Kunpeng + 昇腾310P/910B | 19GB | RC模式(70T/176T核心板)、单EP、FIO/iperf3性能、SPEC CPU |
| 3 | [联通大衍DPU](./03-联通大衍DPU项目总结.md) | S920X20 + DPU | 13GB | BMC功能、DPU功能/稳定性、网络虚拟化、云盘启动 |
| 4 | [K620BS背板导入](./04-K620BS背板导入项目总结.md) | S920S21 + 920BS背板 | 558MB | NVMe/SAS-SATA背板适配、RAID功能、20盘性能分析 |

---

## 通用测试能力

| 能力 | 使用项目 | 说明 |
|------|----------|------|
| DC Cycle 自动重启 | 金丝雀、磐鹿、联通大衍DPU | 自动掉电重启+健康检查+diff对比 |
| FIO 磁盘压测 | 全部 | 顺序/随机读写、混合负载、长时间稳定性 |
| iperf3 网络测试 | 磐鹿、联通大衍DPU | 千兆/万兆/Bond网络性能 |
| stress-ng CPU压测 | 金丝雀、磐鹿、联通大衍DPU | 全核心CPU+内存压力 |
| Ascend NPU 测试 | 金丝雀、磐鹿 | ascend-dmi/npu-smi 功耗/带宽 |
| IPMI/BMC 管理 | 全部 | 带外管理、传感器、电源控制 |
| RAID 配置测试 | 金丝雀、K620BS | storcli64 创建/删除/重建VD |
| SPEC CPU | 磐鹿 | 标准CPU性能基准 |

---

## 自动化脚本架构

4 个项目共享类似的自动化重启测试架构:

```
main.py (主控)
  ├── info_cpu.py      → CPU 信息 (型号/核心数/频率)
  ├── info_mem.py      → 内存信息 (容量/频率/插槽)
  ├── info_pcie.py     → PCIe 设备 (lspci)
  ├── info_eth.py      → 网络接口 (ip/ifconfig)
  ├── info_hdd.py      → 硬盘信息 (lsblk/blkid)
  ├── info_nvme.py     → NVMe 信息 (nvme list/smart)
  ├── info_ipmi.py     → IPMI (sdr/sel/fru)
  ├── info_dmesg.py    → dmesg 错误日志
  ├── reboot.py        → 重启控制逻辑
  └── utils.py         → 通用工具

每轮流程:
  1. 采集系统信息 → /root/log/
  2. 与基准文件 diff 对比
  3. PASS/FAIL 记录到 contrast/
  4. 归档到 result/
  5. 执行 ipmitool power cycle
  6. rc.local 自动继续下一轮
```

---

## 文档说明

本文档是从 4 个项目的约 **54GB** 文件（含系统镜像、日志、固件、截图、视频等大文件）
中提取核心内容整理而成的结构化总结。原始项目文件保留在 E:\桌面\ 原目录下。
