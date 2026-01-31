# load kernel functions ----
source(file = "Ex1/kernel.R")

# Kernel regression ----
kernel_reg <- function(x, y, x_eval, h, kernel = "gauss") {
  wi <- process.KDE(data = x, y = x_eval, h = h, kernel = kernel)
  wi_sum <- sum(wi)
  w <- wi/wi_sum
  y_hat <- sum(y * w)
  return(y_hat)
}

kernel_reg <- Vectorize(FUN = kernel_reg, vectorize.args = "x_eval")

# CV 1 ----
cv1_h <- function(x, y, h, kernel = "gauss"){
  n <- length(x)
  err <- numeric(n)
  for(i in 1:n){
    x_new <- x[-i]
    y_new <- y[-i]
    y_i <- kernel_reg(x = x_new, y = y_new, x_eval = x[i], h = h, 
                      kernel = kernel)
    err[i] <- (y[i] - y_i)^2
  }
  cv_hat <- mean(err)
  return(cv_hat)
}

cv1_h <- Vectorize(FUN = cv1_h, vectorize.args = "h")

# CV 2 ----
cv2_h <- function(x, y, h, kernel = "gauss"){
  n <- length(x)
  wi0 <- numeric(n)
  for(i in 1:n){
    wi0[i] <- sum(kernel_gauss((x[i] - x)/h))
  }
  w0 <- kernel_gauss(0)/wi0
  m0 <- kernel_reg(x = x, y = y, x_eval = x, h = h, kernel = kernel)
  cv <- mean(((y - m0)/(1 - w0))^2)
  return(cv)
}

cv2_h <- Vectorize(FUN = cv2_h, vectorize.args = "h")

# GCV ----
gcv_h <- function(x, y, h, kernel = "gauss"){
  n <- length(x)
  wi0 <- numeric(n)
  for(i in 1:n){
    wi0[i] <- sum(kernel_gauss((x[i] - x)/h))
  }
  w0 <- kernel_gauss(0)/wi0
  m0 <- kernel_reg(x = x, y = y, x_eval = x, h = h, kernel = kernel)
  gcv <- sum((y - m0)^2)/(n - sum(w0))^2
  return(gcv)
}

gcv_h <- Vectorize(FUN = gcv_h, vectorize.args = "h")
