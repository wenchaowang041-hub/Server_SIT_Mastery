# Linux 试跑手册

这份手册按“明天到公司 Linux 环境直接试跑”来写，只覆盖当前原框架主线。

## 1. 控制器前置条件

建议控制器主机安装：

- `python3.11+`
- `python3-venv`
- `openssh-client`
- `ipmitool`

如果是 Ubuntu/Debian：

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-venv openssh-client ipmitool
```

## 2. 安装控制器依赖

在仓库根目录执行：

```bash
bash scripts/bootstrap_controller_linux.sh
```

或者手动执行：

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements-controller.txt
python TestController/StartController.py check-environment
```

## 3. 配置实际清单

优先复制下面两个模板之一：

- [linux_template.yaml](../TestController/UserFiles/ServerLists/linux_template.yaml)
- [json_template.json](../TestController/UserFiles/ServerLists/json_template.json)

建议先新建一个真实清单，例如：

- `TestController/UserFiles/ServerLists/lab_linux.yaml`

至少填这些字段：

- `targets[].name`
- `targets[].host`
- `targets[].username`
- `targets[].password`
- `targets[].bmc.*`，如果要跑 `power_cycle`

如果远端目录不是默认的 `~/sit-auto`，同时改：

- [user-settings.json](../Toolkit/Settings/user-settings.json)

## 4. 先做预检查

检查套件定义：

```bash
source .venv/bin/activate
python TestController/StartController.py validate-suite --name linux_smoke
```

检查清单定义：

```bash
python TestController/StartController.py validate-server-list --name lab_linux
```

检查 SSH 联通：

```bash
python TestController/StartController.py validate-server-list --name lab_linux --probe-ssh
```

联通、套件、清单一起检查：

```bash
python TestController/StartController.py preflight --suite linux_smoke --server-list lab_linux --probe-ssh
```

如果要验证 BMC，再加：

```bash
python TestController/StartController.py preflight --suite linux_power_cycle --server-list lab_linux --probe-ssh --probe-bmc
```

预检查报告会落到：

- `Results/_diagnostics/`

## 5. 第一轮建议怎么跑

先跑最轻的：

```bash
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux
```

验证目标机侧工具和测试脚本：

```bash
python TestController/StartController.py run-suite --name linux_toolkit_tools --server-list lab_linux
```

如果先不想同步 `Toolkit/UserFiles` 或 `Toolkit/Settings`：

```bash
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --skip-user-sync --skip-settings-sync
```

按标签筛选：

```bash
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --labels smoke
```

只跑某几个目标：

```bash
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --targets node01 node02
```

多台机器可以并发跑，`--jobs` 表示同一 ServerList 里同时执行的 target 数：

```bash
python TestController/StartController.py run-suite --name linux_smoke --server-list lab_linux --jobs 2
```

## 6. 解析结果

解析最近一次 suite 结果：

```bash
python TestController/StartController.py parse-results --suite linux_smoke
```

解析最近一次 master suite 结果：

```bash
python TestController/StartController.py parse-results --master-suite linux_smoke
```

解析最近一次 plan 结果：

```bash
python TestController/StartController.py parse-results --plan local_trial
```

## 7. 如果要批量跑

计划文件模板：

- [plan_template.yaml](../TestController/UserFiles/Plans/plan_template.yaml)

本地演示计划：

- [local_trial.yaml](../TestController/UserFiles/Plans/local_trial.yaml)

执行计划：

```bash
python TestController/StartController.py run-plan --name local_trial
```

临时覆盖计划里的并发数：

```bash
python TestController/StartController.py run-plan --name local_trial --jobs 2
```

## 8. 明天现场排障时先看哪里

先看控制器汇总：

- `Results/<suite>/Run-<timestamp>/summary.json`
- `Results/<suite>/Run-<timestamp>/controller.log`

再看单步结果：

- `Results/<suite>/Run-<timestamp>/<target>/<phase>-<test>/stdout.log`
- `Results/<suite>/Run-<timestamp>/<target>/<phase>-<test>/stderr.log`
- `Results/<suite>/Run-<timestamp>/<target>/<phase>-<test>/metadata.json`

## 9. 当前明确边界

- 真正的 Linux SSH/BMC 链路还需要你明天拿公司环境做第一次实机验证
- `power_cycle` 依赖控制器本地可用 `ipmitool` 或目标 BMC 支持 Redfish
- 工作区里仍保留更早的 `app/` Web scaffold，但明天试跑不需要用它
