# Negative tests derived from the real official example; no scientific simulation.
expr <- readRDS("Data/DC.rds.gz")
meta <- readRDS("Data/info.rds.gz")
meta <- meta[match(colnames(expr), meta$CellID), , drop = FALSE]
header <- parse("Code/run_rogue.R")
# Evaluate the script's actual input checks only, before creating any output.
end <- which(vapply(header, function(x) startsWith(paste(deparse(x), collapse = ""), "dir.create(out"), logical(1)))[1] - 1L
check <- function(counts, metadata, should_pass) {
  counts_path <- tempfile(fileext = ".rds"); metadata_path <- tempfile(fileext = ".rds")
  saveRDS(counts, counts_path); saveRDS(metadata, metadata_path)
  frame <- new.env(parent = globalenv())
  frame$commandArgs <- function(...) c(counts_path, metadata_path, tempfile(), "UMI")
  result <- tryCatch({eval(header[seq_len(end)], frame); TRUE}, error = function(e) FALSE)
  stopifnot(identical(result, should_pass))
}
check(expr, meta[nrow(meta):1, ], TRUE) # correct cell set may be reordered
bad <- meta; bad$CellID[1] <- bad$CellID[2]; check(expr, bad, FALSE)
bad <- meta; bad$CellID[1] <- "mismatched_cell"; check(expr, bad, FALSE)
bad <- meta; bad$Patient[1] <- NA; check(expr, bad, FALSE)
bad <- expr; bad[1, 1] <- -1; check(bad, meta, FALSE)
bad <- expr; bad[1, 1] <- 0.5; check(bad, meta, FALSE)
cat("PASS: reordered real metadata accepted; duplicates/mismatch/missing sample/negative/fractional UMI rejected.\n")
