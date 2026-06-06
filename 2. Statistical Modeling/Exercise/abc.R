# ==============================================================================
# THỰC HÀNH R: KIỂM ĐỊNH, KHẮC PHỤC VÀ VẼ BIỂU ĐỒ PHƯƠNG SAI THAY ĐỔI
# ==============================================================================

# 1. CÀI ĐẶT CÁC GÓI LỆNH 
# (Xóa dấu # ở 4 dòng dưới đây và chạy 1 lần duy nhất nếu máy bạn chưa cài đặt)
# install.packages("car")
# install.packages("lmtest")
# install.packages("sandwich")
# install.packages("ggplot2")

# 2. GỌI THƯ VIỆN (Bắt buộc phải chạy để không bị lỗi "could not find function")
library(car)
library(lmtest)
library(sandwich)
library(ggplot2)

# 3. NẠP DỮ LIỆU VÀ CHẠY MÔ HÌNH OLS GỐC
data(Prestige)
model <- lm(prestige ~ income + education, data = Prestige)

cat("\n===============================================================\n")
cat("1. BẢNG KẾT QUẢ OLS GỐC (CHƯA HIỆU CHỈNH)\n")
cat("===============================================================\n")
print(summary(model))

# 4. CÁC KIỂM ĐỊNH PHÁT HIỆN PHƯƠNG SAI THAY ĐỔI
cat("\n===============================================================\n")
cat("2. KIỂM ĐỊNH BREUSCH-PAGAN (1979)\n")
cat("===============================================================\n")
print(bptest(model))

cat("\n===============================================================\n")
cat("3. KIỂM ĐỊNH WHITE (1980)\n")
cat("===============================================================\n")
print(bptest(model, ~ income * education + I(income^2) + I(education^2), data = Prestige))

# 5. KHẮC PHỤC BẰNG ROBUST STANDARD ERRORS (CHUẨN HC3)
cat("\n===============================================================\n")
cat("4. BẢNG KẾT QUẢ VỚI ROBUST STANDARD ERRORS (CHUẨN HC3)\n")
cat("===============================================================\n")
robust_model <- coeftest(model, vcov = vcovHC(model, type = "HC3"))
print(robust_model)


# 6. VẼ BIỂU ĐỒ MINH HỌA TRỰC QUAN
# ------------------------------------------------------------------------------
# 6.1 Biểu đồ chẩn đoán cơ bản (Xuất hiện trong tab Plots mặc định)
par(mfrow = c(1, 2)) 
plot(model, which = 1, main = "Residuals vs Fitted\n(Phân tán phần dư)", pch = 16, col = "steelblue")
plot(model, which = 3, main = "Scale-Location\n(Kiểm tra phương sai)", pch = 16, col = "darkorange")
par(mfrow = c(1, 1)) 

# ------------------------------------------------------------------------------
# 6.2 Biểu đồ so sánh Khoảng tin cậy bằng ggplot2
# Lấy khoảng tin cậy của OLS
ci_ols <- confint(model)[2:3, ] 

# Lấy khoảng tin cậy của HC3
ci_hc3 <- coefci(model, vcov. = vcovHC(model, type = "HC3"))[2:3, ]

# Tạo dataframe để vẽ biểu đồ
df_plot <- data.frame(
  Variable = rep(c("Income", "Education"), 2),
  Method = rep(c("1. OLS Standard Errors", "2. Robust SE (HC3)"), each = 2),
  Estimate = rep(coef(model)[2:3], 2),
  Lower = c(ci_ols[, 1], ci_hc3[, 1]),
  Upper = c(ci_ols[, 2], ci_hc3[, 2])
)

# Vẽ biểu đồ và lưu vào biến bieu_do
bieu_do <- ggplot(df_plot, aes(x = Variable, y = Estimate, color = Method)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = Lower, ymax = Upper), 
                position = position_dodge(width = 0.5), 
                width = 0.2, linewidth = 1) +
  facet_wrap(~ Variable, scales = "free") +
  labs(title = "So sánh Khoảng tin cậy 95% (OLS vs Robust HC3)",
       subtitle = "Khoảng tin cậy rộng hơn cho thấy SE đã được hiệu chỉnh mạnh mẽ",
       x = "Biến độc lập",
       y = "Giá trị hệ số ước lượng") +
  theme_minimal() +
  scale_color_manual(values = c("steelblue", "firebrick")) +
  theme(legend.position = "bottom",
        text = element_text(size = 12),
        strip.text = element_text(face = "bold", size = 12))

# Lệnh này sẽ in trực tiếp biểu đồ ggplot ra tab Plots
print(bieu_do)

