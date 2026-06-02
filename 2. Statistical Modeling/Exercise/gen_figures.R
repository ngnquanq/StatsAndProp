# ============================================================
# Sinh hình cho multiple_regression_assumptions.tex
# Chạy: Rscript gen_figures.R
# Seed: 42 (set toàn cục, reproducible)
# ============================================================

set.seed(42)

# -- fig6_blue_clt.png ---------------------------------------------------------
# Minh họa: (1) Gauss-Markov BLUE — OLS đạt phương sai nhỏ nhất
#           (2) CLT — β̂ tiến về chuẩn dù sai số lệch phải

B     <- 4000
n     <- 40
beta1 <- 2

beta_ols <- numeric(B)
beta_alt <- numeric(B)

for (b in seq_len(B)) {
  x   <- runif(n, 0, 1)
  eps <- rnorm(n, sd = 1)
  y   <- beta1 * x + eps

  xc <- x - mean(x)
  beta_ols[b] <- sum(xc * y) / sum(xc^2)

  # Ước lượng tuyến tính không chệch thay thế: trung bình hóa theo nhóm trung vị
  med_x <- median(x)
  hi <- x > med_x;  lo <- !hi
  beta_alt[b] <- (mean(y[hi]) - mean(y[lo])) / (mean(x[hi]) - mean(x[lo]))
}

ns   <- c(10, 40, 200)
cols <- c("#E74C3C", "#3498DB", "#27AE60")

betas_n <- lapply(ns, function(nn) {
  replicate(3000, {
    x   <- runif(nn, 0, 1)
    eps <- rexp(nn, rate = 1) - 1       # mean = 0, lệch phải
    y   <- beta1 * x + eps
    xc  <- x - mean(x)
    sum(xc * y) / sum(xc^2)
  })
})

png("./figures/fig6_blue_clt.png", width = 920, height = 420, res = 110)

par(mfrow = c(1, 2), mar = c(4, 4, 3, 1.5), mgp = c(2.4, 0.7, 0))

# Panel 1: BLUE
v_ols    <- round(var(beta_ols), 3)
v_alt    <- round(var(beta_alt), 3)
xlim1    <- range(c(beta_ols, beta_alt))
dens_ols <- density(beta_ols)
dens_alt <- density(beta_alt)
ylim1    <- c(0, max(dens_ols$y, dens_alt$y) * 1.12)

plot(dens_alt, col = "#E74C3C", lwd = 2, xlim = xlim1, ylim = ylim1,
     xlab = expression(hat(beta)[1]), ylab = "Mật độ",
     main = "Gauss-Markov: OLS đạt phương sai nhỏ nhất",
     bty = "l", cex.main = 0.93)
lines(dens_ols, col = "#3498DB", lwd = 2)
abline(v = beta1, lty = 2, col = "gray40", lwd = 1.4)
legend("topright",
       legend = c(paste0("OLS  (Var = ", v_ols, ")"),
                  paste0("Trung vị nhóm (Var = ", v_alt, ")")),
       col = c("#3498DB", "#E74C3C"), lwd = 2, bty = "n", cex = 0.82)
text(beta1 + 0.08, ylim1[2] * 0.55,
     expression(beta[1] == 2), col = "gray40", cex = 0.8)

# Panel 2: CLT cho beta_ols với sai số lệch phải
dens_list <- lapply(betas_n, density)
ylim2 <- c(0, max(sapply(dens_list, function(d) max(d$y))) * 1.12)
xlim2 <- range(sapply(dens_list, function(d) range(d$x)))

plot(dens_list[[1]], col = cols[1], lwd = 2,
     xlim = xlim2, ylim = ylim2,
     xlab = expression(hat(beta)[1]), ylab = "Mật độ",
     main = expression("CLT: sai số" ~ Exp(1) - 1 * ", " * hat(beta) * " vẫn tiến về chuẩn"),
     bty = "l", cex.main = 0.93)
for (i in 2:3) lines(dens_list[[i]], col = cols[i], lwd = 2)
abline(v = beta1, lty = 2, col = "gray40", lwd = 1.4)
legend("topright", legend = paste0("n = ", ns),
       col = cols, lwd = 2, bty = "n", cex = 0.82)

dev.off()
cat("fig6_blue_clt.png done\n")

# -- fig7_anscombe.png ---------------------------------------------------------
# Tứ giác Anscombe: 4 bộ dữ liệu, cùng β̂ / R² / p-value, hình dạng khác nhau
# Hàng trên: scatterplot + đường hồi quy
# Hàng dưới: đồ thị phần dư theo giá trị khớp

data(anscombe)

# Khớp 4 mô hình
fits <- lapply(1:4, function(i)
  lm(anscombe[[paste0("y", i)]] ~ anscombe[[paste0("x", i)]]))

# Thống kê số — để chú thích trên hình
stats <- lapply(fits, function(m) {
  s   <- summary(m)
  pv  <- coef(s)[2, 4]
  list(b0 = round(coef(m)[1], 2),
       b1 = round(coef(m)[2], 2),
       r2 = round(s$r.squared, 3),
       pv = formatC(pv, digits = 3, format = "g"))
})

titles <- c("I: tuyến tính", "II: phi tuyến bậc 2",
            "III: ngoại lai ảnh hưởng hệ số", "IV: đòn bẩy cao")

png("./figures/fig7_anscombe.png", width = 1000, height = 800, res = 110)

par(mfrow = c(2, 4), mar = c(3.5, 3.5, 2.8, 0.8),
    mgp = c(2.2, 0.6, 0), oma = c(0, 0, 2, 0))

# Hàng 1: scatterplot + đường hồi quy
for (i in 1:4) {
  xi <- anscombe[[paste0("x", i)]]
  yi <- anscombe[[paste0("y", i)]]
  st <- stats[[i]]
  plot(xi, yi, pch = 16, col = "steelblue",
       xlab = paste0("x", i), ylab = paste0("y", i),
       main = titles[i], cex.main = 0.88, bty = "l")
  abline(fits[[i]], col = "#C0392B", lwd = 2)
  legend("bottomright",
         legend = bquote(atop(hat(beta)[1] == .(st$b1),
                              R^2 == .(st$r2))),
         bty = "n", cex = 0.75)
}

# Hàng 2: đồ thị phần dư
for (i in 1:4) {
  fv <- fitted(fits[[i]])
  rv <- residuals(fits[[i]])
  plot(fv, rv, pch = 16, col = "steelblue",
       xlab = "Giá trị khớp", ylab = "Phần dư",
       main = paste0("Phần dư — ", c("I","II","III","IV")[i]),
       cex.main = 0.88, bty = "l")
  abline(h = 0, lty = 2, col = "gray50")
  lines(lowess(fv, rv), col = "#C0392B", lwd = 2)
}

mtext("Tứ giác Anscombe: cùng β̂, R², p-value — chỉ đồ thị phần dư tiết lộ sự khác biệt",
      outer = TRUE, cex = 0.9, font = 2)

dev.off()
cat("fig7_anscombe.png done\n")

# -- fig8_avplot.png -----------------------------------------------------------
# Đồ thị hồi quy riêng phần (added-variable / partial regression plots)
# Mô hình: mpg ~ hp + wt + disp  (mtcars)
# Mỗi panel: e(Y | others) vs e(Xj | others)
# Độ dốc của mỗi panel = hệ số β trong mô hình đầy đủ

data(mtcars)
fit_full <- lm(mpg ~ hp + wt + disp, data = mtcars)
vars <- c("hp", "wt", "disp")
labels_x <- c("Công suất (hp)", "Trọng lượng (wt)", "Dung tích (disp)")

av_data <- lapply(vars, function(jname) {
  others <- setdiff(vars, jname)
  fmY  <- as.formula(paste("mpg ~", paste(others, collapse = "+")))
  fmXj <- as.formula(paste(jname, "~", paste(others, collapse = "+")))
  eY   <- residuals(lm(fmY,  data = mtcars))
  eXj  <- residuals(lm(fmXj, data = mtcars))
  list(eY = eY, eXj = eXj,
       beta_av   = round(coef(lm(eY ~ eXj))[2], 3),
       beta_full = round(coef(fit_full)[jname], 3))
})

png("./figures/fig8_avplot.png", width = 960, height = 350, res = 110)

par(mfrow = c(1, 3), mar = c(4, 4, 3, 1), mgp = c(2.4, 0.7, 0))

for (i in seq_along(vars)) {
  d <- av_data[[i]]
  plot(d$eXj, d$eY,
       pch = 16, col = "steelblue", cex = 0.85,
       xlab = paste0("e(", vars[i], " | others)"),
       ylab = "e(mpg | others)",
       main = paste0("Biến: ", vars[i]),
       bty  = "l", cex.main = 0.93)
  abline(lm(d$eY ~ d$eXj), col = "#C0392B", lwd = 2)
  abline(h = 0, lty = 2, col = "gray60")
  abline(v = 0, lty = 2, col = "gray60")
  legend("topright",
         legend = c(bquote(hat(beta)[AV] == .(d$beta_av)),
                    bquote(hat(beta)[full] == .(d$beta_full))),
         bty = "n", cex = 0.78)
}

dev.off()
cat("fig8_avplot.png done\n")

# -- fig9_splines.png ----------------------------------------------------------
# So sánh đa thức bậc 7 vs cubic B-spline (4 nút) trên dữ liệu dạng sóng
# Mục đích: thể hiện đa thức dao động mạnh ở biên, splines ổn định toàn vùng

library(splines)

n_obs <- 80
x_obs <- sort(runif(n_obs, 0, 10))
y_obs <- sin(x_obs) + 0.5 * rnorm(n_obs)

x_seq  <- seq(0, 10, length.out = 400)
y_true <- sin(x_seq)

# Đa thức bậc 7 (toàn cục)
fit_poly <- lm(y_obs ~ poly(x_obs, 7))
pred_poly <- predict(fit_poly,
                     newdata = data.frame(x_obs = x_seq))

# Cubic B-spline với 4 nút tại phân vị
knots4    <- quantile(x_obs, probs = c(0.2, 0.4, 0.6, 0.8))
fit_spl   <- lm(y_obs ~ bs(x_obs, knots = knots4, degree = 3))
pred_spl  <- predict(fit_spl,
                     newdata = data.frame(x_obs = x_seq))

png("./figures/fig9_splines.png", width = 900, height = 420, res = 110)

par(mfrow = c(1, 2), mar = c(4, 4, 3, 1), mgp = c(2.4, 0.7, 0))

# Panel 1 — Đa thức bậc 7
plot(x_obs, y_obs, pch = 16, cex = 0.65, col = "gray55",
     xlab = "x", ylab = "y",
     main = "Đa thức bậc 7 (toàn cục)",
     bty = "l", cex.main = 0.95)
lines(x_seq, y_true,    col = "gray40",   lwd = 1.5, lty = 2)
lines(x_seq, pred_poly, col = "#C0392B",  lwd = 2.2)
legend("topright",
       legend = c("Giá trị thực (sin x)", "Đa thức bậc 7"),
       col = c("gray40", "#C0392B"), lwd = c(1.5, 2.2),
       lty = c(2, 1), bty = "n", cex = 0.8)

# Panel 2 — Cubic B-spline
plot(x_obs, y_obs, pch = 16, cex = 0.65, col = "gray55",
     xlab = "x", ylab = "y",
     main = "Cubic B-spline (4 nút)",
     bty = "l", cex.main = 0.95)
lines(x_seq, y_true,   col = "gray40",   lwd = 1.5, lty = 2)
lines(x_seq, pred_spl, col = "#2980B9",  lwd = 2.2)
abline(v = knots4, lty = 3, col = "gray65", lwd = 1)
legend("topright",
       legend = c("Giá trị thực (sin x)",
                  "Cubic B-spline",
                  "Nút (knots)"),
       col = c("gray40", "#2980B9", "gray65"),
       lwd = c(1.5, 2.2, 1), lty = c(2, 1, 3),
       bty = "n", cex = 0.8)

dev.off()
cat("fig9_splines.png done\n")

# -- fig10_projection.png ------------------------------------------------------
# Trái: Sơ đồ hình học — OLS là chiếu trực giao Y lên Col(X)
# Phải: Xác minh số — X'e ≈ 0 trên 500 dataset ngẫu nhiên

png("./figures/fig10_projection.png", width = 900, height = 420, res = 110)
par(mfrow = c(1, 2), mar = c(3, 3, 3.2, 1.2), mgp = c(2, 0.6, 0))

# -- Panel 1: sơ đồ hình học ---------------------------------------------------
plot(0, 0, type = "n", xlim = c(-0.15, 2.2), ylim = c(-0.15, 2.4),
     xlab = "", ylab = "", asp = 1,
     main = "OLS = chiếu trực giao lên Col(X)",
     axes = FALSE, cex.main = 0.93)

# Trục gốc
arrows(-0.1, 0, 2.1, 0, length = 0.07, col = "gray70", lwd = 1)
arrows(0, -0.1, 0, 2.3, length = 0.07, col = "gray70", lwd = 1)
text(2.15, 0, expression(e[1]), cex = 0.8, col = "gray60")
text(0.06, 2.3, expression(e[2]), cex = 0.8, col = "gray60")
text(0.06, -0.1, "O", cex = 0.85, col = "gray50")

# Không gian dự báo Col(X): đường thẳng qua gốc theo hướng (2,1)/||...||
dir_x <- c(2, 1) / sqrt(5)
t_vals <- seq(0, 2.2, length.out = 50)
lines(t_vals * dir_x[1], t_vals * dir_x[2],
      col = "gray50", lwd = 1.8, lty = 2)
text(2.05 * dir_x[1] + 0.03, 2.05 * dir_x[2] + 0.12,
     "Col(X)", col = "gray50", cex = 0.82, srt = 27)

# Vector Y
Y <- c(1.0, 2.2)
arrows(0, 0, Y[1], Y[2], lwd = 2.8, col = "#2C3E50", length = 0.09)
text(Y[1] + 0.09, Y[2] + 0.06, "Y", col = "#2C3E50", cex = 1.05, font = 2)

# Ŷ = chiếu Y lên Col(X)
Yhat_s <- sum(Y * dir_x)
Yhat   <- Yhat_s * dir_x
arrows(0, 0, Yhat[1], Yhat[2], lwd = 2.8, col = "#C0392B", length = 0.09)
text(Yhat[1] - 0.22, Yhat[2] - 0.07,
     expression(hat(Y) == X * hat(beta)), col = "#C0392B", cex = 0.82)

# Residual e = Y - Ŷ
arrows(Yhat[1], Yhat[2], Y[1], Y[2],
       lwd = 2.2, col = "#2980B9", length = 0.08)
mid_e <- (Yhat + Y) / 2
text(mid_e[1] + 0.12, mid_e[2],
     expression(e == Y - hat(Y)), col = "#2980B9", cex = 0.78)

# Góc vuông tại Ŷ
sq  <- 0.06
perp_dir <- c(-dir_x[2], dir_x[1])
sq_pts <- rbind(Yhat + sq * dir_x,
                Yhat + sq * dir_x + sq * perp_dir,
                Yhat + sq * perp_dir)
lines(sq_pts[, 1], sq_pts[, 2], col = "gray40", lwd = 1.2)

# -- Panel 2: Xác minh X'e = 0 -------------------------------------------------
max_xte <- replicate(500, {
  n <- 40; p <- 3
  X    <- cbind(1, matrix(rnorm(n * p), n, p))
  beta <- c(1, 2, -1, 0.5)
  y    <- X %*% beta + rnorm(n, sd = 2)
  bhat <- solve(t(X) %*% X) %*% t(X) %*% y
  e    <- y - X %*% bhat
  max(abs(t(X) %*% e))
})

hist(log10(max_xte), breaks = 40,
     col = "steelblue", border = "white",
     main = expression("Kiểm tra " * X^T * e == 0 * " (500 dataset ngẫu nhiên)"),
     xlab = expression(log[10] * "||" * X^T * e * "||"),
     ylab = "Tần số", cex.main = 0.93, bty = "l")
abline(v = log10(.Machine$double.eps * 1e3),
       lty = 2, col = "#C0392B", lwd = 1.5)
mtext("Ngưỡng sai số máy", side = 3, at = log10(.Machine$double.eps * 1e3),
      col = "#C0392B", cex = 0.72, line = 0.2)

dev.off()
cat("fig10_projection.png done\n")

# -- fig11_liduan.png ----------------------------------------------------------
# Mô phỏng định lý Li-Duan: OLS ước lượng đúng hướng β dù g phi tuyến
# Thiết kế: Y = g(β'X) + ε, β = (3,1), X ~ N(0,I), g thay đổi
# Hiển thị: scatter β̂_1 vs β̂_2 chuẩn hóa — luôn xếp thẳng theo (3,1)

beta_true <- c(3, 1)          # hướng thực sự
beta_true_n <- beta_true / sqrt(sum(beta_true^2))

n_sim  <- 800
n_obs  <- 60

g_list <- list(
  "g(t) = t (tuyến tính)"           = function(t) t,
  "g(t) = exp(t/4)"                 = function(t) exp(t / 4),
  "g(t) = |t|^{1.5} * sign(t)"      = function(t) abs(t)^1.5 * sign(t)
)
cols_g <- c("#2C3E50", "#C0392B", "#27AE60")

png("./figures/fig11_liduan.png", width = 1050, height = 380, res = 110)
par(mfrow = c(1, 3), mar = c(4.5, 4.5, 3.2, 1), mgp = c(2.8, 0.7, 0))

for (gi in seq_along(g_list)) {
  g_fn  <- g_list[[gi]]
  b1_hat <- numeric(n_sim)
  b2_hat <- numeric(n_sim)

  for (s in seq_len(n_sim)) {
    X   <- matrix(rnorm(n_obs * 2), n_obs, 2)
    idx <- X %*% beta_true
    y   <- g_fn(idx) + rnorm(n_obs, sd = 0.8)
    bh  <- coef(lm(y ~ X - 1))   # hồi quy không có tung độ gốc
    bh_n <- bh / sqrt(sum(bh^2)) # chuẩn hóa về độ dài 1
    b1_hat[s] <- bh_n[1]
    b2_hat[s] <- bh_n[2]
  }

  plot(b1_hat, b2_hat,
       pch = 16, cex = 0.35, col = adjustcolor(cols_g[gi], 0.35),
       xlim = c(-0.5, 1.2), ylim = c(-0.4, 0.8),
       xlab = expression(hat(beta)[1] / "||" * hat(beta) * "||"),
       ylab = expression(hat(beta)[2] / "||" * hat(beta) * "||"),
       main = names(g_list)[gi], cex.main = 0.85, bty = "l")

  # Điểm β thực sự (đã chuẩn hóa)
  points(beta_true_n[1], beta_true_n[2],
         pch = 4, cex = 2.2, lwd = 2.5, col = "black")
  text(beta_true_n[1] + 0.08, beta_true_n[2] - 0.08,
       expression(beta / "||" * beta * "||"), cex = 0.82, font = 2)
}

dev.off()
cat("fig11_liduan.png done\n")

# -- fig12_violations.png ------------------------------------------------------
# Bốn ví dụ thực tế vi phạm tính tuyến tính
# Cột trái : scatter + đường OLS bậc 1
# Cột phải : đồ thị phần dư (LOESS đỏ) — mẫu hình có hệ thống
# Seed riêng cho mỗi dataset mô phỏng (set.seed() cục bộ, reproducible)

library(MASS)

# -- Dataset 1: Turkey growth (Weisberg) --------------------------------------
# E(Y|Dose) = β₀ + β₁[1 − exp(−β₂ × Dose)]; mô phỏng 5 lần/mức nồng độ
set.seed(101)
dose_lvl  <- c(0, 0.04, 0.08, 0.12, 0.16, 0.20)
dose_t    <- rep(dose_lvl, each = 5)
y_turkey  <- 639 + 168 * (1 - exp(-37 * dose_t)) + rnorm(30, 0, 18)

# -- Dataset 2: Mammals brain vs body (MASS) -----------------------------------
body_kg  <- mammals$body
brain_g  <- mammals$brain

# -- Dataset 3: Physics cross sections (Weisberg-inspired) --------------------
# Y ~ cross section (mb), X ~ momentum (GeV/c); dạng lũy thừa giảm
set.seed(102)
x_phys <- sort(runif(38, 0.3, 3.5))
y_phys <- 45 * x_phys^(-1.7) * exp(rnorm(38, 0, 0.15))

# -- Dataset 4: Tree height vs diameter (Idaho cedar, Weisberg) ---------------
set.seed(103)
dbh    <- sort(runif(65, 5, 78))
height <- 30 * (1 - exp(-0.055 * dbh)) + rnorm(65, 0, 2.2)

# -- Vẽ figure -----------------------------------------------------------------
png("./figures/fig12_violations.png",
    width = 900, height = 1180, res = 110)

par(mfrow = c(4, 2),
    mar   = c(3.8, 4.0, 2.8, 1.2),
    mgp   = c(2.4, 0.7, 0),
    oma   = c(0, 0, 1.5, 0))

datasets <- list(
  list(x      = dose_t,
       y      = y_turkey,
       xlab   = "Dose methionine (mg/g)",
       ylab   = "Weight gain (g)",
       title  = "(1) Turkey growth experiment"),
  list(x      = body_kg,
       y      = brain_g,
       xlab   = "Body weight (kg)",
       ylab   = "Brain weight (g)",
       title  = "(2) Mammals: brain ~ body (62 loài)"),
  list(x      = x_phys,
       y      = y_phys,
       xlab   = "Momentum (GeV/c)",
       ylab   = "Cross section (mb)",
       title  = "(3) Physics: strong interaction"),
  list(x      = dbh,
       y      = height,
       xlab   = "Dbh (cm)",
       ylab   = "Height (m)",
       title  = "(4) Cedar trees: height ~ diameter")
)

for (d in datasets) {
  fit_lin <- lm(d$y ~ d$x)
  fv      <- fitted(fit_lin)
  rv      <- residuals(fit_lin)

  # Cột trái: scatter + OLS
  plot(d$x, d$y,
       pch = 16, cex = 0.72, col = "steelblue",
       xlab = d$xlab, ylab = d$ylab,
       main = d$title, cex.main = 0.90, bty = "l")
  abline(fit_lin, col = "#C0392B", lwd = 2)

  # Cột phải: đồ thị phần dư
  plot(fv, rv,
       pch = 16, cex = 0.72, col = "steelblue",
       xlab = "Giá trị khớp", ylab = "Phần dư",
       main = paste(d$title, "— phần dư"),
       cex.main = 0.90, bty = "l")
  abline(h = 0, lty = 2, col = "gray50")
  lines(lowess(fv, rv), col = "#C0392B", lwd = 2.2)
}

mtext("Vi phạm tuyến tính: dữ liệu thực tế",
      outer = TRUE, cex = 0.95, font = 2)

dev.off()
cat("fig12_violations.png done\n")

# -- fig13_violations_fixed.png ------------------------------------------------
# Cùng 4 bộ dữ liệu, sau khi áp dụng biến đổi / mô hình phù hợp
# Cột trái : scatter + đường khớp đúng
# Cột phải : đồ thị phần dư sau khi khắc phục (không còn mẫu hình)

library(splines)

png("./figures/fig13_violations_fixed.png",
    width = 900, height = 1180, res = 110)

par(mfrow = c(4, 2),
    mar   = c(3.8, 4.0, 2.8, 1.2),
    mgp   = c(2.4, 0.7, 0),
    oma   = c(0, 0, 1.5, 0))

# -- (1) Turkey: NLS fit -------------------------------------------------------
fit_nls_t <- nls(y_turkey ~ b0 + b1 * (1 - exp(-b2 * dose_t)),
                 start = list(b0 = 630, b1 = 160, b2 = 30))
dose_seq  <- seq(0, 0.21, length.out = 200)
pred_nls  <- predict(fit_nls_t,
                     newdata = data.frame(dose_t = dose_seq))
rv_nls_t  <- residuals(fit_nls_t)
fv_nls_t  <- fitted(fit_nls_t)

plot(dose_t, y_turkey,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Dose methionine (mg/g)", ylab = "Weight gain (g)",
     main = "(1) Turkey — NLS: E(Y) = β₀ + β₁[1−exp(−β₂·dose)]",
     cex.main = 0.82, bty = "l")
lines(dose_seq, pred_nls, col = "#27AE60", lwd = 2.2)

plot(fv_nls_t, rv_nls_t,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Giá trị khớp", ylab = "Phần dư",
     main = "(1) Turkey — phần dư sau NLS",
     cex.main = 0.90, bty = "l")
abline(h = 0, lty = 2, col = "gray50")
lines(lowess(fv_nls_t, rv_nls_t), col = "#27AE60", lwd = 2.2)

# -- (2) Mammals: log-log transform --------------------------------------------
log_body  <- log(body_kg)
log_brain <- log(brain_g)
fit_log   <- lm(log_brain ~ log_body)
fv_log    <- fitted(fit_log)
rv_log    <- residuals(fit_log)

plot(log_body, log_brain,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "log(body weight, kg)", ylab = "log(brain weight, g)",
     main = "(2) Mammals — log-log: quan hệ tuyến tính",
     cex.main = 0.90, bty = "l")
abline(fit_log, col = "#27AE60", lwd = 2.2)

plot(fv_log, rv_log,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Giá trị khớp", ylab = "Phần dư",
     main = "(2) Mammals — phần dư sau log-log",
     cex.main = 0.90, bty = "l")
abline(h = 0, lty = 2, col = "gray50")
lines(lowess(fv_log, rv_log), col = "#27AE60", lwd = 2.2)

# -- (3) Physics: log-log transform --------------------------------------------
log_xp   <- log(x_phys)
log_yp   <- log(y_phys)
fit_logp <- lm(log_yp ~ log_xp)
fv_logp  <- fitted(fit_logp)
rv_logp  <- residuals(fit_logp)
xp_seq   <- seq(min(x_phys), max(x_phys), length.out = 200)

plot(x_phys, y_phys,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Momentum (GeV/c)", ylab = "Cross section (mb)",
     main = "(3) Physics — đường lũy thừa (hàm exp của log-log)",
     cex.main = 0.88, bty = "l")
lines(xp_seq,
      exp(predict(fit_logp, newdata = data.frame(log_xp = log(xp_seq)))),
      col = "#27AE60", lwd = 2.2)

plot(fv_logp, rv_logp,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Giá trị khớp (log scale)", ylab = "Phần dư",
     main = "(3) Physics — phần dư sau log-log",
     cex.main = 0.90, bty = "l")
abline(h = 0, lty = 2, col = "gray50")
lines(lowess(fv_logp, rv_logp), col = "#27AE60", lwd = 2.2)

# -- (4) Trees: cubic spline ---------------------------------------------------
fit_spl_t <- lm(height ~ bs(dbh,
                             knots  = quantile(dbh, c(0.25, 0.5, 0.75)),
                             degree = 3))
fv_spl_t  <- fitted(fit_spl_t)
rv_spl_t  <- residuals(fit_spl_t)
dbh_seq   <- seq(min(dbh), max(dbh), length.out = 300)
pred_spl_t <- predict(fit_spl_t,
                      newdata = data.frame(dbh = dbh_seq))

plot(dbh, height,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Dbh (cm)", ylab = "Height (m)",
     main = "(4) Cedar trees — cubic spline (3 nút)",
     cex.main = 0.90, bty = "l")
lines(dbh_seq, pred_spl_t, col = "#27AE60", lwd = 2.2)

plot(fv_spl_t, rv_spl_t,
     pch = 16, cex = 0.72, col = "steelblue",
     xlab = "Giá trị khớp", ylab = "Phần dư",
     main = "(4) Cedar trees — phần dư sau spline",
     cex.main = 0.90, bty = "l")
abline(h = 0, lty = 2, col = "gray50")
lines(lowess(fv_spl_t, rv_spl_t), col = "#27AE60", lwd = 2.2)

mtext("Khắc phục: mô hình phù hợp với từng cấu trúc dữ liệu",
      outer = TRUE, cex = 0.95, font = 2)

dev.off()
cat("fig13_violations_fixed.png done\n")

# -- fig14_scatterplot_matrix.png ----------------------------------------------
# Ma trận đồ thị phân tán: mtcars, 4 biến (mpg, hp, wt, disp)
# Đường chéo dưới: scatter + LOESS để phát hiện độ cong biên
# Đường chéo trên: hệ số tương quan Pearson (cỡ chữ theo độ lớn)
# Đường chéo giữa: tên biến + histogram mật độ

png("./figures/fig14_scatterplot_matrix.png",
    width = 860, height = 860, res = 110)

vars   <- c("mpg", "hp", "wt", "disp")
labels <- c("mpg\n(miles/gallon)", "hp\n(horsepower)",
            "wt\n(weight, 1000 lb)", "disp\n(displacement)")
dat    <- mtcars[, vars]
k      <- length(vars)

# Hàm vẽ từng ô
panel_scatter <- function(x, y, ...) {
  points(x, y, pch = 16, cex = 0.65, col = "steelblue")
  lines(lowess(x, y), col = "#C0392B", lwd = 2)
}

panel_cor <- function(x, y, digits = 2, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r   <- cor(x, y, use = "complete.obs")
  txt <- format(round(r, digits), nsmall = digits)
  cex_val <- 0.8 + 1.8 * abs(r)
  text(0.5, 0.5, txt, cex = cex_val,
       col = if (r > 0) "#2980B9" else "#C0392B", font = 2)
}

panel_hist <- function(x, ...) {
  usr <- par("usr"); on.exit(par(usr))
  h   <- hist(x, plot = FALSE, breaks = "FD")
  par(usr = c(usr[1:2], 0, max(h$density) * 1.3))
  rect(h$breaks[-length(h$breaks)], 0,
       h$breaks[-1], h$density,
       col = "steelblue", border = "white")
  lines(density(x), col = "#C0392B", lwd = 1.5)
}

pairs(dat,
      labels      = labels,
      lower.panel = panel_scatter,
      upper.panel = panel_cor,
      diag.panel  = panel_hist,
      gap         = 0.4,
      cex.labels  = 0.85, font.labels = 2)

dev.off()
cat("fig14_scatterplot_matrix.png done\n")

# -- fig15_model_eval.png ------------------------------------------------------
# So sánh trước / sau khi khắc phục phi tuyến (mtcars: mpg ~ hp)
# Hàng 1: mô hình tuyến tính (trước);  Hàng 2: đa thức bậc 2 (sau)
# Panels: scatter + fit  |  residuals vs fitted  |  Q-Q plot
# mtcars là dữ liệu thực, không cần seed riêng

data(mtcars)
model_lin  <- lm(mpg ~ hp, data = mtcars)
model_quad <- lm(mpg ~ poly(hp, 2), data = mtcars)

press_stat <- function(fit) sum((residuals(fit) / (1 - hatvalues(fit)))^2)

hp_seq  <- seq(min(mtcars$hp), max(mtcars$hp), length.out = 300)
new_df  <- data.frame(hp = hp_seq)

png("./figures/fig15_model_eval.png", width = 2800, height = 1800, res = 220)
par(mfrow = c(2, 3), mar = c(4, 4.2, 3.2, 1.5), oma = c(0, 0, 2.5, 0))

col_pts <- "gray35"

## --- Hàng 1: Linear (trước) ---
# 1a: scatter + fit
plot(mtcars$hp, mtcars$mpg, pch = 16, col = col_pts,
     xlab = "Horsepower (hp)", ylab = "mpg",
     main = "(a) Scatter — Linear")
abline(model_lin, col = "#C0392B", lwd = 2.2)

# 1b: residuals vs fitted
rv1 <- residuals(model_lin); fv1 <- fitted(model_lin)
plot(fv1, rv1, pch = 16, col = col_pts,
     xlab = "Fitted values", ylab = "Residuals",
     main = "(b) Phần dư — Linear")
abline(h = 0, lty = 2, col = "gray60")
lines(lowess(fv1, rv1, f = 0.7), col = "#C0392B", lwd = 2.2)

# 1c: Q-Q
qqnorm(rv1, main = "(c) Q-Q — Linear", pch = 16, col = col_pts,
       xlab = "Theoretical Quantiles", ylab = "Sample Quantiles")
qqline(rv1, col = "#C0392B", lwd = 2.2)

## --- Hàng 2: Quadratic (sau) ---
# 2a: scatter + fit
plot(mtcars$hp, mtcars$mpg, pch = 16, col = col_pts,
     xlab = "Horsepower (hp)", ylab = "mpg",
     main = "(d) Scatter — Quadratic")
lines(hp_seq, predict(model_quad, newdata = new_df), col = "#2980B9", lwd = 2.2)

# 2b: residuals vs fitted
rv2 <- residuals(model_quad); fv2 <- fitted(model_quad)
plot(fv2, rv2, pch = 16, col = col_pts,
     xlab = "Fitted values", ylab = "Residuals",
     main = "(e) Phần dư — Quadratic")
abline(h = 0, lty = 2, col = "gray60")
lines(lowess(fv2, rv2, f = 0.7), col = "#2980B9", lwd = 2.2)

# 2c: Q-Q
qqnorm(rv2, main = "(f) Q-Q — Quadratic", pch = 16, col = col_pts,
       xlab = "Theoretical Quantiles", ylab = "Sample Quantiles")
qqline(rv2, col = "#2980B9", lwd = 2.2)

mtext("So sánh mô hình trước và sau khi khắc phục phi tuyến (mtcars)",
      outer = TRUE, cex = 1.05, font = 2)
dev.off()
cat("fig15_model_eval.png done\n")

# -- fig16_normality_patterns.png ----------------------------------------------
# Bốn mẫu hình chẩn đoán tính chuẩn của phần dư
# Mỗi hàng: histogram + normal Q-Q plot cho cùng một tập phần dư mô phỏng

set.seed(1601)

n_norm <- 120
normal_resid <- rnorm(n_norm)
skew_resid   <- scale(rexp(n_norm, rate = 1) - 1)[, 1]
heavy_resid  <- rt(n_norm, df = 3) / sqrt(3)
out_resid    <- rnorm(n_norm)
out_resid[c(12, 84)] <- c(4.2, -3.8)

normality_sets <- list(
  list(name = "Chuẩn", data = normal_resid,
       note = "Điểm Q-Q gần đường thẳng"),
  list(name = "Lệch phải", data = skew_resid,
       note = "Đuôi phải cao hơn chuẩn"),
  list(name = "Đuôi nặng", data = heavy_resid,
       note = "Hai đầu tách xa đường chuẩn"),
  list(name = "Có ngoại lai", data = out_resid,
       note = "Một vài điểm rời khỏi mẫu chung")
)

png("./figures/fig16_normality_patterns.png", width = 980, height = 1180, res = 120)

par(mfrow = c(4, 2), mar = c(3.8, 4.0, 3.0, 1.0),
    mgp = c(2.4, 0.7, 0), oma = c(0, 0, 1.2, 0))

for (d in normality_sets) {
  z <- as.numeric(scale(d$data))

  hist(z, breaks = 18, freq = FALSE,
       col = "#D8EAF7", border = "white",
       xlab = "Phần dư chuẩn hóa", ylab = "Mật độ",
       main = paste0(d$name, " — histogram"),
       cex.main = 0.9, bty = "l")
  curve(dnorm(x), add = TRUE, col = "#C0392B", lwd = 2)
  rug(z, col = adjustcolor("#2C3E50", 0.45))
  legend("topright", legend = d$note, bty = "n", cex = 0.74)

  qq <- qqnorm(z, plot.it = FALSE)
  plot(qq$x, qq$y,
       pch = 16, cex = 0.68, col = "steelblue",
       xlab = "Phân vị chuẩn lý thuyết",
       ylab = "Phân vị phần dư",
       main = paste0(d$name, " — Q-Q plot"),
       cex.main = 0.9, bty = "l")
  qqline(z, col = "#C0392B", lwd = 2)
  abline(h = 0, lty = 3, col = "gray70")
  abline(v = 0, lty = 3, col = "gray70")
}

mtext("Các mẫu hình trực quan khi kiểm tra tính chuẩn của phần dư",
      outer = TRUE, cex = 0.95, font = 2)

dev.off()
cat("fig16_normality_patterns.png done\n")

# -- fig17_boston_normality.png ------------------------------------------------
# Boston housing: raw residuals vs externally studentized residuals
# Model: medv ~ lstat + rm

library(MASS)
data(Boston)
fit_boston <- lm(medv ~ lstat + rm, data = Boston)
raw_resid <- residuals(fit_boston)
stud_resid <- rstudent(fit_boston)

png("./figures/fig17_boston_normality.png", width = 980, height = 820, res = 120)

par(mfrow = c(2, 2), mar = c(4.0, 4.2, 3.2, 1.0),
    mgp = c(2.5, 0.7, 0), oma = c(0, 0, 1.0, 0))

hist(raw_resid, breaks = 28, freq = FALSE,
     col = "#D8EAF7", border = "white",
     xlab = "Raw residuals", ylab = "Mật độ",
     main = "Raw residuals — histogram", cex.main = 0.9, bty = "l")
curve(dnorm(x, mean = mean(raw_resid), sd = sd(raw_resid)),
      add = TRUE, col = "#C0392B", lwd = 2)
rug(raw_resid, col = adjustcolor("#2C3E50", 0.35))

qqnorm(raw_resid, pch = 16, cex = 0.65, col = "steelblue",
       main = "Raw residuals — Q-Q plot",
       xlab = "Phân vị chuẩn lý thuyết", ylab = "Raw residuals",
       cex.main = 0.9, bty = "l")
qqline(raw_resid, col = "#C0392B", lwd = 2)

hist(stud_resid, breaks = 28, freq = FALSE,
     col = "#E3F3E8", border = "white",
     xlab = "Studentized residuals", ylab = "Mật độ",
     main = "Studentized residuals — histogram", cex.main = 0.9, bty = "l")
curve(dnorm(x), add = TRUE, col = "#C0392B", lwd = 2)
rug(stud_resid, col = adjustcolor("#2C3E50", 0.35))

qqnorm(stud_resid, pch = 16, cex = 0.65, col = "steelblue",
       main = "Studentized residuals — Q-Q plot",
       xlab = "Phân vị chuẩn lý thuyết", ylab = "Studentized residuals",
       cex.main = 0.9, bty = "l")
qqline(stud_resid, col = "#C0392B", lwd = 2)

mtext("Boston housing: chẩn đoán chuẩn tắc của phần dư", outer = TRUE,
      cex = 0.95, font = 2)

dev.off()
cat("fig17_boston_normality.png done\n")

