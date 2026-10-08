---
name: rogue-cluster-qc
description: 用 ROGUE 审计单细胞群体的转录纯度，辅助亚群检查或重新聚类决策。用于用户要求 ROGUE、cluster purity、亚群纯度、是否需要继续分群或审计已有细胞标签时；不自动选分辨率，不把高纯度等同正确注释。
---

# ROGUE 亚群审计

先阅读 [README](README.md) 的输入约定、决策指南与 [验证边界](Notes/VALIDATION.md)，再运行。用中文说明关键判断，保留函数、参数和状态原值。

1. 确认 count 矩阵是 genes × cells 的未归一化表达，UMI 为非负整数；使用全部可用基因，不仅 HVG。检查 CellID 唯一、metadata 对齐、真实 sample_id、平台与候选标签。缺真实样本信息时停在输入准备，不随机补样本。
2. 明确研究问题和输出新目录；记录 QC、doublet、深度、ambient RNA、批次/条件混杂和标签证据。运行环境未准备时按 README 隔离安装上游包，不在 source 时自动安装。
3. 用 `Rscript Code/run_rogue.R counts.rds metadata.csv Results/new_run UMI sample_id celltype`。确认输出分组细胞总数等于输入细胞总数；少于 10 个细胞及错误组保留 NA 状态，不补零或过滤隐藏。
4. 同时交付 `rogue_scores.csv`、`fit_warnings.csv`、`validation.json` 和真实 PNG/PDF。逐组检查拟合警告；数值 PASS 不等于稳定拟合。没有成功运行不得用预存官方示例假装用户分析。
5. 依据 marker、技术混杂、连续状态和跨真实样本证据建议继续检查；不给统一“低于多少必须拆群”阈值。任何重聚类另行明确参数、保存旧标签映射并比较，不无限拆群追分。
6. 汇报数据来源、参数、保留/不足/错误数量及未验证范围。上传前排除 counts、患者信息和密钥，未知数据许可不擅自公开。

本技能只调用外部 ROGUE 依赖。官方示例已运行，但有局部拟合警告；未实现自动聚类选择或论文结果复现。
