# Download the immutable upstream tutorial inputs; never replace existing files.
dir.create("Data", showWarnings = FALSE)
sha <- "6e1c8f9ee419c8c323ce9816841f78545dc17bf9"
for (name in c("DC.rds.gz", "info.rds.gz")) {
  target <- file.path("Data", name)
  if (file.exists(target)) stop("Already exists; verify it rather than overwriting: ", target)
  download.file(paste0("https://raw.githubusercontent.com/PaulingLiu/ROGUE/", sha, "/example.data/", name),
                target, mode = "wb", method = "libcurl")
}
hashes <- vapply(file.path("Data", c("DC.rds.gz", "info.rds.gz")), digest::digest, character(1),
                 file = TRUE, algo = "sha256")
write.csv(data.frame(file = names(hashes), sha256 = hashes), "Data/download_checksums.csv", row.names = FALSE)
