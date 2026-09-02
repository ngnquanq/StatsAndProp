## Kiểm chứng riêng khẳng định "10-fold CV: log-level 0.168 vs log-log 0.169" (dòng 260-262)
setwd("/Users/quangnguyen/StatsAndProp/2. Statistical Modeling/Test")
load("_audit/_env.RData")

y <- reg$logMass
Xlv <- reg[, pred_vars]
Xll <- Xlv
for (v in morph_vars) Xll[[v]] <- log(Xll[[v]])   # logRange đã ở thang log

cv_rmse <- function(X, y, folds) {
  e <- numeric(0)
  for (k in sort(unique(folds))) {
    tr <- folds != k
    d  <- data.frame(.resp = y[tr], X[tr, , drop = FALSE])
    m  <- lm(.resp ~ ., data = d)
    e  <- c(e, y[!tr] - as.numeric(predict(m, newdata = X[!tr, , drop = FALSE])))
  }
  sqrt(mean(e^2))
}

## kiểm tra tính đúng đắn của helper: phải khớp OLS trong bảng repeated-CV (~0.169)
set.seed(100 + 1); fo1 <- sample(rep(1:10, length.out = nrow(reg)))
cat(sprintf("Sanity check (fold giống rep 1 của chunk repeated-cv): log-level RMSE = %.4f\n",
            cv_rmse(Xlv, y, fo1)))
cat(sprintf("  (chunk repeated-cv báo OLS trung bình 50 fold = %.4f)\n\n",
            mean(rep_res[, "OLS"])))

res <- t(sapply(c(2026, 1, 42, 100, 123, 7, 999), function(s) {
  set.seed(s); fo <- sample(rep(1:10, length.out = nrow(reg)))
  c(seed = s, log_level = cv_rmse(Xlv, y, fo), log_log = cv_rmse(Xll, y, fo))
}))
res <- as.data.frame(res)
res$chenh <- res$log_log - res$log_level
print(round(res, 4), row.names = FALSE)
cat(sprintf("\nTrung bình: log-level = %.4f | log-log = %.4f | chênh = %+.4f\n",
            mean(res$log_level), mean(res$log_log), mean(res$chenh)))
cat(sprintf("Số seed mà log-log TỐT HƠN: %d/%d\n", sum(res$chenh < 0), nrow(res)))

## R^2 điều chỉnh trên toàn tập, để tham khảo
cat(sprintf("\nAdj R2 toàn tập: log-level = %.4f | log-log = %.4f\n",
  summary(lm(.resp ~ ., data.frame(.resp = y, Xlv)))$adj.r.squared,
  summary(lm(.resp ~ ., data.frame(.resp = y, Xll)))$adj.r.squared))
