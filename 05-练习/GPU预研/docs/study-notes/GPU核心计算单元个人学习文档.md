# GPU 核心计算单元个人学习文档

文档日期：2026-03-31  
文档定位：个人独立学习讲义  
当前重点：NVIDIA 不同架构之间的 SM 对比、昇腾 AI Core 架构理解、NVIDIA 与昇腾对比

## 1. 这份文档现在要解决什么问题

这一版不再停留在“学习框架”层面，而是直接回答三个更具体的问题：

1. NVIDIA 不同架构之间，SM 到底差在哪里
2. 昇腾架构里的 AI Core 到底是什么，和 SM 有什么根本差异
3. 如果我要把这两套体系讲给别人，应该按什么逻辑展开

因此，下面的内容会尽量做到：

- 有具体架构内容
- 有模块级解释
- 有横向对比
- 有“为什么这么设计”的解释
- 有适合教学的讲法

## 2. 学 NVIDIA SM 之前，先把观察维度定下来

如果不先定观察维度，很容易把架构对比写成参数表。  
真正有价值的学习，不是背“某代有多少 TFLOPS”，而是看 **SM 的角色如何变化**。

我建议以后看每一代 NVIDIA 架构，都先从下面六个维度看：

### 2.1 执行单元怎么变

关注：

- FP32 / INT / FP64 单元怎么配
- Tensor Core 是第几代
- 每个 SM 内不同执行资源的比例怎么变

### 2.2 调度方式怎么变

关注：

- Warp Scheduler 还是不是核心
- 是否更强调独立线程调度
- 是否出现更细粒度的执行与发射配合

### 2.3 数据类型怎么变

关注：

- FP16、BF16、TF32、FP8、FP4 是什么时候进入主流的
- 这些精度变化如何反过来影响 SM 设计

### 2.4 数据搬运怎么变

关注：

- Shared Memory / L1 / L2 的关系
- 异步拷贝能力
- Tensor Core 的喂数路径有没有被重点加强

### 2.5 适用负载怎么变

关注：

- 是更偏图形
- 更偏 HPC
- 还是更偏大模型训练和推理

### 2.6 软件栈怎么配合

关注：

- CUDA、PTX、编译器、库、调优工具
- 这些软件能力是否让新 SM 特性真正可用

这六个维度，是后面做跨代对比和跨厂对比时的主线。

## 3. NVIDIA SM 的基本定义

SM，全称 Streaming Multiprocessor，通常翻成流多处理器。  
它不是“一个核”的简单同义词，而是 GPU 内部的 **并行执行与调度中心**。

一个现代 SM 内部大致包含：

- 通用计算单元，如 FP32、INT、FP64
- Tensor Core
- SFU
- Load/Store 单元
- Register File
- Shared Memory / L1
- Warp Scheduler
- Dispatch / Issue 相关逻辑

所以 SM 的本质不是单纯计算，而是：

**把线程组织、指令发射、数据搬运、执行单元占用和延迟隐藏绑定到一起的局部执行系统。**

这句话非常重要，因为后面不同架构的变化，几乎都可以归结为：  
NVIDIA 不断在重塑这个“局部执行系统”的重心。

## 4. NVIDIA 各代架构的主线变化

如果把 Volta、Turing、Ampere、Hopper、Blackwell 作为一条连续演进链看，我现在的理解是：

- Volta：奠定现代 AI GPU 的基础形态
- Turing：在控制流、图形和通用执行上做了重要演化
- Ampere：把数据类型扩展、Tensor Core 实用性和异步拷贝推向主流
- Hopper：正式把大模型时代需要的 Transformer 路径做成架构中心
- Blackwell：进一步把低精度、Tensor 路径、数据流协同和系统级扩展推到更强

下面按“教学版”的写法，一代一代展开。

## 5. Volta：现代 AI GPU SM 的起点

### 5.1 为什么 Volta 重要

Volta 不是今天最新，但它在学习路径里很重要，因为很多现代 NVIDIA SM 的关键元素，是从 Volta 开始真正成型的。

从学习角度看，Volta 的价值在于：

- Tensor Core 开始成为核心组成
- GPU 不再只是通用并行设备，也开始明显为 AI 训练服务
- 现代 SM 的基本分析思路，从这一代开始变得稳定

### 5.2 Volta 的 SM 重点是什么

Volta 的核心不是“ALU 又多了多少”，而是：

- 把 Tensor Core 正式引入主流架构语境
- 让混合精度矩阵计算开始有明确硬件落点

也就是说，从 Volta 开始，学习 SM 不能只盯着 CUDA Core，而必须把 Tensor Core 纳入主线。

### 5.3 我该怎么理解 Volta 的历史意义

如果用教学语言概括：

**Volta 是 NVIDIA 从“通用 GPU 很能做 AI”走向“为 AI 明确造硬件”的起点。**

这句话背后最重要的变化，是 SM 的角色变了。

以前更像：

- 高吞吐并行执行单元

从 Volta 开始越来越像：

- 能同时服务通用并行和张量计算的复合执行单元

## 6. Turing：理解控制流和执行路径演化的关键一代

### 6.1 为什么 Turing 值得学

很多人学 GPU 会跳过 Turing，直接看 Ampere/Hopper。  
但从“理解 SM 内部控制流与调度”这个角度，Turing 很有价值。

原因有两个：

1. Turing 保留了现代 SM 的很多基础结构特征
2. 关于控制流管理、独立线程调度、收敛机制的研究，Turing 是一个非常重要的观察窗口

### 6.2 从研究视角看 Turing 的关键点

压缩包里关于 `Control Flow Management in Modern GPUs` 的论文材料，核心就是在研究 Turing 一类现代 GPU 的控制流管理问题。

这说明 Turing 的学习重点，不只是看参数，而是看：

- Warp 内线程一旦发散，底层怎么处理
- 收敛机制如何设计
- 为什么现代 GPU 不再只是简单的旧式 SIMT-Stack 逻辑

### 6.3 Turing 对学习者的启发

学习 Turing，不是为了记“这一代比上一代快多少”，而是为了真正建立下面这个认识：

**现代 GPU 的难点，不只在算术吞吐，而在如何管理复杂控制流而不让硬件浪费太多。**

这对后面读 Warp 调度、控制流管理、可变 Warp 论文都很关键。

## 7. Ampere：把 Tensor Core、数据类型和异步拷贝推向主流

Ampere 是目前学习 SM 非常重要的一代，因为从这一代开始，很多今天仍然在沿用的优化思路已经非常清楚了。

### 7.1 官方资料能确认的 Ampere SM 关键变化

根据 NVIDIA 官方 `NVIDIA Ampere Architecture In-Depth`：

- A100 使用 Ampere 架构
- A100 对应的 A100 GPU 有 108 个 SM
- 每个 SM 有 64 个 FP32 CUDA Cores
- 每个 SM 有 4 个第三代 Tensor Cores

更重要的不是数量本身，而是官方对这一代 SM 的定位：

- 在 Volta 和 Turing 基础上继续增强
- 第三代 Tensor Core 支持更多数据类型
- 引入更实用的稀疏加速
- 引入异步拷贝与硬件加速 barrier

### 7.2 为什么 Ampere 是“教学上最舒服”的一代

因为 Ampere 的很多变化，既足够现代，又没有 Hopper/Blackwell 那么强的“大模型时代专门术语负担”。

学 Ampere 可以把这些事讲清楚：

#### 1. Tensor Core 不再只是“一个新奇加速器”

Ampere 的第三代 Tensor Core 支持：

- TF32
- BF16
- FP16
- FP64 Tensor Core 路径
- 稀疏特性

这说明 Tensor Core 已经从“深度学习专用附加单元”变成了更广义的重要执行路径。

#### 2. 数据类型开始直接影响 SM 的学习重点

Ampere 里一个特别重要的点是 TF32。  
它的意义不只是新精度，而是：

- 让很多原本 FP32 的工作负载可以更容易迁移到 Tensor Core 路径
- 减少开发者手动改精度带来的门槛

这非常值得教学时强调，因为它体现了一个架构思想：

**不是只增加硬件能力，而是让软件更容易吃到这份能力。**

#### 3. 异步拷贝开始成为主线能力

Ampere 官方资料特别强调：

- asynchronous copy instructions
- hardware-accelerated barriers

这意味着什么？

这意味着 NVIDIA 已经非常明确地在架构层支持：

- 计算和数据搬运重叠
- 用更低开销的方式组织片上数据流

从学习视角看，这一代开始，SM 的重点不只是“算”，而是：

- 算
- 搬
- 同步
- 重叠

### 7.3 Ampere 的 SM 学习重点总结

如果要把 Ampere 讲给别人，我会抓下面四点：

1. 第三代 Tensor Core 让更多数据类型真正进入主流
2. TF32 让很多 AI/HPC 负载更容易利用 Tensor 路径
3. 稀疏加速开始明显进入架构主线
4. 异步拷贝和 barrier 让“数据搬运协同”变成 SM 学习主线之一

## 8. Hopper：SM 从“高吞吐执行单元”走向“大模型时代核心工厂”

Hopper 是现在必须重点学的一代，因为它已经非常明确地体现出：

**SM 的中心使命，从传统通用并行，转向了面向大模型和 Transformer 负载的高效执行。**

### 8.1 官方资料能确认的 Hopper SM 关键变化

根据 NVIDIA 官方 `NVIDIA Hopper Architecture In-Depth`：

- H100 的 SM 数量相对 A100 增加
- H100 的每个 SM 有 128 个 FP32 Cores
- 每个 SM 有 4 个第四代 Tensor Cores
- 新第四代 Tensor Cores 在等价数据类型上，每 SM 的 MMA 计算率相对 A100 可达到 2 倍
- Hopper 新增 FP8
- Hopper 强调 Transformer Engine
- Hopper 把异步能力进一步扩展，官方甚至称 H100 是 “the first truly asynchronous GPU”

### 8.2 Hopper 的第一个关键点：Tensor Core 从重要变成绝对主角

Ampere 已经很重视 Tensor Core。  
到了 Hopper，这件事进一步升级。

为什么？

因为 Hopper 官方描述里，SM 的改进不再主要围绕“通用 CUDA Core 有什么变化”，而是围绕：

- 第四代 Tensor Core
- FP8
- Transformer Engine
- 更强异步数据搬运

这说明从架构叙事上，SM 已经是为大模型服务的核心单元。

### 8.3 Hopper 的第二个关键点：FP8 的架构意义

很多人学 FP8 会停在“更低精度，所以更快”。  
这太浅了。

真正的架构意义是：

- 精度降低带来更高吞吐
- 同时需要架构和软件共同控制精度损失
- Transformer Engine 正是为这类问题而出现

也就是说，Hopper 的创新并不是“支持一种新数字格式”，而是：

**把低精度计算真正做成了硬件与软件协同的主路径。**

### 8.4 Hopper 的第三个关键点：异步 GPU

官方把 H100 描述为第一个真正异步的 GPU，这句话非常值得拆开讲。

教学上可以这样理解：

- 以前也能做拷贝和计算重叠，但能力没这么系统化
- Hopper 进一步扩展了异步搬运能力和地址空间支持
- 这让 SM 的学习重点，从“线程怎么跑”升级为“线程和数据流怎么一起跑”

所以 Hopper 一代最值得记住的一件事是：

**SM 不再只是调度 Warp 的地方，它也是组织计算流和数据流重叠的核心节点。**

### 8.5 Hopper 的第四个关键点：它把大模型负载正式写进了架构目标

从 Transformer Engine、FP8，到更强的异步搬运，Hopper 的核心逻辑已经很明确：

- 不是泛泛提高吞吐
- 而是有针对性地解决大模型训练和推理里的关键瓶颈

这意味着学习 Hopper 时，我不应该问：

- 它比 Ampere 快多少

而应该问：

- 它为什么能把 Transformer 类工作负载作为架构设计对象

## 9. Blackwell：SM 进一步向低精度 AI 工厂进化

截至 2026-03-31，Blackwell 已经是当前学习重点之一。  
但要注意，Blackwell 家族信息分布在官方页面、技术博客和软件适配说明中，学习时最好抓“稳定结论”，不要乱堆未经确认的细枝末节。

### 9.1 官方资料能确认的 Blackwell 重点

根据 NVIDIA 官方站点与技术博客可以确认的重点：

- Blackwell 使用第五代 Tensor Cores
- Blackwell 引入第二代 Transformer Engine
- Blackwell 强调 FP4 / NVFP4 等更低精度路径
- Blackwell 继续强化 NVLink、系统级扩展和大模型训练推理能力
- NVIDIA Tensor Cores 官方页面明确写到 Blackwell 支持 FP64、TF32、BF16、FP16、FP8、INT8、FP6、FP4

### 9.2 Blackwell 的第一个关键点：低精度从“可选优化”变成“架构主轴”

如果说 Hopper 的关键词是 FP8，那么 Blackwell 更进一步，把 FP4 直接推到架构主轴。

这意味着什么？

- Blackwell 不只是提高张量吞吐
- 它是在重新定义 AI 工作负载的“精度-性能平衡点”

教学上这一点要讲透：

- 低精度不是单纯牺牲精度换速度
- 它背后是硬件、编译器、库、训练配方一起变化

所以 Blackwell 的 SM 对学习者提出了一个新要求：

**你不能只看线程调度，还得看数值格式和张量路径如何共同决定吞吐。**

### 9.3 Blackwell 的第二个关键点：Tensor Core 已经成为架构叙事中心

从 Blackwell 的公开资料看，架构讨论几乎都围绕：

- FP4
- Transformer Engine
- 推理与训练性能
- 大规模互联

这反过来说明：

- CUDA Core 还重要
- 但从“架构价值表达”来看，Tensor Core 已经是 SM 里最值得优先关注的主角

### 9.4 Blackwell 的第三个关键点：SM 学习从“算多少”转向“怎么喂”

到了 Blackwell，真正难的问题越来越不是“有没有 Tensor Core”，而是：

- 数据怎么以合适的精度和布局到位
- Tensor 路径是否持续吃满
- 系统和软件栈能否支撑超大模型推理/训练

所以 Blackwell 学习时必须把下面这些概念放一起：

- Tensor Core
- 精度格式
- 数据搬运
- 缓存与内存带宽
- 软件库和编译器支持

### 9.5 Blackwell 的第四个关键点：架构学习正在系统化

学习 Volta/Ampere 时，我还能相对聚焦单颗 GPU。  
到 Blackwell，架构叙事明显已经扩展到：

- GPU 本身
- GPU 间互联
- 系统级部署形态
- 软件栈协同

这说明 Blackwell 的 SM 已经不能只作为“芯片内部局部模块”来理解，而是要把它放在整个 AI 工厂体系里看。

## 10. NVIDIA 各代 SM 的横向对比

下面把真正适合教学的对比点压缩成一张表。

| 架构 | 学习关键词 | SM 的核心变化 | 教学重点 |
|---|---|---|---|
| Volta | Tensor Core 起点 | SM 从纯通用并行开始走向 AI 复合执行 | 为什么张量计算值得单独硬件化 |
| Turing | 控制流与现代调度观察窗口 | 更适合研究发散、收敛和现代执行管理 | 为什么控制流管理是 GPU 难点 |
| Ampere | 数据类型扩展、异步拷贝主流化 | 第三代 Tensor Core、TF32、稀疏、异步拷贝 | 为什么“算”和“搬”要一起学 |
| Hopper | 大模型时代中心架构 | 第四代 Tensor Core、FP8、Transformer Engine、更强异步 | 为什么 SM 正在变成大模型执行工厂 |
| Blackwell | 更低精度、更强张量路径、更系统化 | 第五代 Tensor Core、FP4、第二代 Transformer Engine | 为什么低精度和系统协同成为新主线 |

这张表里最重要的不是“第几代 Tensor Core”，而是 SM 的角色变化：

- Volta：开始有 AI 方向
- Ampere：AI 路径真正实用化、工程化
- Hopper：大模型主导架构目标
- Blackwell：更低精度、更系统级的 AI 工厂化

## 11. 如果我要讲“SM 学习重点”，不同代应该怎么讲

### 11.1 讲 Ampere

重点讲：

- Tensor Core 为什么从这里开始进入“真正主路径”
- TF32 为什么重要
- 异步拷贝为什么改变了学习重点

### 11.2 讲 Hopper

重点讲：

- FP8 和 Transformer Engine
- 为什么 H100 会被描述成真正异步 GPU
- 为什么大模型负载已经进入架构中心

### 11.3 讲 Blackwell

重点讲：

- FP4 的架构意义
- Tensor Core 与精度体系进一步绑定
- SM 的学习正在从“核级优化”扩展为“系统级 AI 数据流优化”

## 12. 昇腾架构：为什么不能把它简单理解成“国产版 SM”

现在进入第二大块：昇腾。

先讲结论：

**昇腾不是“也有一个 SM，只是名字不同”。**

更准确的说法是：

- NVIDIA 用 SM 组织通用并行和 AI 路径
- 昇腾用 Da Vinci 架构下的 AI Core 组织 AI 计算主路径

两者虽然都属于“核心计算单元”，但设计出发点并不一样。

## 13. 昇腾架构里，AI Core 到底是什么

根据压缩包材料和华为公开资料，昇腾处理器的核心计算单元是 **Da Vinci AI Core**。

华为公开资料里，与学习最相关的稳定结论有两个：

1. Atlas 300T Pro 使用 Ascend 910 AI Processor  
2. 该处理器集成 30 个华为 Da Vinci AI Cores

同时，公开材料也反复强调 Da Vinci 架构的核心计算逻辑是围绕：

- Cube Unit
- Vector Unit
- Scalar Unit

来组织的。

这已经足够说明一个根本差异：

- NVIDIA 的解释入口通常是线程、Warp、SM
- 昇腾的解释入口更适合是计算单元类型、矩阵路径、向量路径和控制路径

## 14. 昇腾 AI Core 的内部理解方法

如果我要教学式地解释 AI Core，我会这样讲。

### 14.1 Cube Unit

Cube Unit 主要面向矩阵/张量类计算。  
这部分最接近 NVIDIA 里 Tensor Core 对应的能力定位。

它的重要性在于：

- AI 训练和推理里的主计算量往往集中在矩阵乘加
- 专用矩阵单元可以大幅提升单位面积和单位功耗下的吞吐

### 14.2 Vector Unit

Vector Unit 负责向量类计算和很多非矩阵但仍然高频的 AI 运算。

它的作用类似于：

- 补充纯矩阵单元不擅长的部分
- 处理激活、归一化、逐元素操作等更细碎的算子逻辑

### 14.3 Scalar Unit

Scalar Unit 负责控制、标量运算、地址与流程支撑。

这部分很重要，因为它说明：

- AI Core 不是只有一个“矩阵乘法大块”
- 它也必须有自己的控制和辅助执行路径

### 14.4 Memory System 与 Control Unit

公开资料和相关书籍也强调，Da Vinci 架构除了计算单元，还包含：

- 对应的片上存储和数据通路
- 控制单元

这和 NVIDIA SM 在本质上是相通的：  
任何高吞吐核心计算单元，最终都必须同时解决：

- 计算
- 存储
- 数据路径
- 控制

只是两家芯片把重点放在了不同抽象上。

## 15. 昇腾 AI Core 和 NVIDIA SM 的第一个根本差异：设计起点不同

### 15.1 NVIDIA SM 的起点

NVIDIA 的 GPU 传统上来自图形和通用并行计算路线。  
因此它的执行模型长期围绕：

- thread
- block
- warp
- SIMT

这套模型建立起来。

后来 AI 越来越重要，Tensor Core 被并入 SM，形成了今天的复合执行体系。

### 15.2 昇腾 AI Core 的起点

昇腾从一开始就更偏 AI 计算优化。  
因此它的主叙事不是：

- 线程如何被 Warp 调度

而是：

- AI 计算如何由矩阵、向量、标量与数据路径协同完成

### 15.3 这带来的学习差异

学习 NVIDIA 时，主线更容易是：

- 执行模型
- Warp 行为
- 线程组织
- Occupancy
- 发散

学习昇腾时，主线更适合是：

- AI Core 由哪些子单元构成
- 矩阵、向量、标量如何分工
- 数据如何在片上流动
- 软件栈如何把模型映射到这些单元

## 16. 昇腾 AI Core 和 NVIDIA SM 的第二个根本差异：调度抽象不同

### 16.1 NVIDIA 更强调线程级并行抽象

在 NVIDIA 体系里，程序员和工具链都自然围绕：

- kernel
- block
- warp
- thread

来理解硬件行为。

这意味着：

- 发散问题很显性
- Warp 调度是分析重点
- Occupancy 是典型分析指标

### 16.2 昇腾更适合从算子和流来理解

在昇腾体系里，公开材料和软件栈更常见的是：

- 图执行
- 流并行
- 算子映射
- AI Core 资源编排

这并不意味着昇腾内部没有更细粒度执行逻辑，而是说：

**它对外暴露给学习者和工程师的主抽象，不是 Warp。**

### 16.3 为什么这点在教学里很重要

因为如果用 NVIDIA 的语言硬套昇腾，会出现两个问题：

1. 你会误以为“它只是把 SM 改名成 AI Core”
2. 你会错过真正重要的软件栈和数据流组织方式

## 17. 昇腾 AI Core 和 NVIDIA SM 的第三个根本差异：软件栈绑定方式不同

### 17.1 NVIDIA 的软件栈优势

NVIDIA 的强项不只在硬件，还在于：

- CUDA 编程模型很统一
- PTX/SASS 研究生态成熟
- Nsight 等工具链完整
- cuDNN、TensorRT、CUTLASS、Triton 等生态强

这让 SM 的学习不仅能看到“是什么”，还能看到“怎么调、怎么测、怎么验证”。

### 17.2 昇腾的软件栈侧重点

昇腾的软件栈更常围绕：

- CANN
- 图执行
- 算子编译
- NPU 资源调度

因此学习它时，更需要从：

- 框架适配
- 图级优化
- 算子下发
- 流并行

这些角度入手。

### 17.3 这带来的现实差异

NVIDIA 更适合建立“底层并行执行直觉”。  
昇腾更适合建立“AI 专用加速器工程理解”。

这不是谁强谁弱，而是路径不同。

## 18. NVIDIA SM vs 昇腾 AI Core：教学版逐项对比

| 维度 | NVIDIA SM | 昇腾 AI Core |
|---|---|---|
| 设计起点 | 图形与通用并行计算起家，后深度 AI 化 | AI 专用加速起家 |
| 对外主抽象 | thread / block / warp / kernel | AI Core / 算子 / 图 / 流 |
| 核心执行组织 | SIMT + Warp 调度 | 矩阵、向量、标量协同 |
| 关键执行单元 | CUDA Core + Tensor Core + SFU + LD/ST | Cube Unit + Vector Unit + Scalar Unit |
| 典型学习指标 | Occupancy、Warp Efficiency、Stall Reasons | 算子映射、AI Core 利用、图执行效率 |
| 学习切入口 | Warp、发散、访存合并、Tensor Core | AI Core 结构、数据流、图调度、算子下发 |
| 软件生态 | CUDA 生态成熟，工具链极强 | CANN 生态，更偏平台化和工程链路 |

这张表里最关键的一行是“对外主抽象”。

因为它决定了：

- 我分析问题时脑子里先想什么
- 我讲给别人时先讲什么
- 我做实验时应该看哪些指标

## 19. 如果我要把这部分讲成一堂课，应该怎么讲

### 19.1 第一节：先讲 NVIDIA 为什么需要 SM

这一节讲：

- GPU 和 CPU 的目标不同
- GPU 要高吞吐
- 所以需要一个能同时管理线程、访存、执行和切换的局部系统
- 这个系统就是 SM

### 19.2 第二节：再讲 NVIDIA 各代 SM 怎么变化

这一节按下面顺序讲最顺：

1. Volta：Tensor Core 进入主线
2. Ampere：数据类型扩展、异步拷贝进入工程主线
3. Hopper：Transformer Engine、FP8、大模型中心化
4. Blackwell：FP4、更强张量路径、系统级 AI 工厂化

### 19.3 第三节：再讲为什么昇腾不能简单等同于 SM

这一节讲：

- NVIDIA 以 Warp/SIMT 为外显主线
- 昇腾以 AI Core/算子/图/流为外显主线
- 两者都在解决高吞吐 AI 计算，但抽象层级不同

### 19.4 第四节：最后讲怎么比较

这一节只保留四个维度：

1. 核心计算单元
2. 调度与执行抽象
3. 数据通路
4. 软件栈

这样比较最稳，不容易流于表面。

## 20. 我现在对这两套架构的阶段性结论

### 20.1 对 NVIDIA 的结论

NVIDIA SM 的演进，本质上是在回答同一个问题：

**怎样把越来越大的 AI 计算负载，以更低的数据精度、更高的执行效率、更强的数据流协同方式，稳定压进一个可扩展的软件与系统生态。**

从这个角度看：

- Volta 是起点
- Ampere 是工程成熟化
- Hopper 是大模型中心化
- Blackwell 是低精度与系统级工厂化

### 20.2 对昇腾的结论

昇腾 AI Core 的价值，不在于“它是不是另一个 SM”，而在于：

**它代表了另一种更偏 AI 专用化的核心计算单元组织方式。**

学习它时要优先看：

- 计算单元内部分类
- 数据流
- 图和算子调度
- 软件栈绑定

### 20.3 对比学习的结论

如果我的目标是建立底层并行计算直觉，优先学 NVIDIA SM。  
如果我的目标是理解国产 AI 加速器体系，必须再学昇腾 AI Core 和其软件栈。  
这两者不是互斥，而是先后关系。

## 21. 下一步还可以继续补什么

现在这份文档已经从“提纲”变成了“可讲内容”，但如果继续深化，最值得补的是三块：

### 21.1 补一版“模块级结构图说明”

例如：

- SM 内部模块关系图
- Ampere/Hopper/Blackwell 的学习重点示意图
- AI Core 的 Cube / Vector / Scalar 结构说明图

### 21.2 补一版“实验与指标映射”

例如：

- 用 Nsight Compute 验证 Warp 发散
- 用简单 GEMM 验证 Tensor Core 路径
- 用数据布局实验验证访存合并

### 21.3 补一版“术语双语表”

例如：

- Warp、Occupancy、Reconvergence、Transformer Engine、AI Core、Cube Unit、Graph Engine 等

这会非常适合后续长期学习。

## 22. 当前参考来源

本地压缩包材料：

- `学习/SM资料/流多处理器（SM-Streaming Multiprocessor）与线程调度.md`
- `学习/SM资料/从理论模型到代码实践，再到底层剖析.md`
- `学习/深入理解 SM（生产线）的内部结构.md`
- `总结/NVIDIA GPU 架构与SM线程调度解析.md`
- `总结/英伟达与昇腾对比.md`
- `总结/PDF资料总结/PDF资料概况.md`

官方校准资料：

- NVIDIA Ampere Architecture In-Depth  
  https://developer.nvidia.com/blog/nvidia-ampere-architecture-in-depth/

- NVIDIA Hopper Architecture In-Depth  
  https://developer.nvidia.com/blog/nvidia-hopper-architecture-in-depth/

- NVIDIA Hopper Architecture  
  https://www.nvidia.com/en-us/data-center/technologies/hopper-architecture/

- NVIDIA Tensor Cores  
  https://www.nvidia.com/en-us/data-center/tensor-cores

- NVIDIA Blackwell and CUDA 12.9 Introduce Family-Specific Architecture Features  
  https://developer.nvidia.com/blog/nvidia-blackwell-and-nvidia-cuda-12-9-introduce-family-specific-architecture-features

- 华为 Atlas 300T Pro 训练卡基本规格  
  https://support.huawei.com/enterprise/zh/doc/EDOC1100260610/8a8fc999

- 华为 Atlas 300T Pro 训练卡性能特点  
  https://support.huawei.com/enterprise/zh/doc/EDOC1100260610/8de20d80

- Huawei Atlas AI Computing Platform 新闻稿（含 Da Vinci 3D Cube 架构表述）  
  https://www.huawei.com/en/news/2019/4/huawei-atlas-intelligent-computing-launch

备注：

- Blackwell 家族的很多公开信息分散在不同官方页面和技术博客中，因此本版重点采用“稳定架构方向”而不是堆砌未完全统一的细节参数。
- Rubin 未作为本版重点，因为你这次明确要求先把“已经能教学”的内容写扎实。
