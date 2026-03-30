大家好，我是JACK，本篇是服务器测试百日学习计划Day10。

前几天我们用 fio 和 iostat 手工做了顺序/随机读写基线测试，今天换个思路——用 Python 写一个存储自动检测脚本 `storage_check.py`，把之前手工敲的 lsblk、nvme list 等命令自动化起来，输出结构化的检测报告。

---

## 一、为什么要写自动检测脚本

手工敲命令有三个问题：

- **重复劳动**：每台新服务器上机都要敲同一套命令
- **容易漏项**：记不住检查哪几个命令，靠人工盯着输出容易遗漏
- **结果不规范**：每次输出格式不一样，不方便对比和存档

一个自动检测脚本能解决这三个问题，同时也是从"会用命令"向"会写测试工具"迈出的第一步——这正是测试工程师和系统工程师的分水岭。

---

## 二、Day10 目标

编写 `storage_check.py v1`，实现以下功能：

- 调用 lsblk，获取所有磁盘设备的名称、容量、类型
- 调用 nvme list，获取 NVMe 盘的型号、SN、固件版本
- 统计磁盘总数和 NVMe 数量
- 输出异常提示（NVMe 数量不足、盘容量为空、命令执行失败等）

---

## 三、脚本设计思路

脚本分 4 个输出区块：

```
[基础信息]    主机名 / 时间 / 内核版本
[lsblk 解析]  所有磁盘设备列表
[nvme list 解析]  NVMe 设备详情
[异常提示]    WARN 汇总
[结论]        一句话总结
```

核心技术点：用 Python 的 `subprocess` 模块调用 shell 命令，解析输出，结构化展示。

---

## 四、storage_check.py v1 完整代码

```python
#!/usr/bin/env python3
"""
storage_check.py v1
自动检测服务器存储配置，调用 lsblk / nvme list，输出检测报告
"""

import json
import shutil
import socket
import subprocess
import sys
from datetime import datetime


def run_cmd(cmd):
    """执行 shell 命令，返回 (ok, stdout, stderr)"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            text=True,
            capture_output=True,
            timeout=10
        )
        return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return False, "", str(e)


def get_kernel():
    ok, out, err = run_cmd("uname -r")
    return out if ok else f"ERROR: {err}"


def get_lsblk_disks():
    """
    调用 lsblk JSON 输出，只取 TYPE=disk 的设备
    """
    ok, out, err = run_cmd("lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINT")
    if not ok:
        return [], [f"lsblk failed: {err}"]

    warnings = []
    disks = []

    try:
        data = json.loads(out)
        for item in data.get("blockdevices", []):
            if item.get("type") == "disk":
                disks.append({
                    "name":       item.get("name", ""),
                    "size":       item.get("size", ""),
                    "type":       item.get("type", ""),
                    "mountpoint": item.get("mountpoint", "")
                })
    except Exception as e:
        return [], [f"lsblk json parse failed: {e}"]

    if not disks:
        warnings.append("No disk found from lsblk")

    return disks, warnings


def parse_nvme_list_text(text):
    """
    解析 nvme list 文本输出
    典型格式: Node  SN  Model  Namespace  Usage  Format  FW Rev
    """
    devices = []
    lines = [line.rstrip() for line in text.splitlines() if line.strip()]

    for line in lines:
        if line.startswith("/dev/nvme"):
            parts = line.split()
            node  = parts[0] if len(parts) > 0 else ""
            sn    = parts[1] if len(parts) > 1 else ""
            model = " ".join(parts[2:-4]) if len(parts) > 6 else ""
            usage = parts[-4] if len(parts) >= 4 else ""
            fw    = parts[-1] if len(parts) >= 1 else ""
            devices.append({
                "node":  node,
                "sn":    sn,
                "model": model,
                "usage": usage,
                "fw":    fw
            })
    return devices


def get_nvme_devices():
    warnings = []

    if shutil.which("nvme") is None:
        return [], ["nvme command not found"]

    ok, out, err = run_cmd("nvme list")
    if not ok:
        return [], [f"nvme list failed: {err}"]

    devices = parse_nvme_list_text(out)
    if not devices:
        warnings.append("No NVMe device found from nvme list")

    return devices, warnings


def build_warnings(disks, nvmes):
    warnings = []
    nvme_count = len(nvmes)

    if nvme_count == 0:
        warnings.append("WARN: NVMe count is 0")
    elif nvme_count < 2:
        warnings.append(f"WARN: NVMe count is low ({nvme_count})")

    for d in disks:
        if not d["size"]:
            warnings.append(f"WARN: disk {d['name']} has empty size")

    return warnings


def main():
    now      = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    hostname = socket.gethostname()
    kernel   = get_kernel()

    disks,  lsblk_warnings = get_lsblk_disks()
    nvmes,  nvme_warnings  = get_nvme_devices()
    extra_warnings         = build_warnings(disks, nvmes)

    print("=" * 60)
    print("storage_check.py v1")
    print("=" * 60)
    print(f"Time     : {now}")
    print(f"Hostname : {hostname}")
    print(f"Kernel   : {kernel}")
    print()

    print("[Disk Summary from lsblk]")
    print(f"Disk count: {len(disks)}")
    for d in disks:
        print(f"  - {d['name']:10s}  size={d['size']:>8s}  "
              f"type={d['type']}  mount={d['mountpoint']}")
    print()

    print("[NVMe Summary from nvme list]")
    print(f"NVMe count: {len(nvmes)}")
    for n in nvmes:
        print(f"  - {n['node']}  sn={n['sn']}  model={n['model']}  "
              f"usage={n['usage']}  fw={n['fw']}")
    print()

    all_warnings = lsblk_warnings + nvme_warnings + extra_warnings
    print("[Warnings]")
    if all_warnings:
        for w in all_warnings:
            print(f"  {w}")
    else:
        print("  none")
    print()

    print("[Conclusion]")
    print(f"  Detected {len(disks)} disks in lsblk, "
          f"including {len(nvmes)} NVMe device(s).")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
```

---

## 五、部署与运行

```bash
# 创建目录
mkdir -p /root/server_lab

# 写入脚本（复制上面代码）
vi /root/server_lab/storage_check.py

# 赋予执行权限
chmod +x /root/server_lab/storage_check.py

# 运行
python3 /root/server_lab/storage_check.py
```

---

## 六、本机实际运行结果

```
============================================================
storage_check.py v1
============================================================
Time     : 2026-03-20 14:25:05
Hostname : bogon
Kernel   : 5.10.0-216.0.0.115.oe2203sp4.aarch64

[Disk Summary from lsblk]
Disk count: 12
  - sda         size= 447.1G  type=disk  mount=None
  - sdb         size= 447.1G  type=disk  mount=None
  - sdc         size= 446.6G  type=disk  mount=None
  - sdd         size= 446.6G  type=disk  mount=None
  - sde         size= 446.6G  type=disk  mount=None
  - sdf         size= 446.6G  type=disk  mount=None
  - sdg         size= 446.6G  type=disk  mount=None
  - sdh         size= 446.6G  type=disk  mount=None
  - sdi         size= 446.6G  type=disk  mount=None
  - sdj         size= 446.6G  type=disk  mount=None
  - nvme0n1     size=   2.9T  type=disk  mount=None
  - nvme1n1     size=   2.9T  type=disk  mount=None

[NVMe Summary from nvme list]
NVMe count: 2
  - /dev/nvme0n1  sn=D77446D401J852  model=DERAP44YGM03T2US  usage=+  fw=D7Y05M1F
  - /dev/nvme1n1  sn=D77446D4017E52  model=DERAP44YGM03T2US  usage=+  fw=D7Y05M1F

[Warnings]
  none

[Conclusion]
  Detected 12 disks in lsblk, including 2 NVMe device(s).
```

---

## 七、结果解读

脚本识别结果和我们之前手工查的完全一致：

| 分类 | 数量 | 设备 |
|------|------|------|
| 磁盘总数（lsblk）| 12 | sda/sdb（Intel SATA）+ sdc~sdj（Broadcom RAID逻辑盘）+ nvme0n1/nvme1n1 |
| NVMe 盘 | 2 | DERAP44YGM03T2US，各 3.2TB，固件 D7Y05M1F |
| 异常提示 | 0 | none |

**验证点：**
- `lsblk -J` 输出 JSON 格式，解析比 grep 文本更可靠
- `nvme list` 识别到 2 块 NVMe，SN 和固件版本都拿到了
- 12 块盘全部有容量信息，无空值，Warnings 为 none

---

## 八、代码逻辑拆解

### subprocess 调用方式

```python
result = subprocess.run(
    cmd,
    shell=True,       # 允许管道等 shell 语法
    text=True,        # stdout/stderr 以字符串返回（不是 bytes）
    capture_output=True,  # 捕获 stdout 和 stderr
    timeout=10        # 超时保护，防止命令卡住
)
```

> 💡 `capture_output=True` 等价于 `stdout=PIPE, stderr=PIPE`，是 Python 3.7+ 的简写。在服务器测试脚本中，一定要加 `timeout` 参数，防止某条命令卡死导致整个脚本挂起。

### lsblk 为什么用 JSON 格式

`lsblk` 默认输出是对齐的文本，不同版本列宽不同，用 split 解析容易出错。加 `-J` 参数输出标准 JSON，解析更稳定：

```bash
lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINT
```

### 异常提示的触发逻辑

```python
# NVMe 数量检查
if nvme_count == 0:
    warnings.append("WARN: NVMe count is 0")
elif nvme_count < 2:
    warnings.append(f"WARN: NVMe count is low ({nvme_count})")

# 盘容量为空检查
for d in disks:
    if not d["size"]:
        warnings.append(f"WARN: disk {d['name']} has empty size")
```

当前触发阈值是 NVMe < 2 就报警，这个数值可以根据不同服务器型号调整（比如 4 卡机就改成 4）。

---

## 九、v1 的局限和后续升级方向

v1 已经满足 Day10 的硬性要求，但还有几个可以继续优化的方向：

| 版本 | 优化方向 |
|------|---------|
| v2 | 加入预期值配置（EXPECTED_NVME_COUNT=2），不符合就报警 |
| v3 | 自动识别盘类型来源（NVMe / SATA直连 / RAID逻辑盘），目前只靠名字区分 |
| v4 | 结果同时保存为 JSON 文件，方便自动化巡检和历史对比 |
| v5 | 结合 lsscsi + storcli 输出，完整标记每块盘的控制器路径 |

---

## 总结

Day10 核心收获：

**一、从手工到自动的第一步。** 之前手工敲 lsblk、nvme list 看结果，现在用脚本一键输出结构化报告，这是测试工程师工具化思维的起点。

**二、subprocess 是 Python 调用系统命令的标准方式。** `run_cmd` 这个封装模式（返回 ok/stdout/stderr，加 timeout）可以直接复用到后续其他检测脚本里。

**三、JSON 格式解析比文本解析更稳定。** lsblk 加 `-J` 是个好习惯，同理很多 Linux 工具都支持 `--json` 输出，优先用 JSON 而不是 grep/awk 解析文本。



欢迎关注 **JACK的服务器笔记**，我们下篇见！
