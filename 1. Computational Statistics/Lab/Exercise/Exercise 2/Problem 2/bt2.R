source("boostrap.R")
source("permutation_test.R")


data_raw <- read.table("cancersurvival.dat", header = TRUE)

# Log transform
data_raw$logtime <- log(data_raw$survivaltime)
stomach <- data_raw$logtime[data_raw$disease == 1]  # Ung thư dạ dày
breast  <- data_raw$logtime[data_raw$disease == 2]  # Ung thư vú


#Câu (a): Sử dụng phương pháp bootstrap studentized và BCa để xây dựng khoảng tin cậy 95% cho thời gian sống trung bình của mỗi nhóm.       


set.seed(42)
R <- 2000

# class 1
stomach_bts <- my_boots(stomach, R = R)
ci_stomach_quantile <- my_ci_boot(data = stomach, boot_sample = stomach_bts, fun = mean, alpha = 0.05, ci_type = "quantile")
ci_stomach_bca <- my_ci_boot(data = stomach, boot_sample = stomach_bts, fun = mean, alpha = 0.05, ci_type = "bca")


# class 2
breast_bts <- my_boots(breast, R = R)
ci_breast_quantile <- my_ci_boot(data = breast, boot_sample = breast_bts, fun = mean, alpha = 0.05, ci_type = "quantile")
ci_breast_bca <- my_ci_boot(data = breast, boot_sample = breast_bts, fun = mean, alpha = 0.05, ci_type = "bca")

cat("Câu (a): CI 95%\n")
cat("\n[Ung thư dạ dày]\n")
cat("  Percentile: [", ci_stomach_quantile$ci_boot, "]\n")
cat("  BCa       : [", ci_stomach_bca$ci_boot, "]\n")

cat("\n[Ung thư vú]\n")
cat("  Percentile: [", ci_breast_quantile$ci_boot, "]\n")
cat("  BCa       : [", ci_breast_bca$ci_boot, "]\n\n")


# Cau (b): Sử dụng permutation test để kiểm tra giả thuyết rằng không có sự khác biệt về thời gian sống trung bình giữa các nhóm


set.seed(42)
perm_result <- my_perm_test(dataA = stomach, dataB = breast, fun = mean, R = 10000)

cat("Cau (b): Permutation Test\n")
cat("t_diff (stomach - breast) =", perm_result$t_diff, "\n")
cat("p-value = ", perm_result$p_value, "\n")
cat("chon alpha = 0.05 -> p-value = ", perm_result$p_value, "\n")
if (perm_result$p_value < 0.05) {
  cat("bac bo H0\n\n")
} else {
  cat("khong bac bo H0\n\n")
}


breast_raw <- data_raw$survivaltime[data_raw$disease == 2]

set.seed(42)

# Cau (c): Sau khi đã tính toán được khoảng tin cậy trong (a), chúng ta hãy xem xét một số sai sót có thể xảy ra. Xây dựng khoảng tin cậy 95% cho thời gian sống trung bình của bệnh ung thư vú bằng cách áp dụng phương pháp bootstrap percentile cho dữ liệu đã được chuyển đổi logarit và sau đó áp dụng exp(·) cho chặn dưới và chặn trên của khoảng tin cậy. Xây dựng một khoảng tin cậy khác bằng cách áp dụng phương pháp bootstrap percentile cho dữ liệu trên thang đo gốc. So sánh với (a).

# CI 1: Percentile tren log(x), roi exp()
bts_log <- my_boots(breast, R = R)
ci_c1 <- my_ci_boot(data = breast, boot_sample = bts_log, fun = mean,
                    alpha = 0.05, ci_type = "quantile")
ci_c1_exp <- exp(ci_c1$ci_boot)

# CI 2: Percentile tren du lieu goc
bts_raw <- my_boots(breast_raw, R = R)
ci_c2 <- my_ci_boot(data = breast_raw, boot_sample = bts_raw, fun = mean,
                    alpha = 0.05, ci_type = "quantile")

cat("Cau (c): CI 95% cho mean thoi gian song (breast)\n\n")
cat("Percentile tren log(x) -> exp(): [", ci_c1_exp, "]\n")
cat("Percentile tren du lieu goc    : [", ci_c2$ci_boot, "]\n")
cat("BCa tren log(x) tu cau (a) -> exp(): [", exp(ci_breast_bca$ci_boot), "]\n")
