# Runner only. Edit analysis and prose in TH2_MANOVA.Rmd.
arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (length(arg)) setwd(dirname(normalizePath(sub("^--file=", "", arg[1]))))
if (!requireNamespace("knitr", quietly=TRUE)) stop("Package knitr is required")
local({
  extracted <- tempfile(fileext=".R")
  on.exit(unlink(extracted))
  knitr::purl("TH2_MANOVA.Rmd", output=extracted, documentation=0, quiet=TRUE)
  sys.source(extracted, envir=environment())
  print(mvtests, row.names=FALSE)
  cat("Analysis observations:", n, "\nOutputs:", normalizePath(out), "\n")
})
