## Kiểm chứng các khẳng định trong phần văn xuôi KHÔNG có code sinh ra chúng.
setwd("/Users/quangnguyen/StatsAndProp/2. Statistical Modeling/Test")
load("_audit/_env.RData")
suppressMessages({library(dplyr)})

cat("=========== (A) Tương quan cặp cao nhất (dòng 275-277) ===========\n")
Rm <- cor(reg[, c(morph_vars, "logRange", "logMass")])
ut <- which(upper.tri(Rm), arr.ind = TRUE)
pairs_df <- data.frame(v1 = rownames(Rm)[ut[, 1]], v2 = colnames(Rm)[ut[, 2]],
                       r = Rm[ut]) |> arrange(desc(abs(r)))
cat("-- 8 cặp tương quan mạnh nhất:\n"); print(head(pairs_df, 8), row.names = FALSE)
cat("\n-- Hai cặp được nêu đích danh trong báo cáo:\n")
cat(sprintf("   Wing.Length - Kipps.Distance            r = %.4f\n",
            Rm["Wing.Length", "Kipps.Distance"]))
cat(sprintf("   Beak.Length_Culmen - Beak.Length_Nares  r = %.4f\n",
            Rm["Beak.Length_Culmen", "Beak.Length_Nares"]))

cat("\n=========== (B) Ngoại lai nằm ở đuôi nào? (dòng 228) ===========\n")
up <- dn <- 0
per_var <- data.frame()
for (v in morph_vars) {
  x <- reg[[v]]; q <- quantile(x, c(.25, .75)); f <- 1.5 * diff(q)
  lo <- sum(x < q[1] - f); hi <- sum(x > q[2] + f)
  up <- up + hi; dn <- dn + lo
  per_var <- rbind(per_var, data.frame(bien = v, duoi_duoi = lo, duoi_tren = hi))
}
print(per_var, row.names = FALSE)
cat(sprintf("\n   TỔNG: đuôi dưới = %d, đuôi trên = %d  (%.1f%% số cờ nằm ở đuôi trên)\n",
            dn, up, 100 * up / (up + dn)))
## Loài bị gắn cờ có nặng hơn trung bình không? (khẳng định "loài lớn")
fl <- rowSums(sapply(reg[, morph_vars], iqr_flag)) > 0
cat(sprintf("   Mass trung vị: loài BỊ gắn cờ = %.2f g | loài KHÔNG = %.2f g\n",
            median(reg$Mass[fl]), median(reg$Mass[!fl])))

cat("\n=========== (C) log-level vs log-log, 10-fold CV (dòng 260-262) ===========\n")
cat("Báo cáo khẳng định: RMSE 0.168 (log-level) so với 0.169 (log-log).\n")
cat("Không có chunk nào trong Rmd sinh ra hai số này -> tái dựng lại:\n\n")
Xlv <- reg[, pred_vars]                       # thang gốc  (log-level)
Xll <- reg[, pred_vars]
for (v in morph_vars) Xll[[v]] <- log(Xll[[v]])   # logRange đã là log sẵn
y <- reg$logMass

cv_rmse <- function(X, y, folds) {
  e <- numeric(0)
  for (k in sort(unique(folds))) {
    tr <- folds != k
    m <- lm(y[tr] ~ ., data = data.frame(y = y[tr], X[tr, ]))
    e <- c(e, y[!tr] - predict(m, X[!tr, ]))
  }
  sqrt(mean(e^2))
}
## nhiều seed để xem con số có ổn định không
res <- t(sapply(c(2026, 1, 42, 100, 123), function(s) {
  set.seed(s); fo <- sample(rep(1:10, length.out = nrow(reg)))
  c(seed = s, log_level = cv_rmse(Xlv, y, fo), log_log = cv_rmse(Xll, y, fo))
}))
print(round(as.data.frame(res), 4), row.names = FALSE)
cat(sprintf("\n   Trung bình 5 seed: log-level = %.4f | log-log = %.4f | chênh = %.4f\n",
            mean(res[, "log_level"]), mean(res[, "log_log"]),
            mean(res[, "log_log"]) - mean(res[, "log_level"])))

cat("\n=========== (D) Hệ số chuẩn hóa xếp theo ĐỘ LỚN (dòng 401) ===========\n")
cs <- coef(ols_std)[-1]
cat("Báo cáo khẳng định: 'Beak.Width và các số đo cánh có độ lớn ảnh hưởng lớn nhất'\n\n")
print(data.frame(bien = names(cs), he_so = round(as.numeric(cs), 3),
                 do_lon = round(abs(as.numeric(cs)), 3)) |>
        arrange(desc(do_lon)), row.names = FALSE)

cat("\n=========== (E) Cỡ mẫu từng nhóm Habitat (dòng 809: 'n <= 20') ===========\n")
print(as.data.frame(table(anv$Habitat)) |> setNames(c("Habitat", "n")), row.names = FALSE)

cat("\n=========== (F) LASSO có giữ 1 đại diện mỗi cụm không? (dòng 452-454) ===\n")
cat("Giữ lại:", paste(setdiff(rownames(kept), "(Intercept)"), collapse = ", "), "\n")
cat("Cụm cánh (Wing.Length, Kipps.Distance, Secondary1) -> giữ:",
    paste(intersect(rownames(kept), c("Wing.Length", "Kipps.Distance", "Secondary1")),
          collapse = ", "), "\n")
cat("Cụm mỏ-dài (Beak.Length_Culmen, Beak.Length_Nares) -> giữ:",
    paste(intersect(rownames(kept), c("Beak.Length_Culmen", "Beak.Length_Nares")),
          collapse = ", "), "\n")
