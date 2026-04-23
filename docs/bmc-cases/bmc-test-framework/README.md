# BMC Web 自动化测试框架 v2.0

基于 **Playwright + pytest + Allure** 的服务器 BMC Web UI 自动化测试框架。

## 技术栈

| 组件 | 技术 | 版本 |
|------|------|------|
| 浏览器自动化 | Playwright | >=1.40 |
| 测试框架 | pytest | >=8.0 |
| 报告 | Allure | >=2.13 |
| 配置 | PyYAML | >=6.0 |
| Python | CPython | >=3.10 |

## 快速开始

```bash
# 安装依赖
pip install -e .
python -m playwright install chromium

# 运行测试
pytest tests/ -v --bmc-model default

# 指定机型 + IP
pytest tests/ -v --bmc-model n810t_a2 --bmc-ip 10.121.176.137

# 无头模式
pytest tests/ -v --bmc-model default --headless

# 生成 Allure 报告
allure generate reports/allure-results -o reports/allure-report --clean
allure open reports/allure-report
```

## 架构

```
config/          # YAML 配置（全局设置 + 机型模板）
core/            # 核心层（驱动工厂、基础页面、配置加载器）
pages/           # 页面对象层（POM 模式）
tests/           # 测试用例（pytest + Allure）
reports/         # 测试报告输出
```

## 添加新机型

1. 在 `config/bmc_models/` 下创建 `model_<名称>.yaml`
2. 覆盖与 `template.yaml` 不同的字段
3. 运行: `pytest tests/ -v --bmc-model <名称>`

## 已修复问题

- 硬编码凭据 → YAML 配置注入
- `submit()` 调 `input()` → 正确 `click()`
- `click_changeuser()` 缺失 → 已实现
- 断言变量用错 → 每个 assert 正确对齐
- 重复 LoginPage → 统一单文件
- 类名冲突 → 独立 Test 类
- 缩进错误/拼写错误 → 全部修复
- `.venv` 打包 → `.gitignore` 排除
