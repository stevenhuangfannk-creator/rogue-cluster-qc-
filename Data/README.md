# 数据来源 / Data provenance

固定来源：[PaulingLiu/ROGUE，提交 6e1c8f9](https://github.com/PaulingLiu/ROGUE/tree/6e1c8f9ee419c8c323ce9816841f78545dc17bf9/example.data)。`Code/download_example.R` 下载 `DC.rds.gz` 与 `info.rds.gz`，逐个保存，不替换已有文件。

本次矩阵 9,795 genes × 913 cells；metadata 的 `Patient` 为 p1–p7、`ct` 为 tDC1/tDC2/tDC3/tpDC，`Tissue` 为 tumor。真实分组直接沿用上游字段，未重解释患者身份。上游教程的公开示例来源可确认，但本次没有独立核实到原始测序 accession，不能声称完整原始研究已复现。

SHA-256 见 [download_checksums.csv](download_checksums.csv)：DC 为 `385928a155fb836f32879295b42adeae394c959367e04b6aaae47b86835d0f65`；info 为 `1bd36bb7096031d1fc777d88740cb91cd0a6a90e35debcf57940ae30a664b704`。只有这个校验清单和说明进入 Git，两个 RDS 保留本地。下载前遵守上游数据条件；本项目不重新授予示例数据许可。

自有数据也应留在此目录并被 Git 忽略。只公开经过审计、允许分享的汇总表和图；不要把姓名、联系方式、住院号或患者元数据提交到 GitHub。
