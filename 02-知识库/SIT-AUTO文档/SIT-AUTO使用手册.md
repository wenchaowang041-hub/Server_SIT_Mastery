# SIT-AUTO 自动化测试平台使用手册

适用路径：`E:\桌面\SIT-AUTO`

当前平台主线是 `TestController + Toolkit` 风格的 Linux 自动化测试框架。控制器负责读取测试套件和服务器清单，向目标机同步 Toolkit，远程执行命令，回收结果，并生成汇总报告。

## 1. 目录说明

```text
SIT-AUTO/
  TestController/            控制器代码和内置测试套件
  Toolkit/                   目标机执行端
    UserFiles/               目标机侧附加文件
    Settings/                运行时设置
  TestController/UserFiles/  用户侧服务器清单和计划文件
  Results/                   测试结果和诊断报告
  docs/                      使用文档
  scripts/                   启动和环境脚本
  tests/                     本地自动化测试
```

日常最常改的是：

- `TestController/UserFiles/ServerLists/<清单名>.yaml`
- `TestController/UserFiles/Plans/<计划名>.yaml`
- `Toolkit/Settings/user-settings.json`

不要直接修改参考 ZIP。参考包只用于对照原始架构。

## 2. 到底要复制哪些文件到服务器

服务器本地只需要目标执行端，不需要整个项目。

需要复制或同步到服务器的目录只有：

```text
Toolkit/
Toolkit/UserFiles/
Toolkit/Settings/
```

不要复制这些目录到服务器作为测试包：

```text
TestController/
tests/
docs/
Results/
.runtime/
_archive/
_references/
CSIToolkit.External.6.5.4_CP_GoldenSample_20240613.zip
```

原因：

- `TestController` 只在公司电脑上运行，负责调度。
- `TestController/UserFiles` 里的 ServerList 和 Plan 是控制器配置，不是目标机执行包。
- `Results` 是回收结果，不是输入包。
- 参考 ZIP 很大，只用于对照原始框架，不能整包丢到目标机上跑。

正常情况下你不需要手工复制。执行 `run-suite` 时，控制器会通过 SSH/SFTP 自动把下面三类同步到目标机：

```text
Toolkit -> ~/sit-auto/Toolkit
Toolkit/UserFiles -> ~/sit-auto/Toolkit/UserFiles
Toolkit/Settings -> ~/sit-auto/Toolkit/Settings
```

也就是说，真实使用时优先走这一条：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux
```

如果你只是想先生成一个“目标机测试包”手工上传，可以在公司电脑上执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_target_bundle.ps1
```

生成文件：

```text
dist/sit-auto-target-toolkit.zip
```

如果旧 zip 被占用，脚本会自动生成带时间戳的新文件，例如：

```text
dist/sit-auto-target-toolkit-20260429_140448.zip
```

手工上传到服务器后，在服务器上解压到 `~/sit-auto`：

```bash
mkdir -p ~/sit-auto
unzip -o sit-auto-target-toolkit.zip -d ~/sit-auto
ls ~/sit-auto
```

解压后服务器上应该能看到：

```text
~/sit-auto/Toolkit
~/sit-auto/Toolkit/UserFiles
~/sit-auto/Toolkit/Settings
```

手工验证 Toolkit 能不能启动：

```bash
python3 ~/sit-auto/Toolkit/invoke_remote.py --help
```

## 3. 第一次使用前检查

在 PowerShell 进入项目根目录：

```powershell
cd E:\桌面\SIT-AUTO
```

检查控制器环境：

```powershell
python TestController/StartController.py check-environment
```

通过标准：

- `status: PASSED`
- Python 模块 `yaml`、`paramiko` 可用
- `TestController`、`Toolkit`、`Toolkit/Settings/user-settings.json` 存在
- 如果要跑 BMC 电源类测试，`ipmitool` 最好可用

查看当前可用内容：

```powershell
python TestController/StartController.py list-suites
python TestController/StartController.py list-server-lists
python TestController/StartController.py list-plans
```

## 4. 本机自检

先用本地 demo 验证平台链路，不接触真实机器：

```powershell
python TestController/StartController.py preflight --suite controller_smoke --server-list local_demo
python TestController/StartController.py run-plan --name local_trial --jobs 2
python TestController/StartController.py parse-results --plan local_trial --json
```

通过标准：

- `preflight` 返回 `status: PASSED`
- `run-plan` 中所有 target 显示 `PASSED`
- `parse-results` 返回 `overall_status: PASSED`

如果本机自检不过，先不要连真实 DUT。

## 5. 配置真实 Linux 目标机

从模板复制一个真实清单：

```powershell
Copy-Item TestController\UserFiles\ServerLists\linux_template.yaml TestController\UserFiles\ServerLists\lab_linux.yaml
```

编辑：

```text
TestController/UserFiles/ServerLists/lab_linux.yaml
```

最小 SSH 清单示例：

```yaml
description: 公司实验室 Linux 目标
settings:
  remote:
    root_dir: ~/sit-auto
    toolkit_dir: ~/sit-auto/Toolkit
    toolkit_user_dir: ~/sit-auto/Toolkit/UserFiles
    toolkit_settings_dir: ~/sit-auto/Toolkit/Settings
    results_dir: ~/sit-auto/Results
variables:
  environment: lab
defaults:
  executor_type: ssh
  port: 22
  labels:
    - linux
targets:
  - name: node01
    host: 10.x.x.x
    username: root
    password: change-me
    labels:
      - smoke
```

如果要跑 BMC 电源循环，再给对应 target 增加：

```yaml
    bmc:
      provider: ipmi
      address: 10.x.x.x
      username: admin
      password: change-me
```

注意：

- 不要把真实密码提交到 Git。
- 不要用模板里的 `192.168.1.100`、`192.168.1.200` 直接跑。
- `power_cycle` 只允许在确认 BMC IP 和目标机对应关系后执行。

## 6. 配置远端目录

默认远端目录是：

```text
~/sit-auto
```

对应配置在：

```text
Toolkit/Settings/user-settings.json
```

默认值：

```json
{
  "remote": {
    "root_dir": "~/sit-auto",
    "toolkit_dir": "~/sit-auto/Toolkit",
    "toolkit_user_dir": "~/sit-auto/Toolkit/UserFiles",
    "toolkit_settings_dir": "~/sit-auto/Toolkit/Settings",
    "results_dir": "~/sit-auto/Results",
    "python": "python3"
  }
}
```

如果目标机没有 `python3`，需要先安装，或把 `remote.python` 改成实际路径。

## 7. 实机预检查

先检查套件格式：

```powershell
python TestController/StartController.py validate-suite --name linux_smoke
```

检查清单格式：

```powershell
python TestController/StartController.py validate-server-list --name lab_linux
```

检查 SSH：

```powershell
python TestController/StartController.py validate-server-list --name lab_linux --probe-ssh
```

联合预检查：

```powershell
python TestController/StartController.py preflight --suite linux_smoke --server-list lab_linux --probe-ssh
```

如果要跑 BMC 相关套件，再检查 BMC：

```powershell
python TestController/StartController.py preflight --suite linux_power_cycle --server-list lab_linux --probe-ssh --probe-bmc
```

预检查报告位置：

```text
Results/_diagnostics/
```

## 8. 第一轮实机试跑

先跑最轻的 smoke：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux
```

多台机器并发跑：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --jobs 2
```

验证目标机侧工具和测试脚本：

```powershell
python TestController/StartController.py run-suite --name linux_toolkit_tools --server-list lab_linux --jobs 1
python TestController/StartController.py parse-results --suite linux_toolkit_tools --json
```

只跑某些目标：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --targets node01 node02
```

按标签跑：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --labels smoke
```

如果只想验证命令链路，临时跳过用户文件和设置同步：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --skip-user-sync --skip-settings-sync
```

## 9. 回归和批量执行

单个回归套件：

```powershell
python TestController/StartController.py run-suite --name linux_regression --server-list lab_linux --jobs 2
```

多个 ServerList 批量跑同一个套件：

```powershell
python TestController/StartController.py run-master-suite --name linux_smoke --server-lists rack_a rack_b --jobs 2
```

按计划文件跑：

```powershell
python TestController/StartController.py run-plan --name local_trial --jobs 2
```

真实计划文件建议放在：

```text
TestController/UserFiles/Plans/lab_trial.yaml
```

计划文件示例：

```yaml
description: 公司实验室第一轮试跑
defaults:
  skip_toolkit_sync: false
  skip_user_sync: false
  skip_settings_sync: false
  jobs: 2
runs:
  - suite: linux_smoke
    server_list: lab_linux
  - suite: linux_regression
    server_list: lab_linux
    labels_any:
      - smoke
```

执行：

```powershell
python TestController/StartController.py run-plan --name lab_trial
```

## 10. BMC 电源循环测试

只有在下面条件全部满足后再跑：

- SSH 已通过 `--probe-ssh`
- BMC 已通过 `--probe-bmc`
- 已确认 BMC IP 和目标机是一一对应关系
- 当前测试窗口允许断电或重启

预检查：

```powershell
python TestController/StartController.py preflight --suite linux_power_cycle --server-list lab_linux --probe-ssh --probe-bmc
```

执行：

```powershell
python TestController/StartController.py run-suite --name linux_power_cycle --server-list lab_linux --targets node01
```

不确认 BMC 映射时，不要执行 `linux_power_cycle`。

## 11. 结果查看

解析最近一次 suite 结果：

```powershell
python TestController/StartController.py parse-results --suite linux_smoke --json
```

解析最近一次 master suite 结果：

```powershell
python TestController/StartController.py parse-results --master-suite linux_smoke --json
```

解析最近一次 plan 结果：

```powershell
python TestController/StartController.py parse-results --plan lab_trial --json
```

重点看这些文件：

```text
Results/<suite>/Run-<timestamp>/summary.json
Results/<suite>/Run-<timestamp>/summary.csv
Results/<suite>/Run-<timestamp>/controller.log
Results/<suite>/Run-<timestamp>/<target>/<phase>-<test>/stdout.log
Results/<suite>/Run-<timestamp>/<target>/<phase>-<test>/stderr.log
Results/<suite>/Run-<timestamp>/<target>/<phase>-<test>/metadata.json
```

判定规则：

- `summary.json` 里 `failures: 0` 表示套件通过
- `parsed_summary.json` 里 `overall_status: PASSED` 表示解析汇总通过
- 单步失败时先看对应目录下的 `stderr.log`

## 12. 常见问题处理

### 11.1 SSH 探测失败

检查：

```powershell
python TestController/StartController.py validate-server-list --name lab_linux --probe-ssh
```

重点确认：

- IP 是否能 ping 通
- 端口是否为 22
- 用户名和密码是否正确
- 目标机是否允许密码登录
- 目标机是否有 `python3`

### 11.2 Toolkit 同步失败

重点确认：

- 目标机 `~/sit-auto` 是否有写权限
- 磁盘空间是否足够
- `Toolkit/Settings/user-settings.json` 里的远端目录是否正确

可以先跳过部分同步验证命令执行链路：

```powershell
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --skip-user-sync --skip-settings-sync
```

### 11.3 BMC 探测失败

重点确认：

- `ipmitool` 是否可用
- BMC IP、用户名、密码是否正确
- 控制器到 BMC 网络是否可达
- BMC 是否启用 IPMI 或 Redfish

IPMI 手动检查示例：

```powershell
ipmitool -I lanplus -H <BMC_IP> -U <USER> -P <PASS> chassis power status
```

### 11.4 结果目录里有失败

按顺序看：

1. `Results/<suite>/Run-<timestamp>/summary.json`
2. `Results/<suite>/Run-<timestamp>/controller.log`
3. 失败步骤目录下的 `stderr.log`
4. 失败步骤目录下的 `metadata.json`

## 13. 推荐正式使用顺序

第一次真实环境使用：

```powershell
python TestController/StartController.py check-environment
python TestController/StartController.py validate-server-list --name lab_linux --probe-ssh
python TestController/StartController.py preflight --suite linux_smoke --server-list lab_linux --probe-ssh
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --jobs 2
python TestController/StartController.py parse-results --suite linux_smoke --json
```

smoke 连续通过后再跑：

```powershell
python TestController/StartController.py run-suite --name linux_regression --server-list lab_linux --jobs 2
python TestController/StartController.py parse-results --suite linux_regression --json
```

BMC 类测试最后跑，并且只对确认过映射的目标执行：

```powershell
python TestController/StartController.py preflight --suite linux_power_cycle --server-list lab_linux --probe-ssh --probe-bmc
python TestController/StartController.py run-suite --name linux_power_cycle --server-list lab_linux --targets node01
```

## 14. 不要做的事

- 不要用模板 IP 和模板密码跑真实测试。
- 不要在未确认 BMC 映射时执行电源循环。
- 不要把真实密码提交到 Git。
- 不要把参考 ZIP 提交到 Git。
- 不要先跑长回归，先跑 `linux_smoke`。
