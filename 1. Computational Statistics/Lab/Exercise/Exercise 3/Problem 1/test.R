source("src/intergrate.R")

x <- seq(0, pi, length.out = 101)
f1 <- function(x) x* sin(x)
f1(x)

integ_trap(x = x, f = f1)

# Monte carlo
x_uniform <- runif(n = 1500, 0, pi)
f1_uni <- pi*f1(x_uniform)
mean(f1_uni)



# 1.1

f1_1 <- function(sigma, m,x){
  (1/(sqrt(2*pi)*sigma))*(1/(x*(1-x))) * exp((-1/(2*sigma*sigma))* ((log(x/(1-x)))-m)^2)
}

# set value
m = 2
sigma = 1
a = 0
x <- seq(10^(-9), 1/(1+exp(-a)), length.out = 101)

# trapezoid
integ_trap(x, f1_1, m = m, sigma = sigma)


# Monte carlo
# sấp sỉ Pi

pi_est <- function(n){
  x1 = runif(n, -1, 1)
  x2 = runif(n, -1, 1)
  res <-  4*mean((x1^2+x2^2) <= 1)
  return (res)
}


pi_est_n <- sapply(c(100, 200, 500, 1000, 100000), function(x) pi_est(x))


# importance Sampling

p = runif(1000, 0, 1)
xi <- -log(1-p*(1-exp(-1)))

calculate_i2 <- function(xi){
  return (mean((1-exp(-1))/(1+xi^2)))
}