# GPU预研学习文档：SM 学习、英伟达 SM 对比、与国产 GPU 对比

文档日期：2026-03-31  
适用目的：个人学习、建立核心计算单元的总体认识  
材料来源：基于压缩包 `核心计算单元.zip` 内现有资料整理，并补充少量官方公开资料用于校准

## 1. 先建立一个总认识：为什么要学 SM

SM（Streaming Multiprocessor，流多处理器）是 NVIDIA GPU 的核心计算单元。  
如果把一张 GPU 理解成一座工厂，那么：

- GPU 是整座工厂
- SM 是一条条并行生产线
- Warp 是生产线上的一个标准作业班组
- Thread 是班组里的单个工人

CPU 更强调低延迟、强控制、擅长串行逻辑；GPU 更强调高吞吐，用大量线程并行去覆盖访存等待时间。  
因此，学 GPU 不能只盯着“算力指标”，必须理解 SM 内部如何调度 Warp、如何隐藏延迟、如何把计算单元持续喂饱。

一句话总结：  
**SM 决定 GPU 能不能把理论算力真正变成有效吞吐。**

## 2. SM 学习

### 2.1 SM 的基本组成

结合压缩包中的学习材料，可以把一个现代 NVIDIA SM 粗略理解为以下几个部分：

- CUDA Cores / FP32 单元：负责通用标量或向量计算
- Tensor Cores：负责矩阵乘加，是 AI 训练和推理的关键单元
- SFU：负责三角函数、指数、对数等特殊函数
- Load/Store 单元：负责数据搬运
- Register File：保存线程运行时状态
- Shared Memory / L1：片上高速缓存与线程块共享数据区
- Warp Scheduler：决定下一个周期发射哪个 Warp 的哪条指令
- Dispatch Unit：把指令送到对应执行单元

学习重点不是死记结构图，而是建立一个判断逻辑：  
**SM 本质上是在“算、取、等、切换”之间做资源编排。**

### 2.2 Warp 为什么是关键

GPU 不是按单个线程调度，而是按 Warp 调度。通常一个 Warp 含 32 个线程。

这意味着：

- 32 个线程会一起执行同一条指令
- 如果同一个 Warp 内线程走不同分支，就会发生分支发散
- 一旦发生发散，硬件通常要把不同路径串行跑完，效率下降

因此，写 CUDA 或理解 GPU 内核时，不能只看“线程多不多”，而要看：

- 同一个 Warp 内线程行为是否一致
- 访存是否连续
- 是否有足够多的活跃 Warp 可供切换

### 2.3 SM 如何隐藏延迟

GPU 性能的核心不是“某个线程跑得多快”，而是“一个 Warp 等内存时，另一个 Warp 能不能立刻顶上”。

关键机制：

- 活跃 Warp 池：SM 中同时驻留多个 Warp
- Warp 调度：每个周期选择就绪 Warp 发射指令
- 零开销上下文切换：Warp 切换不需要像 CPU 线程切换那样付出大开销
- Occupancy：SM 上并发驻留 Warp/Block 的能力
- ILP：单 Warp 内独立指令并行度
- WLP：多个 Warp 之间的并行度

学习时要记住一个非常实用的结论：  
**高 Occupancy 不等于高性能，但 Occupancy 不够通常很难有高性能。**

### 2.4 影响 SM 效率的三类核心问题

#### 1. 分支发散

典型问题：

- `if/else` 导致同一 Warp 内线程分路
- 掩码执行变多
- 有效吞吐下降

#### 2. 访存不合并

典型问题：

- 相邻线程访问分散地址
- 同一个 Warp 触发更多内存事务
- SM 大量周期消耗在等待内存

#### 3. 资源占用过高

典型问题：

- 每线程寄存器使用过多
- 每 Block 共享内存过大
- 导致每个 SM 可驻留 Block 数量下降

### 2.5 建议的学习顺序

按“概念 -> 代码 -> 剖析 -> 优化”走最稳：

1. 先理解 Grid / Block / Warp / Thread 的层级关系
2. 再理解 Warp 调度、Occupancy、Branch Divergence
3. 然后做两个小实验
4. 最后再看 PTX、Nsight Compute 指标和具体优化

建议优先做两个实验：

- 分支发散实验：比较 Warp 内分支一致和不一致时的效率差异
- Occupancy 实验：通过调寄存器或 Block 大小观察吞吐变化

如果只做一件事来入门，我建议是：  
**用 Nsight Compute 看一次 Warp Execution Efficiency 和 Stall Reasons。**

## 3. 英伟达 SM 对比

这一部分不追求参数堆砌，重点看架构思路怎么演进。

### 3.1 Hopper、Blackwell、Rubin 的主线变化

可以把这三代理解成三步：

- Hopper：把 AI 大模型时代需要的 Transformer 加速能力做深
- Blackwell：把低精度、张量吞吐、数据搬运协同做强
- Rubin：更偏前瞻，目前更适合作为趋势理解，而不是按已定版规格背参数

### 3.2 Hopper SM 的学习重点

Hopper 的关键词：

- 第四代 Tensor Core
- Transformer Engine
- FP8
- 更强的异步执行和大模型支撑能力

从学习角度看，Hopper 的意义是：  
它让“SM 不只是通用并行计算单元，而是 AI 主力执行单元”这件事彻底坐实。

对程序员最重要的理解：

- 计算与访存开始更强调解耦
- Tensor Core 的地位进一步上升
- 混合精度成为主流优化手段

### 3.3 Blackwell SM 的学习重点

结合压缩包内容与 NVIDIA 官方公开资料，Blackwell 是当前学习重点。

Blackwell 关注点：

- 第五代 Tensor Core
- 第二代 Transformer Engine
- 对 FP4 / 更低精度格式的强化支持
- 更强的数据搬运与计算协同
- 更强调把硬件调度、低精度计算、数据流组织打通

从 SM 视角看，Blackwell 的核心变化不是“SM 这个名字变了”，而是：

- SM 里的张量计算权重更高
- 为 AI 推理和训练优化得更激进
- 数据搬运、缓存、计算单元配合更紧

学习 Blackwell 时要把注意力放在：

- Tensor Core 什么时候成为主路径
- 低精度如何影响指令编排
- 数据搬运如何减少 SM 空转
- 为什么单纯追求 Occupancy 已经不够

### 3.4 Rubin 怎么看

截至 2026-03-31，Rubin 更适合当作“前瞻方向”而不是“已完全定型的公开教材”。

从压缩包已有内容看，Rubin 常被描述为：

- 更高带宽
- 更激进的低精度支持
- 更动态的调度思路
- CPU-GPU 更紧的协同

这里要注意一个学习上的边界：

- **Hopper、Blackwell 可以按相对确定的已公开架构学习**
- **Rubin 更适合记“趋势”，不要把所有预判当成已落地规格**

### 3.5 英伟达三代 SM 的学习型对比

| 维度 | Hopper | Blackwell | Rubin（学习上按前瞻理解） |
|---|---|---|---|
| 关注重点 | Transformer 与 FP8 | 更强低精度、张量吞吐、数据搬运协同 | 更高带宽、更动态调度 |
| SM 角色 | 通用并行 + AI 主力 | 更偏 AI 工厂核心单元 | 进一步面向超大模型 |
| 优化思路 | 兼顾 Occupancy 与 Tensor Core 使用 | 更强调数据流、低精度、混合执行路径 | 更强调整体系统级协同 |
| 学习建议 | 学 SIMT 与 Tensor Core 基础 | 重点学 TMA/数据搬运协同、低精度执行 | 重点学趋势，不死记参数 |

我的结论是：  
**如果现在只选一代重点学，优先 Blackwell；如果要打基础，必须先吃透 Hopper；如果做预研汇报，可以把 Rubin 放在趋势展望。**

## 4. 与国产 GPU 对比

### 4.1 先说明比较口径

压缩包里“国产 GPU 对比”的现成材料，最完整的是 **NVIDIA SM 与华为昇腾 AI Core** 的对比。  
因此这一节以昇腾为代表来写，更符合你当前材料基础。

要先明确一点：

- NVIDIA 的核心硬件单元叫 **SM**
- 华为昇腾的核心硬件单元叫 **AI Core**
- 二者不是简单同名替换，而是设计哲学本身就不同

### 4.2 NVIDIA SM 与昇腾 AI Core 的本质差异

#### NVIDIA SM

特点：

- 面向通用并行计算起家
- 图形计算和 AI 计算长期共用同一条技术演进主线
- SIMT 模型成熟，Warp 调度机制清晰
- CUDA 生态非常完整

更适合这样理解：

**SM 是“通用并行 + AI 加速”双能力融合的核心单元。**

#### 昇腾 AI Core

根据压缩包资料和华为公开资料，昇腾采用达芬奇架构，其核心计算单元为 AI Core。

特点：

- 更偏 AI 专用加速
- 更强调矩阵计算、向量计算、标量计算的协同
- 软件栈以 CANN 为主
- 在调度表达上，更偏图执行、算子编排、流并行

更适合这样理解：

**AI Core 从一开始就更像“面向 AI 工作负载定制的计算阵列”。**

### 4.3 两者对比表

| 对比项 | NVIDIA SM | 华为昇腾 AI Core |
|---|---|---|
| 核心单元名称 | SM | AI Core |
| 设计起点 | 通用并行计算，兼顾图形与 AI | 面向 AI 计算优化 |
| 基本执行思想 | SIMT，Warp 为核心调度粒度 | 更偏 AI 专用阵列与图/流调度 |
| 生态 | CUDA、PTX、Nsight、cuDNN、TensorRT | CANN、GE、昇腾工具链 |
| 优势 | 通用性强，生态成熟，开发者资料多 | AI 定向优化明显，国产化价值高 |
| 学习难点 | 需要深入理解 Warp、内存层次、低层优化 | 需要理解其软件栈、图编译与专用执行模型 |

### 4.4 学习上应该怎么比较，而不是只比参数

不要把对比停留在“谁多少 TOPS / TFLOPS”。  
真正有价值的比较应放在四个层面：

#### 1. 核心计算模型

- NVIDIA：更适合从线程、Warp、Kernel、内存层次去理解
- 昇腾：更适合从算子、图、流、AI Core 资源编排去理解

#### 2. 调度方式

- NVIDIA：硬件级 Warp 调度非常关键
- 昇腾：更强调图级调度、流并行和 AI 任务编排

#### 3. 软件栈成熟度

- NVIDIA：工具链与社区资料明显更成熟
- 昇腾：在国产生态和行业落地上有重要价值，但学习资料结构更偏平台化

#### 4. 适用任务

- NVIDIA：适合通用 GPU 计算、科研、AI 训练/推理、多样化生态
- 昇腾：适合国产 AI 基础设施、行业落地、与国产软件栈协同

### 4.5 我的学习结论

如果目标是“理解 GPU 的核心计算单元”，优先学 NVIDIA SM。  
原因很直接：

- 概念体系更清晰
- 工具链更成熟
- 从底层线程调度到性能优化的学习路径更完整

如果目标是“理解国产 AI 加速器设计思路”，再去对照昇腾 AI Core。  
这样不会把两个不同设计哲学的体系硬套在一起。

## 5. 给个人学习使用的最短路线

如果你要把这份文档变成接下来一周的行动方案，可以直接按下面走：

### 第一步：先吃透 5 个关键词

- SM
- Warp
- Occupancy
- Branch Divergence
- Tensor Core

### 第二步：完成 2 个实验

- 分支发散实验
- Occupancy 实验

### 第三步：做 1 次工具分析

用 Nsight Compute 看：

- Warp Execution Efficiency
- Achieved Occupancy
- Stall Reasons

### 第四步：补 2 组对比

- Hopper vs Blackwell
- NVIDIA SM vs 昇腾 AI Core

## 6. 最终结论

这次预研如果只保留三句话，我建议记这三句：

1. **SM 是 NVIDIA GPU 的核心计算单元，Warp 调度是理解 GPU 性能的主线。**
2. **英伟达 SM 的演进方向，是从通用并行不断走向更强的 AI 专用化、低精度化和数据流协同。**
3. **国产体系里不能机械寻找“SM 的翻版”，更合理的做法是用“核心计算单元 + 调度方式 + 软件栈”三个维度做对比。**

## 7. 参考来源

压缩包内重点参考材料：

- `学习/SM资料/流多处理器（SM-Streaming Multiprocessor）与线程调度.md`
- `学习/SM资料/从理论模型到代码实践，再到底层剖析.md`
- `总结/NVIDIA GPU 架构与SM线程调度解析.md`
- `总结/英伟达与昇腾对比.md`

补充校准资料：

- NVIDIA Hopper Architecture: https://www.nvidia.com/en-us/data-center/technologies/hopper-architecture/
- NVIDIA Hopper Architecture In-Depth: https://developer.nvidia.com/blog/nvidia-hopper-architecture-in-depth/
- NVIDIA Blackwell Architecture: https://www.nvidia.com/en-us/data-center/technologies/blackwell-architecture/
- NVIDIA Tensor Cores: https://www.nvidia.com/en-us/data-center/tensor-cores
- 华为昇腾计算: https://e.huawei.com/cn/products/computing/ascend
- 华为 Atlas 300T Pro 用户指南（含 AI Core 规格）: https://support.huawei.com/enterprise/zh/doc/EDOC1100260610/8a8fc999

备注：

- 文中涉及 Rubin 的内容以“前瞻趋势理解”为主，不应等同于完全定版公开规格。
- “与国产 GPU 对比”部分当前以昇腾为代表，因为压缩包已有材料主要围绕这一对象展开。
