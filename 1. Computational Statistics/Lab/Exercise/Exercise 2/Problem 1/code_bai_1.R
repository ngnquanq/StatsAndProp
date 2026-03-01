#Bài 1
data <- read.table("salmon.dat",header = TRUE)
#đưa về tuyến tính hoá: lm()
model <- lm(I(1/recruits)~I(1/spawners),data=data)
b0 <- coef(model)[1] # hệ số tự do
b1 <- coef(model)[2] # hệ số biến
theta <- (1-b1)/b0
#Câu a
cat("Ước lượng điểm cho mức dân số ổn định khi R = S là:", theta,"(nghìn con cá)")

#========================
#Câu b
B <- 1000
set.seed(123)
# CÁCH 1: Bootstrap dữ liệu
calc_theta <-function(d){
  fit <- lm(I(1/recruits)~I(1/spawners),data=d)
  b0_star <- coef(fit)[1]
  b1_star <- coef(fit)[2]
  (1 - b1_star) / b0_star
} 
#--------------
# function for making bootstrap sample
my_boot <- function(data, R = 500, seed = NULL){
  if(is.null(seed)) seed <- 34
  set.seed(seed)
  data_bts <- list() # list-object
  if(is.null(dim(data))){
    n <- length(data)
    id_bts <- replicate(n = R, 
                        expr = sample(1:n, size = n, replace = TRUE))
    for(i in 1:R){
      data_bts[[i]] <- data[id_bts[, i]]
    }
  } else{
    n <- nrow(data) # dim(data)[1] # number's rows 
    id_bts <- replicate(n = R, 
                        expr = sample(1:n, size = n, replace = TRUE))
    for(i in 1:R){
      data_bts[[i]] <- data[id_bts[, i], ]
    }
  }
  return(data_bts)
}
my_ci_boot <- function(boot_sample, data, fun, alpha = 0.05, 
                       ci_type = c("quantile", "bca"), ...){
  ci_type <- match.arg(ci_type) ## defaut is quantile
  est_boot <- sapply(boot_sample, function(x) fun(x, ...))
  est_boot_st <- sort(est_boot)
  R <- length(boot_sample)
  alpha2 <- alpha/2
  if (ci_type == "quantile"){
    ci_boot <- est_boot_st[c(floor(R * alpha2), floor(R * (1 - alpha2)))]
  }
  if (ci_type == "bca"){
    est_sample <- fun(data, ...)
    b_est <- qnorm(mean(est_boot <= est_sample))
    if(is.null(dim(data))){
      est_jack <- sapply(1:length(data), function(i){
        fun(data[-i], ...)
      })
    } else{
      est_jack <- sapply(1:nrow(data), function(i){
        fun(data[-i, ], ...)
      })
    }
    est_jack2 <- mean(est_jack)
    u <- est_jack2 - est_jack
    a_est <- ((1/6) * sum(u^3)) * (sum(u^2))^(-3/2)
    z_alp <- qnorm(alpha2)
    beta1_est <- pnorm(b_est + 1/(1/(b_est + z_alp) - a_est))
    beta2_est <- pnorm(b_est + 1/(1/(b_est - z_alp) - a_est))
    ci_boot <- est_boot_st[c(floor(R * beta1_est), floor(R * beta2_est))]
    print(c(a_est, b_est))
  }
  return(list(est_boot = est_boot, ci_type = ci_type, ci_boot = ci_boot))
}
#--------------
boot_data <- my_boot(data,R=B,seed=123)#tạo mẫu
ci_method1 <- my_ci_boot(boot_sample=boot_data,data=data,fun=calc_theta,ci_type="quantile")
theta_star_1 <- ci_method1$est_boot
se_1 <- sd(theta_star_1)
ci_perc_1 <- ci_method1$ci_boot
cat("\n--- CÁCH 1: Bootstrap dữ liệu ---\n")
cat("Sai số chuẩn (SE):", se_1, "\n")
cat("Khoảng tin cậy Percentile 95%:\n")
print(ci_perc_1)

#================
#CÁCH 2: Residual-based bootstrap

y_hat <- predict(model) 
res_orig <- residuals(model) 
boot_res <- my_boot(res_orig, R = B, seed = 123)
theta_star_2 <- numeric(B)

for(i in 1:B) {
  res_star <- boot_res[[i]]
  R_star <- 1 / (y_hat + res_star)
  
  data_star <- data.frame(recruits = R_star, spawners = data$spawners)
    fit_star <- lm(I(1/recruits) ~ I(1/spawners), data = data_star)
  b0_star2 <- coef(fit_star)[1]
  b1_star2 <- coef(fit_star)[2]
  
  theta_star_2[i] <- (1 - b1_star2) / b0_star2
}

se_2 <- sd(theta_star_2)
ci_perc_2 <- quantile(theta_star_2, probs = c(0.025, 0.975))

cat("\n--- CÁCH 2: Residual-based bootstrap ---\n")
cat("Sai số chuẩn (SE):", se_2, "\n")
cat("Khoảng tin cậy Percentile 95%:\n")
print(ci_perc_2)

#========================
# VẼ BIỂU ĐỒ HISTOGRAM SO SÁNH (theta_1* và theta_2*)
par(mfrow = c(1, 2))
hist(theta_star_1, main = "Data Bootstrap", xlab = "Theta_1*", col = "lightblue")
hist(theta_star_2, main = "Residual Bootstrap", xlab = "Theta_2*", col = "lightgreen")
par(mfrow = c(1, 1))

#=======================
#Câu c
# CÁCH 1: BCa cho Data Bootstrap
# ------------------------------------------------------------------
cat("\n--- CÁCH 1: Data Bootstrap (BCa) ---\n")

# Sử dụng hàm my_ci_boot với tham số ci_type = "bca"
ci_method1_bca <- my_ci_boot(boot_sample = boot_data, 
                             data = data, 
                             fun = calc_theta, 
                             ci_type = "bca")

cat("Khoảng tin cậy BCa 95%:\n")
print(ci_method1_bca$ci_boot)

# ------------------------------------------------------------------
# CÁCH 2: BCa cho Residual Bootstrap
# ------------------------------------------------------------------
cat("\n--- CÁCH 2: Residual Bootstrap (BCa) ---\n")

# Bước 1: Tính hệ số chệch z0 (Bias correction)
# Tỷ lệ các giá trị theta_star_2 nhỏ hơn hoặc bằng ước lượng gốc theta
p_leq <- mean(theta_star_2 <= theta)
z0 <- qnorm(p_leq)

# Bước 2: Tính hệ số gia tốc a (Acceleration) bằng thuật toán Jackknife trên dữ liệu gốc
n <- nrow(data)
theta_jack <- numeric(n)

for(i in 1:n) {
  # Ước lượng mô hình khi lần lượt loại bỏ quan sát thứ i
  fit_jack <- lm(I(1/recruits) ~ I(1/spawners), data = data[-i, ])
  b0_j <- coef(fit_jack)[1]
  b1_j <- coef(fit_jack)[2]
  theta_jack[i] <- (1 - b1_j) / b0_j
}

theta_jack_mean <- mean(theta_jack)
U <- theta_jack_mean - theta_jack
a_est <- (1/6) * sum(U^3) / (sum(U^2))^(3/2)

# Bước 3: Xác định các phân vị điều chỉnh (Adjusted percentiles) cho độ tin cậy 95%
alpha <- 0.05
z_alpha2 <- qnorm(alpha / 2)       
z_1_alpha2 <- qnorm(1 - alpha / 2) 

# Công thức tính xác suất phân vị điều chỉnh cho BCa
alpha1 <- pnorm(z0 + (z0 + z_alpha2) / (1 - a_est * (z0 + z_alpha2)))
alpha2 <- pnorm(z0 + (z0 + z_1_alpha2) / (1 - a_est * (z0 + z_1_alpha2)))

# Bước 4: Trích xuất khoảng tin cậy từ phân phối bootstrap đã sắp xếp của Cách 2
theta_star_2_sorted <- sort(theta_star_2)
ci_bca_2 <- theta_star_2_sorted[c(floor(B * alpha1), floor(B * alpha2))]

cat(sprintf("Hệ số gia tốc (a): %f, Hệ số chệch (z0): %f\n", a_est, z0))
cat("Khoảng tin cậy BCa 95%:\n")
print(ci_bca_2)

#===================================================================
# Câu d: Xác định khoảng tin cậy 95% với phương pháp studentized cho
#θ theo hai cách bootstrap
#sử dụng trong (a), kết hợp với một quy trình bootstrap thứ 2.

cat("\n=========================================\n")
cat("CÂU (d): KHOẢNG TIN CẬY STUDENTIZED 95%\n")

B_outer <- 500 
B_inner <- 50  
alpha <- 0.05

# ------------------------------------------------------------------
# CÁCH 1: Studentized cho Data Bootstrap (Xáo trộn theo cặp)

t_stars_1 <- numeric(B_outer)

for(i in 1:B_outer) {
  data_star <- data[sample(1:nrow(data), replace = TRUE), ]
  fit_star <- lm(I(1/recruits) ~ I(1/spawners), data = data_star)
  b0_star <- coef(fit_star)[1]
  b1_star <- coef(fit_star)[2]
  theta_star <- (1 - b1_star) / b0_star
    theta_inner_1 <- numeric(B_inner)
  for(j in 1:B_inner) {
    data_inner <- data_star[sample(1:nrow(data_star), replace = TRUE), ]
    fit_inner <- lm(I(1/recruits) ~ I(1/spawners), data = data_inner)
    theta_inner_1[j] <- (1 - coef(fit_inner)[2]) / coef(fit_inner)[1]
  }
  
  se_star <- sd(theta_inner_1)
  
  t_stars_1[i] <- (theta_star - theta) / se_star
}

t_quantiles_1 <- quantile(t_stars_1, probs = c(1 - alpha/2, alpha/2), na.rm = TRUE)

# Khoảng tin cậy (se_1 đã được tính ở Câu b)
ci_stud_1 <- theta - t_quantiles_1 * se_1

cat("\n--- CÁCH 1: Data Bootstrap (Studentized) ---\n")
cat("Khoảng tin cậy Studentized 95%:\n")
print(ci_stud_1)


# ------------------------------------------------------------------
# CÁCH 2: Studentized cho Residual Bootstrap

t_stars_2 <- numeric(B_outer)

for(i in 1:B_outer) {
  res_star <- sample(res_orig, size = nrow(data), replace = TRUE)
  R_star <- 1 / (y_hat + res_star)
  data_star <- data.frame(recruits = R_star, spawners = data$spawners)
  
  fit_star <- lm(I(1/recruits) ~ I(1/spawners), data = data_star)
  theta_star <- (1 - coef(fit_star)[2]) / coef(fit_star)[1]
  y_hat_star <- predict(fit_star)
  res_star_model <- residuals(fit_star)
  res_star_model <- res_star_model - mean(res_star_model) # centering phần dư
  
  theta_inner_2 <- numeric(B_inner)
  for(j in 1:B_inner) {
    res_inner <- sample(res_star_model, size = nrow(data_star), replace = TRUE)
    R_inner <- 1 / (y_hat_star + res_inner)
    data_inner <- data.frame(recruits = R_inner, spawners = data_star$spawners)
    
    fit_inner <- lm(I(1/recruits) ~ I(1/spawners), data = data_inner)
    theta_inner_2[j] <- (1 - coef(fit_inner)[2]) / coef(fit_inner)[1]
  }
  
  se_star <- sd(theta_inner_2)
  
  t_stars_2[i] <- (theta_star - theta) / se_star
}

t_quantiles_2 <- quantile(t_stars_2, probs = c(1 - alpha/2, alpha/2), na.rm = TRUE)

# Khoảng tin cậy (se_2 đã được tính ở Câu b)
ci_stud_2 <- theta - t_quantiles_2 * se_2

cat("\n--- CÁCH 2: Residual Bootstrap (Studentized) ---\n")
cat("Khoảng tin cậy Studentized 95%:\n")
print(ci_stud_2)
