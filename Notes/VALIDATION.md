# 验证、图形契约与来源 / Validation and provenance

2026-10-08：Windows R 4.3.1，隔离安装 ROGUE 1.0。原始输入校验通过，未删除输入细胞或输入基因；26 个实际分组，22 个有限分数、4 个不足、0 个失败，189 条 fit warnings / 13 个分组。警告涉及 loess 近奇异性、伪逆等，不能忽略。少细胞组与不同捕获深度会影响解释；未做参数敏感性或稳定性重复验证。

图形契约：要表达“真实样本内各 DC 标签的转录纯度审计”，而非验证所有标签或决定最佳分辨率。913 个细胞用于计算，点对应实际 patient-subtype 分组；缺失/不足组保留在 CSV。没有 p 值；箱线只描述分组分布。不随机生成样本；横向 jitter seed 42 只为分开点，不改变 ROGUE 数值。Arial，183 × 120 mm，PNG 400 dpi 与 Cairo PDF。全部绘图在 R 完成；PDF 字号和实际预览另行检查。

公众号线索：[ROGUE 介绍](https://mp.weixin.qq.com/s/grZN0PDvCTf-Sz7HPZo5WA)，访问 2026-10-08。原文示例包含随机 sample 分配及 HVG 数据，故未复制为“真实样本验证”。本项目使用官方 DC counts 和原 Patient 字段，独立撰写操作指南。

方法：[PaulingLiu/ROGUE](https://github.com/PaulingLiu/ROGUE)，[Liu et al. 2020 方法论文](https://www.nature.com/articles/s41467-020-16904-3)。本次未复现原论文全套分析，不是作者认可的实现。

许可审计：上游根 `LICENSE` 为 BSD-3-Clause，但 `DESCRIPTION` 标注 GPL (>=2)，存在不一致。没有把其代码纳入本仓库，也没有给其数据/代码重新加许可；使用和再分发应查明对应权利条件。本仓库先作为私人科研资产库，不添加覆盖所有内容的开源许可证。

图形 QA：实际 PNG 已检查，Cairo PDF 的有效最小字号 7 pt。通用 Nature submission preflight 对缺少 SVG/TIFF 和 400 而非默认 600 dpi 有提示；本次目标是 GitHub PNG/PDF 图例，不宣称完成投稿导出。原始 Tf 扫描器把 Cairo 的 `1 Tf + Tm 缩放` 误读为 1 pt，已用 PyMuPDF 提取最终有效字号核对（只作非可视化 PDF 文本检查，图仍全部由 R 生成）。技能 frontmatter 校验通过。可在原数据下载后运行 `Rscript Code/test_inputs.R` 检查真实输入的对齐与拒绝规则。
