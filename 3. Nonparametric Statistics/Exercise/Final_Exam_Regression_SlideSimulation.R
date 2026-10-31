# Reproduce the Chapter 3 simulation examples on slide pages 26-28 and 44-47.
set.seed(2025)
n <- 200
X <- sort(runif(n))
r <- function(x) sin(2 * pi * x) + 0.5 * x
Y <- r(X) + rnorm(n, sd = 0.25)
xx <- seq(0, 1, length.out = 400)

nw <- function(x, x_data, y_data, h) {
  k <- dnorm((x_data - x) / h)
  sum(k * y_data) / sum(k)
}
loc_lin <- function(x, x_data, y_data, h) {
  u <- x_data - x
  k <- dnorm(u / h)
  s0 <- sum(k)
  s1 <- sum(k * u)
  s2 <- sum(k * u^2)
  t0 <- sum(k * y_data)
  t1 <- sum(k * u * y_data)
  (s2 * t0 - s1 * t1) / (s0 * s2 - s1^2)
}

# Slide 27 calls ksmooth with its bandwidth argument.
h_display <- c(0.02, 0.08, 0.30)
ks_fits <- lapply(h_display, function(h)
  ksmooth(X, Y, kernel = "normal", bandwidth = h, x.points = xx)$y)

# Slide 28's Gaussian formula and bandwidth grid.
h_grid <- seq(0.01, 0.30, length.out = 40)
cv <- vapply(h_grid, function(h) {
  residual <- vapply(seq_along(X), function(i) {
    fit <- nw(X[i], X[-i], Y[-i], h)
    Y[i] - fit
  }, numeric(1))
  mean(residual^2)
}, numeric(1))
h_cv <- h_grid[which.min(cv)]

point <- c(0, 0.5, 1)
point_table <- data.frame(
  x = point,
  true_r = r(point),
  NW_h_0.10 = vapply(point, nw, numeric(1), X, Y, h = 0.10),
  LL_h_0.05 = vapply(point, loc_lin, numeric(1), X, Y, h = 0.05)
)
cat("n =", n, "\n")
cat("CV best h =", format(h_cv, digits = 7),
    "; CV =", format(min(cv), digits = 7), "\n")
print(point_table, row.names = FALSE, digits = 7)

# Intermediate sums for the worked calculation at x=0.
x0 <- 0
k_nw <- dnorm((X - x0) / 0.10)
cat("NW at x=0: numerator =", format(sum(k_nw * Y), digits = 9),
    "; denominator =", format(sum(k_nw), digits = 9), "\n")
u_ll <- X - x0
k_ll <- dnorm(u_ll / 0.05)
s <- vapply(0:2, function(j) sum(k_ll * u_ll^j), numeric(1))
t <- vapply(0:1, function(j) sum(k_ll * u_ll^j * Y), numeric(1))
cat("LL at x=0: S0,S1,S2 =", paste(format(s, digits = 9), collapse = ", "),
    "; T0,T1 =", paste(format(t, digits = 9), collapse = ", "), "\n")
cat("LL at x=0: numerator =", format(s[3] * t[1] - s[2] * t[2], digits = 9),
    "; denominator =", format(s[1] * s[3] - s[2]^2, digits = 9), "\n")
loo_first <- nw(X[1], X[-1], Y[-1], h_cv)
cat("CV first row: X1 =", format(X[1], digits = 9),
    "; Y1 =", format(Y[1], digits = 9),
    "; leave-one-out prediction =", format(loo_first, digits = 9),
    "; squared residual =", format((Y[1] - loo_first)^2, digits = 9), "\n")

# Slide 45: compare local-linear and local-quadratic package fits.
fit_ll_pkg <- KernSmooth::locpoly(X, Y, degree = 1,
                                 bandwidth = 0.08, gridsize = 400,
                                 range.x = c(0, 1))
fit_lq_pkg <- KernSmooth::locpoly(X, Y, degree = 2,
                                 bandwidth = 0.08, gridsize = 400,
                                 range.x = c(0, 1))
package_table <- data.frame(
  x = point, true_r = r(point),
  local_linear = approx(fit_ll_pkg$x, fit_ll_pkg$y, xout = point)$y,
  local_quadratic = approx(fit_lq_pkg$x, fit_lq_pkg$y, xout = point)$y
)
cat("KernSmooth::locpoly, bandwidth 0.08:\n")
print(package_table, row.names = FALSE, digits = 7)

pdf("Final_Exam_Regression_SlideSimulation.pdf", width = 7.1, height = 7.7)
par(mfrow = c(2, 1), family = "serif", mar = c(3.6, 4, 2.2, 1))
plot(X, Y, pch = 16, cex = 0.38, col = "gray70",
     xlab = "x", ylab = "Y", main = "Slide 27: effect of bandwidth")
lines(xx, r(xx), lwd = 2)
cols <- c("#C23B22", "#1764AA", "#1F8A5B")
for (j in seq_along(ks_fits)) lines(xx, ks_fits[[j]], col = cols[j], lwd = 1.8)
legend("topright", c("true r", sprintf("ksmooth h=%.2f", h_display)),
       col = c("black", cols), lwd = 2, bty = "n", cex = 0.8)

plot(X, Y, pch = 16, cex = 0.38, col = "gray70",
     xlab = "x", ylab = "Y", main = "Slides 44-47: NW and local linear near boundaries")
lines(xx, r(xx), lwd = 2)
lines(xx, vapply(xx, nw, numeric(1), X, Y, h = 0.10),
      col = "#C23B22", lwd = 1.8)
lines(xx, vapply(xx, loc_lin, numeric(1), X, Y, h = 0.05),
      col = "#1764AA", lwd = 1.8)
legend("topright", c("true r", "NW h=0.10", "local linear h=0.05"),
       col = c("black", "#C23B22", "#1764AA"), lwd = 2,
       bty = "n", cex = 0.8)
dev.off()

pdf("Final_Exam_Regression_LocalPolynomials.pdf", width = 7.1, height = 4.2)
par(family = "serif")
plot(X, Y, pch = 16, cex = 0.42, col = "gray70",
     xlab = "x", ylab = "Y",
     main = "Slide 45: local linear vs local quadratic")
lines(xx, r(xx), lwd = 2)
lines(fit_ll_pkg$x, fit_ll_pkg$y, col = "#1764AA", lwd = 2)
lines(fit_lq_pkg$x, fit_lq_pkg$y, col = "#C56A16", lwd = 2)
legend("topright", c("true r", "degree 1, h=0.08", "degree 2, h=0.08"),
       col = c("black", "#1764AA", "#C56A16"), lwd = 2,
       bty = "n", cex = 0.8)
dev.off()
