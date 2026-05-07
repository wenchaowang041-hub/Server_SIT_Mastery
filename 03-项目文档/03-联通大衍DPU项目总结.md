# 联通大衍DPU项目总结

> 基于华为 S920X20 服务器 + DPU 加速卡的硬件与功能测试项目，覆盖BMC/BIOS固件、DPU功能/性能/稳定性验证

---

## 1. 项目概况

- **平台**: 华为 S920X20 服务器
- **DPU**: 联通大衍 DPU 加速卡
- **BMC版本**: 11.01.15.05
- **测试范围**: BMC功能、BIOS升级、DPU基本功能、网络虚拟化、存储虚拟化、稳定性

---

## 2. 固件管理 (FW)

### 2.1 BIOS 固件

- **签名包**: compressed_mjqwljb8_华为签名版
  - resigned_Kunpeng920_Update_CS_2P_cms.hpm

### 2.2 BMC 固件

| 固件 | 说明 |
|------|------|
| S920X20-CLU-FAN(BC83FDCA)-CPLD_2.05.hpm | 风扇板CPLD固件 |
| S920X20-EXU(BC83SMMBC)-CPLD_4.02.hpm | 扩展板CPLD固件 |
| bm_local.json | BMC本地配置 |
| config.json | BMC功能配置 |

**文档**:
- 联通大衍DPU BMC功能手册 (2份)

---

## 3. 测试分类与内容

### 3.1 基础检测

| 用例 | 测试项 | 格式 | 状态 |
|------|--------|------|------|
| 1 | 机器外观检测 | PDF/DOCX | 完成 |
| 2 | CPU配置检测 | PDF | 完成 |
| 3 | DPU加速卡检测 | PDF | 完成 |
| 4 | 主板配置检测 | PDF | 完成 |

### 3.2 BMC 管理功能

| 用例 | 测试项 | 格式 | 内容 |
|------|--------|------|------|
| 5 | 设备状态指示灯显示 | DOCX | LED状态验证 |
| 6 | 远程登录功能 | PDF | SSH/Web登录 |
| 7 | 远程控制功能 | PDF | 远程电源管理 |
| 10 | 风扇监控功能 | PDF | 转速监控 |
| 11 | 故障告警测试 | PDF | 告警机制 |
| 12 | BIOS升级测试 | PDF | BIOS FW升级 |
| 13 | BMC升级测试 | PDF | BMC FW升级 |
| 14 | VNC管理功能 | PDF | 远程控制台 |
| 15 | BMC读取DPU信息 | DOCX | DPU信息读取 |
| 17 | IPMI远程开关机及复位 | PDF | IPMI电源管理 |
| 18 | IPMI获取整机功耗 | PDF | 功耗监控 |

### 3.3 电源与散热

| 用例 | 测试项 | 格式 | 内容 |
|------|--------|------|------|
| 8 | 整机功耗 | DOCX | 功耗测试 |
| 9 | 温度监控功能 | PDF | 温度传感器 |
| 24 | 电源冗余和热插拔 | PDF | PSU冗余+热拔插 |
| 25 | 风扇冗余和热插拔 | PDF | 风扇冗余+热拔插 |

### 3.4 DPU 功能测试

| 用例 | 测试项 | 格式 | 内容 |
|------|--------|------|------|
| 20 | 查询指定网卡资源信息 | DOCX | 网卡资源查询 |
| 21 | 配置VNC服务开关 | DOCX | VNC配置 |
| 22 | 设置启动设备 | DOCX | Boot设备配置 |
| 23 | 查询DPU加速卡资源信息 | DOCX | DPU资源 |
| 26 | DPU基本功能测试 | DOCX | 基础功能验证 |
| 27 | DPU BMC | DOCX | DPU带外管理 |
| 28 | DPU支持的PF数量 | DOCX | SR-IOV PF数量 |
| 29 | 网络性能 | DOCX | 网络带宽/延迟 |
| 30 | 存储性能 | DOCX | 存储IO性能 |

### 3.5 DPU 稳定性测试

| 用例 | 测试项 | 格式 | 内容 |
|------|--------|------|------|
| 31 | DPU CPU稳定性 | DOCX | CPU压力测试 |
| 32 | DPU内存稳定性 | DOCX | 内存压力测试 |
| 33 | DPU管理网口Bond1稳定性 | DOCX | Bond网络稳定 |
| 36 | HOST服务器reboot | DOCX | 主机重启验证 |

### 3.6 虚拟化功能

| 用例 | 测试项 | 格式 | 内容 |
|------|--------|------|------|
| 44 | 云盘启动 | DOCX | 云盘引导 |
| 45 | 网络虚拟化 | DOCX | 网络虚拟化功能 |
| 46 | 存储虚拟化 | DOCX | 存储虚拟化功能 |
| 47 | 虚拟化设备热插拔 | DOCX | 虚拟设备热插拔 |

---

## 4. 自动化测试

### 4.1 Reboot + iperf3 自动化脚本

**位置**: `脚本/reboot——iperf3的脚本/`

**架构** (与金丝雀项目类似):
```
main.py (主控) → 调用各模块:
  ├─ info_cpu.py      → CPU信息
  ├─ info_mem.py      → 内存信息
  ├─ info_pcie.py     → PCIe设备
  ├─ info_eth.py      → 网络接口
  ├─ info_hdd.py      → 硬盘信息
  ├─ info_nvme.py     → NVMe信息
  ├─ info_ipmi.py     → IPMI信息
  ├─ info_dmesg.py    → dmesg错误
  └─ reboot.py / utils.py → 工具函数
```

**特色功能**: 每轮重启后自动执行 iperf3 网络性能测试

**iperf3 配置**:
```python
IPERF3_SERVER = "9.9.9.3"    # 服务器地址
IPERF3_DURATION = "30"        # 测试30秒
IPERF3_INTERVAL = "2"         # 报告间隔
IPERF3_PARALLEL = "4"         # 4并行流
```

### 4.2 DPU 72小时压力测试

**内容** (`Log/dpu stress72h.txt`):

```bash
# CPU: 全核心压力
stress-ng --cpu $(nproc) --timeout 259200s

# 内存: 90%内存压力
memtester $((TOTAL_MEM * 9 / 10))M 99999

# 网络: Bond1 + Bond4 同时测试
iperf3 -c 9.9.9.3 -i 2 -t 20 -p 5001    # Bond1
iperf3 -c 10.9.9.3 -i 2 -t 20 -P 8      # Bond4

# 监控: 每5秒刷新 CPU/内存使用率
```

### 4.3 AC 掉电重启测试

**位置**: `Log/联通大衍AC_log/`

- base_round/: 基准文件
- contrast/: 差异对比结果
- result/: 归档结果
- log_reboot.txt: 重启次数记录

### 4.4 业务拉起脚本

`脚本/业务拉起脚本/bm_start.sh`

### 4.5 云盘启动测试

**位置**: `Tool/云盘-arm镜像/`

**镜像**: Kylin-Server-V10-SP3-2303-ARM64-YunBao
- qcow2格式，分割为1GB片段 (百度网盘限制)
- MD5: 6091ed239e97bd9acb12d0b7be137125
- 需要转换为 raw 格式用于云盘启动

**测试结果**:
- 云盘启动lscpu.txt: CPU信息验证
- 云盘启动上传系统.txt: 系统上传
- 云盘启动拉起业务.txt: 业务启动

---

## 5. 测试日志汇总

| 日志 | 内容 |
|------|------|
| DPU_reboot_iperf3/ | DPU重启+网络性能测试日志 |
| DPU_DC_iperf3/ | DPU掉电+网络性能测试日志 |
| DPU_Reset——iperf3/ | DPU复位+网络性能测试日志 |
| DC_DPU_mem/ | DPU掉电+内存测试日志 |
| Bond1+Bond4稳定性72h/ | 72小时网络稳定性 |
| iperf3_86400/ | 24小时网络测试 |
| AC/ | AC掉电测试 |
| 云盘启动/ | 云盘启动测试 |
| final_test_report.txt | 最终测试报告 |

---

## 6. 脚本与工具

| 脚本 | 用途 |
|------|------|
| reboot——iperf3脚本 | 自动化重启+网络测试 |
| 业务拉起脚本 | 业务服务启动 |
| bm_test.json | BMC测试配置 |
| bm_start.sh | BMC业务启动 |
| info_*.py | 系统信息采集模块 (9个) |
| main.py/main-1.py/mainok.py | 主控脚本 (3个版本) |
| reboot.py | 重启控制 |
| utils.py | 通用工具 |

---

## 7. DPU 最终测试报告摘要

**final_test_report.txt** 关键信息:
- DPU Reboot 测试: 299/300 循环完成, 0次失败
- DPU 压力测试: 运行2天23分钟, load average ~47
- 压力测试进程: 19个
- 网络接口: enp8s0f0/f1 (DOWN状态)
- VFIO设备: 4个
- IPMI LAN连接存在问题 (Unable to establish LAN session)

**测试结果**: FAIL (因 IPMI LAN 连接问题)
