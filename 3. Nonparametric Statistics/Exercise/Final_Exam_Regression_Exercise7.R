# Exercise 7, Chapter 3 slides: mcycle, NW and local linear, CV and GCV.
# Uses only the MASS package distributed with R.
library(MASS)
data(mcycle)
x <- mcycle$times
y <- mcycle$accel
n <- length(x)
h_grid <- seq(0.5, 15, by = 0.25)

smoother <- function(h, method) {
  z <- outer(x, x, function(x0, xi) xi - x0)
  k <- dnorm(z / h)
  if (method == "NW") return(k / rowSums(k))
  s0 <- rowSums(k)
  s1 <- rowSums(k * z)
  s2 <- rowSums(k * z^2)
  denominator <- s0 * s2 - s1^2
  w <- k * (s2 - z * s1) / denominator
  w
}

scores <- function(method) {
  out <- do.call(rbind, lapply(h_grid, function(h) {
    W <- smoother(h, method)
    fitted <- as.vector(W %*% y)
    residual <- y - fitted
    diagonal <- diag(W)
    cv <- mean((residual / (1 - diagonal))^2)
    gcv <- mean(residual^2) / (1 - sum(diagonal) / n)^2
    c(h = h, CV = cv, GCV = gcv, trace = sum(diagonal))
  }))
  out
}

nw <- scores("NW")
ll <- scores("LL")
best <- rbind(
  data.frame(method = "NW", criterion = "CV", nw[which.min(nw[, "CV"]), , drop = FALSE]),
  data.frame(method = "NW", criterion = "GCV", nw[which.min(nw[, "GCV"]), , drop = FALSE]),
  data.frame(method = "LL", criterion = "CV", ll[which.min(ll[, "CV"]), , drop = FALSE]),
  data.frame(method = "LL", criterion = "GCV", ll[which.min(ll[, "GCV"]), , drop = FALSE])
)
print(best, row.names = FALSE, digits = 7)

# Show one complete row calculation at the first observed time.
cat("n =", n, "; time range =", min(x), max(x), "\n")
for (method in c("NW", "LL")) {
  h <- best$h[best$method == method & best$criterion == "CV"]
  u <- x - x[1]
  k <- dnorm(u / h)
  if (method == "NW") {
    numerator <- sum(k * y)
    denominator <- sum(k)
    fit <- numerator / denominator
    self_weight <- k[1] / denominator
    cat("NW row 1: numerator =", format(numerator, digits = 9),
        "; denominator =", format(denominator, digits = 9), "\n")
  } else {
    s <- vapply(0:2, function(j) sum(k * u^j), numeric(1))
    t <- vapply(0:1, function(j) sum(k * u^j * y), numeric(1))
    numerator <- s[3] * t[1] - s[2] * t[2]
    denominator <- s[1] * s[3] - s[2]^2
    fit <- numerator / denominator
    self_weight <- k[1] * s[3] / denominator
    cat("LL row 1: S0,S1,S2 =", paste(format(s, digits = 9), collapse = ", "),
        "; T0,T1 =", paste(format(t, digits = 9), collapse = ", "), "\n")
    cat("LL row 1: numerator =", format(numerator, digits = 9),
        "; denominator =", format(denominator, digits = 9), "\n")
  }
  loo <- (fit - self_weight * y[1]) / (1 - self_weight)
  cat(method, "row 1: x1 =", format(x[1], digits = 9),
      "; y1 =", format(y[1], digits = 9),
      "; W11 =", format(self_weight, digits = 9),
      "; fitted =", format(fit, digits = 9),
      "; leave-one-out =", format(loo, digits = 9),
      "; squared residual =", format((y[1] - loo)^2, digits = 9), "\n")
}

predict_smoother <- function(x0, h, method) {
  z <- x - x0
  k <- dnorm(z / h)
  if (method == "NW") return(sum(k * y) / sum(k))
  s0 <- sum(k)
  s1 <- sum(k * z)
  s2 <- sum(k * z^2)
  t0 <- sum(k * y)
  t1 <- sum(k * z * y)
  (s2 * t0 - s1 * t1) / (s0 * s2 - s1^2)
}

grid <- seq(min(x), max(x), length.out = 400)
h_nw <- best$h[best$method == "NW" & best$criterion == "CV"]
h_ll <- best$h[best$method == "LL" & best$criterion == "CV"]
fit_nw <- vapply(grid, predict_smoother, numeric(1), h = h_nw, method = "NW")
fit_ll <- vapply(grid, predict_smoother, numeric(1), h = h_ll, method = "LL")

pdf("Final_Exam_Regression_Exercise7.pdf", width = 7.1, height = 4.3)
par(family = "serif")
plot(x, y, pch = 16, cex = 0.45, col = "gray65",
     xlab = "Time (ms)", ylab = "Acceleration (g)",
     main = "mcycle: NW vs local linear (CV bandwidth)")
lines(grid, fit_nw, col = "#C23B22", lwd = 2)
lines(grid, fit_ll, col = "#1764AA", lwd = 2)
legend("topright", legend = c(sprintf("NW, h=%.2f", h_nw),
                               sprintf("Local linear, h=%.2f", h_ll)),
       col = c("#C23B22", "#1764AA"), lwd = 2, bty = "n")
dev.off()
