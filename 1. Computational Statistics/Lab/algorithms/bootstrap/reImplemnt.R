# Kernel Gaussian
kernel_gauss <- function(u) {exp(-u^2/2)/sqrt(2*pi)}

# Kernel Regression (Nadaraya Watson)
kernel_reg <- function(x, y, x_eval, h, kernel_func="gauss") {
  wi <- kernel_gauss((x_eval - x)/h)
  wi_sum <- sum(wi)
  w <- wi/wi_sum
  y_h <- sum(y*w)
  return(y_h)
}

kernel_reg <- Vectorize(FUN=kernel_reg, vectorize.args = "x_eval")

# Bandwidth

## Formular 1: 

cv_bandwidth <- function(x, y, h, kernel = "gauss"){
  n <- length(x)
  err <- numeric(n)
  for(i in 1:n){
    x_new <- x[-i]
    y_new <- y[-i]
    y_i <- kernel_reg(x = x_new, y = y_new, x_eval = x[i]
                      , h=h, kernel=kernel)
    err <- (y[i] - y_i)^2
  }
  cv_h <- mean(err)
  return(cv_h)
}

cv_bandwidth <- Vectorize(FUN=cv_bandwidth, vectorize.args = "h")
## Formular 2: 

# cv_bandwidth_2 <- function(x, y, h, kernel = "gauss"){
#   n <- length(x)
#   err <- numeric(n)
#   # W_i
#   k_0 <- kernel_gauss(0)
#   tmp_W_i_0 <- numeric(n)
#   for(i in 1:n){
#     tmp_err <- numeric(n)
#     for(j in 1:n){
#       tmp_err <- kernel_gauss(x[i] - x[j]/h)
#     }
#     W_i_0 <- k_0 / sum(tmp_err)
#   }
#   # cv-h
#   x_new <- x[-i]
#   y_new <- y[-i]
#   y_i <- kernel_reg(x = x_new, y = y_new, x_eval = x[i]
#                     , h=h, kernel=kernel)
#   err <- sum(((y[i] - y_i)/(1 - tmp_W_i_0[i]))^2)
#   cv_h <- mean(err)
#   return(cv_h)
# }
# cv_bandwidth_2 <- Vectorize(FUN=cv_bandwidth_2, vectorize.args = "h")

cv_bandwidth_2 <- function(x, y, h, kernel = "gauss"){                                                                                   
  n <- length(x)                                                                                                                         
  y_hat <- numeric(n)                                                                                                                    
  W_ii <- numeric(n)                                                                                                                     
  k_0 <- kernel_gauss(0)                                                                                                                 
  
  for(i in 1:n){                                                                                                                         
    # Compute all kernel weights for point i                                                                                             
    k_sum <- 0                                                                                                                           
    weighted_y <- 0                                                                                                                      
    for(j in 1:n){                                                                                                                       
      k_ij <- kernel_gauss((x[i] - x[j])/h)                                                                                              
      k_sum <- k_sum + k_ij                                                                                                              
      weighted_y <- weighted_y + k_ij * y[j]                                                                                             
    }                                                                                                                                    
    
    # Fitted value using all data                                                                                                        
    y_hat[i] <- weighted_y / k_sum                                                                                                       
    
    # Self-weight W_ii = K(0) / sum of weights                                                                                           
    W_ii[i] <- k_0 / k_sum                                                                                                               
  }                                                                                                                                      
  
  # Efficient LOO-CV formula                                                                                                             
  err <- ((y - y_hat) / (1 - W_ii))^2                                                                                                    
  cv_h <- mean(err)                                                                                                                      
  return(cv_h)                                                                                                                           
}                                                                                                                                        

cv_bandwidth_2 <- Vectorize(FUN = cv_bandwidth_2, vectorize.args = "h")    
