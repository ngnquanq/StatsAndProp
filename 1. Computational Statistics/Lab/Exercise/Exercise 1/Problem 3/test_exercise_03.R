# Test Script for Exercise 3
source("Exercise/Exercise 1/exercise_03.R")

set.seed(123)

# 1. Generate Synthetic Data
# Non-linear function: f(x) = sin(2*x) + 0.5 * x
n_points <- 100
x <- runif(n_points, -2, 4)
x <- sort(x) # Sort for cleaner line plots
true_y <- sin(2 * x) + 0.5 * x
noise <- rnorm(n_points, mean = 0, sd = 0.4)
y <- true_y + noise

# 2. Test Cases

# Case A: Nadaraya-Watson (p=0) with CV bandwidth
cat("\n--- Testing Case A: Nadaraya-Watson (p=0) ---\n")
fit_nw <- locpoly_reg(x, y, p = 0, h = NULL)

# Case B: Local Linear (p=1) with CV bandwidth
cat("\n--- Testing Case B: Local Linear (p=1) ---\n")
fit_ll <- locpoly_reg(x, y, p = 1, h = NULL)

# Case C: Local Quadratic (p=2) with fixed bandwidth
cat("\n--- Testing Case C: Local Quadratic (p=2, fixed h=0.5) ---\n")
fit_lq <- locpoly_reg(x, y, p = 2, h = 0.5)


# 3. Visualization
png("Exercise/Exercise 1/exercise_03_result.png", width=800, height=600)
plot(x, y, main = "Exercise 3: Local Polynomial Regression",
     xlab = "X", ylab = "Y", pch = 16, col = "gray", cex = 0.8)

# Plot True Function
lines(x, true_y, col = "black", lty = 2, lwd = 1.5)

# Plot Case A (Red)
lines(fit_nw$x, fit_nw$fitted, col = "red", lwd = 2)

# Plot Case B (Blue)
lines(fit_ll$x, fit_ll$fitted, col = "blue", lwd = 2)

# Plot Case C (Green)
lines(fit_lq$x, fit_lq$fitted, col = "darkgreen", lwd = 2, lty = 1)

legend("topleft", 
       legend = c("True Function", 
                  paste("NW (p=0, h=", round(fit_nw$h, 3), ")", sep=""), 
                  paste("LocLin (p=1, h=", round(fit_ll$h, 3), ")", sep=""),
                  "LocQuad (p=2, h=0.5)"),
       col = c("black", "red", "blue", "darkgreen"),
       lty = c(2, 1, 1, 1),
       lwd = c(1.5, 2, 2, 2),
       bg = "white")

dev.off()
cat("\nPlot saved to Exercise/Exercise 1/exercise_03_result.png\n")
