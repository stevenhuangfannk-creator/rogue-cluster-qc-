# Counts: genes x cells. Metadata must have exact cell IDs and real sample IDs.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4L) stop("Usage: Rscript Code/run_rogue.R counts.rds metadata.rds output_dir UMI [sample_column label_column]")
lib <- Sys.getenv("ROGUE_R_LIB")
if (nzchar(lib)) .libPaths(c(lib, .libPaths()))
library(Matrix)
library(dplyr)
library(tibble)
library(ggplot2)
library(ROGUE)

expr <- readRDS(args[1])
meta <- if (grepl("\\.csv$", args[2])) read.csv(args[2], check.names = FALSE) else readRDS(args[2])
out <- args[3]
platform <- args[4]
sample_col <- if (length(args) >= 5L) args[5] else "Patient"
label_col <- if (length(args) >= 6L) args[6] else "ct"
stopifnot(platform %in% c("UMI", "full-length"), length(dim(expr)) == 2L,
          all(c("CellID", sample_col, label_col) %in% names(meta)),
          !anyDuplicated(colnames(expr)), !anyDuplicated(meta$CellID),
          setequal(colnames(expr), meta$CellID))
meta <- meta[match(colnames(expr), meta$CellID), , drop = FALSE]
stopifnot(identical(as.character(meta$CellID), colnames(expr)),
          !anyNA(meta[, c(sample_col, label_col)]),
          all(nzchar(as.character(meta[[sample_col]]))), all(nzchar(as.character(meta[[label_col]]))))
values <- if (inherits(expr, "sparseMatrix")) expr@x else as.numeric(expr)
stopifnot(all(is.finite(values)), all(values >= 0))
if (platform == "UMI" && any(abs(values - round(values)) > 1e-8)) stop("UMI input must be unnormalized integer counts")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
groups <- unique(meta[, c(sample_col, label_col), drop = FALSE])
rows <- vector("list", nrow(groups))
warning_rows <- list()
started <- proc.time()[3]
for (i in seq_len(nrow(groups))) {
  sample_id <- as.character(groups[[sample_col]][i])
  label <- as.character(groups[[label_col]][i])
  cells <- which(meta[[sample_col]] == sample_id & meta[[label_col]] == label)
  fit_warnings <- character()
  result <- list(score = NA_real_, status = "INSUFFICIENT_CELLS", message = "Fewer than 10 cells")
  if (length(cells) >= 10L) {
    result <- tryCatch({
      # Same span/platform/outlier defaults as the upstream real-data tutorial.
      score <- withCallingHandlers(ROGUE::rogue(expr[, cells, drop = FALSE], labels = rep(label, length(cells)),
                            samples = rep(sample_id, length(cells)), platform = platform,
                            span = 0.6, min.cell.n = 10, remove.outlier.n = 2, filter = FALSE)[1, 1],
        warning = function(w) {
          fit_warnings <<- c(fit_warnings, conditionMessage(w))
          invokeRestart("muffleWarning")
        })
      if (!is.finite(score)) stop("Nonfinite ROGUE result")
      list(score = score, status = "PASS", message = "")
    }, error = function(e) list(score = NA_real_, status = "FAILED", message = conditionMessage(e)))
  }
  rows[[i]] <- data.frame(sample = sample_id, label = label, cells = length(cells),
                         rogue = result$score, status = result$status, warnings = length(fit_warnings), message = result$message)
  if (length(fit_warnings)) warning_rows[[length(warning_rows) + 1L]] <- data.frame(
    sample = sample_id, label = label, warning = fit_warnings)
  cat(sprintf("%s / %s: %d cells, %s\n", sample_id, label, length(cells), result$status))
  if (length(fit_warnings)) cat(sprintf("  %d fit warnings retained in fit_warnings.csv; inspect before interpretation.\n", length(fit_warnings)))
}
scores <- do.call(rbind, rows)
write.csv(scores, file.path(out, "rogue_scores.csv"), row.names = FALSE, na = "NA")
warnings_table <- if (length(warning_rows)) do.call(rbind, warning_rows) else data.frame(sample = character(), label = character(), warning = character())
write.csv(warnings_table, file.path(out, "fit_warnings.csv"), row.names = FALSE)
valid <- scores[scores$status == "PASS", ]
if (!nrow(valid)) stop("No valid groups; inspect rogue_scores.csv")
stopifnot(all(valid$rogue >= 0 & valid$rogue <= 1), sum(scores$cells) == ncol(expr))
order <- names(sort(tapply(valid$rogue, valid$label, median)))
valid$label <- factor(valid$label, levels = order)
colours <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#56B4E9", "#555555")
if (length(order) > 7L) colours <- grDevices::hcl.colors(length(order), "Dark 3")
palette <- setNames(colours[seq_along(order)], order)
p <- ggplot(valid, aes(label, rogue, colour = label)) +
  geom_boxplot(width = 0.55, outlier.shape = NA, linewidth = 0.4) +
  geom_point(position = position_jitter(width = 0.08, height = 0, seed = 42), size = 2) +
  scale_colour_manual(values = palette) + coord_cartesian(ylim = c(0, 1)) +
  labs(title = "ROGUE purity audit: real patient groups", x = "Cell subtype", y = "ROGUE",
       subtitle = sprintf("%d cells | %d real sample IDs | no random sample assignment", ncol(expr), length(unique(meta[[sample_col]]))),
       caption = "Dots: patient-subtype groups; missing/failed groups are retained in CSV. No hypothesis test.") +
  theme_classic(base_size = 10, base_family = "Arial") +
  theme(legend.position = "none", plot.title = element_text(face = "bold"), plot.caption = element_text(size = 7))
figures <- file.path(dirname(out), "Figures")
dir.create(figures, showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(figures, "rogue_purity.png"), p, width = 183, height = 120, units = "mm", dpi = 400, device = grDevices::png, type = "cairo")
ggsave(file.path(figures, "rogue_purity.pdf"), p, width = 183, height = 120, units = "mm", device = cairo_pdf)
jsonlite::write_json(list(cells = ncol(expr), genes = nrow(expr), sample_column = sample_col,
  label_column = label_col, platform = platform, span = 0.6, min_cell_n = 10,
  remove_outlier_n = 2, excluded_input_cells = 0, excluded_input_genes = 0,
  groups = nrow(scores), pass = sum(scores$status == "PASS"),
  insufficient = sum(scores$status == "INSUFFICIENT_CELLS"), failed = sum(scores$status == "FAILED"),
  fit_warnings = nrow(warnings_table), groups_with_warnings = sum(scores$warnings > 0),
  elapsed_seconds = unname(proc.time()[3] - started), R = R.version.string,
  ROGUE = as.character(packageVersion("ROGUE")), validation_scope = "Official real-data example only; not a clustering decision or biological certification"),
  file.path(out, "validation.json"), pretty = TRUE, auto_unbox = TRUE)
capture.output(sessionInfo(), file = file.path(out, "sessionInfo.txt"))
