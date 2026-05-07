# 服务器硬件整合测试完美手册（2026 年 3 月版）

> 版本：V2026.03  
> 体裁：认证级操作手册 / 实施手册 / 验收手册  
> 适用对象：服务器硬件测试工程师、整机厂验证工程师、数据中心交付工程师、AI 集群运维负责人、国产化项目经理、第三方认证机构  
> 输出形态：Markdown 原版，可直接转 PDF / DOCX / 内部 Wiki  
> 推荐配套：与本手册配套的《版本冻结单》《异常闭环单》《性能回归单》《变更窗口审批单》一起使用

---

## 0. 阅读与使用说明

1. **本手册不是“只看结果”的压测清单，而是完整的认证执行蓝本。**  
   每一章都同时覆盖：  
   - 基线采集  
   - 参数解释  
   - 验证命令  
   - Pass/Fail 判定  
   - 异常排查  
   - 日志归档  
   - 复测与回归策略  

2. **所有“性能数字”都必须放回“版本冻结”语境下理解。**  
   服务器硬件集成测试最常见的错误并不是“跑不起来”，而是：
   - 固件升级后性能漂移，但没有保留前版本基线；
   - 驱动与框架版本组合错误，导致结果不可复现；
   - BIOS 默认值与厂商推荐值不一致，导致 NUMA、C-state、SMT、SR-IOV、Above 4G Decoding、CXL 等关键项偏离最佳实践；
   - 同一机型不同批次器件（SSD、HBA、网卡、retimer、风扇）存在差异，却按同一结果解释；
   - 在 AI 场景中，框架、驱动、固件、交换网络与机架供电被割裂验证，最后上线失败。

3. **2026 年 3 月口径说明。**  
   本手册覆盖用户指定的核心对象，包括：  
   - 华为 Kunpeng 950（高性能版 / 高密度版）  
   - 华为 TaiShan 950 超节点  
   - 华为 Ascend 950PR / 950DT  
   - 华为 Atlas 950 SuperPoD  
   - Intel Xeon 6  
   - AMD EPYC 9005 系列  
   - NVIDIA H200 / B200 / GB200  
   - AMD MI325X  
   - Google TPU v6e / TPU7x（Ironwood）  
   - BlueField DPU / SmartNIC  
   - 以及与之相配套的 openEuler、Ubuntu 24.04、RHEL 10、Windows Server 环境

4. **重要勘误与边界条件。**
   - 用户给出的“Windows Server 2026”要求，在截至 2026-03 的公开产品线中并非可确认的正式主线版本；因此本手册在 Windows 章节中统一按 **Windows Server 2025 / 2022** 的公开兼容方法书写，同时预留“若贵司内部称呼为 2026 预览构建，则按 2025 驱动与验证逻辑交叉核验”的执行说明。
   - 对于 2026 年下半年才进入实际交付窗口的产品（例如部分 950DT / Atlas 950 形态），本手册同时提供 **“发布后正式验收项”** 和 **“预交付实验室验收项”** 两类做法。
   - 对于**未公开**的 TDP、价格、单芯片精确指标，本手册绝不擅自编造；一律以“官方未披露 / 项目报价 / 需以 POC 清单为准”处理。

---

## 1. 前言

过去十年，服务器硬件测试从“单机跑满负载”演进为“整机—机架—集群—框架—业务链路”的一体化验证。  
今天，真正决定交付成败的往往不是某一项理论峰值，而是以下五个层面的耦合是否稳定：

1. **器件层**：CPU、内存、网卡、SSD、GPU/NPU、DPU、PCIe retimer、PSU、风扇是否工作在正确链路与版本上。  
2. **平台层**：BIOS/UEFI、BMC/iBMC、PCIe BAR、NUMA、IOMMU、SR-IOV、CXL、RAS 是否配置正确。  
3. **系统层**：OS 内核、驱动、固件、容器运行时、虚拟化/编排栈是否匹配。  
4. **软件栈层**：CUDA/DCGM/TensorRT、ROCm、CANN、MindSpore、vLLM、MLPerf 工具链是否成套冻结。  
5. **业务层**：数据库、AI 训练、AI 推理、对象存储、分布式 KV、混部负载在真实工况下是否稳定且可复现。

因此，本手册按“**先确诊平台正确，再验证组件性能，最后拉通业务链路**”的顺序组织内容；目标不是让工程师“知道有哪些命令”，而是让工程师在面对复杂交付时可以**照章执行，不靠经验拍脑袋**。

---

## 2. 测试目的

本手册的目标分为七类：

1. **识别硬件是否与采购/交付规格一致。**
2. **确认平台配置是否满足厂商推荐的最佳实践。**
3. **确认在目标 OS、驱动、固件与框架组合下无功能性缺陷。**
4. **确认在长时压力下不存在掉卡、掉盘、链路降速、热降频、ECC 异常、PCIe AER、RAS 错误等稳定性问题。**
5. **确认多厂商混配时不存在功耗、散热、BAR 空间、驱动冲突、NUMA 亲和错误等系统级问题。**
6. **确认 AI 端到端业务（训练/推理/Serving）在真实框架中达到预期吞吐、延迟、功耗与可靠性。**
7. **形成可归档、可复测、可审计、可签字的正式报告。**

---

## 3. 适用服务器与场景范围

### 3.1 适用服务器类型

本手册适用于下列形态：

- 2U / 4U 双路或四路通用服务器
- 4 路以上大内存数据库服务器
- GPU / NPU 训练服务器
- 推理服务器（低延迟 / 高吞吐 / 混合精度）
- DPU/SmartNIC 卸载服务器
- CXL 扩展与内存池化服务器
- 机架级液冷 / 风冷服务器
- 超节点 / SuperPoD / Pod 级集群节点
- 边缘节点与高密度微型数据中心

### 3.2 特别纳入的重点对象

- **华为 TaiShan 950 超节点**：最多 16 节点、32 CPU、48TB 内存，支持内存 / SSD / DPU 池化与灵衢互联。
- **华为 Atlas 950 SuperPoD**：最多 8192 张 Ascend 950DT，8 EFLOPS FP8 / 16 EFLOPS 低精度，1152TB 内存，16.3PB/s UnifiedBus 带宽。
- **NVIDIA GB200 NVL72 / HGX B200 / H200**：面向 AI 工厂、液冷机架、机架级 NVLink 域。
- **AMD MI325X 平台**：大显存、高带宽、长上下文推理与训练。
- **Google TPU v6e / TPU7x**：云侧 TPU VM、Slice、GKE 集群环境。
- **多厂商混配平台**：Huawei + NVIDIA / AMD / DPU / NVMe / RoCE 交换机等组合。

---

## 4. 测试环境准备（含一键安装脚本）

### 4.1 推荐实验室拓扑

| 项目 | 最低要求 | 推荐要求 |
|---|---|---|
| 供电 | 双路独立 PDU | A/B 双路 + 机架级功耗计 |
| 网络 | 管理网 + 业务网 | 管理网 + 业务网 + 存储网 + RoCE/IB 网 |
| 时间同步 | NTP 可用 | PTP/NTP 双保险，BMC 也同步 |
| 日志 | 本地磁盘保存 | 统一 NFS/对象存储归档 + SIEM |
| BMC 接入 | 仅手工访问 | 支持 Redfish/API 拉取 |
| 监控 | 单机命令行 | Prometheus/Grafana + DCGM/Node Exporter/Ascend 监控 |
| 安全 | 普通内网 | 独立验证 VLAN、镜像仓库、离线包仓库 |

### 4.2 推荐操作系统矩阵

| 平台 | 推荐版本 | 备注 |
|---|---|---|
| openEuler | 24.03 LTS / 24.03 LTS SP2 | 国产化与 Ascend / Kunpeng 场景优先 |
| Ubuntu | 24.04 LTS（建议 24.04.4） | GPU/AI 生态成熟 |
| RHEL | 10.x | 企业级支持与认证链路稳定 |
| Windows Server | 2025 / 2022 | 截至 2026-03 公开主线建议按此验证 |
| 容器运行时 | containerd / Docker CE / Podman | 按安全策略统一 |

### 4.3 目录规划与离线包规划

建议预先准备以下目录：

```bash
mkdir -p /opt/offline/{base,nvidia,amd,ascend,kungpeng,mlperf,firmware}
mkdir -p /opt/lab/{logs,reports,scripts,artifacts}
mkdir -p /var/log/hwcert/{baseline,stress,diag,ai,archive}
```

目录含义：

- `/opt/offline/base`：stress-ng、fio、sysbench、iperf3、smartmontools 等基础包
- `/opt/offline/nvidia`：驱动、CUDA、DCGM、Fabric Manager、TensorRT、gpu-burn 源码
- `/opt/offline/amd`：ROCm、rocm-smi、带宽测试工具
- `/opt/offline/ascend`：驱动、固件、CANN、MindSpore、本地 wheel 包
- `/opt/offline/kungpeng`：Kunpeng 调优工具、BoostKit/Hyper Tuner、perf 工具
- `/opt/offline/mlperf`：MLPerf inference/training 镜像、代码和数据清单
- `/opt/offline/firmware`：BIOS/BMC/网卡/HBA/SSD/NPU/GPU 固件包

### 4.4 一键安装脚本（基础环境 + 专有栈挂接）

> 设计原则：  
> 1）开源工具自动安装；  
> 2）专有工具先检测是否已存在，存在则校验版本；  
> 3）若不存在，则从离线目录或企业镜像仓库安装；  
> 4）所有动作必须写入日志；  
> 5）失败时不中断整批检测，而是给出明确的“缺件/缺包/版本不兼容”提示。

```bash
#!/usr/bin/env bash
# 文件名：prepare_lab.sh
# 用途：服务器硬件测试实验室一键准备
# 兼容：openEuler / RHEL / Ubuntu
set -euo pipefail

LOG_DIR=/var/log/hwcert/baseline
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/prepare_lab_$(date +%F_%H%M%S).log"

exec > >(tee -a "${LOG_FILE}") 2>&1

echo "[INFO] detect os"
source /etc/os-release || true
OS_ID="${ID:-unknown}"
OS_VER="${VERSION_ID:-unknown}"

echo "[INFO] OS=${OS_ID} VERSION=${OS_VER}"

install_pkg_apt() {
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

install_pkg_dnf() {
  dnf install -y "$@"
}

install_base_tools() {
  echo "[INFO] install base tools"
  if command -v apt-get >/dev/null 2>&1; then
    install_pkg_apt       curl wget git vim jq tmux tree unzip zip rsync       fio stress-ng sysbench ipmitool dmidecode pciutils usbutils lshw       numactl hwloc ethtool iperf3 nvme-cli smartmontools hdparm       lsscsi sdparm sg3-utils rdma-core infiniband-diags       python3 python3-pip python3-venv gcc g++ make cmake       linux-tools-common linux-tools-generic linux-cloud-tools-generic       lm-sensors dstat sysstat chrony bc psmisc tcpdump net-tools       edac-utils rasdaemon mdadm parted xfsprogs dosfstools       podman docker.io
  else
    install_pkg_dnf       curl wget git vim-enhanced jq tmux tree unzip zip rsync       fio stress-ng sysbench ipmitool dmidecode pciutils usbutils lshw       numactl hwloc ethtool iperf3 nvme-cli smartmontools hdparm       lsscsi sdparm sg3_utils rdma-core infiniband-diags       python3 python3-pip gcc gcc-c++ make cmake       perf lm_sensors dstat sysstat chrony bc psmisc tcpdump net-tools       edac-utils rasdaemon mdadm parted xfsprogs dosfstools       podman docker
  fi
}

install_python_tools() {
  echo "[INFO] install python tools"
  python3 -m pip install -U pip wheel setuptools
  python3 -m pip install     pandas numpy scipy psutil py-cpuinfo jinja2 pyyaml tabulate     requests redfish prometheus_client matplotlib
}

install_gpu_burn() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "[INFO] detected NVIDIA environment"
    if [ ! -d /opt/lab/scripts/gpu-burn ]; then
      if [ -d /opt/offline/nvidia/gpu-burn ]; then
        cp -a /opt/offline/nvidia/gpu-burn /opt/lab/scripts/
      else
        git clone https://github.com/wilicc/gpu-burn.git /opt/lab/scripts/gpu-burn || true
      fi
    fi
    if [ -d /opt/lab/scripts/gpu-burn ]; then
      make -C /opt/lab/scripts/gpu-burn || true
    fi
  else
    echo "[WARN] nvidia-smi not found, skip gpu-burn build"
  fi
}

install_mlperf_tools() {
  mkdir -p /opt/lab/scripts
  if [ -d /opt/offline/mlperf/inference ]; then
    rsync -a /opt/offline/mlperf/inference/ /opt/lab/scripts/mlperf_inference/
  else
    git clone https://github.com/mlcommons/inference.git /opt/lab/scripts/mlperf_inference || true
  fi
  if [ -d /opt/lab/scripts/mlperf_inference ]; then
    python3 -m pip install -r /opt/lab/scripts/mlperf_inference/loadgen/requirements.txt || true
  fi
}

install_nvidia_stack() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "[INFO] nvidia-smi already exists"
  elif [ -d /opt/offline/nvidia ]; then
    echo "[INFO] NVIDIA offline packages detected; install according to certified bundle"
    echo "[NOTE] 请按贵司驱动白名单安装数据中心驱动、Fabric Manager、CUDA、DCGM、TensorRT。"
  else
    echo "[WARN] NVIDIA stack not found and offline bundle absent"
  fi

  if command -v dcgmi >/dev/null 2>&1; then
    echo "[INFO] DCGM exists"
  else
    echo "[WARN] dcgmi missing; if NVIDIA platform, install DCGM from certified bundle"
  fi
}

install_amd_stack() {
  if command -v rocm-smi >/dev/null 2>&1; then
    echo "[INFO] rocm-smi already exists"
  elif [ -d /opt/offline/amd ]; then
    echo "[INFO] AMD ROCm offline bundle detected; please install certified ROCm stack"
  else
    echo "[WARN] ROCm stack not found"
  fi
}

install_ascend_stack() {
  if command -v npu-smi >/dev/null 2>&1; then
    echo "[INFO] npu-smi already exists"
  elif [ -d /opt/offline/ascend ]; then
    echo "[INFO] Ascend offline bundle detected"
    echo "[NOTE] 典型顺序：驱动/固件 -> CANN Toolkit -> CANN Kernels -> set_env.sh -> MindSpore wheel"
  else
    echo "[WARN] Ascend stack not found"
  fi

  if [ -f /usr/local/Ascend/ascend-toolkit/set_env.sh ]; then
    echo "[INFO] Ascend env script found"
  else
    echo "[WARN] CANN env script not found"
  fi
}

install_kunpeng_tools() {
  if [ -d /opt/offline/kungpeng ]; then
    echo "[INFO] Kunpeng tool bundle detected"
    echo "[NOTE] 可在此目录下安装 Hyper Tuner / BoostKit / perf 工具"
  else
    echo "[WARN] Kunpeng tuning toolkit bundle not present"
  fi
}

postcheck() {
  echo "[INFO] running post-check"
  for cmd in fio stress-ng sysbench ipmitool dmidecode lspci numactl ethtool iperf3 nvme nvidia-smi dcgmi rocm-smi npu-smi python3; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      echo "[OK] ${cmd} -> $(command -v ${cmd})"
    else
      echo "[MISS] ${cmd}"
    fi
  done
}

install_base_tools
install_python_tools
install_nvidia_stack
install_amd_stack
install_ascend_stack
install_kunpeng_tools
install_gpu_burn
install_mlperf_tools
postcheck

echo "[DONE] lab preparation completed"
```

#### 逐参数详细解析

| 参数 / 变量 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `set -euo pipefail` | 遇到未定义变量、非零返回或管道错误时立即失败 | 脚本在首行设置 | 未设置导致静默失败 | 固定写在脚本头部 |
| `LOG_DIR` / `LOG_FILE` | 日志输出目录和文件名 | `/var/log/hwcert/baseline/*.log` | 日志未落盘 | 检查权限、SELinux、磁盘空间 |
| `command -v xxx` | 判断命令是否已存在 | 输出程序路径 | 命令不存在 | 检查 PATH、包是否安装 |
| `/opt/offline/*` | 专有离线包目录 | 目录存在且有文件 | 目录为空或包版本错误 | 对照交付清单重新导入 |
| `python3 -m pip install` | 安装 Python 依赖 | 成功返回 0 | 证书、代理、镜像源失败 | 使用内部 PyPI 镜像或离线 wheel |
| `make -C gpu-burn` | 编译 gpu-burn | 成功生成可执行文件 | 缺少编译器、CUDA 头文件 | 安装 build-essential / CUDA |

#### 基础环境 Pass / Fail 判定

**Pass：**
- 基础工具安装完成，至少可以正常执行：`fio`、`stress-ng`、`sysbench`、`ipmitool`、`dmidecode`、`lspci`、`numactl`、`ethtool`、`iperf3`。
- 对应厂商平台存在对应管理工具：
  - NVIDIA：`nvidia-smi`，建议同时有 `dcgmi`
  - AMD：`rocm-smi`
  - Ascend：`npu-smi`，且 `set_env.sh` 可用
- 日志已落盘到 `/var/log/hwcert/baseline`

**Fail：**
- 工具缺失但测试仍继续执行
- 厂商专有工具版本与认证组合不匹配
- 离线包来源不明或哈希未校验
- Python 依赖不固定，导致后续结果不可复现

---

## 5. 测试安全注意事项

1. **任何 BIOS、BMC、SSD、GPU/NPU、DPU 固件升级，必须先备份版本清单与可回退路径。**
2. **任何 burn-in 测试之前，先验证散热与功耗余量。**
3. **液冷系统必须确认冷板、流量、入口水温与漏液传感告警正常。**
4. **混插 GPU/NPU/DPU 的系统必须先核对 PSU 额定余量和上电顺序。**
5. **RoCE/IB 网络测试不得在生产网络直接压测。**
6. **AI 模型与客户数据必须脱敏；日志中不得落敏感明文。**
7. **BMC/Redfish 口令不得硬编码在脚本中，应使用环境变量或临时凭据。**
8. **需要热插拔、掉电、PSU 拔插、链路 flap 的测试，必须在维护窗口执行。**
9. **出现以下情况立即停测：**
   - 温度持续越过厂商上限；
   - PSU 冗余丢失且无法恢复；
   - ECC/UE/CE 激增；
   - PCIe AER 不可校正错误持续增长；
   - GPU/NPU 掉卡、驱动 reset、Xid / HCCS / HBM 错误；
   - BMC 失联；
   - RAID 重建异常或关键盘 SMART 告警。

---

## 6. 统一日志记录模板

### 6.1 每台设备必须采集的元数据

| 字段 | 示例 | 说明 |
|---|---|---|
| 测试单号 | HWCERT-2026-0318-001 | 与项目、批次绑定 |
| 机房/机架位 | IDC-A / R12-U34 | 便于物理定位 |
| 厂商/型号 | TaiShan 950 / Atlas 800T / HGX B200 | 设备标识 |
| 序列号 | SNxxxxxxxx | 唯一身份 |
| BIOS/BMC 版本 | 5.12 / 3.08 | 固件冻结 |
| OS 版本 | openEuler 24.03 LTS SP2 | 系统冻结 |
| 驱动版本 | NVIDIA / ROCm / Ascend Driver | 厂商栈冻结 |
| CANN/CUDA/ROCm | 8.5.0 / 12.x / 6.x | AI 栈冻结 |
| 测试人 | 张三 | 执行人 |
| 见证人 | 李四 | 审核与签字 |
| 开始/结束时间 | 2026-03-24 09:00/18:30 | 时长 |
| 结果 | Pass / Fail / Conditional Pass | 结论 |

### 6.2 推荐 YAML 记录格式

```yaml
ticket_id: HWCERT-2026-0318-001
project: atlas950_poc
rack: IDC-A/R12-U34
vendor: Huawei
model: TaiShan 950 SuperPoD
serial: TS950-XXXX
bios_version: "x.x.x"
bmc_version: "x.x.x"
os: "openEuler 24.03 LTS SP2"
kernel: "6.x"
driver:
  nvidia: null
  rocm: null
  ascend: "25.x"
framework:
  cann: "8.5.0"
  mindspore: "2.7.2"
  cuda: null
  tensorrt: null
tester: "张三"
witness: "李四"
result: "PASS"
notes:
  - "所有节点 NUMA 一致"
  - "HCCS topo 对称"
artifacts:
  - "/var/log/hwcert/baseline/..."
  - "/var/log/hwcert/stress/..."
```

---

## 7. 统一报告模板（简版）

| 章节 | 结论 | 关键证据 | 风险等级 | 是否放行 |
|---|---|---|---|---|
| 系统信息采集 | Pass | baseline_*.tar.gz | 低 | 是 |
| CPU | Pass | sysbench / stress-ng | 低 | 是 |
| BIOS/UEFI | Conditional Pass | CXL 设置待客户确认 | 中 | 视场景 |
| 内存 | Pass | ECC / 带宽 / 长稳 | 低 | 是 |
| 网络 | Pass | iperf3 / RDMA / PFC | 低 | 是 |
| 存储 | Pass | fio / SMART | 低 | 是 |
| RAID | Pass | 控制器与重建 | 低 | 是 |
| 电源散热 | Pass | 功耗/温度曲线 | 低 | 是 |
| PCIe | Pass | AER / lane width | 低 | 是 |
| GPU / NPU | Pass | nvidia-smi / npu-smi / dcgmi | 中 | 是 |
| AI 端到端 | Pass | 吞吐 / 延迟 / 稳定性 | 中 | 是 |

---

## 8. 通用证据采集脚本

```bash
#!/usr/bin/env bash
# 文件名：collect_evidence.sh
set -euo pipefail

OUT_BASE=/var/log/hwcert/archive
STAMP=$(date +%F_%H%M%S)
HOST=$(hostname -s)
OUT_DIR=${OUT_BASE}/${HOST}_${STAMP}
mkdir -p "${OUT_DIR}"

run_cmd() {
  local name="$1"
  shift
  echo "[INFO] collecting ${name}"
  ("$@" > "${OUT_DIR}/${name}.txt" 2>&1) || true
}

run_cmd os_release cat /etc/os-release
run_cmd uname uname -a
run_cmd uptime uptime
run_cmd lscpu lscpu
run_cmd lscpu_ext lscpu -e=CPU,CORE,SOCKET,NODE,ONLINE,MAXMHZ,MINMHZ
run_cmd numactl numactl -H
run_cmd free free -h
run_cmd lsblk lsblk -e7 -o NAME,MODEL,SIZE,ROTA,TYPE,MOUNTPOINT,SERIAL
run_cmd lspci lspci -nn
run_cmd lspci_vv sh -c 'lspci -vv'
run_cmd dmidecode_system dmidecode -t system
run_cmd dmidecode_bios dmidecode -t bios
run_cmd dmidecode_memory dmidecode -t memory
run_cmd ip_addr ip -br a
run_cmd ip_link ip -d link
run_cmd route ip route
run_cmd ethtool_all sh -c 'for i in $(ls /sys/class/net | grep -v lo); do echo "### $i"; ethtool $i || true; ethtool -i $i || true; done'
run_cmd sensors sensors
run_cmd dmesg dmesg -T
run_cmd journal_kernel journalctl -k -b
run_cmd ipmitool_mc ipmitool mc info
run_cmd ipmitool_sdr ipmitool sdr elist all

if command -v nvidia-smi >/dev/null 2>&1; then
  run_cmd nvidia_smi nvidia-smi -q
  run_cmd nvidia_topo nvidia-smi topo -m
fi

if command -v dcgmi >/dev/null 2>&1; then
  run_cmd dcgmi_discovery dcgmi discovery -l
  run_cmd dcgmi_health dcgmi health -c
fi

if command -v rocm-smi >/dev/null 2>&1; then
  run_cmd rocm_smi rocm-smi --showproductname --showbus --showtemp --showpower --showuse --showmemuse
fi

if command -v npu-smi >/dev/null 2>&1; then
  run_cmd npu_smi_info npu-smi info
  run_cmd npu_smi_topo npu-smi info -t topo
  run_cmd npu_smi_health npu-smi info -t health
fi

tar -C "${OUT_BASE}" -czf "${OUT_DIR}.tar.gz" "$(basename "${OUT_DIR}")"
echo "[DONE] ${OUT_DIR}.tar.gz"
```

## 目录

- 第 1 章 系统整体信息收集与诊断
- 第 2 章 CPU（重点包含 Kunpeng 950 + TaiShan 950 超节点测试）
- 第 3 章 BIOS / UEFI（优化设置表，含灵衢、Ascend 启用）
- 第 4 章 内存（DDR5 + CXL + 池化）
- 第 5 章 网络（含 RoCE + DPU offload）
- 第 6 章 存储（NVMe / SAS 等）
- 第 7 章 RAID（硬件 / 软件，全级别）
- 第 8 章 电源 / PSU + 散热 / 温度监控
- 第 9 章 PCIe / 扩展槽 / 兼容性
- 第 10 章 GPU（NVIDIA B200 / GB200 / H200 + AMD MI325X + Ascend 补充）
- 第 11 章 NPU / AI 加速器（Ascend 950PR / DT / Atlas 950 全套，npu-smi、CANN、MindSpore、分布式）
- 第 12 章 TPU（Google）
- 第 13 章 DPU / SmartNIC（NVIDIA BlueField + 华为 Kunpeng 集成）
- 第 14 章 固件 / BMC / iBMC / Redfish 升级（前后对比）
- 第 15 章 整机烧机 + 多厂商混配兼容矩阵
- 第 16 章 AI 端到端验证（MLPerf + vLLM / TensorRT + CANN / MindSpore + DeepSeek 等）
- 附录 A-E：报告模板、速查表、放行标准、监控速查

# 第1章 系统整体信息收集与诊断

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 建立唯一可信的单机与批量设备基线。
2. 在压测前 5 分钟内筛掉明显故障节点。
3. 形成带内 + 带外双视角证据链。
4. 保证任何异常都可快速回溯到当时现场。

## 本章风险点
1. 设备硬件批次不一致，但测试人员误认为是同配置。
2. 带内看到的 BIOS/BMC/风扇/PSU 信息不完整，导致误判。
3. 故障发生后先重启，致使现场信息不可恢复。
4. 加速卡工具不存在或版本错误，却仍强行进行 AI 测试。

## 推荐测试时长
建议单机 20~30 分钟；批量节点可并发执行，首轮建议每批次预留半天。

## 章节说明
本章是整本手册的入口。任何“性能结论”“稳定性结论”“升级结论”都必须建立在一份**可审计的系统基线**之上。
在实战中，最容易被忽略的不是某条 benchmark 命令，而是：

- 设备本身硬件批次是否一致；
- BIOS/BMC/SSD/NIC/GPU/NPU 固件是否已被动过；
- 当前测试节点是否其实早已存在历史告警；
- 带内与带外看到的信息是否一致；
- 故障发生时是否能在第一时间抓到完整现场。

因此，本章的原则是：  
**先采全、再开跑；先冻结、再出分；先抓现场、再重启。**

### 1.1 系统基线信息一次性采集（单机 / 首次上电）

| 项目 | 内容 |
|---|---|
| 测试名称 | 系统基线信息一次性采集（单机 / 首次上电） |
| 测试目的 | 在不引入业务负载的前提下，完整固化该服务器当前的硬件、固件、OS、驱动、拓扑与链路状态，作为后续所有测试与回归的唯一基线。 |
| 预期结果 | 形成一份包含 CPU、内存、存储、网卡、PCIe、BMC、GPU/NPU/DPU、内核与驱动的完整归档包；归档后同一台机器再次执行，差异仅应来自人工变更。 |
| 工具 / 前提 | root 权限；`collect_evidence.sh`；本地有至少 2GB 空余空间；BMC 已接管理网。 |

#### 步骤
1. 登录目标服务器，确认当前处于**空载**或仅系统空闲态。若机器刚做过固件升级，先重启一次再采集，避免采到升级过程残留状态。
2. 执行基线采集脚本，并在采集前记录工单号、机架位、序列号。[建议插入截图：工单系统与设备铭牌界面]
3. 核对输出目录中是否存在 `os_release.txt`、`lscpu.txt`、`numactl.txt`、`lsblk.txt`、`lspci.txt`、`ipmitool_mc.txt` 等关键文件。
4. 若平台存在 GPU/NPU/DPU，则额外检查 `nvidia_smi.txt`、`rocm_smi.txt`、`npu_smi_info.txt`、`npu_smi_topo.txt`、`dcgmi_discovery.txt` 是否出现。
5. 对 tar 包计算 SHA256 并写入交付单；该哈希值在整个测试周期内不能变化，除非重新采集并记录变更原因。
6. 将归档包同步到 NFS 或对象存储，并在测试报告中记录下载路径。

#### 完整命令
```bash
bash /opt/lab/scripts/collect_evidence.sh
ARCHIVE=$(ls -1t /var/log/hwcert/archive/*.tar.gz | head -n 1)
sha256sum "${ARCHIVE}" | tee "${ARCHIVE}.sha256"
tar -tzf "${ARCHIVE}" | sed -n '1,80p'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `collect_evidence.sh` | 统一采集脚本入口 | 避免人工遗漏项 | 脚本版本也要纳入版本冻结 |
| `ARCHIVE=$(...)` | 定位最新归档包 | 保证后续哈希与上传对象是同一个文件 | 批量测试时建议按主机名筛选 |
| `sha256sum` | 生成归档完整性校验 | 防止日志包被覆盖或污染 | 报告附件必须同时附哈希 |
| `tar -tzf` | 查看 tar.gz 文件清单 | 验证包内容齐全 | 不要仅凭文件大小判断是否采集成功 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Architecture` | CPU 架构 | aarch64 / x86_64 | 与采购规格不一致 | 检查主板型号与 BIOS 识别 |
| `CPU(s)` | 逻辑 CPU 总数 | 96/192/256/384 等 | 少核、SMT 未开 | 检查 BIOS SMT/超线程、离线核 |
| `NUMA node(s)` | NUMA 节点数 | 2 / 4 / 8 | 数量缺失或分布异常 | 检查 SRAT、内存插法、BIOS NUMA 设置 |
| `LinkCap` / `LnkSta` | PCIe 标称与当前速率/宽度 | Gen4/Gen5 x16 | 降到 x8 或 Gen3 | 检查插槽、电源、retimer、线缆 |
| `Power Supply` | PSU 状态 | 双电源均健康 | 单路故障/缺失 | 检查 PDU、PSU、BMC 传感器 |
| `Driver Version` | 加速卡驱动版本 | 与基线冻结单一致 | 版本漂移 | 对照变更单与离线包清单 |

#### Pass / Fail 判断标准
**Pass：**
- 归档包生成成功且内容齐全。
- 关键硬件数量、链路宽度、固件版本、驱动版本与采购/交付清单一致。
- 重复执行两次采集，结构与文件名稳定，差异仅限时间戳与瞬时计数器。

**Fail：**
- 任一核心类别缺失：CPU、内存、存储、网络、BMC、加速器。
- 同一台机器两次空载采集结果存在结构性差异，例如 GPU 数量、PCIe 宽度、NUMA 节点数不同。
- 基线包未做哈希，后续证据链不可信。

#### 常见问题排查
1. **归档包为空或过小**：通常是脚本未以 root 执行，或 `ipmitool` 在非带外环境超时。先单独执行失败命令验证。
2. **`lspci -vv` 输出不完整**：可能是内核日志过多或权限不足；确认 root 权限并重定向输出到文件。
3. **BMC 信息缺失**：检查 OS 内是否装有带内 IPMI 驱动，必要时使用带外 Redfish 方式补采。
4. **GPU/NPU 工具不存在**：不要直接判定 Fail，应先确认该平台是否本来就没有该类设备；若存在设备而工具不存在，判定环境准备失败。

#### 实时监控命令
```bash
watch -n 5 '
echo "===== uptime ====="; uptime;
echo "===== sensors ====="; sensors 2>/dev/null | head -n 20;
echo "===== ipmitool sel ====="; ipmitool sel elist last 5 2>/dev/null;
echo "===== nvidia-smi ====="; nvidia-smi --query-gpu=index,name,temperature.gpu,power.draw,utilization.gpu --format=csv,noheader 2>/dev/null;
echo "===== rocm-smi ====="; rocm-smi --showtemp --showpower --showuse 2>/dev/null;
echo "===== npu-smi ====="; npu-smi info watch -d 5 -s pta 2>/dev/null;
'
```

#### 实施补充说明
该用例是全书最重要的入口。任何后续性能结果如果找不到对应的基线包，一律视为不可审计结果。


### 1.2 版本冻结与差异审计（固件 / 驱动 / 框架）

| 项目 | 内容 |
|---|---|
| 测试名称 | 版本冻结与差异审计（固件 / 驱动 / 框架） |
| 测试目的 | 建立“硬件器件—固件—驱动—框架”四层冻结表，确保任何性能和稳定性结论都能在相同版本下复现。 |
| 预期结果 | 形成一份版本矩阵：BIOS/BMC/SSD/HBA/NIC/GPU/NPU/DPU Firmware + OS Kernel + Driver + Runtime + Framework，并输出与前一轮测试的差异报告。 |
| 工具 / 前提 | 已有上一轮或上一批次设备的版本台账；建议使用 Git 或配置管理系统。 |

#### 步骤
1. 收集本机所有关键版本，包括 BIOS、BMC、网卡固件、RAID/HBA 固件、SSD 固件、GPU/NPU/DPU 驱动与框架版本。
2. 将采集结果整理为 CSV 或 YAML，字段至少包含：组件名、当前版本、目标版本、来源包名、变更单号、变更窗口。
3. 与历史基线做差异比较；只有“已审批”差异才能继续后续认证测试。
4. 若发现 SSD/NIC/GPU 同型号但固件小版本不同，需立即标记为**混批风险**，并在后续压力测试中单独关注。
5. 将差异审计结果输出到报告首页，明确说明“本次成绩只对当前冻结组合有效”。

#### 完整命令
```bash
OUT=/opt/lab/reports/version_freeze_$(hostname -s)_$(date +%F).csv
{
  echo "component,current_version"
  echo "bios,$(dmidecode -s bios-version 2>/dev/null | tr -d ',')"
  echo "bmc,$(ipmitool mc info 2>/dev/null | awk -F: '/Firmware Revision/{gsub(/^[ 	]+/,"",$2); print $2}')"
  echo "kernel,$(uname -r)"
  echo "os,$(source /etc/os-release && echo ${PRETTY_NAME})"
  echo "nvidia_driver,$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n 1)"
  echo "rocm_smi,$(rocm-smi --showdriverversion 2>/dev/null | awk -F: '/Driver version/{print $2}' | xargs)"
  echo "ascend_npu_smi,$(npu-smi info 2>/dev/null | awk '/npu-smi/{print $NF; exit}')"
  echo "python,$(python3 -V 2>&1 | awk '{print $2}')"
} | tee "${OUT}"

diff -u /opt/lab/reports/previous_version_freeze.csv "${OUT}" || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `OUT=...csv` | 定义版本冻结文件路径 | 输出留痕 | 建议按主机名和日期命名 |
| `dmidecode -s bios-version` | 读取 BIOS 版本 | 验证 BIOS 是否被回退或漂移 | 虚拟机环境下可能为空 |
| `ipmitool mc info` | 读取 BMC 固件版本 | 固件升级前后最关键项之一 | 若带内不可用，改用 Redfish |
| `nvidia-smi --query-gpu=driver_version` | 获取 NVIDIA 驱动版本 | 驱动漂移会直接影响 DCGM/TensorRT 结果 | 多卡环境取第一行即可代表驱动栈 |
| `diff -u` | 输出差异报告 | 用于审批和审计 | CI/CD 中建议改成结构化比较 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `component` | 组件名称 | bios / bmc / kernel / nvidia_driver | 命名不统一 | 在团队内先统一字段字典 |
| `current_version` | 当前版本字符串 | 精确到小版本 | 为空或多值 | 改用更具体命令或人工补录 |
| `target_version`（扩展字段） | 目标冻结版本 | 与当前一致 | 目标未定义 | 回到项目冻结单 |
| `change_ticket`（扩展字段） | 变更工单号 | 非空 | 版本变了但无工单 | 禁止继续认证 |
| `package_source`（扩展字段） | 安装来源 | 离线包/镜像仓库路径 | 来源不明 | 重新制作离线包清单 |

#### Pass / Fail 判断标准
**Pass：**
- 所有关键组件有明确版本记录；
- 与上一轮相比的差异均能对应到审批工单；
- 测试报告首页能清楚写出本轮冻结组合。

**Fail：**
- 版本记录缺项；
- 驱动/固件已变化但无变更记录；
- 同批设备版本不一致但未标识混批风险。

#### 常见问题排查
1. **`diff` 输出很多噪声**：说明字段顺序不固定，应先做字典排序再比对。
2. **BMC 版本为空**：带内 IPMI 不通；换带外 Redfish 或现场登记。
3. **NPU/CUDA/ROCm 版本混乱**：同一环境同时存在多个 toolkit 时，必须记录环境变量和默认路径。

#### 实时监控命令
```bash
watch -n 10 '
echo "[kernel] $(uname -r)";
echo "[bios] $(dmidecode -s bios-version 2>/dev/null)";
echo "[bmc] $(ipmitool mc info 2>/dev/null | awk -F: "/Firmware Revision/{print \$2}" | xargs)";
echo "[nvidia] $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n 1)";
echo "[rocm] $(rocm-smi --showdriverversion 2>/dev/null | awk -F: "/Driver version/{print \$2}" | xargs)";
echo "[ascend] $(npu-smi info 2>/dev/null | awk "/npu-smi/{print \$NF; exit}")";
'
```


### 1.3 系统健康快诊（5 分钟内定位大故障）

| 项目 | 内容 |
|---|---|
| 测试名称 | 系统健康快诊（5 分钟内定位大故障） |
| 测试目的 | 在测试批次开始前，用最短路径发现明显故障，如掉盘、掉卡、链路降速、温度异常、BMC 告警、ECC/SEL 激增等。 |
| 预期结果 | 5 分钟内输出“可继续 / 需人工介入 / 立即停测”结论。 |
| 工具 / 前提 | 基线包已完成；现场允许读取 BMC SEL 和系统日志。 |

#### 步骤
1. 执行健康快诊脚本，优先检查温度、供电、SEL、内核错误、PCIe AER、磁盘 SMART、加速卡健康。
2. 若看到明显硬故障，例如 `Uncorrectable`, `Xid`, `AER Fatal`, `Media Error`, `HBM UE`，立即将该节点移出批量测试。
3. 将快诊结论写入日报，避免问题节点混入大批次压测导致结果污染。
4. 对于机架级集群，所有节点都必须先过快诊，再进入多机训练/推理。

#### 完整命令
```bash
#!/usr/bin/env bash
set -euo pipefail
echo "===== kernel critical ====="
journalctl -k -b | egrep -i 'error|fail|fatal|mce|edac|aer|xid|ras|uncorrect|i/o error' | tail -n 50 || true
echo "===== ipmi sel ====="
ipmitool sel elist last 50 || true
echo "===== sensors ====="
sensors || true
echo "===== nvme smart ====="
for d in $(nvme list 2>/dev/null | awk 'NR>2{print $1}'); do
  echo "--- $d ---"; nvme smart-log $d | egrep 'critical_warning|temperature|percentage_used|media_errors|num_err_log_entries' || true
done
echo "===== nvidia ====="
nvidia-smi -q -d TEMPERATURE,POWER,ERROR 2>/dev/null || true
echo "===== rocm ====="
rocm-smi --showtemp --showpower --showrasinfo 2>/dev/null || true
echo "===== ascend ====="
npu-smi info -t health 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `journalctl -k -b` | 读取当前启动周期内核日志 | 最快看到 MCE/AER/Xid | 批次前快诊必跑 |
| `egrep -i ...` | 过滤关键错误关键词 | 快速缩小排查范围 | 关键词列表可按经验扩展 |
| `ipmitool sel elist` | 读取 BMC 事件日志 | 发现掉电、风扇故障、过温等板级问题 | 若日志已满先备份再清空 |
| `nvme smart-log` | 读取 NVMe 健康指标 | 发现介质错误、过温、寿命 | 企业盘必须重点看 media_errors |
| `npu-smi info -t health` | 查看 Ascend 健康状态 | NPU 节点快诊必须项 | 健康项异常需停测 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `fatal` | 致命级错误 | 无 | 出现即高风险 | 抓完整日志并停测 |
| `Xid` | NVIDIA GPU 驱动错误码 | 无 | 出现表示 GPU/驱动异常 | 结合 DCGM/驱动日志排查 |
| `AER` | PCIe 高级错误报告 | 无或极少可纠正项 | Fatal/Non-Fatal 增长 | 检查插槽、retimer、固件 |
| `media_errors` | NVMe 介质错误 | 0 | 持续增长 | 更换盘并做掉盘分析 |
| `Health` | NPU 健康 | OK/Normal | Warning/Error | 先看温度、电源、固件、驱动 |

#### Pass / Fail 判断标准
**Pass：**
- 内核日志无致命类硬件错误；
- SEL 无新增高危告警；
- 温度、功耗、SMART、加速器健康均正常。

**Conditional Pass：**
- 仅有历史已知、已闭环的低风险告警，且本次未新增。

**Fail：**
- 任一关键器件出现致命错误；
- AER/Xid/HBM/ECC/Media Error 持续增长；
- 传感器已经处于越限状态。

#### 常见问题排查
1. **SEL 历史事件太多**：先导出历史 SEL，再执行 `ipmitool sel clear`，重新观察 5~10 分钟新增事件。
2. **温度正常但仍掉卡**：多半不是散热问题，而是 PCIe、电源纹波、固件不匹配或驱动 reset。
3. **NPU 健康正常但训练异常退出**：继续看 `npu-smi info -t usages`、框架日志、HCCS/HCCL 拓扑。


### 1.4 带外管理采集（BMC / iBMC / Redfish）

| 项目 | 内容 |
|---|---|
| 测试名称 | 带外管理采集（BMC / iBMC / Redfish） |
| 测试目的 | 把带内 OS 看不到的板级与机箱级信息采完整，包括 PSU、风扇、FRU、传感器、告警、升级服务与 BIOS 可编程项。 |
| 预期结果 | 形成带外 JSON 或文本证据，可与带内 `ipmitool` 结果互相校验。 |
| 工具 / 前提 | 已知 BMC 地址、账号、密码；网络可访问 Redfish。 |

#### 步骤
1. 先通过浏览器确认 BMC / iBMC 正常登录，记录网页版本与证书状态。[建议插入截图：BMC 首页 / 固件信息界面]
2. 用 Redfish 拉取系统、BIOS、热管理、电源、网卡、固件更新服务等对象，保存原始 JSON。
3. 将带外 JSON 与带内 `dmidecode`、`ipmitool` 对比，发现序列号、机箱类型、固件版本不一致时，必须人工复核。
4. 对于批量机群，建议把 Redfish 拉取动作做成 Ansible/并发脚本，在每个测试窗口前后都执行一次。

#### 完整命令
```bash
export BMC_HOST=192.168.100.10
export BMC_USER=admin
export BMC_PASS='***REDACTED***'
OUT=/var/log/hwcert/baseline/redfish_$(hostname -s)_$(date +%F_%H%M%S)
mkdir -p "${OUT}"

for uri in   /redfish/v1   /redfish/v1/Systems/1   /redfish/v1/Systems/1/Bios   /redfish/v1/Chassis/1   /redfish/v1/Chassis/1/Thermal   /redfish/v1/Chassis/1/Power   /redfish/v1/Managers/1   /redfish/v1/UpdateService
do
  curl -k -u "${BMC_USER}:${BMC_PASS}" "https://${BMC_HOST}${uri}"     -o "${OUT}/$(echo ${uri} | tr '/' '_').json"
done

ls -lh "${OUT}"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `BMC_HOST` | BMC 或 iBMC 地址 | 带外采集核心入口 | 建议写入安全变量而非明文脚本 |
| `curl -k -u` | 调用 Redfish API | 适用于绝大多数主流厂商 | 证书自签名场景用 `-k`，生产可改为 CA 校验 |
| `/Systems/1/Bios` | BIOS 设置对象 | 可用于升级前后对比 | 部分厂商路径可能不同 |
| `/Chassis/1/Thermal` | 热管理对象 | 风扇和温度的板级真相 | 比带内 sensors 更完整 |
| `/UpdateService` | 升级服务对象 | 固件升级前后必须采 | 可检查是否支持队列与激活方式 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `SerialNumber` | 序列号 | 与铭牌一致 | 不一致 | 检查板卡/主板替换记录 |
| `BiosVersion` | BIOS 版本 | 与带内一致 | 带内带外不一致 | 重新启动/重新读取 |
| `PowerSupplies` | 电源模块列表 | 全部 Present + Healthy | 缺失/Failed | 检查物理插入与 PDU |
| `Fans` | 风扇状态 | 速度合理、无 Failed | 转速异常/缺失 | 检查风道与风扇模块 |
| `Status.Health` | 对象健康 | OK | Warning/Critical | 展开具体对象排查 |

#### Pass / Fail 判断标准
**Pass：**
- Redfish 对象可正常读取；
- 关键字段与带内信息一致；
- Power/Thermal/UpdateService 对象无异常。

**Fail：**
- 带外无法访问；
- 关键固件版本不一致且无法解释；
- Thermal/Power 对象存在 Critical 状态。

#### 常见问题排查
1. **HTTPS 证书报错**：实验室环境允许 `-k`，但必须在报告中注明“未校验证书链”。
2. **`/Systems/1` 路径不对**：不同厂商可能是 `/Systems/Self` 或其他索引，先从根目录 `/redfish/v1` 递归发现。
3. **带外与带内信息冲突**：以厂商带外控制面为优先事实源，但要在报告中说明冲突和复测结果。


### 1.5 异常快照与证据打包（故障复现当下）

| 项目 | 内容 |
|---|---|
| 测试名称 | 异常快照与证据打包（故障复现当下） |
| 测试目的 | 当出现掉卡、掉盘、性能突降、训练中断、重启、温度越限等问题时，在第一时间捕获可供厂商定位的完整证据。 |
| 预期结果 | 故障发生后 3~5 分钟内完成一轮快照，至少保留：系统日志、BMC SEL、传感器、拓扑、加速器状态、进程、coredump 和当前负载命令。 |
| 工具 / 前提 | 问题可复现；系统未完全宕死；root 权限；测试人员对故障窗口有明确时间点记录。 |

#### 步骤
1. 故障出现后**不要立刻重启**，先记下发生时间、当前测试命令和负载类型。
2. 立即执行快照脚本，并保存前后台日志；若是多机问题，所有参与节点同时快照。
3. 对掉卡问题，必须保留 `dmesg`、`journalctl -k`、`lspci -vv`、加速器工具输出与 BMC SEL。
4. 对性能突降问题，必须保留 `top`、`mpstat`、`iostat`、`sar -n DEV`、功耗温度与链路速率。
5. 打包后再决定是否重启；重启会清除大量现场信息。

#### 完整命令
```bash
STAMP=$(date +%F_%H%M%S)
OUT=/var/log/hwcert/diag/failure_${STAMP}
mkdir -p "${OUT}"

dmesg -T > "${OUT}/dmesg.txt" 2>&1 || true
journalctl -k -b > "${OUT}/journal_kernel.txt" 2>&1 || true
ps auxfw > "${OUT}/ps_auxfw.txt" 2>&1 || true
top -b -n 1 > "${OUT}/top.txt" 2>&1 || true
mpstat -P ALL 1 5 > "${OUT}/mpstat.txt" 2>&1 || true
iostat -xz 1 5 > "${OUT}/iostat.txt" 2>&1 || true
sar -n DEV 1 5 > "${OUT}/sar_net.txt" 2>&1 || true
lspci -vv > "${OUT}/lspci_vv.txt" 2>&1 || true
ipmitool sel elist > "${OUT}/sel.txt" 2>&1 || true
ipmitool sdr elist all > "${OUT}/sdr.txt" 2>&1 || true
sensors > "${OUT}/sensors.txt" 2>&1 || true
nvidia-smi -q > "${OUT}/nvidia_smi_q.txt" 2>&1 || true
dcgmi health -c > "${OUT}/dcgmi_health.txt" 2>&1 || true
rocm-smi --showtemp --showpower --showrasinfo > "${OUT}/rocm_smi.txt" 2>&1 || true
npu-smi info > "${OUT}/npu_smi_info.txt" 2>&1 || true
npu-smi info -t usages > "${OUT}/npu_smi_usages.txt" 2>&1 || true
npu-smi info -t topo > "${OUT}/npu_smi_topo.txt" 2>&1 || true

tar -C /var/log/hwcert/diag -czf "${OUT}.tar.gz" "$(basename "${OUT}")"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `mpstat -P ALL 1 5` | 采样所有 CPU 核心使用率 | 定位是否只有部分 NUMA 过载 | 性能突降时非常关键 |
| `iostat -xz 1 5` | 采样块设备队列和时延 | 判断是否被存储拖慢 | 关注 await、svctm、%util |
| `sar -n DEV 1 5` | 采样网络吞吐与丢包 | 排查 RoCE/TCP 瓶颈 | 需安装 sysstat |
| `npu-smi info -t usages` | 采样 NPU 使用率 | 排查 NPU 实际是否在工作 | 空转会指向框架或亲和错误 |
| `tar -czf` | 二次封装证据目录 | 便于邮件/工单传递 | 压缩前先确认文件已关闭写入 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `await` | 磁盘平均等待时间 | < 5ms（高速 NVMe 常见） | 突增到数十毫秒以上 | 检查队列深度、掉盘、PCIe 降速 |
| `%util` | 磁盘繁忙度 | < 90%（常态） | 持续 100% | 区分瓶颈是设备还是 workload 设计 |
| `GPU Temp`/`power.draw` | GPU 温度/功耗 | 温度不过上限、功耗与负载匹配 | 温度高但利用率低 | 看散热与 power cap |
| `AICore%` | NPU AI Core 利用率 | 与训练/推理负载匹配 | 长期接近 0 | 检查框架是否回退到 CPU |
| `SEL timestamp` | 板级告警时间 | 与故障时间点吻合 | 无对应事件 | 再看 OS 日志/驱动日志 |

#### Pass / Fail 判断标准
**Pass：**
- 故障快照覆盖系统、板级、器件、负载四类证据；
- 证据有明确时间戳；
- 打包后的证据可直接提交厂商工单。

**Fail：**
- 故障后先重启导致现场丢失；
- 只保留单一日志，没有链路、温度、功耗或拓扑证据；
- 多机问题只采单机快照。

#### 常见问题排查
1. **节点已假死**：优先通过 BMC 获取 SEL、传感器和带外日志；必要时抓串口日志。
2. **压力测试脚本本身退出**：必须保存启动脚本与参数，否则无法复现实验条件。
3. **故障偶现**：每次出现都要重新打包，不要覆盖旧包，便于做时间相关性分析。



# 第2章 CPU（重点包含 Kunpeng 950 + TaiShan 950 超节点测试）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 CPU 拓扑、NUMA、线程、频率与热设计是否正确。
2. 建立单机 CPU 压力稳定性基线。
3. 验证 Kunpeng 平台的绑核、局部性和调优收益。
4. 验证 TaiShan 950 超节点成员节点的一致性与互联前置健康。

## 本章风险点
1. SMT/超线程关闭导致线程数少一半。
2. CPU governor、C-state、功耗策略不一致导致批次成绩不可比。
3. 长时烧机后热降频但短测看不出来。
4. 超节点成员机配置漂移或互联口隐藏故障。

## 推荐测试时长
建议单机 1~4 小时；新品/首批/超节点建议 8~24 小时分阶段执行。

## 章节说明
CPU 测试不是简单地“跑满 nproc”。对现代多路高核心平台而言，真正重要的是四件事：

1. 拓扑是否正确；
2. 频率/功耗策略是否符合目标场景；
3. 长时满载是否稳定；
4. 业务绑核、绑内存和局部性是否得到正确利用。

对于 Kunpeng 950 与 TaiShan 950 超节点，这一点更加重要。高核心密度与超节点互联让平台拥有极高上限，但也意味着：
- 任一节点配置漂移都会被放大；
- 任意 NUMA 错绑都会导致尾时延和带宽恶化；
- 资源池化之前若没有统一拓扑和版本，后面所有问题都会变成“疑难杂症”。

### 2.1 CPU 拓扑、核心数、线程数与 NUMA 一致性验证

| 项目 | 内容 |
|---|---|
| 测试名称 | CPU 拓扑、核心数、线程数与 NUMA 一致性验证 |
| 测试目的 | 确认 BIOS/UEFI、OS 与实际硬件对 CPU 拓扑的识别完全一致，避免少核、离线核、SMT 关闭、NUMA 错配等问题。 |
| 预期结果 | 逻辑 CPU 数、物理核心数、Socket 数、NUMA 节点、缓存层次与采购规格一致；同批节点输出结构一致。 |
| 工具 / 前提 | `lscpu`、`numactl`、`hwloc/lstopo` 可用；已完成系统基线采集。 |

#### 步骤
1. 读取 `lscpu`、`lscpu -e`、`numactl -H` 与 `lstopo-no-graphics` 输出，建立 CPU/CORE/THREAD/NUMA 映射。
2. 核对总线程数是否等于“物理核心数 × SMT 倍数”。在 Kunpeng/Arm 平台上也要特别确认线程模型与 BIOS 配置是否一致。
3. 对双路/多路平台，检查每个 NUMA 节点 CPU 数量是否平衡；若不平衡，应优先怀疑 BIOS 配置、离线核、热插拔或硬件故障。
4. 若是批量节点，建议把结果导出为 CSV，再用脚本做行级比较。
5. 对 AI 服务器，还应同时记录 CPU 到 GPU/NPU 的亲和关系，为后续绑核做准备。[建议插入截图：lstopo 拓扑图]

#### 完整命令
```bash
lscpu
echo "-----"
lscpu -e=CPU,CORE,SOCKET,NODE,ONLINE,MAXMHZ,MINMHZ | column -t
echo "-----"
numactl -H
echo "-----"
if command -v lstopo-no-graphics >/dev/null 2>&1; then
  lstopo-no-graphics
fi
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `lscpu` | CPU 总览 | 先看总量和模型名 | 最基础的真实性校验 |
| `-e=CPU,CORE,SOCKET,NODE,ONLINE,MAXMHZ,MINMHZ` | 按逻辑 CPU 展开拓扑 | 可直接看是否离线核、跨 Socket 映射异常 | 建议固定该列顺序便于脚本解析 |
| `numactl -H` | 查看 NUMA 节点和本地内存 | 判断内存与 CPU 的局部性 | 后续所有绑核、绑内存都依赖此结果 |
| `lstopo-no-graphics` | 显示层级拓扑 | 便于发现 PCIe/GPU/NIC 与 CPU 亲和关系 | 适合插图入报告 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `CPU(s)` | 逻辑 CPU 总数 | 与规格一致，例如 192 / 256 / 384 | 数量偏少 | 检查 BIOS SMT/超线程、离线核、隔离核 |
| `Socket(s)` | 物理 CPU 数 | 1 / 2 / 4 | 识别成单路 | 检查 CPU 插装、主板识别、BIOS |
| `NUMA node(s)` | NUMA 节点数 | 通常与 Socket 数对应或更多 | 缺失或不对称 | 检查 SRAT、内存插法、平台模式 |
| `ONLINE` | 逻辑核在线状态 | 全部 Y | 有 N | 检查 `isolcpus`、`offline`、热问题 |
| `MAXMHZ/MINMHZ` | 频率上下界 | 与平台策略相符 | 异常为 0 或特别低 | 检查 cpufreq 驱动、BIOS 电源策略 |

#### Pass / Fail 判断标准
**Pass：**
- 拓扑、线程数、NUMA 结构完全符合规格；
- 同批设备无结构性差异；
- 关键加速器设备能映射到合理的 CPU 亲和域。

**Fail：**
- 少核、少线程、离线核未解释；
- NUMA 节点不平衡；
- 不同节点同型号却有不同拓扑结构。

#### 常见问题排查
1. **线程数少一半**：典型原因是 SMT/超线程被 BIOS 关闭。
2. **NUMA 节点只有 1 个**：可能被设置成 UMA/Node Interleaving。
3. **`MAXMHZ` 为 0**：内核或 cpufreq 驱动未正确加载，可用 `cpupower frequency-info` 交叉验证。

#### 实时监控命令
```bash
watch -n 5 '
echo "===== topology summary =====";
lscpu | egrep "Architecture|CPU\(s\)|Thread|Core|Socket|NUMA";
echo "===== load distribution =====";
mpstat -P ALL 1 1 | tail -n +4 | head -n 16;
'
```


### 2.2 CPU 频率、功耗策略与调度器配置验证

| 项目 | 内容 |
|---|---|
| 测试名称 | CPU 频率、功耗策略与调度器配置验证 |
| 测试目的 | 确认 CPU 处于厂商推荐的性能模式，避免因节能、C-state、cpufreq governor、功耗封顶导致性能异常。 |
| 预期结果 | 性能型场景下，CPU 频率可在负载下正常拉升；非必要节能项关闭或处于受控状态；多机结果一致。 |
| 工具 / 前提 | `cpupower`、`tuned-adm`（可选）、`perf` 可用。 |

#### 步骤
1. 查看 governor、驱动、当前频率范围，确认是否处于 `performance` 或项目要求的策略。
2. 对数据库、HPC、训练服务器，一般建议使用性能型 governor，并在 BIOS 里关闭深度 C-state；若客户强制节能，则必须单独记录。
3. 负载前记录空载频率，负载中记录提升后的频率和功耗，负载结束后确认频率回落。
4. 同一批次所有节点必须保持相同调度策略，否则 benchmark 不具有可比性。

#### 完整命令
```bash
cpupower frequency-info || true
tuned-adm active 2>/dev/null || true
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true
stress-ng --cpu 0 --cpu-method matrixprod --timeout 60s --metrics-brief &
sleep 5
lscpu | egrep 'MHz|CPU max MHz|CPU min MHz'
grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | sed -n '1,16p'
wait
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `cpupower frequency-info` | 查看频率驱动与 governor | 确认是否处于性能模式 | 某些 ARM 平台信息可能简化 |
| `tuned-adm active` | 查看系统调优配置 | RHEL/openEuler 常用 | 存在 profile 冲突要先统一 |
| `stress-ng --cpu 0` | 对所有 CPU 施加短时计算压力 | 验证频率拉升与调度 | `0` 表示所有在线 CPU |
| `scaling_cur_freq` | 当前频率 | 负载期应明显高于空载 | 若无 cpufreq 接口则改用 perf/stat 观察 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `governor` | 调速策略 | performance / schedutil（按要求） | powersave | 切换 governor 或改 BIOS 策略 |
| `current policy` | 频率策略区间 | 覆盖正常最大最小值 | 上限过低 | 检查 power cap / BIOS |
| `CPU max MHz` | 理论上限 | 与厂商规格接近 | 明显偏低 | 看 BIOS 功耗模式、散热降频 |
| `scaling_cur_freq` | 实时频率 | 随负载拉升 | 不升反降 | 检查温度、功耗、节能策略 |

#### Pass / Fail 判断标准
**Pass：**
- 负载中频率可拉升到合理区间；
- governor 与项目策略一致；
- 节点间无策略漂移。

**Fail：**
- 性能场景下仍使用节能 governor；
- 高负载时频率无法提升；
- 某些节点存在明显不同的功耗/频率策略。

#### 常见问题排查
1. **频率拉不上去但温度正常**：先看 BIOS Power Policy、OS governor、功耗封顶。
2. **频率跳动很大**：若是 latency 场景，要减少 C-state 和 package power management。
3. **Arm/Kunpeng 平台 cpufreq 接口较少**：以实际吞吐和 `perf stat` 为补充判据。


### 2.3 CPU 稳定性压力测试（sysbench + stress-ng）

| 项目 | 内容 |
|---|---|
| 测试名称 | CPU 稳定性压力测试（sysbench + stress-ng） |
| 测试目的 | 验证 CPU 在满核长时负载下无 MCE、无热降频、无重启、无性能异常波动。 |
| 预期结果 | 长时运行无报错，吞吐曲线稳定，温度与功耗在设计上限内。 |
| 工具 / 前提 | `sysbench`、`stress-ng`、`mpstat`、`ipmitool`、`rasdaemon` 可用。 |

#### 步骤
1. 先运行 5 分钟预热，确保散热系统进入稳态，再开始正式 1~4 小时压力测试。
2. 同时记录 CPU 使用率、平均频率、封装温度、BMC 功耗与日志。
3. 测试期间若出现 MCE、RAS、AER、自动重启、软锁死、性能突然掉 20% 以上，立即停止并打快照。
4. 对认证级放行，建议最少 1 小时；对新品首批或混配场景，建议 8~24 小时。

#### 完整命令
```bash
mkdir -p /var/log/hwcert/stress/cpu
sysbench cpu --threads=$(nproc) --time=300 --cpu-max-prime=20000 run   | tee /var/log/hwcert/stress/cpu/sysbench_prewarm.log

stress-ng --cpu 0 --cpu-method matrixprod --verify -t 2h --metrics-brief   | tee /var/log/hwcert/stress/cpu/stress_ng_2h.log &

for i in $(seq 1 120); do
  date | tee -a /var/log/hwcert/stress/cpu/monitor.log
  mpstat -P ALL 1 1 | tee -a /var/log/hwcert/stress/cpu/monitor.log
  ipmitool sdr elist all | egrep -i 'temp|fan|power' | tee -a /var/log/hwcert/stress/cpu/monitor.log
  journalctl -k -b | tail -n 20 | tee -a /var/log/hwcert/stress/cpu/monitor.log
  sleep 60
done
wait
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--threads=$(nproc)` | 使用所有逻辑核 | 最大化 CPU 压力 | 若要按 NUMA 分开测可改绑核 |
| `--cpu-max-prime=20000` | sysbench 计算复杂度 | 用于预热与吞吐基线 | 数字越大单线程工作量越大 |
| `--cpu-method matrixprod` | stress-ng 计算方法 | 高浮点/矩阵压力，常用于烧机 | 也可换 fft、crc 等 |
| `--verify` | 结果校验 | 避免只跑负载不校验正确性 | 烧机建议开启 |
| `-t 2h` | 持续时间 | 示例为 2 小时 | 验收可按标准改成 4h/8h/24h |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `events per second` | sysbench 吞吐 | 同型号节点波动在小范围 | 个别节点明显偏低 | 看频率、温度、绑核、背景负载 |
| `soft lockup` | 软锁死告警 | 无 | 出现即高风险 | 抓内核栈、检查 BIOS/微码 |
| `MCE/EDAC` | 机器检查/ECC | 无 | 出现 | 检查 CPU、内存、电源 |
| `CPU idle` | 空闲比例 | 满载时接近 0 | 仍有大量 idle | 负载未压满或 cpuset 限制 |
| `Temp/Power` | 温度/功耗 | 接近但不超过上限 | 越限/抖动异常 | 检查散热、风扇、功耗策略 |

#### Pass / Fail 判断标准
**Pass：**
- 长时压力全程无硬件/内核级错误；
- 温度稳定，不持续越限；
- 吞吐随时间无明显漂移。

**Fail：**
- 出现任何 MCE、自动重启、内核 panic、热降频到明显影响成绩；
- 同型号节点差异大于项目容忍阈值且无可解释原因。

#### 常见问题排查
1. **跑 20~30 分钟后吞吐下降**：通常是热饱和或风扇策略偏保守。
2. **随机重启**：优先怀疑电源/VRM/BIOS/主板，不要只盯 CPU 本体。
3. **单 NUMA 节点 hotter**：检查散热风道是否偏斜，或某侧 DIMM/加速卡叠加热量。


### 2.4 Kunpeng 950 平台专测：缓存/绑核/亲和与编译优化验证

| 项目 | 内容 |
|---|---|
| 测试名称 | Kunpeng 950 平台专测：缓存/绑核/亲和与编译优化验证 |
| 测试目的 | 针对 Kunpeng 950 的高核心密度平台，验证绑核、缓存局部性、编译选项和调优工具是否生效，避免“CPU 很强但业务跑不满”。 |
| 预期结果 | 在绑核、绑内存、本地缓存命中优化后，吞吐明显优于未绑定运行；系统日志无一致性错误。 |
| 工具 / 前提 | Kunpeng 平台；建议安装 perf、numactl、Kunpeng 调优工具或 BoostKit/Hyper Tuner。 |

#### 步骤
1. 确认编译器、数学库、线程库和容器镜像是否为 Arm 版；不能使用隐式 x86 回退或兼容层。
2. 对关键应用（数据库、推理服务、中间件）做一次“不绑核/不绑内存”与“严格绑定”的对比测试。
3. 使用 `numactl --cpunodebind` 与 `--membind` 约束进程，观察尾延迟和吞吐改善。
4. 结合 perf 或 Kunpeng 调优工具分析 LLC miss、分支预测、上下文切换和跨 NUMA 访存。
5. 将优化前后的参数、吞吐、P99 时延写入报告，形成可复用模板。

#### 完整命令
```bash
# 示例：对应用进行 NUMA 绑定
numactl --cpunodebind=0 --membind=0   sysbench cpu --threads=96 --time=300 --cpu-max-prime=30000 run   | tee /var/log/hwcert/stress/cpu/kunpeng_bound.log

# 对比：不绑定
sysbench cpu --threads=96 --time=300 --cpu-max-prime=30000 run   | tee /var/log/hwcert/stress/cpu/kunpeng_unbound.log

# perf 观察热点
perf stat -d -d -d --timeout 60000   numactl --cpunodebind=0 --membind=0   sysbench cpu --threads=96 --time=60 --cpu-max-prime=30000 run
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--cpunodebind=0` | 仅使用 NUMA 节点 0 的 CPU | 隔离跨节点调度 | 用于观察单 NUMA 局部性 |
| `--membind=0` | 仅从 NUMA 节点 0 分配内存 | 保证本地内存命中 | 对时延敏感业务收益明显 |
| `perf stat -d -d -d` | 输出详细硬件计数器摘要 | 看 cache miss、branch miss、IPC | 用于优化而非放行分数 |
| `--threads=96` | 线程数与目标核心数对齐 | 在高核心平台上避免 oversubscribe | 实际应按应用线程模型选择 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `LLC-load-misses` | 最后级缓存 miss | 优化后应下降或至少不恶化 | 持续很高 | 检查数据局部性和线程绑核 |
| `context-switches` | 上下文切换 | 合理范围 | 异常高 | 检查线程数过多、绑核不当、irq 干扰 |
| `IPC` | 每周期指令数 | 同负载下较稳定 | 明显偏低 | 看缓存 miss、频率、内存带宽 |
| `P99 latency`（业务扩展项） | 尾时延 | 绑定后下降 | 绑定后反而升高 | 检查线程/内存绑定策略与业务模型 |

#### Pass / Fail 判断标准
**Pass：**
- Kunpeng 平台的绑核/绑内存优化能带来可解释、可重复的收益；
- Arm 原生工具链路径清晰；
- 优化前后数据可复现。

**Fail：**
- 实际业务在 Kunpeng 上运行仍走非原生二进制或兼容层；
- 绑定后结果随机波动，说明还有其它系统噪声未控制。

#### 常见问题排查
1. **绑定后性能更差**：线程数可能不匹配，或应用本身需要跨 NUMA 共享大缓存。
2. **perf 权限不足**：调整 `kernel.perf_event_paranoid`，但必须记录变更。
3. **容器内结果差**：确认容器 cpuset/mems 没有与 numactl 冲突。


### 2.5 TaiShan 950 超节点专测：跨节点一致性、灵衢互联与资源池化前置检查

| 项目 | 内容 |
|---|---|
| 测试名称 | TaiShan 950 超节点专测：跨节点一致性、灵衢互联与资源池化前置检查 |
| 测试目的 | 针对超节点架构，验证多个节点在 CPU/内存/网络/互联层面的一致性，为后续内存池化、SSD 池化、DPU 池化和大规模数据库/AI 任务打基础。 |
| 预期结果 | 超节点中每个节点的 CPU 型号、拓扑、固件、内存插法、OS 与驱动完全对齐；节点间互联链路状态正常；资源池化功能具备启用条件。 |
| 工具 / 前提 | 已具备超节点管理面；节点间 SSH 互信；所有成员节点可并发执行命令。 |

#### 步骤
1. 制作节点清单，如 `node01~node16`，并通过并发 SSH 拉取 `hostname`、`lscpu`、`free -h`、`uname -r`、互联口状态。
2. 对比所有节点输出；任何一台节点的 BIOS、BMC、内存容量或内核版本不一致，都要先整改后再进资源池化测试。
3. 检查超节点互联口是否全部 Up，且无协商降速、丢包或链路 flap。
4. 若平台提供灵衢或超节点管理 CLI/API，应同步导出拓扑图和链路健康状态。[建议插入截图：超节点拓扑界面/资源池化管理界面]
5. 在真正启用内存/SSD/DPU 池化前，先做一致性检查，否则后续故障会非常难定位。

#### 完整命令
```bash
NODES="node01 node02 node03 node04"

for n in ${NODES}; do
  echo "===== ${n} ====="
  ssh ${n} 'hostname; lscpu | egrep "Model name|CPU\(s\)|Socket|Thread|Core|NUMA"; free -h; uname -r'
done | tee /var/log/hwcert/baseline/taishan950_cluster_baseline.txt

for n in ${NODES}; do
  echo "===== ${n} net ====="
  ssh ${n} 'ip -br link; ethtool -S $(ls /sys/class/net | grep -E "eth|ens" | head -n 1) 2>/dev/null | head -n 30'
done | tee /var/log/hwcert/baseline/taishan950_cluster_net.txt
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `NODES="..."` | 节点列表 | 可扩展到 16 个节点 | 建议来自 CMDB 而非手填 |
| `ssh ${n} '...'` | 远程并发/串行采集 | 快速形成对比矩阵 | 大规模推荐 pssh/pdsh/Ansible |
| `egrep "Model name|CPU..."` | 筛出 CPU 关键字段 | 便于一眼看差异 | 适合批量汇总 |
| `ethtool -S` | 查看网卡统计 | 用于互联口前置健康验证 | 关注 rx/tx error、drop、flap |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Model name` | CPU 型号 | 所有节点一致 | 混入不同 CPU stepping | 按批次重新分组 |
| `Mem:` | 内存总量 | 所有节点一致或在规划范围内 | 某节点容量偏少 | 检查 DIMM 漏插或故障 |
| `uname -r` | 内核版本 | 全节点一致 | 版本漂移 | 重新做统一镜像 |
| `rx_errors/tx_errors` | 网卡错误计数 | 0 或稳定 | 持续增长 | 查线缆、模块、交换机口 |

#### Pass / Fail 判断标准
**Pass：**
- 全部节点硬件与软件版本一致；
- 互联链路稳定；
- 满足资源池化前置条件。

**Fail：**
- 任一节点版本漂移或硬件容量不一致；
- 互联口错误计数增长；
- 拓扑图与实际节点清单不匹配。

#### 常见问题排查
1. **同机型不同 BIOS**：超节点环境下一律按 Fail 处理，不允许“先跑再说”。
2. **互联口 Up 但性能差**：进一步做点对点延迟/带宽测试，不能只看链路灯。
3. **节点输出偶发超时**：先排 SSH 并发与 DNS，不要误判节点坏。



# 第3章 BIOS / UEFI（优化设置表，含灵衢、Ascend 启用）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 建立 BIOS/UEFI 变更前后快照与回退依据。
2. 按业务场景统一 BIOS 模板。
3. 验证 Secure Boot、IOMMU、SR-IOV、CXL、大 BAR 等关键项。
4. 验证灵衢互联与 Ascend / 多加速器平台的 BIOS 兼容性。

## 本章风险点
1. 未做快照即变更，无法回退。
2. 批量节点 BIOS 漂移导致成绩不可比。
3. Above 4G / 大 BAR 未启，导致多卡少卡或性能异常。
4. IOMMU/SR-IOV/CXL 开启后 OS 不识别。

## 推荐测试时长
建议每台机器 30~60 分钟；批量模板切换需预留维护窗口与重启时间。

## 章节说明
BIOS/UEFI 是平台正确性的“总闸门”。CPU、内存、PCIe、CXL、DPU、GPU/NPU 的许多问题，表面上发生在 OS 或驱动层，根因其实在 BIOS 层。
本章的核心思想是：

- **先导出，再修改；**
- **先模板化，再批量化；**
- **先做 OS 层复核，再相信 BIOS 界面。**

尤其在多加速器、超节点、CXL、SR-IOV、DPU 卸载等新平台上，BIOS 每一个开关都可能改变系统拓扑和可见资源。

## 推荐 BIOS/UEFI 优化设置表（通用模板）

> 注意：不同厂商命名不同，但调优意图相同。执行前必须导出当前 BIOS 配置，并在维护窗口内操作。

| 功能项 | 推荐值（通用性能型） | 适用场景 | 风险/副作用 | 备注 |
|---|---|---|---|---|
| Hyper-Threading / SMT | 按项目要求；吞吐型一般开启，强实时型可评估关闭 | 数据库、虚拟化、推理 | 关闭会减少线程数 | 先与软件许可模型确认 |
| CPU Power Policy | Performance | HPC、训练、低时延推理 | 功耗上升 | 与 OS governor 保持一致 |
| C-State / Deep C-State | 尽量关闭或限制 | 低时延场景 | 待机功耗上升 | 批量节点要一致 |
| NUMA / SRAT | 开启真实 NUMA | 通用/HPC/AI | 若误设为 UMA 会导致性能异常 | 需要 OS 正确识别 |
| Memory Interleaving | 关闭 Node Interleaving，保持 NUMA 可见 | 数据库、AI | 配置不当会增加跨节点访存 | 与绑核策略配套 |
| IOMMU / VT-d / SMMU | 开启 | DPU、SR-IOV、虚拟化、容器 | 旧驱动可能兼容性差 | 需实测性能影响 |
| SR-IOV | 按需开启 | DPU/NIC/GPU 虚拟化 | VF 资源管理复杂 | 不用时关闭更简单 |
| Above 4G Decoding | 开启 | 多 GPU/NPU/DPU/大 BAR | 老系统可能启动失败 | 加速器服务器必查 |
| Resizable BAR / Large BAR | 按厂商建议开启 | 新型 GPU/NPU 平台 | 某些固件组合不兼容 | 先看支持矩阵 |
| PCIe Link Speed | Auto / Gen5 优先 | 新平台 | 强制过高可能不稳定 | 以稳定为先 |
| CXL Support | 按项目要求开启 | CXL 内存扩展 | 新平台组合复杂 | 需与 OS 内核版本匹配 |
| Secure Boot | 按安全要求 | 生产安全场景 | 自编驱动签名复杂 | 测试环境可记录后临时关闭 |
| Lingqiu / 超节点互联 | 按平台要求开启 | TaiShan 950 超节点 | 需匹配整机与管理面 | 变更后必须复查拓扑 |
| Ascend / AI Accelerator Enable | 开启 | Ascend / 混配 AI 服务器 | BAR、IOMMU、启动时间变化 | 与固件/驱动一起核验 |

### 3.1 BIOS / UEFI 当前配置导出与变更前快照

| 项目 | 内容 |
|---|---|
| 测试名称 | BIOS / UEFI 当前配置导出与变更前快照 |
| 测试目的 | 在任何 BIOS 调优或固件升级之前，完整保留当前 BIOS/UEFI 版本、启动方式与关键配置项，形成回退依据。 |
| 预期结果 | 拿到 BIOS 版本、启动模式（Legacy/UEFI）、Secure Boot 状态、引导项顺序，以及可通过 BMC/Redfish 导出的当前 BIOS 配置对象。 |
| 工具 / 前提 | `dmidecode`、`efibootmgr`、`mokutil`（可选）、BMC Redfish 可访问。 |

#### 步骤
1. 记录 BIOS 版本和发布日期；对批量节点要求相同机型同 BIOS 版本。
2. 检查是否为 UEFI 启动，是否开启 Secure Boot，当前默认启动项是什么。
3. 从带外 Redfish 导出 BIOS 设置对象，保存原始 JSON；若厂商提供专用 CLI，也建议一并保留。
4. 在报告中记录‘变更前快照’路径，作为任何优化与升级的回退依据。

#### 完整命令
```bash
dmidecode -t bios
efibootmgr -v || true
mokutil --sb-state 2>/dev/null || true
curl -k -u "${BMC_USER}:${BMC_PASS}" "https://${BMC_HOST}/redfish/v1/Systems/1/Bios"   -o /var/log/hwcert/baseline/bios_before.json
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `dmidecode -t bios` | 查看 BIOS 基本信息 | 确认版本和厂商 | 最直接的固件快照 |
| `efibootmgr -v` | 查看 UEFI 启动项 | 防止升级后启动顺序变化 | OS 启动异常常见根因 |
| `mokutil --sb-state` | 查看 Secure Boot | 驱动签名问题必查 | 若系统未装该工具可跳过 |
| `redfish ... /Bios` | 导出 BIOS 设置对象 | 最适合做升级前后 diff | 厂商路径可能略有不同 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Vendor/Version` | BIOS 厂商与版本 | 明确且与批次一致 | 不同批次混用 | 先统一版本 |
| `BootCurrent/BootOrder` | 当前/顺序引导项 | 与规划一致 | 升级后顺序变更 | 恢复启动项 |
| `SecureBoot` | 安全启动状态 | 按项目要求 | 与驱动签名不兼容 | 调整策略并记审计 |
| `Attributes` | BIOS 参数集 | 可完整导出 | 导不全 | 改用厂商专用导出工具 |

#### Pass / Fail 判断标准
**Pass：**
- BIOS 基本信息、引导项、Secure Boot、配置对象均已导出；
- 快照可用于后续对比。

**Fail：**
- 未做快照就直接改 BIOS；
- 多节点配置漂移但无人知晓。

#### 常见问题排查
1. **`efibootmgr` 报错**：说明当前不是 UEFI 模式或工具未安装。
2. **Redfish 导不出 BIOS**：先从 `/redfish/v1` 发现实际路径，或使用厂商 CLI。


### 3.2 按场景应用 BIOS 优化模板（通用计算 / AI / DPU / 低时延）

| 项目 | 内容 |
|---|---|
| 测试名称 | 按场景应用 BIOS 优化模板（通用计算 / AI / DPU / 低时延） |
| 测试目的 | 把 BIOS 调优从“经验主义”变成“模板化”，确保同场景机器设置一致且可审计。 |
| 预期结果 | 按模板执行后，关键项与目标场景一致；重启后通过带内/带外复查生效。 |
| 工具 / 前提 | 已做好变更单与回退方案；支持带外自动化设置更佳。 |

#### 步骤
1. 根据场景选择模板：通用吞吐、低时延、AI 训练、DPU/SR-IOV/CXL 扩展。
2. 修改后重启，重新导出 BIOS 配置并与模板逐项核对。
3. 对影响大的项目（C-state、NUMA、Above 4G、Resizable BAR、SR-IOV、CXL）必须在重启后用 OS 命令二次验证。
4. 同机型批量交付时，模板必须版本化管理，禁止人工逐项点选但无留痕。

#### 完整命令
```bash
# 伪代码示例：实际请替换为厂商支持的 BIOS 配置工具
# 1) 导出现有 BIOS
cp /var/log/hwcert/baseline/bios_before.json /opt/lab/reports/bios_working_copy.json

# 2) 人工/自动修改后重启
echo "请在维护窗口内应用 BIOS 模板并重启"

# 3) 重启后复核
curl -k -u "${BMC_USER}:${BMC_PASS}" "https://${BMC_HOST}/redfish/v1/Systems/1/Bios"   -o /var/log/hwcert/baseline/bios_after.json
diff -u /var/log/hwcert/baseline/bios_before.json /var/log/hwcert/baseline/bios_after.json || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `bios_before.json / bios_after.json` | 变更前后配置 | 做差异审计 | 最核心留痕 |
| `diff -u` | 文本差异 | 快速看到变更项 | JSON 若乱序可先格式化 |
| `重启后复核` | 确认 BIOS 参数真正生效 | 比单看界面更可靠 | 必须结合 OS 层验证 |
| `模板版本化` | 把 BIOS 调优纳入配置管理 | 避免批量交付漂移 | 推荐 Git 管理 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Node Interleaving` | NUMA 可见性 | Disabled（多数性能场景） | Enabled | NUMA 失真 |
| `Above 4G Decoding` | 大 BAR 支持 | Enabled（多加速卡） | Disabled | 设备枚举不全 |
| `SR-IOV` | 虚拟功能支持 | 按项目要求 | 关闭导致 VF 不存在 | 重启后复核 `lspci`/`ip link` |
| `CXL Support` | CXL 使能 | 按项目要求 | 开了但 OS 看不到 | 查内核与 cxl 工具 |

#### Pass / Fail 判断标准
**Pass：**
- 模板项已生效且 OS 层验证通过；
- 同批机器配置一致。

**Fail：**
- BIOS 界面显示修改但 OS 层未体现；
- 同批机器模板版本不一致。

#### 常见问题排查
1. **改了 Above 4G 后系统启动异常**：先确认 OS/驱动支持，再按模板回退。
2. **改了 C-state 后功耗投诉**：将“性能模式”和“节能模式”拆成两套模板，不要混用。


### 3.3 BIOS 安全项、虚拟化项与 CXL/SR-IOV 能力验证

| 项目 | 内容 |
|---|---|
| 测试名称 | BIOS 安全项、虚拟化项与 CXL/SR-IOV 能力验证 |
| 测试目的 | 确认 Secure Boot、IOMMU、SR-IOV、VT-d/SMMU、CXL 等平台能力与目标业务匹配。 |
| 预期结果 | 安全项按项目要求，虚拟化项与扩展项打开后，OS 能正确识别并正常创建 VF/CXL 设备。 |
| 工具 / 前提 | OS 已安装相应工具；CXL 平台装有 `cxl` / `daxctl`；网卡/DPU 支持 SR-IOV。 |

#### 步骤
1. 检查 Secure Boot、IOMMU、SR-IOV、VT-d/SMMU 是否开启。
2. 对于 DPU、虚拟化、裸金属云主机，确认 VF 可正常创建与枚举。
3. 对于 CXL 平台，确认 `cxl list` 能看到 memory device、region、decoder 等对象。
4. 若开启这些能力后性能有回退，必须在报告中明确列出“以功能正确优先还是以性能优先”的结论。

#### 完整命令
```bash
mokutil --sb-state 2>/dev/null || true
dmesg -T | egrep -i 'iommu|smmu|dmar' | tail -n 50 || true
lspci | egrep -i 'virtual function|ethernet|network' || true
for dev in /sys/class/net/*/device/sriov_numvfs; do echo "$dev"; cat "$dev"; done 2>/dev/null || true
cxl list -M -m -d -p 2>/dev/null || true
daxctl list 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `mokutil --sb-state` | Secure Boot 状态 | 安全与驱动签名的交叉验证 | 敏感环境必查 |
| `dmesg | egrep 'iommu|smmu|dmar'` | IOMMU 初始化日志 | 确认 DMA 重映射已启用 | 虚拟化/直通/DPU 场景必查 |
| `sriov_numvfs` | 当前 VF 数量 | 验证 SR-IOV 已真正生效 | 只有 BIOS 开启还不够，OS/驱动也要支持 |
| `cxl list -M -m -d -p` | 枚举 CXL 资源 | 查看 memdev、region、decoder | CXL 平台关键命令 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `DMAR/IOMMU enabled` | DMA 重映射正常 | 能在日志中看到 | 完全缺失 | 回 BIOS 查看 VT-d/SMMU |
| `sriov_numvfs` | VF 数量 | 0（未创建）或按需求值 | 无法写入或枚举失败 | 查驱动、固件、网卡支持 |
| `memdev` | CXL 内存设备 | 可被枚举 | 列表为空 | 查 BIOS/CXL 插卡/内核版本 |
| `decoder/region` | CXL 地址映射 | 配置正确 | 缺失或 inactive | 重新规划 region 并激活 |

#### Pass / Fail 判断标准
**Pass：**
- 安全、虚拟化、扩展能力均按项目要求生效；
- 功能验证与 OS 枚举结果一致。

**Fail：**
- BIOS 开启但 OS 层完全看不到；
- 开启后导致系统不稳定且无回退结论。

#### 常见问题排查
1. **Secure Boot 开着驱动装不上**：要么签名驱动，要么在受控测试环境临时关闭并留痕。
2. **VF 创建失败**：先看网卡固件是否支持，再看驱动、IOMMU、ACS、交换机配置。
3. **CXL 设备可见但不能上线 region**：通常是内核、工具链或 BIOS 组合不匹配。


### 3.4 灵衢互联、Ascend 使能与大 BAR/加速器兼容性验证

| 项目 | 内容 |
|---|---|
| 测试名称 | 灵衢互联、Ascend 使能与大 BAR/加速器兼容性验证 |
| 测试目的 | 验证超节点互联与 AI 加速器相关 BIOS 项已经正确打开，避免系统虽能启动但加速器无法满配或拓扑错误。 |
| 预期结果 | 灵衢/超节点互联状态正常；Ascend/GPU/NPU/DPU 全部枚举；无 BAR 不足、资源冲突或 PCIe 拓扑异常。 |
| 工具 / 前提 | 平台已安装目标加速器；BMC 或厂商 BIOS 菜单可见相关选项。 |

#### 步骤
1. 确认超节点互联和 Ascend/NPU 相关设置已按平台要求开启。
2. 对多 GPU/NPU/DPU 服务器，必须启用 Above 4G Decoding，必要时启用大 BAR/Resizable BAR。
3. 重启后同时从 `lspci -vv`、厂商工具和 BMC 视角确认设备数量与链路宽度正确。
4. 若设备只枚举出部分，优先怀疑 BIOS 资源项、PCIe bifurcation、BAR 空间或固件兼容性。

#### 完整命令
```bash
lspci | egrep -i 'NVIDIA|AMD|Ascend|3D controller|Processing accelerators|Ethernet'
lspci -vv | egrep -i 'LnkSta:|LnkCap:|Region|BAR'
nvidia-smi -L 2>/dev/null || true
rocm-smi --showproductname --showbus 2>/dev/null || true
npu-smi info 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `lspci` | 统一设备枚举入口 | 先确认设备到底在不在 | 多厂商混配时最基础 |
| `LnkSta/LnkCap` | 当前/能力链路 | 看是否降速降宽 | 加速器性能问题常从这里开始 |
| `Region/BAR` | BAR 资源信息 | 大 BAR 设备最关键 | 若资源不足会导致设备异常枚举 |
| `nvidia-smi / rocm-smi / npu-smi` | 厂商侧二次确认 | 确认驱动层也认到了设备 | 必须与 `lspci` 互证 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Bus Id` | 设备总线号 | 数量与槽位规划一致 | 缺失/冲突 | 查 BIOS/PCIe 开关/背板 |
| `LnkSta Width` | 当前链路宽度 | x16/x8（按设计） | 低于设计 | 查插槽、电源、retimer |
| `BAR` | 内存映射资源 | 分配成功 | 资源不足/冲突 | 开 Above 4G、调整 BAR 配置 |
| `Device count` | 设备总数 | 满配一致 | 少卡 | 优先查 BIOS 资源与供电 |

#### Pass / Fail 判断标准
**Pass：**
- 所有设备都能被 `lspci` 和厂商工具正确识别；
- 链路宽度和数量符合设计；
- 无 BAR 相关冲突。

**Fail：**
- 掉卡、少卡、链路降宽或 BAR 分配失败；
- 超节点互联开关未生效却进入后续测试。

#### 常见问题排查
1. **OS 只看到一半设备**：通常不是驱动问题，而是 BIOS 资源或硬件链路问题。
2. **设备都在但性能低**：看 `LnkSta` 是否只是 Gen4 x8 之类的降配状态。
3. **Ascend/NPU 与 GPU 混插异常**：先统一打开 Above 4G，再核查平台白名单与固件版本组合。



# 第4章 内存（DDR5 + CXL + 池化）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 DDR5 插法、速度训练和 ECC/RAS。
2. 验证本地与远端 NUMA 访问差异。
3. 验证长时内存压力稳定性。
4. 验证 CXL 与内存池化能力。

## 本章风险点
1. 内存插条不满通道导致性能显著下降。
2. NUMA 错绑造成远端访存。
3. 长时压测后出现 CE/UE 或 OOM。
4. CXL/池化功能开了，但缺少性能与回收验证。

## 推荐测试时长
建议基础校验 30 分钟；长稳 2~8 小时；CXL/池化按项目另行预留。

## 章节说明
内存测试分三层：  
第一层是**有没有插对、跑对、ECC 正不正常**；  
第二层是**NUMA 与带宽/时延有没有被用对**；  
第三层是**CXL 与池化这类新能力是否真正可控**。

在 2026 年的服务器验证中，单纯看“总容量”已经远远不够。DDR5、CXL、池化、超节点共享都会直接决定数据库、缓存、大模型推理和训练的尾时延与稳定性。

### 4.1 DIMM / 内存条清点、频率训练与 ECC 基线验证

| 项目 | 内容 |
|---|---|
| 测试名称 | DIMM / 内存条清点、频率训练与 ECC 基线验证 |
| 测试目的 | 确认内存容量、插法、速度、ECC/RAS 状态与设计一致。 |
| 预期结果 | DIMM 数量、容量、速率、通道分布合理；ECC 正常；无持续性 CE/UE 告警。 |
| 工具 / 前提 | `dmidecode`、`edac-util` 或 `rasdaemon`、`journalctl` 可用。 |

#### 步骤
1. 读取 DIMM 清单，检查容量、厂商、Part Number、Locator、Speed。
2. 核对是否满通道或符合采购设计；对数据库和大模型平台，内存插法必须按白皮书执行。
3. 检查 ECC 和 RAS 日志，确认没有持续性 Corrected Error 或任何 Uncorrected Error。
4. 对超大内存服务器，建议重启后再次采集一次，确认训练频率稳定且未回退。

#### 完整命令
```bash
dmidecode -t memory
edac-util -v 2>/dev/null || true
ras-mc-ctl --status 2>/dev/null || true
journalctl -k -b | egrep -i 'edac|ecc|mce|ras' | tail -n 100 || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `dmidecode -t memory` | 读取 DIMM 明细 | 容量、速率、槽位的真实性来源 | 最基础证据 |
| `edac-util -v` | 查看 EDAC 统计 | 观察 CE/UE | 需要内核支持 |
| `ras-mc-ctl --status` | 查看 RAS 内存控制器状态 | 企业平台更常用 | 若没有可略过 |
| `journalctl ...` | 查看 ECC/RAS 日志 | 判断是否有持续性错误 | 结合时间维度分析 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Size` | DIMM 容量 | 与设计一致 | 少条/容量不符 | 检查漏插、坏条 |
| `Speed/Configured Memory Speed` | 标称/训练后速度 | 接近平台支持上限 | 明显回退 | 查插法、混条、BIOS |
| `Locator` | 槽位位置 | 分布均衡 | 集中在一侧 | 重新按白皮书插条 |
| `CE/UE` | 纠错/不可纠错错误 | 0 或极少 CE | 持续增长或 UE | 更换 DIMM/CPU/主板 |

#### Pass / Fail 判断标准
**Pass：**
- 容量、通道、速率、ECC 均正常；
- 不存在持续性错误增长。

**Fail：**
- 插条不对称、速度回退、UE 出现；
- 同型号机器内存配置漂移。

#### 常见问题排查
1. **总容量正确但性能低**：常见原因是插法不满通道。
2. **偶发 CE**：需要观察是否固定落在某个槽位；固定槽位 CE 需重点关注。
3. **训练频率偏低**：检查是否混插不同颗粒、容量或 rank。


### 4.2 NUMA 本地 / 远端内存带宽与时延测试

| 项目 | 内容 |
|---|---|
| 测试名称 | NUMA 本地 / 远端内存带宽与时延测试 |
| 测试目的 | 验证内存子系统在不同 NUMA 节点上的带宽与访问代价，指导 CPU 绑核和内存绑址。 |
| 预期结果 | 本地内存带宽显著优于远端；同类节点结果一致；未出现异常尖峰时延。 |
| 工具 / 前提 | `sysbench`、`numactl`、可选 `stream`/业务自研 microbenchmark。 |

#### 步骤
1. 分别在本地内存绑定和跨 NUMA 绑定下测试内存吞吐与访问时延。
2. 记录 CPU 绑定节点、内存绑定节点、线程数、块大小和总数据量，确保结果可复现。
3. 对数据库和推理服务，必须把本地/远端差异写入优化建议，指导进程与 shard 绑核。

#### 完整命令
```bash
numactl --hardware
for NODE in 0 1; do
  echo "=== local node ${NODE} ==="
  numactl --cpunodebind=${NODE} --membind=${NODE}     sysbench memory --threads=32 --time=60 --memory-block-size=1M --memory-total-size=200G run
done

echo "=== remote access example ==="
numactl --cpunodebind=0 --membind=1   sysbench memory --threads=32 --time=60 --memory-block-size=1M --memory-total-size=200G run
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--cpunodebind` | 绑定运行 CPU 节点 | 隔离执行位置 | 与 `--membind` 配合使用 |
| `--membind` | 绑定内存节点 | 制造本地/远端对比 | NUMA 优化核心参数 |
| `--memory-block-size=1M` | 单次内存块大小 | 平衡系统调用与吞吐 | 可按业务特征调整 |
| `--memory-total-size=200G` | 总测试数据量 | 避免只打到缓存 | 应大于 LLC 若干倍 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `transferred MiB/sec` | 内存吞吐 | 本地高于远端 | 差异反常 | 检查 NUMA/绑核 |
| `total operations` | 完成次数 | 节点间稳定 | 差异过大 | 检查频率/背景噪声 |
| `execution time` | 执行时间 | 相近可重复 | 波动大 | 系统后台干扰或热降频 |
| `numactl --hardware` | NUMA 资源图 | 节点容量清晰 | 容量不均 | 重新查 DIMM 插法 |

#### Pass / Fail 判断标准
**Pass：**
- 本地访问明显优于远端；
- 各节点结果可重复。

**Fail：**
- 本地/远端无差别或结果倒挂；
- 节点间差异巨大。

#### 常见问题排查
1. **结果每次都不同**：检查后台进程、自动任务、IRQ 绑定。
2. **远端性能反而更好**：通常是绑核或绑内存没生效，或 NUMA 被 BIOS 屏蔽。


### 4.3 长时内存压力、内存泄漏与 RAS 观察

| 项目 | 内容 |
|---|---|
| 测试名称 | 长时内存压力、内存泄漏与 RAS 观察 |
| 测试目的 | 在高占用条件下验证内存稳定性、页回收行为、swap 策略、ECC 错误和长稳表现。 |
| 预期结果 | 长时占用 70%~90% 内存运行期间无 OOM、无 UE、无持续 CE、无系统卡死。 |
| 工具 / 前提 | `stress-ng`、`vmstat`、`free`、`rasdaemon`、`dmesg` 可用。 |

#### 步骤
1. 先确定系统不使用生产业务，避免把页面缓存、OOM 行为误解释为故障。
2. 以 70%~90% 可用内存作为压力范围，长时运行 2~8 小时。
3. 同时观察 swap、kswapd、OOM killer、page allocation failure、RAS/ECC 日志。

#### 完整命令
```bash
stress-ng --vm 8 --vm-bytes 80% --vm-method all --vm-keep -t 4h --metrics-brief   | tee /var/log/hwcert/stress/memory/stress_ng_vm_4h.log

for i in $(seq 1 240); do
  date | tee -a /var/log/hwcert/stress/memory/monitor.log
  free -h | tee -a /var/log/hwcert/stress/memory/monitor.log
  vmstat 1 5 | tee -a /var/log/hwcert/stress/memory/monitor.log
  journalctl -k -b | egrep -i 'oom|edac|ecc|mce|page allocation failure' | tail -n 20     | tee -a /var/log/hwcert/stress/memory/monitor.log
  sleep 60
done
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--vm 8` | 8 个内存工作线程 | 可按 NUMA/容量调大 | 线程过多会引入额外调度噪声 |
| `--vm-bytes 80%` | 使用 80% 内存 | 逼近压力但避免直接 OOM | 可根据环境调到 90% |
| `--vm-method all` | 轮换多种内存访问方式 | 覆盖更多模式 | 适合稳定性验证 |
| `--vm-keep` | 保持分配不释放 | 更容易暴露长稳问题 | 烧机建议开启 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `free` | 内存占用与 swap | 高占用但不异常 swap | swap 激增 | 看 swappiness 与内存压力 |
| `si/so` | swap in/out | 接近 0 | 持续不为 0 | 可能压过头或内存不足 |
| `OOM` | 内存耗尽 | 无 | 出现即失败 | 调整内存压测比例或检查泄漏 |
| `page allocation failure` | 页分配失败 | 无 | 出现 | 检查碎片化/hugepage/内核配置 |

#### Pass / Fail 判断标准
**Pass：**
- 长时高占用期间无 OOM/UE/系统卡死；
- RAS 统计稳定。

**Fail：**
- 出现 OOM、UE、持续 CE、内核页分配失败或卡死。

#### 常见问题排查
1. **系统开始 swap**：不一定是故障，但说明压力配置或系统策略不适合认证场景。
2. **只在某节点出错**：优先怀疑特定 DIMM/CPU 内存控制器。


### 4.4 CXL Type-3 内存扩展发现、region 配置与上线验证

| 项目 | 内容 |
|---|---|
| 测试名称 | CXL Type-3 内存扩展发现、region 配置与上线验证 |
| 测试目的 | 验证 CXL 内存设备能被 BIOS 和 OS 正确发现，并可以按规划建立 region/namespace 供系统使用。 |
| 预期结果 | OS 能枚举 CXL memdev、decoder、region；region 状态为 active；上线后容量与规划一致。 |
| 工具 / 前提 | 平台支持 CXL；Linux 内核与 `cxl`/`daxctl` 工具链齐备。 |

#### 步骤
1. 先确认 BIOS 已开启 CXL 支持，再进入 OS 检查。
2. 使用 `cxl list` 查看 memdev、port、decoder、region 等对象。
3. 根据平台规划创建或激活 region，并验证上线后的系统容量。
4. 所有 CXL 变更都必须记录到报告，因为它会改变内存层次和业务性能。

#### 完整命令
```bash
cxl list -M -m -d -p
cxl list -R
daxctl list
lsmem
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `cxl list -M -m -d -p` | 列出 machine/memdev/decoder/port | CXL 架构发现入口 | 排错必备 |
| `cxl list -R` | 列出 region | 关注 active/inactive | 上线验证关键 |
| `daxctl list` | 查看 dax 设备 | 判断 region 是否可被 OS 使用 | 与应用方式相关 |
| `lsmem` | 系统可见内存 | 最终确认容量是否已反映 | 给报告做最终证据 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `memdev` | CXL 内存设备 | 可见且数量正确 | 不可见 | 查 BIOS/硬件/驱动 |
| `region` | 资源区 | active | inactive/缺失 | 重新配置并激活 |
| `size` | 可用容量 | 与规划一致 | 偏小 | 检查 interleave/namespace 规划 |
| `target` | 映射目标 | 与设计一致 | 映射错误 | 重新核对拓扑和 decoder |

#### Pass / Fail 判断标准
**Pass：**
- CXL 设备可见、region active、系统容量反映正确。

**Fail：**
- BIOS 已开但 OS 完全看不到；
- region 反复 inactive 或上线不稳定。

#### 常见问题排查
1. **CXL 设备偶现消失**：优先看 BIOS/固件/retimer，而不是先怪应用。
2. **容量对了但性能差**：CXL 内存分层的时延特性必须单独测，不能等同本地 DDR5。


### 4.5 内存池化 / 共享内存资源验证（超节点 / 池化平台）

| 项目 | 内容 |
|---|---|
| 测试名称 | 内存池化 / 共享内存资源验证（超节点 / 池化平台） |
| 测试目的 | 验证内存池化平台能稳定提供共享内存资源，且在故障、回收、扩容场景中行为可控。 |
| 预期结果 | 池化资源可分配、可回收、可观测；性能与故障域符合平台设计。 |
| 工具 / 前提 | 适用于 TaiShan 950 超节点或类似池化架构；具备管理面。 |

#### 步骤
1. 在管理面查看内存池总量、可用量、分配对象与告警状态。
2. 选择一组测试实例申请池化内存，检查申请前后容量变化与映射关系。
3. 在释放、扩容、重启实例等动作后复核内存池状态是否准确回收。
4. 对数据库或缓存业务，应同时评估池化内存带来的时延影响。

#### 完整命令
```bash
echo "请使用平台管理面/API 导出内存池清单、分配记录与告警"
echo "建议采集字段：pool_id, total_gb, free_gb, allocated_to, health, alert_count"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `pool_id` | 内存池编号 | 便于唯一定位 | 池混淆会导致审计失败 | 必须纳入台账 |
| `total_gb/free_gb` | 总量/剩余量 | 动作前后变化准确 | 回收不及时 | 检查管理面刷新与后端状态 |
| `allocated_to` | 分配对象 | 与实例绑定准确 | 孤儿资源 | 做资源回收/清理 |
| `health` | 池健康状态 | OK | warning/error | 查底层节点和互联 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `free_gb` | 可用容量 | 与操作一致变化 | 不变或负值 | 管理面异常或释放失败 |
| `alert_count` | 告警计数 | 稳定 | 增长 | 查底层节点/链路/策略 |
| `mapping` | 分配映射 | 与实例一致 | 丢映射 | 重新同步管理面与实例状态 |
| `latency`（业务扩展） | 业务尾时延 | 在可接受范围 | 超 SLA | 重新分级使用本地内存/池化内存 |

#### Pass / Fail 判断标准
**Pass：**
- 池化内存可申请、可回收、可观测；
- 健康状态稳定且业务可接受。

**Fail：**
- 池化资源账实不符；
- 回收失败或告警增长未定位。

#### 常见问题排查
1. **池化功能正常但业务抖动**：这是典型的“功能通过、性能待评估”，必须单独标注。
2. **重启后池化映射丢失**：属于高危问题，禁止上线生产。



# 第5章 网络（含 RoCE + DPU offload）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证网口基础链路与速率。
2. 验证 TCP/UDP/Jumbo Frame 基础网络能力。
3. 验证 RoCE/RDMA 与 DPU offload。
4. 验证多机真实业务稳态。

## 本章风险点
1. 服务器与交换机配置不对称。
2. PFC/ECN 配置错误导致假性拥塞。
3. DPU 规则存在但未硬件卸载。
4. 多机业务下出现慢节点或 pause storm。

## 推荐测试时长
建议基础链路校验 30 分钟；RoCE/多机稳态 2~4 小时。

## 章节说明
网络测试要区分三个层次：
- 基础以太网是否正确；
- RoCE/RDMA 与 DPU 卸载是否真正生效；
- 真实业务并发时是否仍然稳定。

今天很多 AI 或分布式存储故障，本质并不是“带宽不够”，而是**优先级、PFC、ECN、队列、RSS、IRQ、NUMA 亲和**没有被成体系地验证。

### 5.1 网卡 / 交换端口基础发现与链路速率校验

| 项目 | 内容 |
|---|---|
| 测试名称 | 网卡 / 交换端口基础发现与链路速率校验 |
| 测试目的 | 确认每张 NIC/DPU 端口的驱动、固件、链路状态、协商速率、FEC 与队列能力正确。 |
| 预期结果 | 所有业务端口 Up；协商速率和宽度符合设计；无持续 error/drop；驱动固件与白名单一致。 |
| 工具 / 前提 | `ethtool`、`ip`、`devlink`、交换机端口信息可用。 |

#### 步骤
1. 列出所有业务网口，区分管理口、业务口、RoCE/IB 口、存储口。
2. 逐口查看链路速率、双工、驱动、固件、是否开启 pause/FEC/PFC 等关键能力。
3. 把服务器视角与交换机视角交叉核验，避免‘服务器显示 Up，交换机端已降速’的误判。
4. 对多网口服务器，必须写清楚端口与业务平面的映射关系。

#### 完整命令
```bash
ip -br link
for nic in $(ls /sys/class/net | grep -E 'eth|ens|eno|enp'); do
  echo "===== ${nic} ====="
  ethtool ${nic}
  ethtool -i ${nic}
  ethtool -S ${nic} | head -n 40
done
devlink dev show 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `ip -br link` | 简洁查看接口状态 | 快速识别 Up/Down | 现场排障最省时间 |
| `ethtool` | 查看链路速率与特性 | 基础验证入口 | 重点看 Speed/Duplex/Link detected |
| `ethtool -i` | 查看驱动与固件 | 版本冻结核心字段 | 混批 NIC 必查 |
| `ethtool -S` | 查看统计项 | 查 drop/error/flap | 不同驱动字段不同 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Speed` | 链路速率 | 25/50/100/200/400G（按设计） | 降速 | 查模块、线缆、交换机、FEC |
| `Link detected` | 链路状态 | yes | no/flap | 查物理链路与端口配置 |
| `driver/firmware-version` | 驱动/固件 | 与白名单一致 | 版本漂移 | 统一驱动包 |
| `rx_errors/tx_errors` | 错误计数 | 0 或稳定 | 增长 | 查模块、光纤、交换端口 |

#### Pass / Fail 判断标准
**Pass：**
- 端口速率与设计一致；
- 无明显错误计数增长；
- 服务器与交换机视角一致。

**Fail：**
- 端口降速、flap、驱动固件漂移、错误计数持续增长。

#### 常见问题排查
1. **单边看起来正常但吞吐很差**：必须查交换机端口 FEC/PFC/MTU。
2. **同批次有一台降速**：优先换光模块和线缆交叉验证。


### 5.2 TCP/UDP 吞吐、时延与 MTU/Jumbo Frame 验证

| 项目 | 内容 |
|---|---|
| 测试名称 | TCP/UDP 吞吐、时延与 MTU/Jumbo Frame 验证 |
| 测试目的 | 确认传统以太网业务面的基础网络性能满足预期，为存储、管理、服务网打底。 |
| 预期结果 | TCP/UDP 吞吐和时延稳定；MTU 与交换机一致；无大量重传或丢包。 |
| 工具 / 前提 | `iperf3`、`ping`、`sar`、交换机可见。 |

#### 步骤
1. 先校验双方 MTU、路由、RSS/队列基本一致。
2. 做单流、多流 TCP 测试，再做 UDP 压测和丢包观察。
3. 在大 MTU 场景下额外执行大包 ping，确认端到端 Jumbo Frame 真正生效。
4. 记录单向/双向、多流/少流结果，避免只凭一个数字下结论。

#### 完整命令
```bash
# server
iperf3 -s -D

# client
ping -M do -s 8972 10.0.0.2 -c 5
iperf3 -c 10.0.0.2 -t 60 -P 1
iperf3 -c 10.0.0.2 -t 60 -P 8
iperf3 -c 10.0.0.2 -u -b 50G -t 30
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `-M do -s 8972` | 验证 9000 MTU 路径 | 确认端到端大包不分片 | Jumbo Frame 场景关键 |
| `-P 1 / -P 8` | 单流/多流 | 区分协议栈瓶颈和线速能力 | 两种结果都要记录 |
| `-u -b` | UDP 指定带宽压测 | 观察丢包与 jitter | 不要直接压满生产网 |
| `-t 60` | 测试时长 | 建议至少 60 秒 | 时间太短容易受瞬时影响 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `sender/receiver bandwidth` | 发送/接收带宽 | 接近链路上限 | 偏低 | 看 MTU/RSS/队列/CPU |
| `retransmits` | TCP 重传 | 低 | 高 | 查丢包、拥塞、驱动 |
| `jitter` | UDP 抖动 | 稳定低值 | 高 | 查交换拥塞与队列 |
| `packet loss` | UDP 丢包 | 接近 0 | 高 | 检查速率设定与无损配置 |

#### Pass / Fail 判断标准
**Pass：**
- 吞吐达到设计预期；
- Jumbo Frame 正常；
- 重传和丢包可接受。

**Fail：**
- 大包不通、吞吐长期偏低、重传/丢包异常。

#### 常见问题排查
1. **多流正常单流偏低**：可能是单核瓶颈或 RSS 配置问题。
2. **Jumbo ping 不通**：查两端 MTU、交换机 trunk、VXLAN/overlay 头部开销。


### 5.3 RoCE/RDMA 无损网络与 DPU Offload 验证

| 项目 | 内容 |
|---|---|
| 测试名称 | RoCE/RDMA 无损网络与 DPU Offload 验证 |
| 测试目的 | 验证 RoCE 环境下的 PFC/ECN/优先级、RDMA 带宽/时延，以及 DPU / SmartNIC 的卸载效果。 |
| 预期结果 | RDMA 设备可见，带宽/时延稳定，无明显 pause storm 或 PFC 死锁；DPU offload 生效。 |
| 工具 / 前提 | `rdma`、`ibv_devinfo`、`ib_write_bw`/等效工具、`dcb`、`devlink`、可选 OVS/TC。 |

#### 步骤
1. 确认服务器和交换机已经按统一优先级开启 PFC/ECN，且 MTU 一致。
2. 执行 RDMA 设备发现与点对点带宽/时延测试。
3. 若使用 DPU/SmartNIC，检查 TC/OVS offload 规则是否真正下发到硬件。
4. 对高性能 AI 集群，至少保存一份网络拓扑与优先级配置快照。

#### 完整命令
```bash
rdma link show
ibv_devinfo 2>/dev/null || true
dcb pfc show dev eth0 2>/dev/null || true
dcb app show dev eth0 2>/dev/null || true
ib_write_bw -d mlx5_0 -F --report_gbits 2>/dev/null || true
devlink health show 2>/dev/null || true
tc -s filter show dev eth0 ingress 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `rdma link show` | 查看 RDMA 设备与状态 | RoCE 环境发现入口 | 先确认设备存在 |
| `dcb pfc show` | 查看 PFC 配置 | 无损网络关键项 | 优先级不一致会直接影响 RDMA |
| `ib_write_bw` | RDMA 带宽基准 | 验证点对点链路质量 | 具体参数可按链路速率调整 |
| `tc -s filter show` | 查看 offload 规则统计 | 判断 DPU/网卡卸载是否生效 | 只看控制面不够 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `state ACTIVE` | RDMA 设备状态 | ACTIVE | DOWN/INIT | 查驱动、固件、交换机 |
| `PFC priority` | 无损优先级 | 两端一致 | 不一致 | 统一 DCB 配置 |
| `Gbps` | RDMA 带宽 | 接近链路设计 | 偏低 | 查 MTU/PFC/ECN/CPU 绑定 |
| `in_hw` | OVS/TC 规则是否硬件卸载 | yes/in_hw | 仅软件命中 | 查 offload 配置和能力 |

#### Pass / Fail 判断标准
**Pass：**
- RDMA 设备与无损配置正确；
- 带宽/时延稳定；
- DPU/网卡卸载生效。

**Fail：**
- RDMA 不可用、PFC/ECN 配置混乱、offload 未生效或造成异常丢包。

#### 常见问题排查
1. **PFC 开了但性能更差**：重点检查是否出现 pause storm 或优先级映射错误。
2. **规则显示存在但不 `in_hw`**：说明根本没有硬件卸载，只是在软件平面转发。


### 5.4 多机 AI / 存储业务网络稳态测试

| 项目 | 内容 |
|---|---|
| 测试名称 | 多机 AI / 存储业务网络稳态测试 |
| 测试目的 | 验证在并行训练、分布式推理、存储复制等真实多流量场景下，网络是否稳定可复现。 |
| 预期结果 | 持续多流场景中，带宽、时延、丢包和 CPU 占用可控；交换机无明显拥塞告警。 |
| 工具 / 前提 | 至少 2~8 节点；具备 AI/存储典型流量；监控可用。 |

#### 步骤
1. 按照业务实际流向安排 east-west 与 north-south 同时存在的流量模型。
2. 记录服务器侧 CPU、网卡队列、软中断与交换机端拥塞指标。
3. 若发现某节点始终拖慢全局，要分别检查该节点 CPU 亲和、NIC 速率、光模块和交换机口。

#### 完整命令
```bash
sar -n DEV 1 60
mpstat -P ALL 1 60
cat /proc/softirqs | egrep 'NET_RX|NET_TX'
ethtool -S eth0 | egrep 'drop|error|timeout|pause'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `sar -n DEV` | 网络吞吐时间序列 | 观察稳态和尖峰 | 适合日报曲线 |
| `softirqs` | 网络软中断 | 判断 CPU 是否被网络栈打爆 | 高带宽场景很关键 |
| `pause` 计数 | 无损网络暂停帧 | 有但受控 | 异常高 | 查 PFC/拥塞 |
| `drop/error` | 丢包与错误 | 接近 0 | 增长 | 查链路/拥塞/队列 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `NET_RX/NET_TX` | 软中断负荷 | 分布均匀 | 集中在少数核 | 调 RSS/IRQ 绑定 |
| `pause` | 暂停帧 | 无或可解释 | 持续激增 | 查 PFC 死锁与拥塞树 |
| `BW variance` | 带宽方差 | 低 | 高 | 查交换机缓冲和路径不均 |
| `node outlier` | 异常慢节点 | 无 | 有 | 单独摘出重测 |

#### Pass / Fail 判断标准
**Pass：**
- 多机稳态无异常抖动；
- 无慢节点拖累；
- 网络与 CPU 占用均可解释。

**Fail：**
- 某节点长期成为瓶颈；
- 无损网络出现明显暂停风暴或拥塞异常。

#### 常见问题排查
1. **只有并行场景出问题**：单机 iperf 通过并不代表真实多机业务没问题。
2. **CPU 很高但网卡不满**：往往是 RSS/IRQ/NUMA 亲和问题。



# 第6章 存储（NVMe / SAS 等）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证盘的健康与资产映射。
2. 建立单盘/多盘性能基线。
3. 验证 TRIM/UNMAP、命名空间与掉盘恢复。

## 本章风险点
1. 固件混批。
2. 个别盘掉队拖慢整体。
3. 掉盘告警不完整。
4. 空间回收与 namespace 规划混乱。

## 推荐测试时长
建议基础健康检查 30 分钟；性能与恢复演练 2~4 小时。

## 章节说明
存储验证不能只看一个 FIO 数字。真正的交付级验证至少要回答三件事：
1. 盘是不是都在、都健康、固件是不是一致；
2. 单盘和盘组的性能有没有异常掉队；
3. 回收空间、掉盘恢复、命名空间管理是否清晰可控。

### 6.1 NVMe / SAS / SATA 盘清点与固件健康基线

| 项目 | 内容 |
|---|---|
| 测试名称 | NVMe / SAS / SATA 盘清点与固件健康基线 |
| 测试目的 | 确认所有盘的数量、型号、固件、命名空间、健康状态与物理槽位一致。 |
| 预期结果 | 无缺盘、无假盘、无陌生固件版本；SMART/NVMe 日志健康。 |
| 工具 / 前提 | `lsblk`、`nvme`、`smartctl`、`lsscsi` 可用。 |

#### 步骤
1. 列出所有块设备，区分系统盘、数据盘、cache 盘、boot 盘与外置 JBOD。
2. 读取 NVMe SMART 和 SAS/SATA SMART，重点关注温度、media errors、寿命、固件版本。
3. 将设备与物理槽位、序列号绑定，后续掉盘分析必须依靠这份映射。

#### 完整命令
```bash
lsblk -e7 -o NAME,MODEL,SERIAL,SIZE,ROTA,TYPE,MOUNTPOINT
nvme list 2>/dev/null || true
for d in $(nvme list 2>/dev/null | awk 'NR>2{print $1}'); do
  echo "===== $d ====="
  nvme smart-log $d
done
smartctl --scan
lsscsi
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `lsblk -e7` | 查看块设备总览 | 最适合做资产清单 | 排除 loop 等伪设备 |
| `nvme list` | 列出 NVMe 设备 | 包含序列号和固件 | NVMe 场景首选 |
| `nvme smart-log` | NVMe 健康信息 | 温度、错误、寿命核心来源 | 企业盘必跑 |
| `smartctl --scan` | 发现 SMART 设备 | 兼顾 SATA/SAS | 与 RAID/HBA 结合使用 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `temperature` | 盘温 | 在设计范围内 | 持续高温 | 查风道/盘位/负载 |
| `critical_warning` | 严重告警位 | 0 | 非 0 | 结合厂商手册判断是否退役 |
| `media_errors` | 介质错误 | 0 | 增长 | 做盘级替换和控制器检查 |
| `percentage_used` | 寿命消耗 | 合理 | 过高 | 评估是否已接近退役阈值 |

#### Pass / Fail 判断标准
**Pass：**
- 设备数量、固件、健康状态均正常。

**Fail：**
- 缺盘、介质错误增长、严重告警非 0、固件混批。

#### 常见问题排查
1. **盘都在但序列号不一致**：可能替换过盘，必须更新资产映射。
2. **同型号盘固件不同**：批量性能与稳定性可能漂移，建议统一。


### 6.2 单盘与多盘 FIO 基线（顺序 / 随机 / 混合）

| 项目 | 内容 |
|---|---|
| 测试名称 | 单盘与多盘 FIO 基线（顺序 / 随机 / 混合） |
| 测试目的 | 建立盘和盘组的 IOPS、吞吐、时延基线，验证是否存在单盘掉队或背板瓶颈。 |
| 预期结果 | 单盘和盘组成绩符合预期；时延分布稳定；无异常长尾。 |
| 工具 / 前提 | `fio`；测试目录可清空；生产环境严禁直接执行破坏性 workload。 |

#### 步骤
1. 在非生产、可擦写的测试卷上执行 FIO。
2. 先测单盘，再测多盘并发，比较是否线性扩展。
3. 同时记录设备温度和 PCIe 链路状态，防止把热降速误认为存储能力问题。

#### 完整命令
```bash
fio --name=randread4k --filename=/data/testfile --size=100G --rw=randread --bs=4k     --iodepth=64 --numjobs=8 --direct=1 --runtime=120 --time_based --group_reporting

fio --name=seqwrite1m --filename=/data/testfile --size=100G --rw=write --bs=1M     --iodepth=32 --numjobs=4 --direct=1 --runtime=120 --time_based --group_reporting
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--rw` | 读写模式 | 顺序/随机/混合 | 必须与业务场景对应 |
| `--bs` | 块大小 | 4k / 128k / 1M 等 | 决定 IOPS 与吞吐形态 |
| `--iodepth` | 队列深度 | 反映设备并行能力 | 太高会掩盖真实业务特征 |
| `--numjobs` | 并发 job 数 | 模拟线程/进程并发 | 配合 CPU/NUMA 一起调 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `IOPS` | 每秒 IO 次数 | 与盘型和 workload 匹配 | 明显偏低 | 查盘状态、PCIe、队列设置 |
| `BW` | 带宽 | 顺序场景接近设计 | 偏低 | 查背板/HBA/文件系统 |
| `clat` | 完成时延 | 稳定 | P99/P99.9 长尾 | 查 GC、后台任务、掉盘重试 |
| `util` | 设备利用率 | 高负载时可接近 100% | 低但性能差 | 查上层瓶颈 |

#### Pass / Fail 判断标准
**Pass：**
- 成绩与盘型相符；
- 单盘无明显掉队；
- 多盘扩展合理。

**Fail：**
- 个别盘显著落后；
- 长尾时延异常；
- 多盘不扩展。

#### 常见问题排查
1. **顺序吞吐低**：看文件系统挂载、CPU、RAID/HBA、NUMA。
2. **随机读很好但写很差**：检查写缓存策略、盘型、磨损与介质状态。


### 6.3 TRIM/UNMAP、命名空间与掉盘恢复验证

| 项目 | 内容 |
|---|---|
| 测试名称 | TRIM/UNMAP、命名空间与掉盘恢复验证 |
| 测试目的 | 确认 NVMe/SAS 设备在回收空间、命名空间管理和故障恢复方面行为正确。 |
| 预期结果 | TRIM/UNMAP 正常；命名空间操作受控；掉盘后系统能清晰告警并完成恢复流程。 |
| 工具 / 前提 | `fstrim`、`nvme list-ns`、`journalctl`、BMC 告警可用。 |

#### 步骤
1. 对 SSD 文件系统执行 TRIM/FSTRIM，观察完成时间和日志。
2. 如有命名空间规划，记录 namespace 列表和大小分配。
3. 在维护窗口可进行模拟掉盘或热插拔，检查 BMC 与 OS 告警以及恢复流程。

#### 完整命令
```bash
fstrim -av || true
for d in $(nvme list 2>/dev/null | awk 'NR>2{print $1}'); do
  echo "=== $d namespaces ==="
  nvme list-ns $d 2>/dev/null || true
done
journalctl -k -b | egrep -i 'nvme|scsi|i/o error|reset' | tail -n 100
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `fstrim -av` | 对所有挂载点执行 trim | 验证回收能力 | 企业 SSD 长期运行建议周期性执行 |
| `nvme list-ns` | 查看命名空间 | 多 namespace 场景必备 | 避免误用错误 ns |
| `journalctl ... nvme` | 查看块设备重置与错误 | 掉盘恢复定位主入口 | 结合 BMC 事件看 |
| `热插拔模拟` | 故障恢复演练 | 仅维护窗口允许 | 必须有回退方案 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `trimmed bytes` | 回收空间量 | 与预期接近 | 异常慢/失败 | 查文件系统和驱动支持 |
| `nsid` | 命名空间 ID | 清晰唯一 | 混乱 | 重做命名空间规划 |
| `I/O error/reset` | 设备错误/重置 | 无 | 出现 | 查固件/背板/供电 |
| `BMC event` | 硬件告警 | 与掉盘动作对应 | 无告警 | 查 BMC 传感映射 |

#### Pass / Fail 判断标准
**Pass：**
- TRIM/UNMAP 与 namespace 管理正常；
- 故障恢复路径清晰。

**Fail：**
- 回收失败、掉盘无告警或恢复不完整。

#### 常见问题排查
1. **文件系统支持 TRIM 但很慢**：说明后端盘或控制器处理效率差，需要单独评估。
2. **OS 看到 reset 但 BMC 无告警**：板级和 OS 证据链未打通，需补做映射。



# 第7章 RAID（硬件 / 软件，全级别）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证硬件 RAID 控制器、缓存与保护状态。
2. 验证常见 RAID 级别创建与性能。
3. 验证软件 RAID 的重建和一致性。

## 本章风险点
1. 写缓存策略与断电保护不匹配。
2. 阵列重建流程未演练。
3. 软件 RAID 开机自动装配缺失。

## 推荐测试时长
建议功能验证 1~2 小时；重建与一致性按容量另计。

## 章节说明
RAID 测试的重点不是“会不会建”，而是“策略对不对、重建稳不稳、断电保护有没有、性能解释是否成立”。
在交付中，很多存储事故来自缓存策略与保护状态不匹配，或者重建流程没有提前演练。

### 7.1 硬件 RAID 控制器识别与缓存策略验证

| 项目 | 内容 |
|---|---|
| 测试名称 | 硬件 RAID 控制器识别与缓存策略验证 |
| 测试目的 | 确认 RAID 控制器型号、固件、缓存策略、电池/超级电容状态正确。 |
| 预期结果 | 控制器健康；写缓存策略符合项目要求；电池/缓存保护正常。 |
| 工具 / 前提 | 已安装 `storcli/perccli/ssacli/arcconf` 中的对应工具；若无则用 `lspci` + BMC 辅助。 |

#### 步骤
1. 识别 RAID/HBA 控制器型号和固件版本。
2. 检查写缓存策略（WT/WB）、读缓存、回写保护、电池/超级电容状态。
3. 若策略与项目不符，必须调整并记录性能变化。

#### 完整命令
```bash
lspci | egrep -i 'RAID|SAS|Serial Attached SCSI'
storcli /call show all 2>/dev/null || true
perccli /call show all 2>/dev/null || true
ssacli ctrl all show config 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `storcli/perccli/ssacli` | 不同厂商 RAID 工具 | 获取控制器与虚拟盘详情 | 按实际控制器选择 |
| `WB/WT` | 写缓存策略 | 决定性能与安全折中 | 断电保护不足时要谨慎 |
| `BBU/CacheVault` | 缓存保护状态 | 无保护时禁止盲目 WB | 报告必须写明 |
| `firmware version` | 控制器固件 | 冻结核心字段 | 避免混批 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Controller Status` | 控制器健康 | Optimal | Degraded/Failed | 先修控制器再测 |
| `Cache Policy` | 缓存策略 | 符合设计 | 策略错误 | 按场景调整 |
| `BBU status` | 电池/超级电容状态 | Healthy | Missing/Failed | 禁止高风险策略 |
| `VD/PD state` | 虚拟盘/物理盘状态 | Online | Offline/UGood | 检查盘与阵列状态 |

#### Pass / Fail 判断标准
**Pass：**
- 控制器、缓存、保护状态正常；
- 策略与项目一致。

**Fail：**
- 控制器或缓存保护异常；
- 策略与验收预期不符。

#### 常见问题排查
1. **控制器很健康但性能低**：很多时候是缓存策略没开对。
2. **BBU 异常**：必须重新评估是否允许继续做破坏性性能测试。


### 7.2 RAID0/1/5/6/10 创建、初始化与性能验证

| 项目 | 内容 |
|---|---|
| 测试名称 | RAID0/1/5/6/10 创建、初始化与性能验证 |
| 测试目的 | 验证常见 RAID 级别的创建流程、初始化行为、容量、容错与性能是否正确。 |
| 预期结果 | RAID 组可正常创建、初始化、挂载并通过基本性能验证；与设计容量和冗余模型一致。 |
| 工具 / 前提 | 测试环境允许重建/清空；对生产盘禁止执行。 |

#### 步骤
1. 根据项目选择 RAID 级别，记录成员盘、条带大小、缓存策略和初始化方式。
2. 初始化完成后创建文件系统并做基础 FIO。
3. 验证容量计算、成员状态与容错行为是否符合预期。

#### 完整命令
```bash
echo "请使用对应 RAID CLI 创建阵列，并记录：level, strip size, members, policy"
lsblk
mkfs.xfs -f /dev/mapper/test_vd
mount /dev/mapper/test_vd /mnt
fio --name=raidtest --filename=/mnt/testfile --size=50G --rw=randrw --rwmixread=70     --bs=128k --iodepth=32 --numjobs=8 --direct=1 --runtime=120 --time_based --group_reporting
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `level` | RAID 级别 | 决定容量与容错 | 报告必须写清楚 |
| `strip size` | 条带大小 | 影响顺序/随机性能 | 要与业务模式匹配 |
| `mkfs.xfs` | 创建文件系统 | 验证阵列可用 | 示例仅限测试环境 |
| `fio randrw` | 混合读写测试 | 较接近通用业务 | 可按实际场景改写 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `size` | 可用容量 | 符合 RAID 计算 | 容量异常 | 检查成员盘与对齐 |
| `state` | 阵列状态 | Optimal | Degraded/Rebuild | 等待初始化或检查故障盘 |
| `IOPS/BW` | 性能 | 与级别和盘数相符 | 明显偏低 | 查缓存策略、控制器、成员盘 |
| `rebuild` | 重建状态 | 按预期 | 卡住 | 检查坏盘和控制器日志 |

#### Pass / Fail 判断标准
**Pass：**
- RAID 创建成功；
- 容量、容错与性能符合设计。

**Fail：**
- 阵列状态异常或性能与级别不符。

#### 常见问题排查
1. **RAID5/6 顺序写差**：先看缓存和初始化状态。
2. **重建期间性能暴跌**：属于正常现象，但要写进验收说明。


### 7.3 软件 RAID（mdadm）创建、重建与一致性校验

| 项目 | 内容 |
|---|---|
| 测试名称 | 软件 RAID（mdadm）创建、重建与一致性校验 |
| 测试目的 | 验证 Linux 软件 RAID 在通用服务器上的功能、重建和一致性。 |
| 预期结果 | md 设备可正常创建、重建、开机自动装配且一致性校验通过。 |
| 工具 / 前提 | `mdadm` 可用；测试盘可清空。 |

#### 步骤
1. 创建 md 设备并写入 `mdadm.conf`，确保重启后可自动装配。
2. 执行一致性检查与模拟成员盘失效，验证重建流程。
3. 对软件 RAID 结果，同样要记录条带大小、bitmap、元数据版本。

#### 完整命令
```bash
mdadm --create /dev/md0 --level=10 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde
watch -n 5 cat /proc/mdstat
mdadm --detail /dev/md0
echo check > /sys/block/md0/md/sync_action
cat /proc/mdstat
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--level=10` | RAID 级别 | 示例为 RAID10 | 也可按需改为 1/5/6 |
| `watch cat /proc/mdstat` | 观察同步/重建进度 | 软件 RAID 最直接状态源 | 排障常用 |
| `mdadm --detail` | 查看设备详情 | 确认成员与策略 | 写报告必备 |
| `sync_action=check` | 一致性检查 | 验证阵列一致性 | 仅在维护窗口做 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `State` | 阵列状态 | clean/active | degraded | 查成员盘 |
| `Rebuild Status` | 重建状态 | 递增到完成 | 卡住 | 查盘错误与系统日志 |
| `Mismatch cnt` | 一致性偏差 | 0 或可解释 | 持续增长 | 检查硬件与缓存 |
| `UUID` | 阵列唯一标识 | 固定 | 变化 | 检查是否误重建 |

#### Pass / Fail 判断标准
**Pass：**
- 软件 RAID 可创建、可重建、可开机恢复。

**Fail：**
- 阵列状态不稳定或一致性检查失败。

#### 常见问题排查
1. **重启后阵列没自动起来**：检查 `mdadm.conf`、initramfs。
2. **一致性检查 mismatch 高**：查盘、内存和缓存策略。



# 第8章 电源 / PSU + 散热 / 温度监控

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 PSU 冗余与空载功耗基线。
2. 验证热浸泡稳定性。
3. 验证满载和混合载荷功耗。

## 本章风险点
1. A/B 路接线错误导致假冗余。
2. 热浸泡后出现降频或掉卡。
3. 混合载荷触发峰值掉电。

## 推荐测试时长
建议基础检查 30 分钟；热浸泡与满载功耗 2~8 小时。

## 章节说明
电源与散热是所有长期稳定性的底座。很多 CPU/GPU/NPU “莫名其妙”的错误，本质上是 PSU 冗余、瞬时功耗或热设计问题。
本章的目标不是只看一个温度值，而是把**冗余、热稳态、峰值功率与封顶行为**说清楚。

### 8.1 PSU 冗余、输入状态与功耗基线验证

| 项目 | 内容 |
|---|---|
| 测试名称 | PSU 冗余、输入状态与功耗基线验证 |
| 测试目的 | 确认双电源或多电源冗余正常，输入相位、PDU 路径和待机/空载功耗清晰可审计。 |
| 预期结果 | PSU 全部 Present/Healthy；A/B 路供电清晰；空载功耗在合理区间。 |
| 工具 / 前提 | `ipmitool`、BMC 电源页、机架功耗计（推荐）。 |

#### 步骤
1. 读取 BMC 电源页和传感器，确认 PSU 数量、输入状态、功率读数。
2. 在 A/B 双路环境下，逐路确认供电路径，必要时做受控单路演练。
3. 记录待机、开机空载、系统空闲、压力前的功耗基线。

#### 完整命令
```bash
ipmitool sdr elist all | egrep -i 'PSU|power|input|output'
ipmitool dcmi power reading 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `sdr` | 读取 PSU/功率传感器 | 板级功耗基线入口 | 不同机型字段不同 |
| `dcmi power reading` | DCMI 功耗读取 | 适合连续记录 | 并非所有平台都支持 |
| `Present/Healthy` | PSU 存在且健康 | 冗余放行前必须确认 | A/B 路都要查 |
| `空载功耗` | 系统基线功耗 | 后续所有功耗测试的起点 | 需固定风扇/环境温度 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Power Reading` | 实时功率 | 稳定 | 抖动大 | 查负载与传感器刷新 |
| `PSU Status` | 电源状态 | OK | Failed/Missing | 立即修复 |
| `Input Lost` | 输入丢失 | 无 | 出现 | 查 PDU/线缆 |
| `Redundancy` | 冗余状态 | Full | Lost | 禁止继续烧机 |

#### Pass / Fail 判断标准
**Pass：**
- 冗余完整；
- 功耗基线清楚；
- 传感器无异常。

**Fail：**
- 任一路 PSU 异常或冗余丢失。

#### 常见问题排查
1. **空载功耗偏高**：先看 BIOS 电源策略、风扇策略和额外设备。
2. **PSU 都在但冗余丢失**：可能两只接到了同一路 PDU。


### 8.2 温度、风扇与热浸泡（Thermal Soak）验证

| 项目 | 内容 |
|---|---|
| 测试名称 | 温度、风扇与热浸泡（Thermal Soak）验证 |
| 测试目的 | 确认服务器在长时负载下散热充足，无持续过温、风扇异常和热降频。 |
| 预期结果 | 长时间压力下温度达到稳态后不越限；风扇策略正常；无器件热失效。 |
| 工具 / 前提 | `sensors`、`ipmitool sdr`、`nvidia-smi`/`rocm-smi`/`npu-smi`。 |

#### 步骤
1. 在目标典型负载下持续运行 2~8 小时，记录 CPU、内存、SSD、GPU/NPU 和进风/出风温度。
2. 观察风扇转速是否随负载合理变化；若风扇迟滞过大，需要厂商优化策略。
3. 在液冷平台上还要记录入口/出口水温与流量告警。

#### 完整命令
```bash
watch -n 30 '
date;
sensors 2>/dev/null | head -n 50;
ipmitool sdr elist all | egrep -i "temp|fan" | head -n 80;
nvidia-smi --query-gpu=index,temperature.gpu,power.draw,clocks.current.graphics --format=csv,noheader 2>/dev/null;
rocm-smi --showtemp --showpower --showclk 2>/dev/null;
npu-smi info watch -d 5 -s pta 2>/dev/null;
'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `sensors` | OS 侧温度与风扇 | 快速查看主板/CPU 温度 | 字段因平台而异 |
| `ipmitool sdr` | 板级温度与风扇 | 比带内更完整 | 报告应两侧互证 |
| `temperature.gpu / AICore temp` | 加速器温度 | AI 服务器关键 | 持续越限需停测 |
| `watch -n 30` | 每 30 秒采样 | 适合热浸泡曲线 | 可改为写入文件 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Temp` | 温度 | 进入稳态且不越限 | 持续升高 | 查风道/环境温度/功耗 |
| `Fan RPM` | 风扇转速 | 负载增加时同步升高 | 异常低/固定 | 查风扇策略或模块故障 |
| `clock` | 频率 | 稳态保持 | 随温度掉频 | 热降频 |
| `liquid alarm`（扩展） | 液冷告警 | 无 | 出现 | 立即检查管路 |

#### Pass / Fail 判断标准
**Pass：**
- 热浸泡期间温度可控，无热降频。

**Fail：**
- 温度持续越限、风扇异常、加速器掉频。

#### 常见问题排查
1. **机房冷但设备仍过热**：常见于风道堵塞、线缆遮挡、风扇策略不当。
2. **只有顶部卡过热**：需看机箱布局和相邻卡间距。


### 8.3 满载功耗、功率封顶与稳定性验证

| 项目 | 内容 |
|---|---|
| 测试名称 | 满载功耗、功率封顶与稳定性验证 |
| 测试目的 | 验证平台在满载和混合载荷下的总功耗、峰值功耗、功率封顶行为和稳定性。 |
| 预期结果 | 功耗曲线可解释；不触发意外功率保护；封顶策略生效且不导致异常。 |
| 工具 / 前提 | CPU/GPU/NPU/存储混合负载工具可用；建议有机架级功率计。 |

#### 步骤
1. 分别做 CPU-only、GPU/NPU-only、混合载荷三种功耗测试。
2. 记录峰值、平均值和波动范围，必要时开启 power cap 观察行为。
3. 多加速器平台要特别关注上电峰值和瞬时波动。

#### 完整命令
```bash
echo "CPU burn -> power"
echo "GPU/NPU burn -> power"
ipmitool dcmi power reading 2>/dev/null || true
nvidia-smi --query-gpu=power.draw,power.limit --format=csv 2>/dev/null || true
rocm-smi --showpower --showmaxpower 2>/dev/null || true
npu-smi info watch -d 5 -s p 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `power.draw` | 实时功耗 | 看峰值与平均值 | AI 服务器关键 |
| `power.limit` | 功率上限 | 判断是否被 cap | 与 BIOS/BMC 配合 |
| `dcmi power` | 整机功率 | 主机总功耗主依据 | 刷新率较低需注意 |
| `混合载荷` | CPU+GPU/NPU+存储 | 最接近真实上限 | 验收不能只测单载荷 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Peak Power` | 峰值功耗 | 在 PSU 额定余量内 | 逼近或超过 | 重新评估 PSU/N+N |
| `Average Power` | 平均功耗 | 可纳入机架预算 | 异常高 | 查 BIOS/风扇/负载 |
| `Power Cap Hit` | 命中功率封顶 | 按设计 | 意外命中 | 调整 cap 或散热 |
| `Stability` | 稳定性 | 无掉电/重启 | 掉电 | 查 PSU/PDU/机房供电 |

#### Pass / Fail 判断标准
**Pass：**
- 功率曲线与设计一致；
- 无意外掉电或重启；
- 可形成机架级容量预算。

**Fail：**
- 峰值超出预算或出现保护动作。

#### 常见问题排查
1. **机架功率计与 BMC 数字不一致**：以机架计为最终容量规划依据，BMC 用于趋势观察。
2. **只在混合载荷掉电**：说明预算不能按单项峰值简单相加。



# 第9章 PCIe / 扩展槽 / 兼容性

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证设备枚举与链路状态。
2. 验证 AER 与日志关联。
3. 验证大 BAR、热插拔与变更回归。

## 本章风险点
1. 链路降宽降速被忽略。
2. AER 错误长期存在但无人跟踪。
3. 大 BAR 变更后没有做回归。

## 推荐测试时长
建议基础校验 30 分钟；兼容性变更回归 1~2 小时。

## 章节说明
PCIe 是现代服务器的“高速地基”。GPU/NPU/DPU/NVMe/NIC 的很多问题最终都会落到 PCIe：链路是否满宽、AER 是否增长、BAR 是否足够、热插拔是否稳。
本章要求工程师把“看得见设备”提升到“看得懂链路状态和错误信号”。

### 9.1 PCIe 设备枚举、链路代际与宽度验证

| 项目 | 内容 |
|---|---|
| 测试名称 | PCIe 设备枚举、链路代际与宽度验证 |
| 测试目的 | 确认所有 PCIe 设备都被正确枚举，且当前链路速率/宽度符合设计。 |
| 预期结果 | 无少卡、无降宽、无意外回落到低代际。 |
| 工具 / 前提 | `lspci -vv`、`dmidecode`、BMC 槽位图（如有）。 |

#### 步骤
1. 列出所有关键 PCIe 设备：GPU、NPU、DPU、NIC、HBA、NVMe。
2. 检查 `LnkCap` 与 `LnkSta`，核对当前代际和宽度。
3. 对出现 x16->x8、Gen5->Gen4/3 的设备，立即定位是插槽、电源、retimer 还是固件问题。

#### 完整命令
```bash
lspci -nn
lspci -vv | egrep -i 'LnkCap:|LnkSta:|AER|ACS|ARI|AtomicOps'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `LnkCap` | 链路能力 | 理论上限 | 看平台设计值 |
| `LnkSta` | 当前链路状态 | 真实在用状态 | 性能问题优先看这里 |
| `ACS/ARI/AtomicOps` | 高级 PCIe 能力 | 虚拟化/加速器场景常用 | 依项目判定 |
| `AER` | 高级错误报告能力 | 排障关键 | 需结合内核日志看 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Speed` | 当前代际 | Gen4/Gen5 | 降级 | 查固件、线缆、retimer、兼容性 |
| `Width` | 当前宽度 | x16/x8 | 降宽 | 查插卡与插槽 |
| `Device count` | 设备总数 | 与设计一致 | 少卡 | 先查 BIOS 资源 |
| `AER capability` | 错误上报能力 | 存在 | 缺失或异常 | 依平台进一步检查 |

#### Pass / Fail 判断标准
**Pass：**
- 设备数正确；
- 链路状态符合设计；
- 无明显降配。

**Fail：**
- 少卡、降宽、降速且无合理解释。

#### 常见问题排查
1. **设备全在但成绩差**：十有八九是 `LnkSta` 降配。
2. **只有热了以后降速**：查 retimer、供电与散热。


### 9.2 PCIe AER / 错误计数与系统日志关联验证

| 项目 | 内容 |
|---|---|
| 测试名称 | PCIe AER / 错误计数与系统日志关联验证 |
| 测试目的 | 发现并定位 PCIe Correctable / Non-Fatal / Fatal 错误，避免隐性链路缺陷进入生产。 |
| 预期结果 | 长期运行中无新增 Fatal/Non-Fatal；可纠正错误也处于受控范围。 |
| 工具 / 前提 | `journalctl`、`dmesg`、`lspci -vv`。 |

#### 步骤
1. 在空载和压测后各检查一次 AER 相关日志，做前后对比。
2. 若出现 Fatal/Non-Fatal，立即关联到具体槽位和设备，并做交叉换卡/换槽验证。
3. 对 Correctable Error 也不能完全忽略，若持续增长，通常意味着边缘兼容性问题。

#### 完整命令
```bash
journalctl -k -b | egrep -i 'pcie|aer|dpc|fatal|non-fatal|corrected' | tail -n 100
dmesg -T | egrep -i 'pcie|aer|dpc|fatal|non-fatal|corrected' | tail -n 100
lspci -vv | egrep -i 'AER|CESta|UESta'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `CESta` | 可纠正错误状态 | 观察是否增长 | 多了不一定立刻停机，但必须跟踪 |
| `UESta` | 不可纠正错误状态 | 高风险 | 通常应判故障 |
| `DPC` | Downstream Port Containment | 端口错误隔离相关 | 有助定位链路级问题 |
| `journalctl/dmesg` | 系统日志 | 用于建立时间关联 | 必须保留原始日志 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Corrected` | 可纠正错误 | 低且稳定 | 持续增长 | 查信号完整性/兼容性 |
| `Non-Fatal` | 不可忽略错误 | 无 | 出现 | 定位设备与槽位 |
| `Fatal` | 致命错误 | 无 | 出现即失败 | 停测并抓现场 |
| `timestamp` | 错误时间 | 可对齐到负载动作 | 无法关联 | 加强监控采样 |

#### Pass / Fail 判断标准
**Pass：**
- 无 Fatal/Non-Fatal；
- Corrected Error 无持续增长。

**Fail：**
- 出现任何 Fatal/Non-Fatal；
- CE 快速增长且无法解释。

#### 常见问题排查
1. **只在满载下报 AER**：多半是边缘电气问题，不是软件问题。
2. **换卡问题跟着卡走**：优先怀疑设备；跟着槽位走则怀疑主板/retimer/背板。


### 9.3 Above 4G、Resizable BAR、热插拔与兼容性回归

| 项目 | 内容 |
|---|---|
| 测试名称 | Above 4G、Resizable BAR、热插拔与兼容性回归 |
| 测试目的 | 确认多加速器平台在大 BAR、热插拔和兼容性变化后仍可正常工作。 |
| 预期结果 | 设备可完整枚举；热插拔/重扫后系统稳定；大 BAR 功能不造成启动或兼容问题。 |
| 工具 / 前提 | 维护窗口；支持热插拔的平台；已做 BIOS 变更快照。 |

#### 步骤
1. 变更 Above 4G/Resizable BAR 后做一次完整枚举回归。
2. 如平台支持，执行受控热插拔或总线重扫测试。
3. 对每次兼容性变更后都要重复枚举、驱动和性能三步回归。

#### 完整命令
```bash
echo 1 > /sys/bus/pci/rescan
lspci | egrep -i 'NVIDIA|AMD|Ascend|Ethernet|RAID'
lspci -vv | egrep -i 'BAR|Region|LnkSta'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `/sys/bus/pci/rescan` | 重新扫描 PCIe 总线 | 验证设备重枚举 | 不等同真正热插拔 |
| `BAR/Region` | 资源窗口 | 大 BAR 兼容性重点 | 要与 BIOS 一起看 |
| `兼容性回归` | 变更后的最小验证集 | 必须包含枚举+驱动+性能 | 不能只看系统起得来 |
| `维护窗口` | 操作约束 | 热插拔类测试必须受控 | 防止误伤业务 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `rescan result` | 重扫结果 | 设备仍完整 | 丢失设备 | 查固件/硬件 |
| `BAR assigned` | BAR 分配状态 | 成功 | 失败 | 调 BIOS/减少设备/升级固件 |
| `driver attach` | 驱动绑定 | 成功 | 未绑定 | 查驱动与 udev |
| `post-change perf` | 变更后性能 | 与基线一致或可解释 | 下降 | 做 A/B 对比 |

#### Pass / Fail 判断标准
**Pass：**
- 大 BAR/重扫/热插拔后平台稳定。

**Fail：**
- 变更后掉卡、驱动绑不上或性能显著下降。

#### 常见问题排查
1. **重扫后设备顺序变化**：不要依赖设备枚举顺序，统一用 BusId/Serial。
2. **开启 Resizable BAR 后个别卡异常**：看厂商支持矩阵，不要强行全开。



# 第10章 GPU（NVIDIA B200 / GB200 / H200 + AMD MI325X + Ascend 补充）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 NVIDIA/AMD GPU 基线与拓扑。
2. 验证长时烧机与健康诊断。
3. 验证 MIG/切分/拓扑能力。
4. 验证多厂商混插。

## 本章风险点
1. 少卡、掉卡、拓扑不对称。
2. 长时烧机后出现 Xid/ECC/RAS。
3. MIG 配置正确但业务时延恶化。
4. 多厂商混插发生 BAR/功耗/热冲突。

## 推荐测试时长
建议基础盘点 30 分钟；烧机 0.5~8 小时；混插回归 2~4 小时。

## 章节说明
GPU 章节不仅要验证“卡在不在”，更要验证：
- 拓扑对不对；
- 负载下稳不稳；
- 多实例切分可不可用；
- 多厂商混插会不会互相影响。

对 H200/B200/GB200 这类 AI 工厂平台，以及 MI325X 这种大显存 GPU，光看短时间 benchmark 毫无意义，必须把**拓扑、功耗、温度、错误日志和业务级回归**串起来。

### 10.1 NVIDIA GPU 盘点、驱动与拓扑验证（H200 / B200 / GB200 节点）

| 项目 | 内容 |
|---|---|
| 测试名称 | NVIDIA GPU 盘点、驱动与拓扑验证（H200 / B200 / GB200 节点） |
| 测试目的 | 确认 NVIDIA GPU 数量、型号、驱动、HBM、拓扑和 NVLink/NVSwitch 关系符合设计。 |
| 预期结果 | 设备枚举完整；驱动版本统一；拓扑矩阵与整机设计一致；无掉卡。 |
| 工具 / 前提 | `nvidia-smi`、`dcgmi`、`nvidia-smi topo -m`。 |

#### 步骤
1. 用 `nvidia-smi -L` 确认 GPU 数量和型号，用 `nvidia-smi -q` 看驱动、功耗上限和 HBM 基本信息。
2. 执行 `nvidia-smi topo -m`，确认 GPU 间拓扑、CPU 亲和与 NIC/GPU 关系。
3. 对 HGX/B200/GB200 类平台，还要确认 NVLink/NVSwitch 域是否与设计一致。

#### 完整命令
```bash
nvidia-smi -L
nvidia-smi -q
nvidia-smi topo -m
dcgmi discovery -l 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `-L` | 列出 GPU 列表 | 验证数量和型号 | 最先执行 |
| `-q` | 详细属性 | 驱动、功耗、温度、ECC、功率上限 | 形成基线 |
| `topo -m` | 拓扑矩阵 | 看 GPU-GPU / GPU-NIC / CPU 亲和 | AI 服务器核心证据 |
| `dcgmi discovery -l` | DCGM 发现 | 管理侧再确认一遍设备 | 适合后续监控接入 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Product Name` | GPU 型号 | H200/B200 等与设计一致 | 混入其他型号 | 查整机批次 |
| `FB Memory Usage` | 显存信息 | 容量与型号相符 | 明显不足 | 查配置/MIG |
| `GPU UUID/Bus Id` | 唯一标识/总线号 | 完整且唯一 | 缺失 | 查掉卡 |
| `topo matrix` | 拓扑关系 | 与机型设计一致 | 不对称 | 查 NVLink/NVSwitch/插槽 |

#### Pass / Fail 判断标准
**Pass：**
- 枚举、驱动、拓扑全部正确；
- 多卡无不对称掉队。

**Fail：**
- 少卡、拓扑异常、驱动版本漂移。

#### 常见问题排查
1. **GPU 都在但拓扑不对称**：先看机型设计，再查 NVSwitch/NVLink 与主板连接。
2. **同一机型拓扑矩阵不同**：往往是硬件批次或固件问题。


### 10.2 NVIDIA 健康诊断与长时烧机（DCGM + gpu-burn）

| 项目 | 内容 |
|---|---|
| 测试名称 | NVIDIA 健康诊断与长时烧机（DCGM + gpu-burn） |
| 测试目的 | 在高负载下验证 GPU 温度、功耗、ECC、Xid、链路稳定性和长时可靠性。 |
| 预期结果 | 长时压力无 Xid、无掉卡、无异常 ECC 增长，功耗与温度稳定。 |
| 工具 / 前提 | `dcgmi`、`gpu-burn`、`nvidia-smi`。 |

#### 步骤
1. 先执行 DCGM 基础健康检查，再做 30~120 分钟 gpu-burn。
2. 全程监控温度、功耗、SM 利用率、ECC、Xid 与时钟频率。
3. 若是液冷或 GB200 类机架级平台，要同步记录机架级温度与功耗。

#### 完整命令
```bash
dcgmi health -c
dcgmi diag -r 4 || true
/opt/lab/scripts/gpu-burn/gpu_burn 1800 2>&1 | tee /var/log/hwcert/stress/gpu/gpu_burn_1800s.log

watch -n 10 '
nvidia-smi --query-gpu=index,name,temperature.gpu,power.draw,utilization.gpu,clocks.current.graphics,ecc.errors.uncorrected.aggregate.total   --format=csv,noheader;
journalctl -k -b | egrep -i "NVRM|Xid" | tail -n 20;
'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `dcgmi health -c` | 查看健康配置/状态 | 进入长稳前的基础检查 | 快速发现问题卡 |
| `dcgmi diag -r 4` | 较完整诊断 | 适合作为准入筛选 | 时间较长 |
| `gpu_burn 1800` | 烧机 1800 秒 | 高强度稳定性验证 | 可按验收标准延长 |
| `ecc.errors...` | 聚合不可纠错 ECC | 必须为 0 | 一旦增长即高风险 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `temperature.gpu` | GPU 温度 | 稳态不过上限 | 持续攀升 | 查散热 |
| `power.draw` | 功耗 | 与负载匹配 | 异常抖动 | 查电源/功率封顶 |
| `utilization.gpu` | 利用率 | 高且稳定 | 忽高忽低 | 查负载与热 |
| `Xid` | 驱动错误 | 无 | 出现即重点排查 | 抓日志与快照 |

#### Pass / Fail 判断标准
**Pass：**
- 长稳期间无 Xid/ECC/掉卡；
- 温度功耗稳定。

**Fail：**
- 任何 Xid、不可纠错 ECC、掉卡或异常 reset。

#### 常见问题排查
1. **gpu-burn 一直不过**：先看散热，再看电源与驱动/固件版本。
2. **DCGM 正常但业务报错**：继续做 TensorRT/vLLM 业务级验证。


### 10.3 MIG、NVLink/NVSwitch 与多实例资源切分验证

| 项目 | 内容 |
|---|---|
| 测试名称 | MIG、NVLink/NVSwitch 与多实例资源切分验证 |
| 测试目的 | 验证 MIG 切分、NVLink 域和多租场景下的资源隔离与拓扑正确性。 |
| 预期结果 | MIG 配置与租户规划一致；切分前后资源统计正确；NVLink/NVSwitch 正常。 |
| 工具 / 前提 | 支持 MIG 的 NVIDIA 平台；有多租或切分需求。 |

#### 步骤
1. 读取当前 MIG 能力和实例模板，确认是否满足租户需求。
2. 创建目标切分配置后，再次检查显存、SM、实例数与设备文件。
3. 对多实例部署的推理场景，建议结合业务做 P50/P99 时延回归。

#### 完整命令
```bash
nvidia-smi mig -lgip 2>/dev/null || true
nvidia-smi mig -lgi 2>/dev/null || true
nvidia-smi topo -m
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `mig -lgip` | GPU 实例 profile 列表 | 决定可切分规格 | MIG 平台专用 |
| `mig -lgi` | 当前实例 | 校验租户分配 | 变更后必须复核 |
| `topo -m` | 切分前后拓扑参考 | 看资源是否仍符合预期 | 多卡场景必要 |
| `业务回归` | 切分后的时延吞吐 | 避免只验证功能不验证效果 | 最好纳入验收 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `GI/CI count` | 实例数量 | 与规划一致 | 多/少 | 重新配置 MIG |
| `FB Memory` | 实例显存 | 符合 profile | 不足 | 切分规格不对 |
| `Isolation` | 资源隔离 | 互不干扰 | 互相抢占 | 查调度策略 |
| `Latency` | 业务时延 | 可接受 | 恶化 | 重新评估切分粒度 |

#### Pass / Fail 判断标准
**Pass：**
- MIG 与拓扑配置正确；
- 多实例资源隔离可用。

**Fail：**
- 切分后资源统计不符或业务时延不可接受。

#### 常见问题排查
1. **功能上能切分，但业务尾时延升高**：切分不等于适合该业务。
2. **切分后监控丢失**：需要同步适配监控采集口径。


### 10.4 AMD GPU 盘点与带宽 / 稳定性验证（MI325X）

| 项目 | 内容 |
|---|---|
| 测试名称 | AMD GPU 盘点与带宽 / 稳定性验证（MI325X） |
| 测试目的 | 确认 AMD Instinct MI325X 的大显存、高带宽和 ROCm 栈工作正常。 |
| 预期结果 | GPU 枚举完整；ROCm 版本一致；带宽与负载稳定；无 RAS 告警。 |
| 工具 / 前提 | `rocm-smi`、`rocminfo`、带宽测试工具。 |

#### 步骤
1. 执行 ROCm 基线盘点，确认 GPU 型号、显存、总线、时钟、功耗上限。
2. 运行带宽测试和长时负载，观察温度、功耗与 RAS。
3. 对大显存模型还应验证是否能稳定加载目标权重和上下文长度。

#### 完整命令
```bash
rocm-smi --showproductname --showbus --showtemp --showpower --showuse --showmemuse
rocminfo | sed -n '1,120p'
rocm-bandwidth-test 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `rocm-smi` | ROCm 侧设备与状态 | AMD 平台基础工具 | 与 nvidia-smi 类似定位 |
| `rocminfo` | 平台与 Agent 信息 | 确认 ROCm 栈完整性 | 驱动/运行时问题先看这里 |
| `rocm-bandwidth-test` | 带宽测试 | 验证 HBM/P2P/主机传输能力 | 平台常用 |
| `showrasinfo`（可扩展） | RAS 信息 | 高可靠场景必查 | 长稳必须跟踪 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `GPU use` | GPU 利用率 | 与负载匹配 | 空转 | 查应用与 ROCm 环境 |
| `Mem use` | 显存使用率 | 与模型大小相符 | 异常低/高 | 查分配策略 |
| `Temp/Power` | 温度/功耗 | 稳态正常 | 高 | 查散热/功率上限 |
| `RAS` | 可靠性告警 | 无严重告警 | 出现 | 停测排查 |

#### Pass / Fail 判断标准
**Pass：**
- ROCm 栈正常，带宽和稳定性达标。

**Fail：**
- 枚举异常、带宽异常、RAS 告警或温度失控。

#### 常见问题排查
1. **显存足够但模型装不下**：看是否有碎片、框架配置和权重量化策略问题。
2. **ROCm 版本对了但业务仍失败**：继续看容器镜像和框架 wheel 是否匹配。


### 10.5 GPU 多厂商混插与 Host 兼容性回归

| 项目 | 内容 |
|---|---|
| 测试名称 | GPU 多厂商混插与 Host 兼容性回归 |
| 测试目的 | 验证 NVIDIA / AMD / Ascend 混插或与不同 CPU 平台组合时的 BAR、驱动、NUMA、功耗与散热兼容性。 |
| 预期结果 | 多厂商设备都能稳定枚举并在各自栈中正常工作；无资源冲突；性能干扰可控。 |
| 工具 / 前提 | 混插实验室环境；已做好 BIOS 大 BAR、IOMMU 与功耗预算。 |

#### 步骤
1. 统一先用 `lspci` 视角确认设备都在，再分别用厂商工具确认驱动层正常。
2. 检查不同厂商驱动安装路径、内核模块和容器运行时是否冲突。
3. 重点记录 BAR、PCIe 链路、NUMA 亲和、功耗峰值和温度耦合。

#### 完整命令
```bash
lspci | egrep -i 'NVIDIA|AMD|Ascend|Ethernet'
nvidia-smi -L 2>/dev/null || true
rocm-smi --showproductname 2>/dev/null || true
npu-smi info 2>/dev/null || true
journalctl -k -b | egrep -i 'nvidia|amdgpu|hisi|ascend|aer|bar' | tail -n 100
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `lspci` | 统一枚举视角 | 混插回归第一步 | 不要只看厂商工具 |
| `journalctl` | 内核模块与 BAR/AER 日志 | 发现驱动冲突和资源问题 | 混插最关键日志之一 |
| `nvidia-smi / rocm-smi / npu-smi` | 三家栈并存验证 | 证明驱动层都可工作 | 需逐一确认 |
| `NUMA/Power/Thermal` | 耦合项 | 混插场景最容易被忽视 | 必须纳入报告 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `device count` | 设备数 | 全部可见 | 缺失 | 查 BIOS/电源/BAR |
| `driver attach` | 驱动绑定 | 三类设备都正常 | 某类失败 | 单独修复再重测 |
| `power peak` | 峰值功耗 | 在预算内 | 超预算 | 重新做功耗预算 |
| `thermal cross-impact` | 热耦合 | 可接受 | 一类设备拖热另一类 | 调整风道/布局 |

#### Pass / Fail 判断标准
**Pass：**
- 混插环境中各类 GPU/NPU 均正常工作；
- 无明显干扰或冲突。

**Fail：**
- 任何一类驱动失效、BAR 冲突或功耗/散热不可控。

#### 常见问题排查
1. **单独插都正常，混插就异常**：几乎总是 BAR、功耗或热耦合问题。
2. **某家工具能看到设备但业务跑不动**：继续检查容器 runtime 和用户态库版本。



# 第11章 NPU / AI 加速器（Ascend 950PR / DT / Atlas 950 全套，npu-smi、CANN、MindSpore、分布式）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 Ascend 基线、映射、健康。
2. 验证拓扑/HCCS/HCCL 与实时使用率。
3. 验证 CANN 与 MindSpore 环境。
4. 验证单卡烧机、8 卡和多机分布式。
5. 验证 Atlas 950 / SuperPoD 集群级准入。

## 本章风险点
1. 掉卡或映射混乱。
2. 拓扑/HCCS 异常但仍强行做分布式。
3. CANN/驱动/框架版本不匹配。
4. 大规模集群放量前没有剔除 outlier 节点。

## 推荐测试时长
建议单机基线 30 分钟；单卡/8 卡 1~4 小时；多机与 Pod 准入按规模分阶段执行。

## 章节说明
NPU 章节是本手册的重点。Ascend 平台的验证必须同时覆盖：
- 设备与映射；
- 拓扑与 HCCS/HCCL；
- CANN 与框架环境；
- 单卡高负载；
- 单机多卡；
- 多机分布式；
- Pod/SuperPoD 级准入。

另外需要特别说明：公开资料中常见 `npu-smi` 主要用于信息、健康、拓扑与监控；烧机通常借助框架/样例负载完成，因此本手册给出的是**可公开执行、可复制的替代烧机方法**。

### 11.1 Ascend NPU 盘点、映射与健康基线（npu-smi info / -m / health）

| 项目 | 内容 |
|---|---|
| 测试名称 | Ascend NPU 盘点、映射与健康基线（npu-smi info / -m / health） |
| 测试目的 | 确认 Ascend NPU 数量、逻辑 ID、芯片映射、温度、功耗和健康状态，建立最基础的设备清单。 |
| 预期结果 | NPU 数量与设计一致；映射关系清晰；健康状态正常；无掉卡。 |
| 工具 / 前提 | `npu-smi` 已安装；驱动与固件完成基础部署。 |

#### 步骤
1. 先执行 `npu-smi info` 查看设备总览，再执行 `npu-smi info -m` 获取设备与逻辑映射。
2. 对每张卡或每个芯片执行健康查询，确认状态正常。
3. 把 Bus、逻辑 ID、Chip ID、槽位、机箱位置建立一一映射，便于后续掉卡定位。

#### 完整命令
```bash
npu-smi info
npu-smi info -m
npu-smi info -t health
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `info` | NPU 总览 | 最基础的设备发现命令 | 先看数量和状态 |
| `info -m` | 映射信息 | 查看设备 ID / 逻辑映射 | 多卡机器必跑 |
| `info -t health` | 健康信息 | 确认是否存在异常状态 | 压测前准入项 |
| `Bus/Device/Chip` | 定位三元组 | 后续排障必须依赖 | 应纳入报告字段 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `NPU ID` | 设备逻辑编号 | 连续无缺失 | 编号跳变/缺失 | 查掉卡和驱动加载 |
| `Health` | 健康状态 | Normal/OK | Warning/Error | 先停测再排查 |
| `Temp` | 温度 | 空载稳定 | 高温 | 查风扇/散热/环境 |
| `Power` | 功耗 | 空载低且稳定 | 异常高 | 查负载残留/功率封顶 |

#### Pass / Fail 判断标准
**Pass：**
- 数量、映射、健康均正常；
- 可形成设备—槽位—Bus—逻辑 ID 对照表。

**Fail：**
- 掉卡、映射混乱或健康异常。

#### 常见问题排查
1. **`npu-smi info` 有卡但 `-m` 映射异常**：优先看驱动与固件组合。
2. **空载功耗偏高**：检查是否有残留进程或框架占卡。


### 11.2 Ascend 拓扑、HCCS 与实时使用率验证（usages / topo / hccs / watch）

| 项目 | 内容 |
|---|---|
| 测试名称 | Ascend 拓扑、HCCS 与实时使用率验证（usages / topo / hccs / watch） |
| 测试目的 | 验证 Ascend 卡间拓扑、HCCS 互联状态、CPU-NPU 亲和，以及实时功耗/温度/AICore 利用率。 |
| 预期结果 | 拓扑对称；HCCS 正常；实时指标随负载变化；无异常链接。 |
| 工具 / 前提 | `npu-smi` 已安装；多卡节点。 |

#### 步骤
1. 执行 `npu-smi info -t topo` 观察拓扑和 CPU 亲和。
2. 执行 `npu-smi info -t hccs` 或对应版本命令，查看互联状态。
3. 在负载运行期间，开启 `watch` 监控功耗、温度、AICore 利用率等指标。
4. 注意：不同 CANN/驱动版本的 `watch` 选项可能略有差异，实际执行以 `-h` 帮助为准。

#### 完整命令
```bash
npu-smi info -t topo
npu-smi info -t hccs -i 0 -R 2>/dev/null || true
npu-smi info -t usages
npu-smi info watch -i 0 -c 0 -d 5 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `-t topo` | 查看拓扑与亲和 | 多卡训练前最重要命令之一 | 用于绑核和排障 |
| `-t hccs` | 查看 HCCS 互联 | 确认卡间互联链路 | 不同版本参数略有差异 |
| `-t usages` | 查看使用率 | 包括内存、AICore 等 | 可判断是否真正跑满 |
| `watch` | 实时监控 | 适合压测中盯温度和功耗 | 参数需按实际版本校验 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `CPU Affinity` | CPU 亲和 | 与槽位和 NUMA 相符 | 亲和混乱 | 重新绑核/查拓扑 |
| `HCCS Link` | 卡间互联状态 | Up/Normal | Down/Error | 查互联与固件 |
| `AICore%` | AI Core 利用率 | 随负载升高 | 长期接近 0 | 框架未真正上卡 |
| `Memory Usage` | 显存/片上内存占用 | 与模型规模匹配 | 异常 | 查框架分配策略 |

#### Pass / Fail 判断标准
**Pass：**
- 拓扑/HCCS 正常；
- 实时指标与负载行为一致。

**Fail：**
- HCCS 异常、AICore 利用率异常低、拓扑不对称。

#### 常见问题排查
1. **负载在跑但 AICore 很低**：通常是数据供给、图编译或框架回退问题。
2. **拓扑显示异常**：先别急着跑分布式，先修平台。

#### 实时监控命令
```bash
watch -n 5 '
echo "===== npu topo ====="; npu-smi info -t topo 2>/dev/null | head -n 60;
echo "===== npu usages ====="; npu-smi info -t usages 2>/dev/null | head -n 80;
'
```


### 11.3 CANN Toolkit / Kernels / 环境变量基线验证

| 项目 | 内容 |
|---|---|
| 测试名称 | CANN Toolkit / Kernels / 环境变量基线验证 |
| 测试目的 | 确认 CANN 组件安装完整，环境变量正确，驱动—固件—Toolkit—框架组合匹配。 |
| 预期结果 | CANN Toolkit、Kernels、环境脚本和 Python 依赖完整；样例程序可运行。 |
| 工具 / 前提 | CANN 离线包或仓库已部署；目标版本已冻结。 |

#### 步骤
1. 检查 `/usr/local/Ascend/ascend-toolkit` 是否存在，是否有 `set_env.sh`。
2. 加载环境变量后打印关键路径，确认 `ASCEND_HOME_PATH`、`LD_LIBRARY_PATH`、`PYTHONPATH` 正确。
3. 执行最小样例或导入测试，证明 Toolkit 和运行时已可用。
4. MindSpore、CANN、驱动与固件必须按兼容矩阵冻结；升级任意一层都要重测。

#### 完整命令
```bash
test -f /usr/local/Ascend/ascend-toolkit/set_env.sh &&   source /usr/local/Ascend/ascend-toolkit/set_env.sh

echo "${ASCEND_HOME_PATH}"
echo "${LD_LIBRARY_PATH}" | tr ':' '
' | sed -n '1,20p'
python3 - <<'PY'
import os
print("ASCEND_HOME_PATH=", os.environ.get("ASCEND_HOME_PATH"))
try:
    import mindspore as ms
    print("MindSpore imported:", ms.__version__)
except Exception as e:
    print("MindSpore import failed:", e)
PY
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `set_env.sh` | CANN 环境脚本 | 加载运行时库和工具路径 | 缺失即环境不完整 |
| `ASCEND_HOME_PATH` | Ascend 工具根目录 | 必须指向有效路径 | 路径错会导致运行时失败 |
| `LD_LIBRARY_PATH` | 动态库搜索路径 | 包含 Ascend 路径 | 最常见环境错误 |
| `MindSpore import` | 框架导入测试 | 证明用户态基本可用 | 需结合版本冻结看 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `ASCEND_HOME_PATH` | 工具根目录 | 非空 | 为空 | 未 source 环境脚本 |
| `LD_LIBRARY_PATH` | 库路径 | 含 Ascend 路径 | 缺失 | 补环境变量 |
| `mindspore version` | 框架版本 | 与冻结单一致 | 漂移 | 重装 wheel |
| `import result` | 导入结果 | 成功 | 失败 | 查兼容矩阵和库路径 |

#### Pass / Fail 判断标准
**Pass：**
- CANN 环境完整；
- 框架可导入；
- 版本与冻结单一致。

**Fail：**
- 环境变量错误、组件缺失或框架导入失败。

#### 常见问题排查
1. **能 source 但业务仍失败**：进一步检查多 Python 环境和容器镜像。
2. **同机不同用户结果不同**：通常是用户环境变量污染。


### 11.4 MindSpore 单卡冒烟与 NPU 基础烧机（公开 burn 负载替代法）

| 项目 | 内容 |
|---|---|
| 测试名称 | MindSpore 单卡冒烟与 NPU 基础烧机（公开 burn 负载替代法） |
| 测试目的 | 在没有统一公开 `npu-smi burn` CLI 的情况下，用 MindSpore/NPU 矩阵计算或小模型训练替代烧机，验证单卡稳定性。 |
| 预期结果 | 单卡可稳定执行高强度计算，AICore 利用率高，温度和功耗稳定，无掉卡。 |
| 工具 / 前提 | MindSpore 已安装；单卡可见；测试环境允许持续计算。 |

#### 步骤
1. 说明：公开文档中常见 `npu-smi` 主要用于信息、健康、拓扑和监控；烧机通常通过框架计算负载完成，而不是依赖统一公开的 `npu-smi burn`。
2. 编写单卡矩阵乘脚本或使用小模型训练循环，持续运行 30~120 分钟。
3. 同步开启 `npu-smi info -t usages` 与 `watch`，观察 AICore 利用率、内存、温度和功耗。

#### 完整命令
```bash
source /usr/local/Ascend/ascend-toolkit/set_env.sh

python3 - <<'PY'
import os, time
import mindspore as ms
from mindspore import Tensor, ops, context
import numpy as np

context.set_context(mode=context.GRAPH_MODE, device_target="Ascend", device_id=0)
a = Tensor(np.random.randn(4096,4096).astype(np.float16))
b = Tensor(np.random.randn(4096,4096).astype(np.float16))
matmul = ops.MatMul()
start = time.time()
for i in range(300):
    c = matmul(a, b)
    if i % 20 == 0:
        print("iter", i, "shape", c.shape, "elapsed", time.time() - start)
print("done", time.time() - start)
PY
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `GRAPH_MODE` | 图模式 | 更接近高性能执行路径 | Ascend 场景常用 |
| `device_target="Ascend"` | 指定设备目标 | 避免误跑到 CPU | 必须显式设置 |
| `device_id=0` | 选择单卡 | 单卡冒烟固定设备 | 多用户环境要谨慎 |
| `4096x4096 MatMul` | 高强度矩阵负载 | 可替代公开 burn CLI | 尺寸可按显存调整 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `iter` | 迭代序号 | 稳定递增 | 中断/卡住 | 查驱动/框架/温度 |
| `elapsed` | 累计耗时 | 线性增长 | 突增 | 查热降频或系统干扰 |
| `AICore%` | NPU 核心利用率 | 高 | 低 | 未真正压满 |
| `Temp/Power` | 温度功耗 | 稳态正常 | 异常 | 查散热与功率限制 |

#### Pass / Fail 判断标准
**Pass：**
- 单卡稳定完成高强度计算；
- AICore 利用率高；
- 无错误退出。

**Fail：**
- 运行中断、掉卡、温度异常、利用率长期过低。

#### 常见问题排查
1. **脚本能跑但 AICore 低**：矩阵尺寸太小或图编译未充分展开。
2. **导入成功但第一次运行慢**：图编译是正常现象，长稳看编译后阶段。


### 11.5 8 卡 / 多机分布式 HCCL 验证（MindSpore / msrun）

| 项目 | 内容 |
|---|---|
| 测试名称 | 8 卡 / 多机分布式 HCCL 验证（MindSpore / msrun） |
| 测试目的 | 验证单机 8 卡和多机 HCCL/HCCS 拓扑、通信与框架分布式执行是否正常。 |
| 预期结果 | 单机 8 卡和多机任务都能启动；rank 拓扑正确；通信稳定；吞吐随卡数增加。 |
| 工具 / 前提 | MindSpore 分布式环境；节点互通；时间同步；HCCS/HCCL 正常。 |

#### 步骤
1. 先做单机 8 卡最小 allreduce 或小模型训练，确认本地通信正常。
2. 再扩展到两机或更多节点，使用 `msrun` 统一下发 rank 信息。
3. 记录每个 rank 的启动日志、设备绑定和吞吐。任何一张卡掉队都会拖垮全局。

#### 完整命令
```bash
# 单机 8 卡示例
msrun --worker_num=8 --local_worker_num=8 --master_addr=127.0.0.1 --master_port=8118   --join=True train.py

# 两机示例（分别在各节点执行，rank table / 环境按实际平台准备）
# node0:
# msrun --worker_num=16 --local_worker_num=8 --master_addr=10.0.0.1 --master_port=8118 --node_rank=0 --join=True train.py
# node1:
# msrun --worker_num=16 --local_worker_num=8 --master_addr=10.0.0.1 --master_port=8118 --node_rank=1 --join=True train.py
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--worker_num` | 总 worker 数 | 等于总卡数 | 单机 8 卡即 8 |
| `--local_worker_num` | 本机 worker 数 | 等于本机卡数 | 跨机必须区分 |
| `--master_addr/master_port` | 主节点通信地址 | 全节点一致 | 端口需放通 |
| `--node_rank` | 节点编号 | 多机时必填 | 从 0 开始递增 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `rank id` | 分布式 rank | 连续完整 | 缺失 | 某卡未启动 |
| `HCCL init` | 通信初始化 | 成功 | 失败 | 查拓扑/网络/版本 |
| `step time` | 训练步耗时 | 稳定 | 抖动大 | 查慢卡/网络 |
| `throughput` | 吞吐 | 随卡数增加 | 不升反降 | 查通信与数据供给 |

#### Pass / Fail 判断标准
**Pass：**
- 单机与多机分布式均正常；
- 无慢卡、无初始化失败；
- 吞吐扩展合理。

**Fail：**
- 任一 rank 启动失败；
- HCCL 初始化错误；
- 扩展性明显异常。

#### 常见问题排查
1. **单机 8 卡过，多机不过**：先看网络、时钟同步、master 地址与端口。
2. **吞吐不扩展**：慢卡、数据读取、HCCS/HCCL 或网络瓶颈都可能导致。


### 11.6 Atlas 950 / SuperPoD 预交付验收：拓扑、分组、链路与功耗窗口

| 项目 | 内容 |
|---|---|
| 测试名称 | Atlas 950 / SuperPoD 预交付验收：拓扑、分组、链路与功耗窗口 |
| 测试目的 | 针对 Atlas 950 SuperPoD / 大规模 Ascend 集群，在正式业务训练前做集群级准入验收。 |
| 预期结果 | 节点分组、拓扑、链路、功耗、温度、版本一致；不存在明显 outlier 节点。 |
| 工具 / 前提 | 适用于 Pod/SuperPoD 管理面；需要运维与网络配合。 |

#### 步骤
1. 按机架、机框、节点、卡位四级组织清单，统一版本冻结。
2. 导出集群拓扑图、链路健康、节点功耗与温度汇总。
3. 用小规模分组任务先筛掉异常节点，再扩大到整 Pod。
4. 任何 outlier 都必须先剔除，不允许在万卡级任务里‘边跑边看’。

#### 完整命令
```bash
echo "建议导出字段：rack,node,card_id,driver,firmware,cann,mindspore,temp,power,health,topo_group"
echo "建议先做 8卡 -> 64卡 -> 512卡 逐级放大验证"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `topo_group` | 拓扑/分组标识 | 便于筛选异常域 | SuperPoD 级别必备 |
| `temp/power` | 温度/功耗汇总 | 找 outlier 的最快方法 | 集群放量前必做 |
| `version freeze` | 版本冻结 | 大集群一致性底线 | 禁止混版本上万卡 |
| `分级放大` | 8卡->64卡->512卡 | 降低风险 | 推荐实施策略 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `outlier node` | 异常节点 | 无 | 存在 | 摘除并复测 |
| `health` | 集群节点健康 | 全部正常 | 个别告警 | 不要带病入大规模 |
| `power envelope` | 功耗窗口 | 在机架预算内 | 超预算 | 调整上电和风冷/液冷策略 |
| `topology consistency` | 拓扑一致性 | 同组一致 | 不一致 | 先整改再放量 |

#### Pass / Fail 判断标准
**Pass：**
- 版本、拓扑、温度、功耗均一致；
- 分级放大验证通过。

**Fail：**
- 带病节点混入集群；
- 大规模前未完成分级准入。

#### 常见问题排查
1. **小规模没问题，大规模出问题**：这是典型网络/功耗/管理域问题，必须做分级放大。
2. **一个异常节点拖垮全局**：大集群场景先追求“无 outlier”，再谈峰值成绩。



# 第12章 TPU（Google）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 TPU 资源发现与健康。
2. 验证 JAX/PyTorch XLA 冒烟与基线。
3. 验证多 Slice / GKE / Cluster Director。

## 本章风险点
1. 资源状态与 VM 内可见设备不一致。
2. 把编译时间误当成设备性能。
3. 大规模 Slice 拓扑或调度异常。

## 推荐测试时长
建议单 Slice 基线 30~60 分钟；多 Slice/GKE 按规模分阶段执行。

## 章节说明
TPU 与传统插卡式服务器不同，它本质上是云侧加速资源。验证重点因此也不同：
- 资源有没有真的分配到位；
- 框架能不能看到正确数量的设备；
- 编译与稳态吞吐是否被区分记录；
- GKE/Cluster Director 多 Slice 拓扑和健康是否正确。

### 12.1 TPU VM / Slice 资源发现与健康检查

| 项目 | 内容 |
|---|---|
| 测试名称 | TPU VM / Slice 资源发现与健康检查 |
| 测试目的 | 确认 Google Cloud TPU 资源、版本、切片/Pod 规模和健康状态符合预期。 |
| 预期结果 | TPU VM 或切片可见；芯片数与预订一致；健康检查无异常。 |
| 工具 / 前提 | 已配置 gcloud；具备 Cloud TPU 访问权限。 |

#### 步骤
1. 在控制端列出 TPU 资源，确认版本（v6e / TPU7x）、区域、规模与保留方式。
2. 进入 TPU VM 后记录系统、驱动、框架与可见设备。
3. 如启用 Cluster Director / All Capacity 模式，应额外导出拓扑和健康视图。

#### 完整命令
```bash
gcloud compute tpus tpu-vm list --zone=${ZONE}
gcloud compute tpus tpu-vm describe ${TPU_NAME} --zone=${ZONE}
python3 - <<'PY'
import jax
print(jax.devices())
PY
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `tpu-vm list` | 列出 TPU VM 资源 | 确认资源是否已分配 | 云侧入口 |
| `tpu-vm describe` | 查看单个资源详情 | 确认版本、规模、状态 | 适合报告留痕 |
| `jax.devices()` | 框架侧设备可见性 | 最简单的冒烟验证 | JAX 是 TPU 常用入口 |
| `ZONE/TPU_NAME` | 资源定位参数 | 必须与预订一致 | 跨区会报找不到 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `state` | 资源状态 | READY/RUNNING | PROVISIONING/ERROR | 查配额与资源健康 |
| `acceleratorType` | TPU 类型 | v6e / tpu-v7 / 等 | 与规划不一致 | 重新申请资源 |
| `device count` | 设备数 | 与切片一致 | 偏少 | 查切片配置 |
| `jax.devices()` | 框架可见设备 | 数量正确 | 少设备 | 查运行时与权限 |

#### Pass / Fail 判断标准
**Pass：**
- 资源状态正常，设备数正确，框架可见。

**Fail：**
- 资源异常或框架看不到设备。

#### 常见问题排查
1. **控制台有资源但 VM 内无设备**：通常是运行时环境或镜像不对。
2. **TPU7x 需 GKE/特定模式**：先核对资源类型和使用方式。


### 12.2 JAX/PyTorch XLA 单 Slice 冒烟与吞吐基线

| 项目 | 内容 |
|---|---|
| 测试名称 | JAX/PyTorch XLA 单 Slice 冒烟与吞吐基线 |
| 测试目的 | 验证 TPU 在实际框架中能正确执行矩阵计算或小模型训练，建立单 Slice 吞吐基线。 |
| 预期结果 | 设备可稳定执行；吞吐和编译行为可解释；无运行时错误。 |
| 工具 / 前提 | TPU VM 已就绪；已安装 JAX 或 PyTorch/XLA。 |

#### 步骤
1. 执行最小矩阵乘或小模型训练，先确认编译成功，再看 steady-state 吞吐。
2. 记录第一次编译开销与后续迭代耗时，不要把编译时间误判为设备性能问题。
3. 对长上下文或大 batch 场景，还要记录 HBM 占用。

#### 完整命令
```bash
python3 - <<'PY'
import time, jax, jax.numpy as jnp
x = jnp.ones((8192,8192), dtype=jnp.bfloat16)
y = jnp.ones((8192,8192), dtype=jnp.bfloat16)
f = jax.jit(lambda a,b: a @ b)
t0=time.time()
z=f(x,y).block_until_ready()
t1=time.time()
for i in range(5):
    s=time.time()
    z=f(x,y).block_until_ready()
    print("iter", i, "elapsed", time.time()-s)
print("compile+first_run", t1-t0)
print("device_count", len(jax.devices()))
PY
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `jax.jit` | 编译到 TPU 执行 | TPU 基础验证核心 | 第一次会有编译开销 |
| `block_until_ready()` | 等待计算完成 | 保证计时真实 | 性能测量必须使用 |
| `bfloat16` | TPU 常用数据类型 | 贴近实际高性能路径 | 可按模型改成 fp8/bf16 等 |
| `8192x8192` | 矩阵规模 | 足够压设备 | 可按资源调整 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `compile+first_run` | 首次编译+执行时间 | 比 steady-state 长 | 过长 | 查编译环境 |
| `iter elapsed` | 稳态迭代时间 | 趋于稳定 | 波动大 | 查数据输入或资源争用 |
| `device_count` | 设备数量 | 与 slice 一致 | 不对 | 查资源配置 |
| `HBM usage`（扩展） | 显存占用 | 与模型规模相符 | 过高/不足 | 调 batch 和并行方式 |

#### Pass / Fail 判断标准
**Pass：**
- 能稳定编译和执行；
- 稳态迭代时间可复现。

**Fail：**
- 编译或执行失败；
- 稳态吞吐异常或设备数不正确。

#### 常见问题排查
1. **第一次很慢是正常的**：必须把编译和稳态分开记录。
2. **设备数对但吞吐差**：看 host 侧数据输入和 GCS/Filestore 性能。


### 12.3 GKE / Cluster Director / 多 Slice 拓扑与健康回归

| 项目 | 内容 |
|---|---|
| 测试名称 | GKE / Cluster Director / 多 Slice 拓扑与健康回归 |
| 测试目的 | 验证大规模 TPU 集群在 GKE/Cluster Director 模式下的拓扑、健康与调度正确性。 |
| 预期结果 | 拓扑与预订一致；健康无异常；多 Slice 调度可用。 |
| 工具 / 前提 | 适用于 TPU7x / 大规模云侧训练推理环境。 |

#### 步骤
1. 导出拓扑、资源组、健康状态与作业调度信息。
2. 按小规模到大规模逐级放量，筛除异常 slice 或 host。
3. 记录 host 到 TPU 的数据通路、存储挂载和网络出口。

#### 完整命令
```bash
echo "建议保存：topology, health, reservation_id, slice_size, GKE node pool, storage mount"
echo "建议执行：小规模 JAX 冒烟 -> 多 Slice 通信 -> 正式训练/推理"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `topology` | 拓扑视图 | 大规模 TPU 最关键的管理信息 | 必须留档 |
| `health` | 健康状态 | 调度前准入条件 | 有异常先摘除 |
| `reservation_id` | 预留资源标识 | 便于审计和成本归因 | 云环境建议保留 |
| `slice_size` | 切片规模 | 决定并行策略 | 报告必须写清楚 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `healthy hosts` | 健康主机数 | 全部正常 | 少量异常 | 先修复再放量 |
| `topology consistency` | 拓扑一致性 | 与计划一致 | 不一致 | 联系云侧支持 |
| `storage path` | 存储路径 | 稳定 | I/O 波动 | 查 GCS/Filestore 配置 |
| `job placement` | 作业调度 | 按预期 | 错配 | 调度配置需修正 |

#### Pass / Fail 判断标准
**Pass：**
- 多 Slice / GKE 环境拓扑和健康正常。

**Fail：**
- 拓扑错配、健康异常或调度不稳定。

#### 常见问题排查
1. **TPU 设备健康但作业慢**：很多时候是 host/存储/调度问题而非 TPU 本体。
2. **多 Slice 问题只在放大后出现**：必须做分级放量。



# 第13章 DPU / SmartNIC（NVIDIA BlueField + 华为 Kunpeng 集成）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 DPU 双侧可用性与固件模式。
2. 验证 OVS/TC/DOCA 硬件卸载。
3. 验证 VF、多租与安全隔离。

## 本章风险点
1. 只验证 Host 侧，不验证 Arm/control plane。
2. 规则存在但没真正硬件卸载。
3. VF 回收后残留规则与越权访问。

## 推荐测试时长
建议功能验证 1~2 小时；offload 与安全回归按项目扩展。

## 章节说明
DPU/SmartNIC 的验证，不能只把它当作“更高级的网卡”。它同时是：
- 数据面卸载器；
- 控制面参与者；
- 多租安全边界的一部分。

因此必须同时验证 Host 侧、Arm 侧、offload 路径和隔离边界。

### 13.1 BlueField / SmartNIC 盘点、固件与 Host / Arm 侧连通性验证

| 项目 | 内容 |
|---|---|
| 测试名称 | BlueField / SmartNIC 盘点、固件与 Host / Arm 侧连通性验证 |
| 测试目的 | 确认 DPU/SmartNIC 的主机侧和 Arm 侧都能正常工作，固件版本与控制面一致。 |
| 预期结果 | DPU 设备可见；固件和模式正确；Host 与 Arm 侧通信正常。 |
| 工具 / 前提 | `lspci`、`devlink`、供应商工具、SSH 到 DPU Arm 侧（如适用）。 |

#### 步骤
1. 从 Host 侧确认 DPU 设备枚举；从 Arm 侧确认系统启动和网络连通。
2. 读取固件、模式（DPU / NIC / ECPF 等）和管理接口状态。
3. 记录 DPU 到 Host、DPU 到交换机、DPU 到管理面三条路径。

#### 完整命令
```bash
lspci | egrep -i 'BlueField|SmartNIC|Ethernet'
devlink dev show
devlink dev info pci/0000:xx:00.0 2>/dev/null || true
echo "如支持，请 SSH 到 DPU Arm 侧执行 uname -a / ip -br a / systemctl status"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `devlink dev show` | 设备发现 | 现代 NIC/DPU 常用入口 | 便于统一管理 |
| `devlink dev info` | 设备与固件信息 | 版本冻结核心字段 | 需替换真实 BDF |
| `Arm side SSH` | DPU 侧操作系统连通性 | DPU 不是纯被动卡，必须双侧验证 | 非常关键 |
| `mode` | 运行模式 | 关系到 offload 和控制面 | 要纳入报告 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `fw.version` | 固件版本 | 与白名单一致 | 漂移 | 统一升级 |
| `mode` | 工作模式 | 按设计 | 错误模式 | 重新切换并重启 |
| `host link` | 主机侧链路 | 正常 | 异常 | 查 PCIe/驱动 |
| `arm mgmt` | Arm 侧管理网络 | 可达 | 不可达 | 查 OOB/管理口 |

#### Pass / Fail 判断标准
**Pass：**
- Host/Arm 双侧正常；
- 固件与模式正确。

**Fail：**
- 任一侧失联或模式错误。

#### 常见问题排查
1. **Host 看到设备但 Arm 侧起不来**：DPU 控制面还不算可用。
2. **模式错误**：很多 offload 问题根因都在模式。


### 13.2 OVS / TC / DOCA / 硬件卸载路径验证

| 项目 | 内容 |
|---|---|
| 测试名称 | OVS / TC / DOCA / 硬件卸载路径验证 |
| 测试目的 | 验证虚拟交换、ACL、隧道或存储/安全规则是否真正下沉到 DPU / SmartNIC 硬件。 |
| 预期结果 | 规则可下发、能命中、显示为 in_hw 或等价状态；吞吐和 CPU 占用改善明显。 |
| 工具 / 前提 | 已部署 OVS/TC/DOCA 或等价栈。 |

#### 步骤
1. 下发一组代表性流表/TC 规则，区分只在软件命中和真正硬件卸载。
2. 用流量压测前后对比 Host CPU、延迟和吞吐。
3. 记录卸载失败规则的特征，形成白名单/黑名单。

#### 完整命令
```bash
ovs-vsctl show 2>/dev/null || true
ovs-appctl dpctl/dump-flows 2>/dev/null | head -n 40 || true
tc -s filter show dev eth0 ingress 2>/dev/null || true
devlink health show 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `dump-flows` | 查看 OVS 流表 | 确认控制面规则存在 | 但不代表已硬件卸载 |
| `tc -s filter` | 查看 TC 规则与统计 | 看是否 `in_hw` 且有命中 | 硬件卸载最直观 |
| `devlink health` | 健康与恢复器状态 | 发现 NIC/DPU 子系统异常 | 排障重要 |
| `前后对比` | 卸载前后性能差异 | 证明 offload 的业务价值 | 不能只看控制面 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `in_hw` | 硬件卸载标识 | 存在 | 不存在 | 规则不支持或配置问题 |
| `packets/bytes` | 命中计数 | 持续增长 | 不增长 | 规则未命中 |
| `host CPU` | 主机 CPU 占用 | 卸载后下降 | 无变化 | 可能没真正卸载 |
| `health reporter` | 健康报告器 | 正常 | error | 先修复设备健康 |

#### Pass / Fail 判断标准
**Pass：**
- 规则真实硬件卸载；
- CPU/时延/吞吐收益可见。

**Fail：**
- 规则仅在软件层生效或设备健康异常。

#### 常见问题排查
1. **规则显示存在但无命中**：先确认流量路径是否真的经过该接口。
2. **命中了但 CPU 不降**：说明卸载面并未覆盖真正热点路径。


### 13.3 DPU 隔离、SR-IOV、多租安全边界验证

| 项目 | 内容 |
|---|---|
| 测试名称 | DPU 隔离、SR-IOV、多租安全边界验证 |
| 测试目的 | 验证 VF、多租户、租户隔离和控制面权限边界正确，避免 DPU 引入新的安全面风险。 |
| 预期结果 | VF 创建、隔离、回收正常；租户互不越权；日志和审计可追溯。 |
| 工具 / 前提 | SR-IOV 已启；租户或测试 namespace 已准备。 |

#### 步骤
1. 创建 VF 并分配到不同租户/namespace，验证互相隔离。
2. 检查租户是否能看到不该看到的控制面资源。
3. 回收 VF 后检查资源是否真正释放，避免僵尸配置残留。

#### 完整命令
```bash
for dev in /sys/class/net/*/device/sriov_numvfs; do echo "$dev"; cat "$dev"; done 2>/dev/null || true
ip netns list
echo "请按租户场景验证 VF 分配、回收与越权访问"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `sriov_numvfs` | VF 数量 | 验证功能入口 | DPU/多租场景关键 |
| `ip netns` | 命名空间 | 可模拟多租户 | 实验室常用 |
| `权限边界` | 租户可见资源 | 必须最小化 | 要做安全验证 |
| `回收` | 资源释放 | 防止僵尸 VF 和残留策略 | 报告应保留截图/日志 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `VF count` | VF 数量 | 与规划一致 | 多/少 | 查 SR-IOV 配置 |
| `tenant visibility` | 租户可见范围 | 仅可见自身 | 越权 | 高危安全问题 |
| `resource cleanup` | 回收状态 | 干净 | 残留 | 做清理与回归 |
| `audit log` | 审计日志 | 完整 | 缺失 | 补日志方案 |

#### Pass / Fail 判断标准
**Pass：**
- VF 和隔离正确；
- 权限边界清晰；
- 回收干净。

**Fail：**
- 越权访问、残留配置或资源泄漏。

#### 常见问题排查
1. **功能正常但审计缺失**：生产放行前仍应视为不完整。
2. **租户退出后规则残留**：很容易造成下一个租户拿到脏环境。



# 第14章 固件 / BMC / iBMC / Redfish 升级（前后对比）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证升级前准备与包完整性。
2. 验证升级过程与带外可达性。
3. 验证升级后差异与最小回归集。

## 本章风险点
1. 无回退方案就升级。
2. 升级后只看版本不做回归。
3. BMC/BIOS 更新导致风扇策略或设备枚举改变。

## 推荐测试时长
建议按维护窗口执行；单台 1~2 小时，多台按并发策略安排。

## 章节说明
固件升级最怕两件事：  
一是**没快照就开刷**；  
二是**版本变了就以为成功**。

真正合格的升级验证，必须把“包校验、过程监控、升级后最小回归、必要时回退”四件事闭环。

### 14.1 升级前快照、校验和与维护窗口准备

| 项目 | 内容 |
|---|---|
| 测试名称 | 升级前快照、校验和与维护窗口准备 |
| 测试目的 | 在执行 BIOS/BMC/NIC/HBA/SSD/GPU/NPU/DPU 固件升级前，做好包校验、版本快照与回退准备。 |
| 预期结果 | 升级包来源可信、哈希正确、当前版本已归档、回退路径明确。 |
| 工具 / 前提 | 变更单已审批；维护窗口明确；升级包可访问。 |

#### 步骤
1. 对升级包计算 SHA256，核对来源与版本。
2. 导出当前版本矩阵和 BMC/Redfish 配置。
3. 确认回退包、启动介质、带外访问与串口方式可用。

#### 完整命令
```bash
sha256sum /opt/offline/firmware/* | tee /opt/lab/reports/firmware_sha256.txt
dmidecode -t bios | tee /opt/lab/reports/bios_before.txt
ipmitool mc info | tee /opt/lab/reports/bmc_before.txt
curl -k -u "${BMC_USER}:${BMC_PASS}" "https://${BMC_HOST}/redfish/v1/UpdateService"   -o /opt/lab/reports/redfish_updateservice_before.json
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `sha256sum` | 包完整性校验 | 避免刷错包或包损坏 | 升级前必做 |
| `bios_before/bmc_before` | 版本快照 | 升级前证据 | 回退和对比依据 |
| `UpdateService` | 升级服务对象 | 看支持的方式与状态 | Redfish 平台关键 |
| `回退包` | 降级资源 | 事故时救命 | 必须实际可访问 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `sha256` | 包哈希 | 与厂商发布一致 | 不一致 | 禁止升级 |
| `before version` | 升级前版本 | 记录完整 | 缺失 | 停止变更 |
| `rollback path` | 回退路径 | 明确 | 未定义 | 禁止升级 |
| `window` | 维护窗口 | 明确可执行 | 不清晰 | 重约窗口 |

#### Pass / Fail 判断标准
**Pass：**
- 包校验、快照和回退都齐备。

**Fail：**
- 无哈希、无快照、无回退路径。

#### 常见问题排查
1. **包名看起来对但哈希不对**：绝不能侥幸升级。
2. **带外没准备好**：升级过程中一旦失联，恢复成本极高。


### 14.2 BMC / BIOS / 设备固件升级执行与过程监控

| 项目 | 内容 |
|---|---|
| 测试名称 | BMC / BIOS / 设备固件升级执行与过程监控 |
| 测试目的 | 在受控窗口内执行升级，并实时监控升级状态、重启次数、带外连通与设备回归情况。 |
| 预期结果 | 升级过程无中断，重启后设备可恢复，版本生效。 |
| 工具 / 前提 | 厂商升级工具、Redfish 或带外界面可用。 |

#### 步骤
1. 按厂商推荐顺序执行：通常先 BMC，再 BIOS，再外设固件；实际以平台支持矩阵为准。
2. 升级期间保持带外会话，记录开始、结束和每次重启时间。
3. 重启后立即检查 BMC 可达、主机可引导、关键设备可枚举。

#### 完整命令
```bash
echo "请按厂商工具或 Redfish UpdateService 执行升级。"
echo "过程监控：ping BMC、记录重启次数、记录 POST 时间、保留操作日志。"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `升级顺序` | 执行先后 | 减少依赖冲突 | 以厂商文档为准 |
| `带外会话` | 升级期间唯一生命线 | 必须持续可用 | 强烈建议录屏/留档 |
| `POST 时间` | 开机自检耗时 | 升级后可能变化 | 异常变长需排查 |
| `设备枚举回归` | 重启后第一时间检查 | 发现掉卡最及时 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `status` | 升级状态 | success | failed | 保留原始日志 |
| `reboot count` | 重启次数 | 符合厂商流程 | 异常多 | 看升级手册 |
| `BMC reachability` | 带外可达性 | 持续可达 | 失联 | 准备现场救援 |
| `post-up devices` | 升级后设备枚举 | 完整 | 少卡/少盘 | 立即停测排查 |

#### Pass / Fail 判断标准
**Pass：**
- 升级流程顺利；
- 版本生效；
- 重启后系统恢复正常。

**Fail：**
- 升级失败、失联、设备枚举异常。

#### 常见问题排查
1. **版本显示变了但设备少了**：升级算失败，不是“部分成功”。
2. **BMC 升级后证书或账号策略变化**：要同步更新自动化脚本。


### 14.3 升级后差异审计与最小回归集

| 项目 | 内容 |
|---|---|
| 测试名称 | 升级后差异审计与最小回归集 |
| 测试目的 | 确保升级后不仅版本变化正确，而且功能、性能、拓扑和传感器全部回归通过。 |
| 预期结果 | 升级前后差异可解释；最小回归集通过；不存在性能回退或新告警。 |
| 工具 / 前提 | 升级已完成；基线包可比对。 |

#### 步骤
1. 比较升级前后的 BIOS/BMC/驱动/固件与拓扑。
2. 执行最小回归集：系统引导、设备枚举、传感器、网络、存储、加速器、基线小压测。
3. 若任何项不通过，优先回退而不是继续堆补丁。

#### 完整命令
```bash
diff -u /opt/lab/reports/bios_before.txt <(dmidecode -t bios)
diff -u /opt/lab/reports/bmc_before.txt <(ipmitool mc info)
lspci | wc -l
lsblk
ip -br link
nvidia-smi -L 2>/dev/null || true
npu-smi info 2>/dev/null || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `diff -u` | 升级前后差异 | 看变化是否仅限预期项 | 最基础回归 |
| `设备枚举` | 少卡少盘最先发现 | 升级后第一时间检查 | 切勿省略 |
| `最小压测` | 短时确认功能和性能基线 | 避免把问题带进长稳测试 | 建议 5~15 分钟 |
| `传感器` | 风扇/温度/功耗 | 升级后也可能被影响 | 必须再看一次 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `version` | 版本变化 | 符合预期 | 未变化/错版本 | 查升级生效条件 |
| `device count` | 设备数 | 不减少 | 减少 | 回退并定位 |
| `sensor health` | 传感器健康 | 正常 | 新告警 | 可能是固件策略变化 |
| `perf delta` | 性能变化 | 在容忍范围 | 明显下降 | 先回退或继续分析 |

#### Pass / Fail 判断标准
**Pass：**
- 差异可解释；
- 最小回归集全部通过。

**Fail：**
- 新告警、少设备、性能显著回退。

#### 常见问题排查
1. **版本升级成功但风扇策略变了**：这是典型“功能过了、体验和功耗没过”。
2. **最小压测通过但长稳失败**：说明固件组合存在边缘问题，仍需回退评估。



# 第15章 整机烧机 + 多厂商混配兼容矩阵

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 24h/72h 整机稳定性。
2. 验证混配互扰。
3. 验证机架级上线预算。

## 本章风险点
1. 单项都过，组合失败。
2. 离群节点被均值掩盖。
3. 机架级供电/散热预算不足。

## 推荐测试时长
建议 24h 为最低整机准入；关键平台推荐 72h 老化筛选。

## 章节说明
整机烧机的意义在于把所有“单项都看起来没问题”的隐患一起逼出来。
特别是在 Huawei 主机与 NVIDIA/AMD/Ascend/DPU 混配的平台里，最危险的问题往往不是单个部件坏，而是**热、电、链路和驱动互相影响**。

## 多厂商混配兼容矩阵（示例）

| Host 平台 | 加速器/外设组合 | 必查项 | 高风险点 | 建议结论口径 |
|---|---|---|---|---|
| Kunpeng / TaiShan | NVIDIA H200/B200 | Above 4G、BAR、PCIe Gen、NUMA 亲和、功耗 | 大 BAR、驱动白名单、热耦合 | 先做单机再做多机 |
| Kunpeng / TaiShan | AMD MI325X | ROCm 版本、IOMMU、PCIe、散热 | 生态镜像与 Arm 兼容 | 业务镜像必须预先适配 |
| Kunpeng / TaiShan | Ascend 950PR/DT | CANN/驱动/固件、HCCS、灵衢互联 | 版本冻结与拓扑 | 优先原生组合 |
| Intel Xeon 6 | H200/B200/GB200 | UEFI、MIG/NVLink、DCGM、散热 | NVSwitch/NVLink 域差异 | 适合成熟 AI 工厂方案 |
| AMD EPYC 9005 | MI325X | ROCm、NUMA、Infinity Fabric 拓扑 | 热设计与长上下文内存占用 | 重点看稳态功耗 |
| 任意 Host | DPU + GPU/NPU + NVMe | PCIe lane、BAR、IOMMU、功耗、风道 | 峰值功耗与链路冲突 | 必做整机烧机 |

### 15.1 24 小时整机烧机（CPU + 内存 + 网络 + 存储 + GPU/NPU）

| 项目 | 内容 |
|---|---|
| 测试名称 | 24 小时整机烧机（CPU + 内存 + 网络 + 存储 + GPU/NPU） |
| 测试目的 | 模拟整机真实高压场景，验证平台在 24 小时内无掉卡、掉盘、重启、链路降速和热失控。 |
| 预期结果 | 24 小时内全系统稳定；关键日志无新增致命错误；性能曲线无明显漂移。 |
| 工具 / 前提 | 所有单模块基线已通过；监控和日志路径已准备。 |

#### 步骤
1. 将 CPU、内存、网络、存储、GPU/NPU 压力组合编排，避免只跑单一负载。
2. 每 1~5 分钟采集一次关键指标，至少包括功耗、温度、设备状态、日志摘要和吞吐。
3. 发现异常时立即执行故障快照，而不是等整轮跑完。

#### 完整命令
```bash
echo "建议组合：stress-ng + fio + iperf3 + gpu-burn/Ascend matmul"
echo "建议采集：CPU/GPU/NPU util, power, temp, dmesg, SEL, link stats, fio/iperf throughput"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `组合压测` | 比单项更接近真实生产 | 整机放行必需 | 需要精心编排避免误伤环境 |
| `采样间隔` | 1~5 分钟 | 平衡粒度和日志量 | 建议写入统一 CSV/TSDB |
| `性能漂移` | 长时间变化趋势 | 判断是否有热或资源泄漏 | 24h 测试核心观察 |
| `异常快照` | 出问题时立刻抓现场 | 整机测试必须内建 | 不能事后补救 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `uptime` | 系统持续在线 | 24h+ | 中断 | 查掉电/内核 panic |
| `device count` | 设备数量 | 不变 | 减少 | 掉卡/掉盘 |
| `throughput trend` | 吞吐趋势 | 平稳 | 逐步下降 | 热/泄漏/错误重试 |
| `fatal logs` | 致命日志 | 0 | 非 0 | 立即停测 |

#### Pass / Fail 判断标准
**Pass：**
- 24 小时组合压测平稳通过；
- 无致命日志和设备丢失。

**Fail：**
- 任意系统级故障或明显性能漂移。

#### 常见问题排查
1. **单项都通过，组合失败**：这正是整机烧机存在的意义。
2. **第 20 小时后才掉速**：多半是热饱和、资源泄漏或纠错重试累积。


### 15.2 72 小时延长老化与批次筛选

| 项目 | 内容 |
|---|---|
| 测试名称 | 72 小时延长老化与批次筛选 |
| 测试目的 | 对新品首批、混配平台或大规模集群节点做延长老化筛选，把边缘故障提前暴露。 |
| 预期结果 | 72 小时内无新增硬故障；异常节点被识别并剔除。 |
| 工具 / 前提 | 适用于首批量产、关键业务平台、Pod 级节点筛选。 |

#### 步骤
1. 把 72 小时测试视为‘筛选实验’，不是追求最高跑分。
2. 对所有节点统一采样口径，输出排名和异常榜单。
3. 任何异常节点先下线复测，不要用均值掩盖 outlier。

#### 完整命令
```bash
echo "建议每日汇总：device health, error count, thermal trend, power trend, perf trend"
echo "建议输出：top offenders / outlier nodes report"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `outlier analysis` | 异常节点分析 | 72h 测试的核心产物 | 不能只看平均值 |
| `daily summary` | 日报 | 便于阶段性止损 | 建议自动生成 |
| `node ranking` | 节点排序 | 识别慢节点/热节点 | 适合集群筛选 |
| `batch screening` | 批次筛选 | 首批交付高价值 | 建议保留原始数据 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `new errors/day` | 每日新增错误 | 0 或极低 | 增长 | 隔离节点 |
| `thermal trend` | 热趋势 | 稳定 | 逐日上升 | 查环境与灰尘 |
| `perf rank` | 性能排名 | 集中 | 极端离群 | 单独调查 |
| `node health` | 节点健康 | 全部良好 | 少数异常 | 下线复测 |

#### Pass / Fail 判断标准
**Pass：**
- 72 小时内无边缘故障暴露；
- 无明显离群节点。

**Fail：**
- 出现慢节点、热节点、掉卡/掉盘等离群问题。

#### 常见问题排查
1. **平均值很好但少数节点很差**：集群环境下一律优先处理离群节点。
2. **异常只在夜间出现**：重点查机房温度和批处理任务。


### 15.3 Huawei + NVIDIA / AMD 混配干扰测试（功耗 / 温度 / 性能）

| 项目 | 内容 |
|---|---|
| 测试名称 | Huawei + NVIDIA / AMD 混配干扰测试（功耗 / 温度 / 性能） |
| 测试目的 | 验证华为主机与国际 GPU/加速器混配时的功耗、温度、驱动和性能互扰情况。 |
| 预期结果 | 不同组合都能稳定运行；互扰在可接受范围；不存在系统级冲突。 |
| 工具 / 前提 | 混配平台已准备；功耗与散热有余量。 |

#### 步骤
1. 分别执行单独负载和同时负载，比较功耗、温度、链路与吞吐变化。
2. 重点观察某类设备满载是否拖慢另一类设备，或导致风扇策略激进。
3. 将结果整理成矩阵，写清哪些组合可放行、哪些仅条件放行。

#### 完整命令
```bash
echo "建议组合：Kunpeng+NVIDIA, Kunpeng+AMD, Huawei host+Ascend+NVMe+DPU"
echo "记录：单独负载、同时负载、峰值功耗、最高温度、吞吐回退百分比"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `单独 vs 同时负载` | A/B 对照 | 找出互扰最直接方法 | 必须两组都做 |
| `回退百分比` | 性能干扰量化 | 决定是否放行 | 推荐写成矩阵 |
| `峰值温度/功耗` | 热电耦合结果 | 混配场景最关键 | 必须入报告 |
| `条件放行` | 受约束结论 | 例如需限功率/限环境温度 | 非常实用 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `perf delta` | 性能回退 | < 项目阈值 | 超阈值 | 优化风道/功率或拆分部署 |
| `max temp` | 最高温度 | 不过上限 | 越限 | 散热不合格 |
| `peak power` | 峰值功耗 | 在预算内 | 超预算 | 重算机架容量 |
| `driver conflicts` | 驱动冲突 | 无 | 有 | 统一镜像/隔离环境 |

#### Pass / Fail 判断标准
**Pass：**
- 混配环境稳定；
- 干扰量可接受。

**Fail：**
- 干扰超阈值或存在系统级冲突。

#### 常见问题排查
1. **单独都好，同时就差**：优先从功耗峰值和风扇策略入手。
2. **只有某组合有问题**：说明不是通用软件问题，而是特定硬件组合边界。


### 15.4 机架级功率 / 温度预算与上线准入

| 项目 | 内容 |
|---|---|
| 测试名称 | 机架级功率 / 温度预算与上线准入 |
| 测试目的 | 把单机测试结果提升到机架视角，确保 PDU、冷量、交换网络与机架布置可以支撑上线。 |
| 预期结果 | 机架功率预算、冷量预算、端口预算和维护策略明确，可形成上线条件。 |
| 工具 / 前提 | 具备机架功率计、温湿度和资产布置表。 |

#### 步骤
1. 根据单机峰值与平均功耗，计算机架级最坏情况和典型情况预算。
2. 按热密度排列高功耗节点，避免局部热点。
3. 将交换机、存储和管理设备也纳入预算，不可只算计算节点。

#### 完整命令
```bash
echo "建议输出：rack_id, total_peak_kw, typical_kw, cooling_margin, pdu_a_margin, pdu_b_margin, hottest_nodes"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `total_peak_kw` | 机架峰值功率 | 供电设计底线 | 必须留余量 |
| `typical_kw` | 典型功率 | 运营期常态预算 | 便于容量规划 |
| `cooling_margin` | 冷量余量 | 热稳态安全边界 | 建议保守计算 |
| `hottest_nodes` | 最热节点列表 | 指导机架布局 | 非常实用 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `pdu margin` | PDU 余量 | 充足 | 不足 | 禁止上线 |
| `cooling margin` | 冷量余量 | 充足 | 不足 | 需调整布局 |
| `hotspot` | 局部热点 | 无严重热点 | 有 | 重新排布 |
| `rack readiness` | 机架上线准备度 | Ready | Not Ready | 形成准入门槛 |

#### Pass / Fail 判断标准
**Pass：**
- 机架级预算明确且有余量。

**Fail：**
- 预算不足或热点明显。

#### 常见问题排查
1. **单机都没问题，上架后出问题**：往往是机架级供电/散热/线缆组织问题。
2. **只算服务器不算交换机**：是机架预算的典型错误。



# 第16章 AI 端到端验证（MLPerf + vLLM / TensorRT + CANN / MindSpore + DeepSeek 等）

### 【2026年3月厂商与主流产品信息】

> 说明：本表统一使用“截至 2026-03 可公开核实的信息”。对**项目制交付**、**未公开 TDP**、**未公开价格**、**路线图/预发布**产品，不强行补齐，统一标注“官方未披露/项目报价/预发布”。在认证环境中，**未公开参数不得作为 Pass/Fail 的唯一依据**，应以整机白皮书、POC 交付清单和厂商支持矩阵为准。

| 型号 | 核心/算力 | TDP | 内存/显存 | 互联带宽 | 性能亮点 | 典型场景 | 参考价区间 |
|---|---:|---:|---:|---|---|---|---|
| 华为 Kunpeng 950（高性能版） | 96核 / 192线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；与 TaiShan 950 超节点可通过灵衢互联扩展 | 面向数据库、虚拟化、通用计算与国产化适配 | OLTP、Java、中间件、云主机 | 公开未披露（整机/项目报价） |
| 华为 Kunpeng 950（高密度版） | 192核 / 384线程 | 官方未披露 | DDR5，容量依整机而定 | 依平台而定；适合高密度并发 | 单机高核心密度，适合高吞吐与整机汇聚场景 | 微服务、批处理、密集型容器 | 公开未披露（整机/项目报价） |
| 华为 TaiShan 950 超节点 | 最多 16 节点 / 32 CPU | 官方未披露 | 最多 48TB 内存 | 灵衢互联；百纳秒级时延、Tb/s 级带宽 | 支持内存池化、SSD 池化、DPU 池化 | 超大数据库、内存型业务、超大规模资源池 | 项目报价 |
| 华为 Ascend 950PR | 面向 Prefill/推荐等推理场景；精确算力指标未完整公开 | 官方未完整披露 | 官方未完整披露 | 官方未完整披露 | 2026Q1 首批可获取，主打大模型推理前半段 | 检索增强、推荐、长上下文预填充 | 项目报价 |
| 华为 Ascend 950DT | 面向 Decode/训练；144GB HBM，4TB/s 显存带宽 | 官方未完整披露 | 144GB HBM | 芯片间互联带宽 2TB/s | 适合训练和解码密集场景 | 训练、解码、MoE、分布式推理 | 项目报价 |
| 华为 Atlas 950 SuperPoD | 最多 8192 张 Ascend 950DT；8 EFLOPS FP8 / 16 EFLOPS 低精度 | 项目级系统 | 1152TB 总内存 | UnifiedBus 16.3PB/s | 超节点互联，面向超大规模 AI 集群 | 基座模型训练、万卡级推理 | 项目报价 |
| Intel Xeon 6980P（Xeon 6 P-core 示例） | 128核 / 256线程 | 500W | 最多 3TB DDR5 | UPI 24GT/s；96 条 PCIe 5.0 | 单插超高通用性能，生态成熟 | 通用虚拟化、数据库、AI 前处理 | 约 USD 12,460（官方列表价） |
| Intel Xeon 6（E-core 家族上限） | 最高 288 核/插槽（家族上限） | 依 SKU 而定 | 依 SKU 而定 | 依 SKU 而定 | 面向云原生高密度并发 | 云计算、边缘、微服务 | 依 SKU 而定 |
| AMD EPYC 9965（EPYC 9005 示例） | 192核 / 384线程 | 500W | 12 通道 DDR5，平台总容量依主板而定 | 128 条 PCIe 5.0 | Zen 5c 高密度，单插核心数极高 | 虚拟化、HPC、内存密集业务 | 约 USD 11,988（1KU） |
| NVIDIA H200 SXM | FP8 约 4 PFLOPS；141GB HBM3e | 最高 700W（可配置） | 141GB HBM3e | NVLink 900GB/s | H100 升级款，LLM 与 HPC 通用 | 训练、推理、仿真 | 公开未披露（整机报价） |
| NVIDIA B200 | 单 GPU 最高 180GB HBM3e；Blackwell 单 Superchip FP4 20 PFLOPS（2 GPU） | 单 GPU 公开页未统一披露 | 180GB HBM3e（单 GPU） | 单 Superchip NVLink 3.6TB/s；HGX B200 节点 NVLink 总带宽 14.4TB/s | 面向 Blackwell 时代高吞吐训练/推理 | 大模型训练、推理、AI 工厂 | 公开未披露（整机/项目报价） |
| NVIDIA GB200 NVL72 | 72 Blackwell GPU，机架级 FP4 1440 PFLOPS（稀疏） | 液冷机架级系统 | 最多 13.4TB HBM3e | NVLink 130TB/s | 机架级单域 NVLink，面向万亿参数实时推理 | 实时推理、训练、AI 工厂 | 项目报价 |
| AMD Instinct MI325X | FP8 2.61 PFLOPS | 最高 1000W | 256GB HBM3E | 6TB/s HBM；8× Infinity Fabric 链路 | 大显存高带宽，适合长上下文与大 batch | 训练、推理、HPC | 公开未披露（整机报价） |
| Google TPU v6e（Trillium） | BF16 918 TFLOPS/芯片 | 云服务形态 | 32GB HBM/芯片 | ICI 双向 800GB/s/芯片 | Google Cloud 普适 TPU 入口 | 训练、推理、研究 | 按地区与时长计费 |
| Google TPU7x（Ironwood，预览） | BF16 2307 TFLOPS/芯片，FP8 4614 TFLOPS/芯片 | 云服务形态 | 192GiB HBM/芯片 | ICI 双向 1200GB/s/芯片 | 面向大规模训练与 decode-heavy 推理 | 超大规模训练、GKE TPU 集群 | 账户团队/预留制 |

## 本章目标
1. 验证 MLPerf 预检和提交流程。
2. 验证 vLLM/TensorRT/CANN/MindSpore 真实推理路径。
3. 统一 KPI 并形成上线推荐配置。

## 本章风险点
1. 只看 benchmark 分数，不看服务化路径。
2. 把冷启动和稳态混为一谈。
3. 只看吞吐，不看错误率、功耗和温度。

## 推荐测试时长
建议单模型单配置至少 30~60 分钟；正式验收按业务模型矩阵执行。

## 章节说明
AI 端到端验证是整本手册的收束章节。前面所有硬件、固件、网络、散热、拓扑验证，最终都要在真实框架和真实服务路径里闭环。
本章强调三个原则：
1. **预检与正式 benchmark 分开；**
2. **冷启动与稳态分开；**
3. **吞吐、时延、功耗、温度、错误率同时看。**

### 16.1 MLPerf 环境预检与提交结构校验

| 项目 | 内容 |
|---|---|
| 测试名称 | MLPerf 环境预检与提交结构校验 |
| 测试目的 | 在正式 benchmark 前验证 MLPerf 环境、依赖、loadgen 和提交目录结构，避免跑了很久最后因格式问题作废。 |
| 预期结果 | 仓库、依赖、loadgen、目录结构和基础验证都通过。 |
| 工具 / 前提 | 可访问 MLPerf 代码仓或内部镜像；Python 环境可用。 |

#### 步骤
1. 拉取或解压 MLPerf Inference 仓库，安装 loadgen 依赖。
2. 构建或验证 loadgen，确认基础工具链可用。
3. 对提交目录执行校验脚本，先过结构，再追求成绩。

#### 完整命令
```bash
git clone https://github.com/mlcommons/inference.git /opt/lab/scripts/mlperf_inference || true
cd /opt/lab/scripts/mlperf_inference
git submodule update --init --recursive || true
python3 -m pip install -r loadgen/requirements.txt || true
make build_loadgen || true
python3 tools/submission/validate_submission.py --input submissions/open/your_org --version v5.1 || true
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `submodule update` | 同步子模块 | MLPerf 依赖较多 | 预检必做 |
| `requirements.txt` | Python 依赖 | 构建 loadgen 与工具脚本 | 建议固定镜像 |
| `build_loadgen` | 构建负载生成器 | 环境最小有效性验证 | 很多问题会在这里暴露 |
| `validate_submission.py` | 校验提交结构 | 正式提测前必跑 | 避免格式错误 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `build status` | 构建结果 | success | failed | 补齐依赖 |
| `submission layout` | 提交目录结构 | 符合规范 | 不符合 | 按官方模板整改 |
| `version` | 规则版本 | 与本轮一致 | 错版本 | 严格统一 |
| `dataset path` | 数据集路径 | 可用 | 缺失 | 修正挂载点 |

#### Pass / Fail 判断标准
**Pass：**
- 环境可构建；
- 提交结构通过校验。

**Fail：**
- build/loadgen/submission 任一环节失败。

#### 常见问题排查
1. **先跑模型后做结构校验**：非常低效，顺序应该反过来。
2. **版本写错**：MLPerf 每轮规则会变化，必须统一口径。

#### 实施补充说明
> 说明：截至 2026 年 3 月，MLPerf Inference 文档已进入 v6.0 轮次流程，但公开可查的已发布结果以 v5.1 为最近一轮主要公开结果为主。  
> 在企业验收中，**预检**与**正式提交**应分开：预检验证环境、数据、负载生成器和提交目录结构；正式提交严格按当轮规则执行。


### 16.2 vLLM + DeepSeek 服务化推理验证（NVIDIA / AMD）

| 项目 | 内容 |
|---|---|
| 测试名称 | vLLM + DeepSeek 服务化推理验证（NVIDIA / AMD） |
| 测试目的 | 用 vLLM 对 DeepSeek 蒸馏模型或项目指定模型做真实服务化验证，观察 TTFT、TPOT、吞吐、显存占用与稳定性。 |
| 预期结果 | 服务可稳定启动；吞吐与延迟在预期范围内；显存占用和错误日志可解释。 |
| 工具 / 前提 | 已准备模型权重；vLLM 环境可用；NVIDIA/AMD 平台任选。 |

#### 步骤
1. 优先使用蒸馏版或项目真实上线模型进行服务化验证，不建议一开始就直接上最大参数模型。
2. 启动服务后，用并发压测工具记录首 token 时延（TTFT）、每输出 token 时延（TPOT）、TPS/QPS 和错误率。
3. 记录显存占用、功耗和温度；不要只看模型能启动。

#### 完整命令
```bash
# 以 DeepSeek 蒸馏模型为例；请按实际权重路径替换
vllm serve deepseek-ai/DeepSeek-R1-Distill-Qwen-32B   --tensor-parallel-size 8   --max-model-len 32768   --gpu-memory-utilization 0.92   --port 8000

# 基础请求
curl http://127.0.0.1:8000/v1/chat/completions   -H 'Content-Type: application/json'   -d '{
    "model": "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
    "messages": [{"role": "user", "content": "请解释 NUMA 绑核的重要性。"}],
    "temperature": 0.0,
    "max_tokens": 128
  }'
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--tensor-parallel-size 8` | 张量并行大小 | 通常与卡数匹配 | 决定模型切分方式 |
| `--max-model-len 32768` | 最大上下文长度 | 直接影响显存占用 | 按业务设定 |
| `--gpu-memory-utilization 0.92` | 显存利用上限 | 留一定余量防 OOM | 长稳时很关键 |
| `/v1/chat/completions` | OpenAI 兼容 API | 便于压测与接入 | 服务化验证核心入口 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `TTFT` | 首 token 时延 | 稳定且可接受 | 过高 | 查编译/权重加载/调度 |
| `TPOT` | 每 token 时延 | 稳态关键指标 | 抖动大 | 查 KV cache/并发/调度 |
| `TPS/QPS` | 吞吐 | 与卡数和模型规模匹配 | 偏低 | 查并行与显存设置 |
| `GPU/VRAM` | 显卡利用率/显存占用 | 高且稳定 | 低利用率 | 查并发与 batching |

#### Pass / Fail 判断标准
**Pass：**
- 服务稳定可用；
- TTFT/TPOT/TPS 在目标范围；
- 无 OOM 和频繁错误。

**Fail：**
- 服务不稳定、延迟不可接受、显存策略失控。

#### 常见问题排查
1. **模型能起但 TTFT 很差**：先区分权重首次加载、图编译和稳态服务。
2. **AMD 平台可用但性能差异大**：看 vLLM/ROCm 版本、容器镜像和模型并行策略。


### 16.3 TensorRT / TensorRT-LLM 冒烟与引擎验证（NVIDIA）

| 项目 | 内容 |
|---|---|
| 测试名称 | TensorRT / TensorRT-LLM 冒烟与引擎验证（NVIDIA） |
| 测试目的 | 验证 NVIDIA 平台的 TensorRT / TensorRT-LLM 基础可用性，确认可构建、可加载、可推理。 |
| 预期结果 | TensorRT 环境正常；引擎可构建或样例可运行；推理结果和吞吐稳定。 |
| 工具 / 前提 | 已安装 TensorRT；有 ONNX 或示例模型。 |

#### 步骤
1. 对通用模型可先用 `trtexec` 做最小可用性验证。
2. 对 LLM 场景，建议在预生产环境进一步验证 TensorRT-LLM/NIM，但本手册的基础准入先以引擎和推理可用为目标。
3. 记录 build 参数、precision、workspace 和吞吐。

#### 完整命令
```bash
trtexec --onnx=/models/model.onnx   --saveEngine=/models/model.plan   --fp16   --workspace=4096   --shapes=input:1x3x224x224

trtexec --loadEngine=/models/model.plan --warmUp=200 --duration=60
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `--saveEngine` | 保存 TensorRT 引擎 | 验证 build 成功 | 便于后续复现 |
| `--fp16` | 半精度模式 | 常见推理路径 | 按模型能力选择 |
| `--workspace=4096` | 工作空间 MB | 影响引擎构建和优化 | 太小可能 build 失败 |
| `--duration=60` | 稳态压测时长 | 看 steady-state 吞吐 | 不要只看单次运行 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `Throughput` | 吞吐 | 稳定 | 偏低 | 查 precision/engine/IO |
| `Latency` | 时延 | 稳定 | 波动大 | 查频率/功耗/输入队列 |
| `Engine build` | 引擎构建 | success | failed | 检查算子支持和 workspace |
| `Memory` | 显存占用 | 可解释 | 异常 | 看 shape 和 precision |

#### Pass / Fail 判断标准
**Pass：**
- 引擎可构建、可加载、可稳定推理。

**Fail：**
- build/load/run 任一失败或吞吐明显异常。

#### 常见问题排查
1. **ONNX 能导入但 build 失败**：通常是算子不支持或 workspace 不足。
2. **稳态吞吐低**：先看是否跑在错误 precision 或 I/O 成了瓶颈。


### 16.4 CANN / MindSpore / vLLM-MindSpore 端到端推理验证（Ascend）

| 项目 | 内容 |
|---|---|
| 测试名称 | CANN / MindSpore / vLLM-MindSpore 端到端推理验证（Ascend） |
| 测试目的 | 验证 Ascend 平台在真实推理框架中的端到端行为，包括服务启动、推理输出、吞吐与稳定性。 |
| 预期结果 | 服务可启动；NPU 利用率正常；输出正确；吞吐、延迟和显存/片上内存占用可解释。 |
| 工具 / 前提 | Ascend 环境、CANN、MindSpore 或 vLLM-MindSpore 已安装；模型权重可用。 |

#### 步骤
1. 优先跑项目指定模型或最接近上线模型的蒸馏版。
2. 验证单实例服务可启动，再做并发压测。
3. 同步记录 `npu-smi` 使用率、功耗、温度与错误日志。

#### 完整命令
```bash
source /usr/local/Ascend/ascend-toolkit/set_env.sh
python3 - <<'PY'
import mindspore as ms
print("MindSpore", ms.__version__)
print("Device target check done")
PY

# 若已部署 vLLM-MindSpore，请按实际版本执行对应 serve 命令
echo "请在已适配环境中启动 vLLM-MindSpore 或 MindSpore 推理服务，并记录 TTFT/TPOT/TPS"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `set_env.sh` | 加载 Ascend 运行时 | 所有推理服务前置 | 必须固定 |
| `MindSpore version` | 框架版本 | 与 CANN 兼容矩阵一致 | 否则结果不可比 |
| `服务化验证` | 不是只跑脚本 | 必须测真实请求路径 | 面向上线 |
| `npu-smi 监控` | 同步监控设备状态 | 证明服务真的在用 NPU | 避免 CPU 回退 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `TTFT/TPOT/TPS` | 核心推理 KPI | 稳定 | 异常 | 查图编译/并发/内存策略 |
| `AICore%` | NPU 利用率 | 与负载匹配 | 偏低 | 服务未充分利用硬件 |
| `memory usage` | 内存占用 | 与模型规模相符 | 异常 | 查权重与 batch |
| `error log` | 框架/驱动报错 | 无 | 有 | 先抓现场再调参 |

#### Pass / Fail 判断标准
**Pass：**
- Ascend 端到端服务可用；
- KPI 与资源占用可解释。

**Fail：**
- 服务不稳、利用率异常、推理结果不正确。

#### 常见问题排查
1. **服务起得来但利用率低**：看请求并发和 batch 策略。
2. **图编译耗时长**：区分冷启动和稳态，报告里必须分开记。


### 16.5 KPI A/B 对比、Throughput-Latency-Power 三角平衡与验收结论

| 项目 | 内容 |
|---|---|
| 测试名称 | KPI A/B 对比、Throughput-Latency-Power 三角平衡与验收结论 |
| 测试目的 | 把不同平台、不同驱动、不同功率限制、不同并行策略下的真实业务 KPI 统一成可签字的验收口径。 |
| 预期结果 | 形成统一 KPI 表：TTFT、TPOT、TPS/QPS、功耗、温度、错误率、稳定性，并给出推荐配置。 |
| 工具 / 前提 | 已完成至少两组可比配置测试。 |

#### 步骤
1. 明确 A/B 方案，例如：默认功率上限 vs 限功率、默认并行 vs 优化并行、不同框架版本。
2. 统一输入数据、并发、token 长度、上下文长度和测试时长。
3. 输出表格与结论：哪套配置最适合上线，哪套配置只适合追峰值。

#### 完整命令
```bash
echo "建议输出 CSV 字段：platform, model, parallel, context_len, concurrency, ttft_ms, tpot_ms, tps, qps, power_w, temp_c, error_rate, result"
```

#### 逐参数详细解析
| 参数 | 含义 | 为何要看 | 建议/注意事项 |
|---|---|---|---|
| `platform` | 平台组合 | 例如 B200x8 / Ascend950x8 | 便于横向比较 |
| `context_len/concurrency` | 测试条件 | 必须统一 | 否则结果不可比 |
| `ttft/tpot/tps` | 核心业务 KPI | 延迟和吞吐都要看 | 不能只给一个数字 |
| `power/temp` | 功耗与温度 | 帮助做上线平衡 | 是交付级验证必需项 |

#### 输出字段专用表格
| 字段 | 含义 | 正常范围示例 | 异常情况 | 排查方法 |
|---|---|---|---|---|
| `best throughput config` | 最高吞吐配置 | 不一定适合上线 | 可能功耗过高 | 单独标记 |
| `best latency config` | 最佳低时延配置 | 适合交互场景 | 吞吐可能下降 | 单独标记 |
| `balanced config` | 最均衡配置 | 推荐上线 | 最重要结论 | 需签字 |
| `error_rate` | 错误率 | 接近 0 | 非 0 | 不能放行 |

#### Pass / Fail 判断标准
**Pass：**
- 有统一 KPI 和推荐配置；
- 结论可签字、可复现。

**Fail：**
- 条件不统一导致结果不可比；
- 只给峰值不考虑功耗/温度/稳定性。

#### 常见问题排查
1. **峰值最高的不一定是上线最优**：很多时候均衡配置更有价值。
2. **KPI 很好但错误率不为 0**：真实上线依然不可接受。



# 附录 A：完整测试报告模板（可直接复制）

## A.1 首页

| 字段 | 填写内容 |
|---|---|
| 项目名称 |  |
| 项目编号 |  |
| 测试单号 |  |
| 客户 / 部门 |  |
| 设备厂商 / 型号 |  |
| 节点数量 / 集群规模 |  |
| 序列号范围 |  |
| 测试地点 |  |
| 测试周期 |  |
| 执行人 |  |
| 见证人 / 审核人 |  |
| 最终结论 | Pass / Conditional Pass / Fail |

## A.2 版本冻结页

| 类别 | 版本 | 备注 |
|---|---|---|
| BIOS |  |  |
| BMC / iBMC |  |  |
| OS / Kernel |  |  |
| NIC Firmware |  |  |
| RAID / HBA Firmware |  |  |
| SSD Firmware |  |  |
| NVIDIA Driver / CUDA / DCGM / TensorRT |  |  |
| ROCm / AMD GPU Driver |  |  |
| Ascend Driver / Firmware / CANN / MindSpore |  |  |
| DPU / SmartNIC Firmware |  |  |
| 交换机 / RoCE 关键配置版本 |  |  |

## A.3 配置摘要页

| 维度 | 摘要 |
|---|---|
| CPU |  |
| 内存 |  |
| 存储 |  |
| 网络 |  |
| GPU / NPU / TPU / DPU |  |
| 电源 / 散热 |  |
| 机架 / 网络 / 供电环境 |  |

## A.4 分模块结果页模板

### 模块名称：____________

| 子项 | 结果 | 关键指标 | 证据路径 | 备注 |
|---|---|---|---|---|
| 基线采集 |  |  |  |  |
| 功能验证 |  |  |  |  |
| 性能验证 |  |  |  |  |
| 长稳验证 |  |  |  |  |
| 升级回归 |  |  |  |  |
| 风险结论 |  |  |  |  |

## A.5 AI 业务 KPI 页模板

| 平台 | 模型 | 并行策略 | 上下文长度 | 并发 | TTFT(ms) | TPOT(ms) | TPS/QPS | 功耗(W) | 温度(°C) | 错误率 | 结论 |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
|  |  |  |  |  |  |  |  |  |  |  |  |

## A.6 风险与整改闭环模板

| 风险 ID | 风险描述 | 发现模块 | 严重级别 | 临时措施 | 根因分析 | 永久措施 | 责任人 | 截止时间 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
|  |  |  | P1/P2/P3 |  |  |  |  |  |  |

---

# 附录 B：分模块常见问题排查速查表（含华为专栏）

| 模块 | 现象 | 通用优先排查 | 华为 / Kunpeng / Ascend 专栏 | 国际厂商专栏 |
|---|---|---|---|---|
| 系统信息 | 基线包缺项 | 先确认 root、工具安装、磁盘空间 | 带外 iBMC / Redfish 补采；Ascend 需补 `npu-smi` | NVIDIA/AMD 补 `nvidia-smi`/`rocm-smi` |
| CPU | 线程数少一半 | BIOS SMT/超线程是否关闭 | Kunpeng 平台同时核查绑核策略与 Arm 原生镜像 | Xeon/EPYC 核查 governor、C-state |
| BIOS | 变更后少卡 | Above 4G / BAR / PCIe bifurcation | 灵衢互联、Ascend 开关、HCCS 相关项 | Resizable BAR、NVSwitch 相关固件 |
| 内存 | 容量对但性能低 | 插法、通道、NUMA、频率训练 | TaiShan 超节点先看池化/共享配置 | x86 平台看 Node Interleaving |
| 网络 | 单机 iperf 正常，多机业务差 | RSS/IRQ/NUMA/PFC/ECN | 超节点/资源池场景先看互联域健康 | RoCE/IB 看交换机无损与队列 |
| 存储 | 单盘健康，多盘性能差 | HBA/背板/条带/缓存策略 | 池化 SSD 先查池状态与映射 | NVMe 背板/PCIe 开关/retimer |
| RAID | 性能低或重建慢 | 缓存策略、保护电池、成员盘 | 国产平台同样必须固定缓存策略 | storcli/perccli 工具链一致 |
| PSU/热 | 长时后掉速 | 风扇策略、风道、环境温度、功率封顶 | Ascend / 超节点重点看群组热点 | GB200/HGX/MI325X 看液冷与相邻卡热耦合 |
| PCIe | 卡都在但性能差 | `LnkSta` 降速降宽、AER | 先看 Ascend / DPU 槽位与互联 | 看 NVLink/NVSwitch 或 IF 拓扑 |
| GPU | 训练偶发报错 | 温度、功耗、Xid/RAS、ECC | 与华为主机混配时加看 BAR 与散热互扰 | H200/B200 看 DCGM/Xid；MI325X 看 ROCm/RAS |
| NPU | 任务启动但 AICore 低 | 框架是否真正上卡、数据供给、拓扑 | `npu-smi info/usages/topo/hccs`、CANN 兼容矩阵 | 无 |
| TPU | 资源分到了但吞吐低 | 编译/稳态分开、host 输入、存储 | 无 | GKE / Cluster Director / GCS 路径 |
| DPU | 规则存在但没加速 | 是否真正 `in_hw`、Host/Arm 双侧是否健康 | 与 Kunpeng/TaiShan 组合要看 IOMMU 与 SR-IOV | BlueField 看 devlink/DOCA/OVS |
| 固件升级 | 版本升了但行为怪 | 做前后 diff、最小回归、必要时回退 | iBMC/Redfish 对比、Ascend 固件兼容链 | BMC/NIC/SSD/GPU 固件联动回归 |
| 整机烧机 | 单项都过，组合失败 | 功耗峰值、热耦合、链路抖动、日志 | Huawei + NVIDIA/AMD 重点看功耗/温度互扰 | 多厂商驱动共存与容器 runtime |
| AI 端到端 | 峰值高但上线差 | 冷启动 vs 稳态、TTFT/TPOT/TPS、错误率 | CANN/MindSpore/vLLM-MindSpore 路径核查 | vLLM/TensorRT/ROCm 版本路径核查 |

---

# 附录 C：通过标准与推荐测试时长汇总表

| 模块 | 最低通过标准 | 推荐最小时长 | 关键扩展时长（新品/首批/集群） |
|---|---|---:|---:|
| 系统基线采集 | 证据完整、版本冻结清晰 | 0.5h | 1h |
| CPU | 无 MCE/无热降频/吞吐稳定 | 1h | 8~24h |
| BIOS/UEFI | 模板生效、OS 层复核通过 | 0.5h | 1h |
| 内存 | 无 UE、无持续 CE、本地/远端关系合理 | 1h | 4~8h |
| 网络 | 链路正常、吞吐/时延达标、RDMA 正常 | 1h | 4h |
| 存储 | 健康正常、性能无掉队 | 1h | 4h |
| RAID | 阵列/重建/一致性正常 | 1h | 4h+ |
| PSU/散热 | 冗余正常、热浸泡不过限 | 1h | 8h |
| PCIe | 无少卡/无降配/AER 受控 | 0.5h | 2h |
| GPU | 无掉卡/Xid/ECC 异常 | 1h | 8h |
| NPU | 拓扑/HCCS/CANN/单卡/多卡通过 | 1h | 8h+ |
| TPU | 资源、框架、Slice 正常 | 0.5h | 2h+ |
| DPU | 双侧可用、offload 生效、隔离正确 | 1h | 4h |
| 固件升级 | 前后快照与回归通过 | 1h | 2h |
| 整机烧机 | 24h 组合压测无故障 | 24h | 72h |
| AI 端到端 | 真实服务 KPI 达标 | 1h | 按模型矩阵扩展 |

---

# 附录 D：常用监控命令速查（npu-smi vs nvidia-smi vs rocm-smi）

| 目标 | Ascend / NPU | NVIDIA / GPU | AMD / GPU |
|---|---|---|---|
| 设备盘点 | `npu-smi info` | `nvidia-smi -L` | `rocm-smi --showproductname --showbus` |
| 详细状态 | `npu-smi info -t usages` | `nvidia-smi -q` | `rocm-smi --showtemp --showpower --showuse --showmemuse` |
| 健康状态 | `npu-smi info -t health` | `dcgmi health -c` / `nvidia-smi -q -d ERROR` | `rocm-smi --showrasinfo` |
| 拓扑 | `npu-smi info -t topo` / `-t hccs` | `nvidia-smi topo -m` | `rocminfo` / 平台拓扑工具 |
| 实时监控 | `npu-smi info watch -d 5` | `watch -n 5 nvidia-smi ...` | `watch -n 5 rocm-smi ...` |
| 长稳烧机 | 框架 MatMul / 训练负载 | `gpu-burn`, `dcgmi diag` | ROCm 负载 / 业务级负载 |

---

# 附录 E：最终放行判定建议

## E.1 可直接放行（Pass）

满足以下全部条件：
1. 所有模块均通过或仅存在不影响上线的低风险观察项；
2. 无未闭环的 P1/P2 级硬件风险；
3. 24h 整机烧机通过（关键平台建议 72h）；
4. AI 端到端 KPI 达到目标；
5. 报告、日志、哈希、版本冻结单完整可审计。

## E.2 条件放行（Conditional Pass）

满足以下条件之一：
- 功能正常，但性能未完全达到目标且客户接受；
- 功耗/温度处于边界，需限功率或限环境温度上线；
- 某高级能力（如 CXL、池化、MIG、多租 offload）暂不启用，基础业务可上线。

必须附带：
- 限制条件；
- 风险说明；
- 后续整改计划；
- 触发回退的阈值。

## E.3 不予放行（Fail）

出现以下任一项：
- 掉卡、掉盘、重启、AER Fatal、Xid、UE、HCCL/HCCS 致命异常；
- 关键模块无证据链；
- 版本冻结不清楚；
- 24h 整机烧机不过；
- 真实业务错误率不为 0 且无法解释；
- 机架供电/散热预算不足。

---

# 结语

真正专业的服务器硬件整合测试，不是“把所有工具都跑一遍”，而是：

- 知道**先做什么、后做什么**；
- 知道**什么现象算真的通过、什么只是暂时看起来没问题**；
- 知道**出现异常时第一时间抓什么证据**；
- 知道**如何把单机、机架、集群、框架和业务串成一条完整证据链**。

本手册的最佳使用方式不是“读完收藏”，而是把其中的：
- 版本冻结表  
- 模块执行清单  
- 日志目录规范  
- KPI 模板  
- 风险闭环表  

直接落到你的项目里，形成团队标准动作。