# GPU预研项目

这个仓库用于沉淀 GPU / AI 加速器核心计算单元方向的预研资料，当前重点围绕：

- NVIDIA 不同架构之间的 SM 演进
- 昇腾 Da Vinci / AI Core 架构理解
- NVIDIA SM 与昇腾 AI Core 的结构化对比
- 后续实验、论文笔记、结构图和扩展学习资料

## 当前主文档

- [docs/architecture/GPU核心计算单元_SM与昇腾架构详细对比.md](./docs/architecture/GPU核心计算单元_SM与昇腾架构详细对比.md)
- [docs/study-notes/GPU核心计算单元个人学习文档.md](./docs/study-notes/GPU核心计算单元个人学习文档.md)
- [docs/study-notes/GPU预研_SM学习与对比文档.md](./docs/study-notes/GPU预研_SM学习与对比文档.md)

## 目录结构

- `docs/`
  预研主文档、学习笔记、专题整理

- `papers/`
  论文入口、论文笔记、关键参考论文索引

- `experiments/`
  后续 CUDA / Nsight / 性能分析实验记录

- `assets/`
  导出的 Word 文档、PPT、结构图等展示材料

- `sources/`
  原始压缩包、解压后的原始资料、PDF 和参考素材

## 当前整理原则

1. 主结论优先放 `docs/`
2. 原始资料统一放 `sources/`
3. 演示与导出件放 `assets/`
4. 后续论文和实验单独扩展，不和主文档混放

## 后续建议

下一步最值得补充的内容：

1. `papers/` 下补关键论文逐篇笔记
2. `experiments/` 下补 Warp 发散、Occupancy、Tensor Core 路径实验
3. `assets/` 下补架构图、对比图、可教学示意图
