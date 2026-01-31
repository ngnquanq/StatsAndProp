# =============================================================================
# Exercise 4: Mars Atmospheric Temperature-Pressure Profile Analysis
# Using Local Polynomial Regression from Exercise 3
# Author: Group K and F
# =============================================================================

# Set working directory to the script's location (if running in RStudio)
# Uncomment the line below if needed:
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load required functions from Exercise 3
source("../Problem 3/exercise_03.R")

# =============================================================================
# Load Data
# =============================================================================
cat("=== Loading Mars Data ===\n")

# Load mars.dat (simple: radius, temperature)
mars <- read.table("mars.dat", header = TRUE)
cat("\nmars.dat structure:\n")
str(mars)
cat("\nSummary:\n")
print(summary(mars))

# Load marsbig.dat (full data with orbit, pressure, etc.)
marsbig <- read.table("marsbig.dat", header = TRUE)
cat("\nmarsbig.dat structure:\n")
str(marsbig)
cat("\nOrbits distribution:\n")
print(table(marsbig$orbit))

# =============================================================================
# Part (a): Temperature vs Radius using Local Polynomial Regression
# =============================================================================
cat("\n\n=== Part (a): Temperature vs Radius ===\n")
cat("Applying local polynomial regression to predict temperature trend as radius changes\n")

# Extract variables
x <- mars$radius
y <- mars$temperature

# Apply local polynomial regression with different degrees
# p = 0: Nadaraya-Watson (local constant)
# p = 1: Local linear regression
# p = 2: Local quadratic regression

cat("\n--- Local Constant (p=0) ---\n")
fit_p0 <- locpoly_reg(x, y, p = 0)
cat(sprintf("Optimal bandwidth h = %.4f\n", fit_p0$h))

cat("\n--- Local Linear (p=1) ---\n")
fit_p1 <- locpoly_reg(x, y, p = 1)
cat(sprintf("Optimal bandwidth h = %.4f\n", fit_p1$h))

cat("\n--- Local Quadratic (p=2) ---\n")
fit_p2 <- locpoly_reg(x, y, p = 2)
cat(sprintf("Optimal bandwidth h = %.4f\n", fit_p2$h))

# Create smooth evaluation grid
eval_x <- seq(min(x), max(x), length.out = 200)

cat("\n--- Fitting on evaluation grid ---\n")
fit_smooth_p0 <- locpoly_reg(x, y, p = 0, h = fit_p0$h, eval_x = eval_x)
fit_smooth_p1 <- locpoly_reg(x, y, p = 1, h = fit_p1$h, eval_x = eval_x)
fit_smooth_p2 <- locpoly_reg(x, y, p = 2, h = fit_p2$h, eval_x = eval_x)

# Plot Part (a)
png("exercise_04a_temp_vs_radius.png", width = 1000, height = 700, res = 120)
par(mar = c(5, 5, 4, 2))

plot(x, y, pch = 16, col = "gray40", cex = 0.8,
     xlab = "Planetocentric Radius (km)",
     ylab = "Temperature (K)",
     main = "Mars Atmospheric Temperature vs Radius\n(Local Polynomial Regression)")

# Add fitted curves
lines(fit_smooth_p0$x, fit_smooth_p0$fitted, col = "blue", lwd = 2, lty = 2)
lines(fit_smooth_p1$x, fit_smooth_p1$fitted, col = "red", lwd = 2)
lines(fit_smooth_p2$x, fit_smooth_p2$fitted, col = "darkgreen", lwd = 2, lty = 3)

legend("topright",
       legend = c("Data",
                  sprintf("p=0 (Nadaraya-Watson), h=%.2f", fit_p0$h),
                  sprintf("p=1 (Local Linear), h=%.2f", fit_p1$h),
                  sprintf("p=2 (Local Quadratic), h=%.2f", fit_p2$h)),
       col = c("gray40", "blue", "red", "darkgreen"),
       pch = c(16, NA, NA, NA),
       lty = c(NA, 2, 1, 3),
       lwd = c(NA, 2, 2, 2),
       cex = 0.8)

dev.off()
cat("Plot saved: exercise_04a_temp_vs_radius.png\n")

cat("\n--- Trend Analysis (Part a) ---\n")
cat("As radius (altitude) increases, temperature generally DECREASES.\n")
cat("This is consistent with the expected atmospheric behavior on Mars.\n")
slope_estimate <- (fit_smooth_p1$fitted[length(fit_smooth_p1$fitted)] - fit_smooth_p1$fitted[1]) /
                  (max(eval_x) - min(eval_x))
cat(sprintf("Estimated average slope (linear): %.4f K/km\n", slope_estimate))

# =============================================================================
# Part (b): Temperature vs Radius by Orbit
# =============================================================================
cat("\n\n=== Part (b): Temperature vs Radius by Different Orbits ===\n")

# Get unique orbits
orbits <- sort(unique(marsbig$orbit))
n_orbits <- length(orbits)
cat(sprintf("Number of distinct orbits: %d\n", n_orbits))

# Colors for different orbits
orbit_colors <- rainbow(n_orbits)

# Plot with all orbits
png("exercise_04b_temp_vs_radius_by_orbit.png", width = 1200, height = 800, res = 120)
par(mar = c(5, 5, 4, 2))

# Initialize plot
plot(marsbig$radius, marsbig$temperature, type = "n",
     xlab = "Planetocentric Radius (km)",
     ylab = "Temperature (K)",
     main = "Mars Atmospheric Temperature vs Radius\nby Different Orbits")

# Store results for each orbit
orbit_results <- list()

for (i in seq_along(orbits)) {
  orb <- orbits[i]

  # Subset data for this orbit
  idx <- marsbig$orbit == orb
  x_orb <- marsbig$radius[idx]
  y_orb <- marsbig$temperature[idx]

  cat(sprintf("\nOrbit %d: %d observations\n", orb, sum(idx)))

  # Plot data points
  points(x_orb, y_orb, pch = 16, col = orbit_colors[i], cex = 0.8)

  # Fit local polynomial regression if enough data
  if (length(x_orb) >= 5) {
    tryCatch({
      # Use local linear regression with automatic bandwidth selection
      fit_orb <- locpoly_reg(x_orb, y_orb, p = 1)
      cat(sprintf("  Bandwidth h = %.4f\n", fit_orb$h))

      # Create smooth curve
      eval_x_orb <- seq(min(x_orb), max(x_orb), length.out = 100)
      fit_smooth_orb <- locpoly_reg(x_orb, y_orb, p = 1, h = fit_orb$h, eval_x = eval_x_orb)

      # Add fitted curve
      lines(fit_smooth_orb$x, fit_smooth_orb$fitted, col = orbit_colors[i], lwd = 2)

      # Store results
      orbit_results[[as.character(orb)]] <- list(
        n = sum(idx),
        h = fit_orb$h,
        x = fit_smooth_orb$x,
        fitted = fit_smooth_orb$fitted
      )

      # Calculate slope
      slope <- (fit_smooth_orb$fitted[length(fit_smooth_orb$fitted)] - fit_smooth_orb$fitted[1]) /
               (max(eval_x_orb) - min(eval_x_orb))
      cat(sprintf("  Estimated slope: %.4f K/km\n", slope))

    }, error = function(e) {
      cat(sprintf("  Error fitting orbit %d: %s\n", orb, e$message))
    })
  } else {
    cat("  Not enough data for regression\n")
  }
}

# Add legend
legend("topright",
       legend = paste("Orbit", orbits),
       col = orbit_colors,
       pch = 16,
       lty = 1,
       lwd = 2,
       cex = 0.7,
       ncol = 2)

dev.off()
cat("\nPlot saved: exercise_04b_temp_vs_radius_by_orbit.png\n")

cat("\n--- Summary (Part b) ---\n")
cat("Each orbit passes through slightly different regions of Mars.\n")
cat("The temperature-radius relationship shows similar decreasing trend across all orbits,\n")
cat("but with slight variations in the absolute temperatures and slopes.\n")

# =============================================================================
# Part (c): Temperature vs Pressure
# =============================================================================
cat("\n\n=== Part (c): Temperature vs Pressure ===\n")

x_pres <- marsbig$pressure
y_temp <- marsbig$temperature

cat("\nPressure range:\n")
print(summary(x_pres))

# Apply local polynomial regression
cat("\n--- Local Linear (p=1) ---\n")
fit_pres_p1 <- locpoly_reg(x_pres, y_temp, p = 1)
cat(sprintf("Optimal bandwidth h = %.4f\n", fit_pres_p1$h))

cat("\n--- Local Quadratic (p=2) ---\n")
fit_pres_p2 <- locpoly_reg(x_pres, y_temp, p = 2)
cat(sprintf("Optimal bandwidth h = %.4f\n", fit_pres_p2$h))

# Smooth evaluation
eval_pres <- seq(min(x_pres), max(x_pres), length.out = 200)
fit_smooth_pres_p1 <- locpoly_reg(x_pres, y_temp, p = 1, h = fit_pres_p1$h, eval_x = eval_pres)
fit_smooth_pres_p2 <- locpoly_reg(x_pres, y_temp, p = 2, h = fit_pres_p2$h, eval_x = eval_pres)

# Plot Part (c)
png("exercise_04c_temp_vs_pressure.png", width = 1000, height = 700, res = 120)
par(mar = c(5, 5, 4, 2))

plot(x_pres, y_temp, pch = 16, col = "gray40", cex = 0.8,
     xlab = "Atmospheric Pressure (Pa)",
     ylab = "Temperature (K)",
     main = "Mars Atmospheric Temperature vs Pressure\n(Local Polynomial Regression)")

lines(fit_smooth_pres_p1$x, fit_smooth_pres_p1$fitted, col = "red", lwd = 2)
lines(fit_smooth_pres_p2$x, fit_smooth_pres_p2$fitted, col = "darkgreen", lwd = 2, lty = 3)

legend("bottomright",
       legend = c("Data",
                  sprintf("p=1 (Local Linear), h=%.2f", fit_pres_p1$h),
                  sprintf("p=2 (Local Quadratic), h=%.2f", fit_pres_p2$h)),
       col = c("gray40", "red", "darkgreen"),
       pch = c(16, NA, NA),
       lty = c(NA, 1, 3),
       lwd = c(NA, 2, 2),
       cex = 0.8)

dev.off()
cat("Plot saved: exercise_04c_temp_vs_pressure.png\n")

cat("\n--- Trend Analysis (Part c) ---\n")
cat("When replacing radius with pressure:\n")
cat("- Temperature INCREASES as pressure INCREASES.\n")
cat("- This is because higher pressure corresponds to lower altitude (smaller radius),\n")
cat("  where temperatures are higher.\n")
cat("- The relationship is essentially the inverse of part (a), since pressure\n")
cat("  decreases exponentially with altitude.\n")

slope_pres <- (fit_smooth_pres_p1$fitted[length(fit_smooth_pres_p1$fitted)] - fit_smooth_pres_p1$fitted[1]) /
              (max(eval_pres) - min(eval_pres))
cat(sprintf("Estimated average slope (linear): %.4f K/Pa\n", slope_pres))

# =============================================================================
# Combined Plot: All three analyses
# =============================================================================
png("exercise_04_combined.png", width = 1400, height = 500, res = 120)
par(mfrow = c(1, 3), mar = c(5, 5, 4, 2))

# (a) Temperature vs Radius
plot(mars$radius, mars$temperature, pch = 16, col = "gray40", cex = 0.8,
     xlab = "Radius (km)", ylab = "Temperature (K)",
     main = "(a) Temp vs Radius")
lines(fit_smooth_p1$x, fit_smooth_p1$fitted, col = "red", lwd = 2)

# (b) By Orbit
plot(marsbig$radius, marsbig$temperature, type = "n",
     xlab = "Radius (km)", ylab = "Temperature (K)",
     main = "(b) Temp vs Radius by Orbit")
for (i in seq_along(orbits)) {
  orb <- orbits[i]
  idx <- marsbig$orbit == orb
  points(marsbig$radius[idx], marsbig$temperature[idx], pch = 16, col = orbit_colors[i], cex = 0.7)
  if (!is.null(orbit_results[[as.character(orb)]])) {
    res <- orbit_results[[as.character(orb)]]
    lines(res$x, res$fitted, col = orbit_colors[i], lwd = 1.5)
  }
}
legend("topright", legend = paste("Orb", orbits), col = orbit_colors, pch = 16, cex = 0.5, ncol = 2)

# (c) Temperature vs Pressure
plot(x_pres, y_temp, pch = 16, col = "gray40", cex = 0.8,
     xlab = "Pressure (Pa)", ylab = "Temperature (K)",
     main = "(c) Temp vs Pressure")
lines(fit_smooth_pres_p1$x, fit_smooth_pres_p1$fitted, col = "red", lwd = 2)

dev.off()
cat("\nCombined plot saved: exercise_04_combined.png\n")

# =============================================================================
# Summary
# =============================================================================
cat("\n")
cat(strrep("=", 70), "\n")
cat("SUMMARY - Exercise 4: Mars Atmospheric Analysis\n")
cat(strrep("=", 70), "\n")

cat("\n(a) Temperature vs Radius (all data):\n")
cat("    - Clear NEGATIVE correlation: temperature decreases with radius\n")
cat(sprintf("    - Local linear bandwidth: h = %.4f\n", fit_p1$h))
cat(sprintf("    - Approximate slope: %.4f K/km\n", slope_estimate))

cat("\n(b) Temperature vs Radius (by orbit):\n")
cat("    - All 7 orbits show similar decreasing trends\n")
cat("    - Slight variations due to different Mars regions\n")
cat("    - Confirms the general atmospheric temperature profile\n")

cat("\n(c) Temperature vs Pressure:\n")
cat("    - POSITIVE correlation: temperature increases with pressure\n")
cat(sprintf("    - Local linear bandwidth: h = %.4f\n", fit_pres_p1$h))
cat(sprintf("    - Approximate slope: %.4f K/Pa\n", slope_pres))
cat("    - Relationship is inverse of (a) because pressure ~ exp(-altitude)\n")

cat("\n")
cat("All plots have been saved in the current directory.\n")
