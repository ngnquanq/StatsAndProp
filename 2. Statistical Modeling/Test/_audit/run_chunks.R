## Harness kiểm toán: chạy từng chunk của Rmd trong MỘT phiên R liên tục,
## ghi output từng chunk ra file riêng, rồi đánh giá toàn bộ inline `r ...`.
setwd("/Users/quangnguyen/StatsAndProp/2. Statistical Modeling/Test")

rmd_path <- "BirdLife_Regression_ANOVA.Rmd"
outdir   <- "_audit"
figdir   <- file.path(outdir, "fig")

lines <- readLines(rmd_path, warn = FALSE)

## ---- 1. Tách chunk -------------------------------------------------------
starts <- grep("^```\\{r", lines)
ends   <- grep("^```\\s*$", lines)

chunks <- list()
for (s in starts) {
  e <- ends[ends > s][1]
  hdr <- lines[s]
  lab <- sub("^```\\{r[ ,]*", "", hdr)
  lab <- sub("[,}].*$", "", lab)
  lab <- trimws(sub("\\}$", "", lab))
  if (!nzchar(lab)) lab <- paste0("unnamed_", s)
  chunks[[length(chunks) + 1]] <- list(
    label = lab, header = hdr, line = s,
    code = if (e > s + 1) lines[(s + 1):(e - 1)] else character(0)
  )
}

cat("Số chunk phát hiện:", length(chunks), "\n")
for (i in seq_along(chunks)) cat(sprintf("  %02d  %-20s (dòng %d, %d dòng code)\n",
    i, chunks[[i]]$label, chunks[[i]]$line, length(chunks[[i]]$code)))

## ---- 2. Chạy tuần tự -----------------------------------------------------
timing <- data.frame(idx = integer(), label = character(),
                     giay = numeric(), loi = character(),
                     n_warning = integer(), stringsAsFactors = FALSE)

run_one <- function(ch, i) {
  fout <- file.path(outdir, sprintf("%02d_%s.txt", i, ch$label))
  zz <- file(fout, open = "wt")
  warns <- character(0)
  err <- NA_character_
  t0 <- Sys.time()

  png(file.path(figdir, paste0(sprintf("%02d_", i), ch$label, "_%03d.png")),
      width = 1400, height = 800, res = 130)
  sink(zz, split = FALSE); sink(zz, type = "message")
  cat("=== CHUNK", i, ch$label, "===\n")
  cat("--- header:", ch$header, "\n\n")
  res <- try(withCallingHandlers({
    exprs <- parse(text = paste(ch$code, collapse = "\n"))
    for (e in exprs) {
      v <- withVisible(eval(e, globalenv()))
      if (v$visible) print(v$value)
    }
    invisible(NULL)
  },
  warning = function(w) {
    warns <<- c(warns, conditionMessage(w))
    cat("[WARNING]", conditionMessage(w), "\n")
    invokeRestart("muffleWarning")
  },
  message = function(m) {
    cat("[MESSAGE]", conditionMessage(m))
    invokeRestart("muffleMessage")
  }), silent = TRUE)
  if (inherits(res, "try-error")) {
    err <- as.character(res)
    cat("\n[LỖI]", err, "\n")
  }
  sink(type = "message"); sink()
  dev.off()
  close(zz)
  el <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  cat(sprintf("[%02d] %-20s %6.1fs  %s  (%d warning)\n", i, ch$label, el,
              if (is.na(err)) "OK" else "LỖI", length(warns)))
  flush.console()
  list(giay = el, loi = err, n_warning = length(warns))
}

for (i in seq_along(chunks)) {
  ch <- chunks[[i]]
  r <- run_one(ch, i)
  timing <- rbind(timing, data.frame(idx = i, label = ch$label, giay = r$giay,
                                     loi = ifelse(is.na(r$loi), "", r$loi),
                                     n_warning = r$n_warning,
                                     stringsAsFactors = FALSE))
  ## Sau chunk setup: thay kb() bằng bản in thẳng data.frame để log đọc được
  ## (bản thật dùng kableExtra khi knit; đây chỉ là công cụ kiểm toán).
  if (ch$label == "setup") {
    assign("kb", function(df, caption = NULL, digits = 4, ...) {
      cat("\n[BẢNG]", if (is.null(caption)) "(không caption)" else caption, "\n")
      print(as.data.frame(df))
      cat("\n")
      invisible(NULL)
    }, envir = globalenv())
  }
}

write.csv(timing, file.path(outdir, "_timing.csv"), row.names = FALSE)

## ---- 3. Đánh giá toàn bộ inline `r ...` ----------------------------------
inl_file <- file.path(outdir, "_inline.txt")
zz <- file(inl_file, open = "wt")
sink(zz); sink(zz, type = "message")
cat("=== GIÁ TRỊ CỦA MỌI BIỂU THỨC INLINE `r ...` (theo thứ tự tài liệu) ===\n\n")
in_chunk <- rep(FALSE, length(lines))
for (i in seq_along(chunks)) {
  s <- chunks[[i]]$line
  e <- s + length(chunks[[i]]$code) + 1
  in_chunk[s:e] <- TRUE
}
pat <- "`r [^`]+`"
for (ln in seq_along(lines)) {
  if (in_chunk[ln]) next
  m <- regmatches(lines[ln], gregexpr(pat, lines[ln]))[[1]]
  if (!length(m)) next
  for (expr_txt in m) {
    code <- substr(expr_txt, 4, nchar(expr_txt) - 1)
    val <- tryCatch(paste(utils::capture.output(print(eval(parse(text = code),
                                                            globalenv()))),
                          collapse = " | "),
                    error = function(e) paste("[LỖI]", conditionMessage(e)))
    cat(sprintf("dòng %4d | %-60s => %s\n", ln, code, val))
  }
}
sink(type = "message"); sink(); close(zz)

save.image(file.path(outdir, "_env.RData"))
cat("\nHOÀN TẤT. Tổng thời gian:", round(sum(timing$giay), 1), "giây\n")
print(timing[, c("idx", "label", "giay", "n_warning")])
