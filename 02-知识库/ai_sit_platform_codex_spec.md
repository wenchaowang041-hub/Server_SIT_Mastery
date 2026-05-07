# AI-SIT 自动化测试平台 Codex 实施说明书

## 1. 目标

面向 Kunpeng 920 + openEuler + 信创环境，建设一套 **AI-SIT 自动化测试平台**，将测试触发、执行、采集、分析、报告闭环化。

平台核心能力：
- Web UI 发起测试任务
- Orchestrator 按状态机调度 case
- Collector 异步采集日志与传感器
- Adapters 统一封装底层工具输出为 JSON
- LLM Engine 对结果做异常检测 / 根因分析 / BUG 草稿生成
- Report Engine 输出 Word/PDF 报告
- Knowledge Base 做历史案例与失败模式检索

---

## 2. MVP 范围（第一阶段）

首版只做最小闭环，聚焦两个方向：
- Storage 压测：`fio`
- BMC 事件与传感器：`ipmitool`, Redfish(预留)

MVP 交付：
1. 用户从 Web UI 提交一次测试任务
2. 系统在目标机执行 `fio`
3. 异步采集 `ipmitool sel list`、`ipmitool sdr list`
4. 测试完成后生成结构化 JSON 结果
5. LLM 输出摘要：是否异常、异常类型、可能原因
6. 生成 HTML/Markdown 报告

---

## 3. 总体架构

```text
[Web UI]
   |
   v
[FastAPI Backend]
   |---- REST API
   |---- Auth / Config / Task Mgmt
   |
   v
[Test Orchestrator]
   |---- FSM 状态机
   |---- Celery Tasks
   |---- Retry / Timeout / Dependency
   |
   +-----------------------------+
   |                             |
   v                             v
[Collectors]                 [Adapters]
   |                             |
   |                             |---- ipmitool
   |                             |---- fio
   |                             |---- nvme-cli
   |                             |---- iperf3 (phase2)
   |                             |---- hns3 stats (phase2)
   |
   +-------------+---------------+
                 |
                 v
         [Result Normalizer]
                 |
                 +---- PostgreSQL
                 +---- Object Storage(local path first)
                 +---- Vector Store(pgvector/Milvus)
                 |
                 v
          [LLM Analysis Engine]
                 |
                 v
           [Report Generator]
```

---

## 4. 推荐工程目录

```text
ai-sit-platform/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── routes_tasks.py
│   │   │   ├── routes_reports.py
│   │   │   ├── routes_assets.py
│   │   │   └── routes_health.py
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   ├── logging.py
│   │   │   ├── celery_app.py
│   │   │   └── security.py
│   │   ├── db/
│   │   │   ├── base.py
│   │   │   ├── models.py
│   │   │   ├── schemas.py
│   │   │   └── session.py
│   │   ├── services/
│   │   │   ├── orchestrator.py
│   │   │   ├── analysis_service.py
│   │   │   ├── report_service.py
│   │   │   ├── artifact_service.py
│   │   │   └── kb_service.py
│   │   ├── adapters/
│   │   │   ├── base.py
│   │   │   ├── ipmi_adapter.py
│   │   │   ├── fio_adapter.py
│   │   │   ├── nvme_adapter.py
│   │   │   ├── redfish_adapter.py
│   │   │   └── hns3_adapter.py
│   │   ├── collectors/
│   │   │   ├── base.py
│   │   │   ├── ipmi_collector.py
│   │   │   └── system_collector.py
│   │   ├── tasks/
│   │   │   ├── run_test.py
│   │   │   ├── collect_metrics.py
│   │   │   ├── analyze_result.py
│   │   │   └── generate_report.py
│   │   ├── prompts/
│   │   │   ├── summary_prompt.txt
│   │   │   ├── rootcause_prompt.txt
│   │   │   └── bugdraft_prompt.txt
│   │   └── main.py
│   ├── tests/
│   ├── alembic/
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── views/
│   │   ├── components/
│   │   ├── api/
│   │   └── router/
│   └── package.json
├── scripts/
│   ├── bootstrap_openEuler.sh
│   ├── run_worker.sh
│   └── dev_start.sh
├── docs/
│   ├── api_spec.md
│   ├── state_machine.md
│   └── deployment.md
└── README.md
```

---

## 5. 数据模型设计

### 5.1 tasks
- `id`
- `task_name`
- `test_type` (`storage`, `bmc`, `network`, `dc_cycle`...)
- `target_host`
- `status` (`pending`, `running`, `collecting`, `analyzing`, `done`, `failed`)
- `priority`
- `created_at`
- `started_at`
- `finished_at`
- `retry_count`
- `scenario_json`
- `final_verdict` (`pass`, `fail`, `warning`, `unknown`)

### 5.2 task_steps
- `id`
- `task_id`
- `step_name`
- `step_type`
- `status`
- `started_at`
- `finished_at`
- `raw_log_path`
- `result_json`

### 5.3 collected_metrics
- `id`
- `task_id`
- `source` (`ipmi_sensor`, `ipmi_sel`, `fio_runtime`, `nvme_smart`)
- `ts`
- `payload_json`

### 5.4 analysis_reports
- `id`
- `task_id`
- `summary_json`
- `root_cause_json`
- `bug_draft_md`
- `model_name`
- `created_at`

### 5.5 kb_cases
- `id`
- `case_title`
- `symptoms`
- `root_cause`
- `resolution`
- `tags`
- `embedding`

---

## 6. API 设计（MVP）

### 6.1 创建任务
`POST /api/tasks`

请求示例：
```json
{
  "task_name": "fio_randread_bmc_watch",
  "test_type": "storage",
  "target_host": "192.168.1.10",
  "scenario": {
    "fio": {
      "filename": "/dev/nvme0n1",
      "rw": "randread",
      "bs": "4k",
      "iodepth": 64,
      "numjobs": 4,
      "runtime": 300
    },
    "collectors": {
      "ipmi_sensor_interval_sec": 10,
      "ipmi_sel_interval_sec": 30
    }
  }
}
```

### 6.2 查询任务列表
`GET /api/tasks`

### 6.3 查询单任务详情
`GET /api/tasks/{task_id}`

### 6.4 查询任务报告
`GET /api/tasks/{task_id}/report`

### 6.5 重新分析
`POST /api/tasks/{task_id}/reanalyze`

### 6.6 下载产物
`GET /api/artifacts/{artifact_id}`

---

## 7. 状态机设计

```text
pending
  -> preparing
  -> running
  -> collecting
  -> normalizing
  -> analyzing
  -> reporting
  -> done

异常分支：
任一阶段失败 -> failed
可恢复异常 -> retrying -> running / collecting
```

### 状态含义
- `pending`: 已创建，等待调度
- `preparing`: 下发配置、检查依赖、检查目标机连通性
- `running`: 主测试执行中，如 fio / iperf3
- `collecting`: 异步采集器仍在取数，等待结束
- `normalizing`: 原始日志转结构化 JSON
- `analyzing`: 调用 LLM / 规则引擎分析
- `reporting`: 生成报告与结论
- `done`: 完成
- `failed`: 流程失败

---

## 8. 适配器接口规范

所有适配器统一继承 `BaseAdapter`。

```python
class BaseAdapter:
    name: str

    def validate(self, config: dict) -> None:
        ...

    def build_command(self, config: dict) -> list[str]:
        ...

    def execute(self, config: dict) -> dict:
        ...

    def normalize(self, raw_output: str) -> dict:
        ...
```

### 统一输出格式
```json
{
  "adapter": "fio",
  "status": "success",
  "started_at": "2026-03-31T10:00:00",
  "finished_at": "2026-03-31T10:05:00",
  "raw_log_path": "/data/tasks/123/fio.log",
  "result": {
    "read_iops": 520000,
    "read_bw_mib": 2031,
    "read_lat_us_p99": 820,
    "device": "/dev/nvme0n1"
  },
  "errors": []
}
```

---

## 9. Collector 设计

Collector 必须与主测试解耦，采用独立线程/进程/worker。

### 9.1 IPMI Sensor Collector
- 周期执行：`ipmitool sdr list`
- 解析温度、风扇、功耗、关键电压
- 输出时序 JSON

### 9.2 IPMI SEL Collector
- 周期执行：`ipmitool sel list`
- 用事件 ID 去重
- 标注新增事件

### 9.3 System Collector（phase2）
- `dmesg -T`
- `/proc/interrupts`
- `sar/iostat/pidstat`
- hns3 stats

---

## 10. 分析引擎设计

采用 **规则引擎 + LLM** 双层结构。

### 10.1 规则引擎先行
先做硬规则，降低 LLM 成本并提升稳定性：
- SEL 出现 `Uncorrectable ECC` -> critical
- 温度 > 阈值 -> warning/critical
- fio 带宽下降超过基线 20% -> warning
- dmesg 出现 AER / nvme timeout / IOMMU fault -> critical

### 10.2 LLM 分析输入
输入给模型的不是整份原始日志，而是整理后的上下文：
```json
{
  "task_meta": {...},
  "environment": {
    "platform": "Kunpeng 920",
    "os": "openEuler",
    "device": "nvme0n1"
  },
  "metrics_summary": {...},
  "events": [...],
  "key_log_lines": [...],
  "kb_hits": [...]
}
```

### 10.3 输出格式
必须强制 JSON 输出：
```json
{
  "verdict": "warning",
  "anomalies": [
    {
      "type": "performance_drop",
      "severity": "medium",
      "evidence": ["fio bandwidth dropped from 2100 MiB/s to 1600 MiB/s"],
      "suspected_component": "nvme_or_pcie_path"
    }
  ],
  "root_cause_candidates": [
    {
      "rank": 1,
      "cause": "thermal throttling or PCIe link degradation",
      "confidence": 0.72
    }
  ],
  "next_actions": [
    "collect nvme smart-log",
    "check dmesg for AER/nvme timeout",
    "verify inlet temperature trend"
  ],
  "bug_ticket_draft": "..."
}
```

---

## 11. Prompt 设计

### system prompt 核心约束
1. 你是服务器 SIT 日志分析助手
2. 平台环境是 Kunpeng 920 + openEuler
3. 优先根据证据判断，不允许编造
4. 输出必须是 JSON
5. 结论要区分 evidence / inference / unknown

### 用户输入模板
```text
请分析以下服务器测试结果，完成：
1. 提取异常
2. 判断严重级别
3. 给出最可能根因
4. 生成 BUG 草稿

上下文：
{context_json}
```

---

## 12. 报告设计

报告建议包含：
1. 测试基本信息
2. 测试拓扑/目标盘/网络口/BMC 地址
3. 关键指标趋势图
4. SEL / dmesg / SMART 摘要
5. AI 结论
6. 最终 verdict
7. 建议动作

首版先输出 Markdown/HTML，第二阶段再接 PDF/Word。

---

## 13. openEuler / Kunpeng 特殊适配要求

### 13.1 命令兼容性
- 避免写死 x86 专有工具路径
- subprocess 调用时保留 ARM 平台兼容
- 所有脚本在 openEuler 先验证依赖

### 13.2 hns3 特性
- 适配 hns3 统计接口
- 处理十六进制/离散值传感器格式
- 网卡异常检测关注 link flap / tx timeout / queue 异常

### 13.3 Atlas 300I（phase3）
- 预留 NPU collector
- 采集温度、利用率、HBM、错误码

---

## 14. MVP 开发优先级

### 第一批必须完成
- FastAPI 项目骨架
- PostgreSQL 数据模型
- Celery worker
- FioAdapter
- IpmiAdapter
- IpmiCollector
- Task 状态机
- 基础规则引擎
- LLM 分析接口抽象
- 单任务报告页

### 第二批再做
- NVMe SMART 深化
- Redfish adapter
- 任务模板
- 用户权限
- RAG 知识库
- PDF/Word 导出

---

## 15. Codex 开发约束

1. 所有 shell 调用必须经过统一封装，不允许业务代码到处直接 `subprocess.run`
2. 所有适配器都要有 `normalize()`
3. API 层只做参数校验，不写核心业务
4. Orchestrator 只处理流程，不直接解析日志
5. 原始日志落盘，结构化结果入库
6. 所有时间统一 UTC 存储，展示层再转本地时区
7. 关键流程写单元测试
8. 所有 JSON 字段命名统一 snake_case

---

## 16. 第一阶段建议交付文件

Codex 至少应生成这些文件：
- `backend/app/main.py`
- `backend/app/core/config.py`
- `backend/app/db/models.py`
- `backend/app/api/routes_tasks.py`
- `backend/app/services/orchestrator.py`
- `backend/app/adapters/base.py`
- `backend/app/adapters/fio_adapter.py`
- `backend/app/adapters/ipmi_adapter.py`
- `backend/app/collectors/ipmi_collector.py`
- `backend/app/tasks/run_test.py`
- `backend/app/services/analysis_service.py`
- `backend/app/services/report_service.py`
- `backend/requirements.txt`
- `README.md`

---

## 17. 直接给 Codex 的提示词

```text
请为一个面向 Kunpeng 920 + openEuler 环境的 AI-SIT 自动化测试平台生成第一阶段 MVP 代码骨架。

目标：
- 使用 Python + FastAPI + Celery + Redis + PostgreSQL
- 提供 REST API 创建/查询测试任务
- 实现基于有限状态机的 Test Orchestrator
- 封装 fio 和 ipmitool 两个适配器
- 实现一个异步 IPMI collector
- 测试完成后生成结构化 JSON 结果
- 预留 LLM 分析接口 analysis_service
- 预留报告生成接口 report_service

要求：
1. 生成完整项目目录结构
2. 所有核心模块写出可运行的最小代码，不要只写空文件
3. 适配器采用统一 BaseAdapter 接口
4. 业务逻辑分层清晰：api / services / adapters / collectors / tasks / db
5. 代码风格简洁，包含类型注解
6. shell 命令执行统一封装
7. 给出 requirements.txt
8. 给出 README，包含本地运行方式
9. 先做后端，不生成复杂前端
10. 输出内容按文件分块展示

补充领域约束：
- 平台运行环境优先考虑 openEuler on ARM64
- fio 输出要 normalize 为结构化 JSON
- ipmitool 需要支持 SEL 和 SDR/Sensor 采集
- 状态机至少包含 pending/running/collecting/analyzing/done/failed
- 原始日志保存到本地 artifacts 目录

请直接开始生成代码。
```

---

## 18. 第二轮给 Codex 的增强提示词

```text
在现有 MVP 基础上继续增强：
1. 增加 PostgreSQL ORM 模型和 Alembic 初始化
2. 增加规则引擎：识别 SEL 中 ECC / 温度超限 / fio 带宽下降
3. 增加任务详情 API 和报告 API
4. 增加任务执行日志落盘
5. 为 FioAdapter、IpmiAdapter、Orchestrator 编写 pytest 单元测试
6. 增加 .env 配置加载
7. 增加 Dockerfile 和 docker-compose.yml

请继续按文件分块输出新增和修改内容。
```

