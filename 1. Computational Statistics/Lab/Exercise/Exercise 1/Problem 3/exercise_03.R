# Exercise 3: Local Polynomial Regression
# Author: Quang Nguyen

# Gaussian Kernel Function
# K(u) = (1 / sqrt(2*pi)) * exp(-u^2 / 2)
gaussian_kernel <- function(u) {
  return(dnorm(u))
}

# Cross-Validation Function to find optimal bandwidth h
# Uses Leave-One-Out Cross-Validation (LOOCV)
# CV(h) = (1/n) * sum((y_i - y_hat_{-i})^2)
calculate_cv_score <- function(h, x, y, p) {
  n <- length(x)
  cv_score <- 0
  
  # For each point i, fit model using all other points and predict y_i
  # This loops n times. Ideally, for efficiency, one would use the smoothing matrix trace method 
  # (CV = mean((residual / (1 - leverage))^2)), but for clarity in this exercise, we use explicit LOOCV.
  
  for (i in 1:n) {
    # Train data: all points except i
    x_train <- x[-i]
    y_train <- y[-i]
    
    # Test data: point i
    x_val <- x[i]
    y_true <- y[i]
    
    # Fit and Predict at x_val
    # We call the core fitting logic directly here to avoid recursion overhead
    # Need to protect against h approaching 0 or numerical instability
    
    # Calculation for predict at single point x_val
    # 1. Weights based on distance to x_val
    weights <- gaussian_kernel((x_train - x_val) / h)
    
    # Handle disconnected graph case (weights all zero)
    if (sum(weights) < 1e-10) {
      y_pred <- mean(y_train) # Fallback
    } else {
      # 2. Design Matrix X_mat for polynomial degree p
      # Columns: 1, (x - x_0), (x - x_0)^2, ...
      X_mat <- matrix(NA, nrow = length(x_train), ncol = p + 1)
      for (k in 0:p) {
        X_mat[, k + 1] <- (x_train - x_val)^k
      }
      
      # 3. Weighted Least Squares: Beta = (X' W X)^-1 X' W y
      # Using standard R lm.wfit or solving explicitly
      W <- diag(weights)
      
      # Using lm() is safer and handles singular matrices better
      # Use local variable u = x_train - x_val to simplify formula
      u_diff <- x_train - x_val
      
      if (p == 0) {
        # Nadaraya-Watson (Local Constant)
        fit <- lm(y_train ~ 1, weights = weights)
        y_pred <- coef(fit)[1]
      } else {
        # Local Linear/Polynomial
        # Create poly terms manually to ensure centered at x_val
        df_train <- data.frame(y = y_train)
        formula_str <- "y ~ 1"
        for(k in 1:p){
            df_train[[paste0("x", k)]] <- u_diff^k
            formula_str <- paste(formula_str, paste0("+ x", k))
        }
        fit <- lm(as.formula(formula_str), data = df_train, weights = weights)
        y_pred <- coef(fit)[1] # Intercept is the estimate at x_val (where u_diff=0)
      }
    }
    
    cv_score <- cv_score + (y_true - y_pred)^2
  }
  
  return(cv_score / n)
}

#' Local Polynomial Regression Function
#'
#' @param x Numeric vector of predictor values
#' @param y Numeric vector of response values
#' @param p Integer, degree of polynomial (0, 1, 2, ...)
#' @param h Numeric (optional), bandwidth. If NULL, selected via CV.
#' @param eval_x Numeric vector (optional), points to evaluate the regression at. If NULL, defaults to x.
#'
#' @return A list containing:
#'   \item{x}{Evaluation points}
#'   \item{fitted}{Fitted values at evaluation points}
#'   \item{h}{Bandwidth used}
locpoly_reg <- function(x, y, p, h = NULL, eval_x = NULL) {
  
  # Input validation
  if (!is.numeric(p) || p < 0 || p %% 1 != 0) stop("p must be a non-negative integer")
  if (length(x) != length(y)) stop("x and y must have same length")
  
  # Bandwidth Selection
  if (is.null(h)) {
    cat("Bandwidth h is NULL. Performing Cross-Validation...\n")
    
    # Define candidate bandwidths
    # Range: from min spacing to range of x
    diffs <- diff(sort(x))
    min_h <- max(min(diffs[diffs > 0]) * 2, diff(range(x))/100)
    max_h <- diff(range(x)) / 2
    
    # Try 10 values logarithmically spaced or use optim()
    # For robust demonstration, let's use optimize()
    opt_res <- optimize(calculate_cv_score, interval = c(min_h, max_h), x = x, y = y, p = p)
    
    h <- opt_res$minimum
    cat(sprintf("Selected optimal bandwidth h = %.4f (CV Score = %.4f)\n", h, opt_res$objective))
  }
  
  if (is.null(eval_x)) {
    eval_x <- sort(x) # Sort for plotting
  }
  
  n_eval <- length(eval_x)
  fitted_values <- numeric(n_eval)
  
  # Main Regression Loop
  for (i in 1:n_eval) {
    x0 <- eval_x[i]
    
    # 1. Compute Weights
    weights <- gaussian_kernel((x - x0) / h)
    
    # 2. Check for zero weights support
    if (sum(weights) < 1e-10) {
      warning(paste("No data points within effective range for x =", x0))
      fitted_values[i] <- NA
      next
    }
    
    # 3. Fit Weighted Polynomial
    # Center x at x0: u = x - x0. Then estimate matches intercept beta_0
    u <- x - x0
    
    df_local <- data.frame(y = y)
    formula_str <- "y ~ 1"
    for (k in 1:p) {
        if (k > 0) { # check purely for safety, loop starts at 1
            df_local[[paste0("x", k)]] <- u^k
            formula_str <- paste(formula_str, paste0("+ x", k))
        }
    }
    
    # Only fit if p=0 (Nadaraya-Watson) logic handled by generic formula "y ~ 1"
    if (p == 0) {
       fit <- lm(y ~ 1, data = df_local, weights = weights) 
    } else {
       fit <- lm(as.formula(formula_str), data = df_local, weights = weights)
    }
    
    # 4. Prediction
    # The estimate f(x0) corresponds to the intercept (beta_0) because we centered the data
    fitted_values[i] <- coef(fit)[1]
  }
  
  return(list(x = eval_x, fitted = fitted_values, h = h))
}
