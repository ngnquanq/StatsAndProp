source("Ex1/teacher_code/kernel_reg.R")
source("Ex1/kernel.R") 

# func
cv_gcv_func <- function(x, y, h, type = "both", kernel = "gaussian") { # type = "CV", "GCV" or "both"
  n <- length(x)
  
  # calculate w0
  wi0 <- numeric(n)
  for(i in 1:n){
    u <- (x[i] - x)/h
    wi0[i] <- sum(process.Kernels(u, kernel))
  }
  
  # calculate k0
  k0 <- process.Kernels(0, kernel)
  
  w0 <- k0 / wi0
  
  m0 <- numeric(n)
  for(i in 1:n) {
     u <- (x - x[i])/h # x_eval = x[i]
     w_i <- process.Kernels(u, kernel)
     m0[i] <- sum(y * w_i) / sum(w_i)
  }
  
  # calculate CV/GCV
  res <- NULL
  
  # calculate CV
  if (type == "CV" || type == "both") {
    cv_val <- mean(((y - m0)/(1 - w0))^2)
    res <- c(res, CV = cv_val)
  }
  
  # calculate GCV
  if (type == "GCV" || type == "both") {
    gcv_val <- sum((y - m0)^2) / ((n - sum(w0))^2)
    res <- c(res, GCV = gcv_val)
  }
  
  return(res)
}

# Vector func
cv_gcv <- Vectorize(FUN = cv_gcv_func, vectorize.args = "h")
