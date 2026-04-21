# Server-SIT-Mastery

这个仓库用于持续沉淀服务器硬件整合测试（SIT）相关的学习资料、现场记录、脚本和正式文档。

## 先看哪里

1. [docs/README.md](docs/README.md)
2. [docs/manual/README.md](docs/manual/README.md)
3. [docs/100-day-plan/README.md](docs/100-day-plan/README.md)
4. [daily-work-学习总结/README.md](daily-work-学习总结/README.md)
5. [practice/scripts-练手脚本/README.md](practice/scripts-练手脚本/README.md)

## 目录分工

### `docs/`

正式知识库，放长期可复用的内容：

- 手册
- 项目案例
- 百日计划资料
- SOP 和速查表

### `daily-work-学习总结/`

日常沉淀区，放当天输入和阶段记录：

- 每日工作记录
- Day 学习笔记
- 临时分析和复盘
- 现场案例草稿

### `practice/`

练手脚本和自动化实验区，按测试主题分类收纳。

### `interview/`

面试题、问答整理和表达训练材料。

### `local/`

本地私有区，不纳入 Git：

- 本机缓存文件
- 临时连接信息
- 不适合提交到仓库的个人环境内容

## 当前整理约定

- 每日工作记录统一命名为 `YYYY-MM-DD-工作记录.md`
- Day 学习笔记统一命名为 `DayN-主题.md`
- 正式案例优先沉淀到 `docs/bmc-cases/`
- 脚本按功能放到 `practice/scripts-练手脚本/` 的对应子目录

## 顶层只保留什么

根目录尽量只保留：

- 总入口文件
- 项目级配置
- 一级分类目录

不再把数据库缓存、连接信息、临时导出文件直接放在顶层。
