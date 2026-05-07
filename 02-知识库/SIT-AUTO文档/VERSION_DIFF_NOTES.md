# 新旧版本对照笔记

## 旧版

- 版本：`LTC.3.11.1`
- 时间：`2021-11-17`
- 特征：
  - `TestController + Toolkit + ToolkitUserFiles`
  - 远程执行明显依赖 `PsExec`、共享目录、文件拷贝
  - 测试套件以 PowerShell 哈希表脚本为主

## 新版

- 版本：`TC.6.5.4_GS_20240613_CP`
- Release Notes 日期：`2024-05-22`
- 体量变化：
  - `TestController` 约从 `164` 个文件增加到 `373`
  - `Toolkit` 约从 `599` 个文件增加到 `1147`
  - `ToolkitUserFiles` 约从 `3.8GB` 增加到 `6.2GB`

## 对 Linux 版最相关的变更点

### 1. 配置外置

新版新增：

- `ToolkitSettings/user-settings.json`

这说明新版已经不再把所有运行配置都硬编码在脚本里，而是转向“外置配置 + 运行时合并”。

### 2. 批量入口增强

新版 `StartController.ps1` 和 `Run-WcsMasterSuite.ps1` 说明它已经更偏向：

- Headless 执行
- 多个 ServerList 批量调度
- 流水线场景复用

### 3. Toolkit 初始化模块化

新版 `Toolkit/StartToolkit.ps1` 明显更强调：

- 模块注册
- 统一初始化
- Settings Loader
- 环境变量覆盖

### 4. ServerList 不再只有 PowerShell

新版 `TestControllerUserFiles/ServerLists/JSONTemplate.json` 说明 ServerList 已经开始支持 JSON 风格描述。

### 5. ToolkitSettings 需要随运行一起分发

新版里不仅有 `Toolkit` 和 `ToolkitUserFiles`，还明确有独立的 `ToolkitSettings`。这意味着控制器在远端执行前，应该把设置目录一起同步过去。

### 6. 远程执行机制变化

Release Notes 6.2.1 明确提到：

- `Remove PSExec for remote execution tasks in SUT`

这说明新版在逐步摆脱老的 PsExec 模式。

## 我已经吸收到当前 Linux 版里的点

### 已落地

- 保留原框架目录：
  - `TestController`
  - `Toolkit`
  - `TestController/UserFiles`
  - `Toolkit/UserFiles`
  - `Toolkit/Settings`
- 加入 `run-master-suite` 批量入口
- 套件和 ServerList 支持运行时 `settings` 合并
- 支持 `Toolkit / Toolkit/UserFiles / Toolkit/Settings` 分开同步
- 支持 YAML/JSON 两类 ServerList
- 支持目标筛选和标签筛选
- 支持计划文件入口 `run-plan`
- 支持同一 ServerList 内 target 级并发：`--jobs`
- 支持试跑前联合检查 `preflight`
- 支持结果解析入口 `parse-results`
- 修掉远端 `~/...` 路径在 SFTP/结果目录上的展开问题

### 还没完全落地

- `Run-TcSuite` 风格的计划文件入口
- `Parse-*` 风格的结果解析器
- 跨 ServerList 并发调度和实机同步压测
- 更完整的 Linux/BMC 实机联调
