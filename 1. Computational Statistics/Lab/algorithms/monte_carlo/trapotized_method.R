random_func <- function(x){
  x*x
}

integ_trap <- function(x, f){
  y <- f(x)
  n <- length(x)
  res <- 0
  for(i in 1:(n-1)){
    res <- res + (x[i+1] - x[i])*(y[i+1] + y[i])
  }
  res <- res*0.5
  return(res)
}

random_func(5)

x <- integ_trap(x = 4,f = random_func)
x

## Monte Carlo
f1 <- function(x) x*sin(x)
x_uniform <- runif(n=10000000,0,pi)
f1_uni <- pi*f1(x_uniform)
mean(f1_uni)


## Monte Carlo for normal dist
func <- function(x, mu, sigma){                                                                                                          
  (1/(sqrt(2*pi)*sigma)) * (1/(x*(1-x))) * exp((-1/(2*sigma^2)) * (log(x/(1-x)) - mu)^2)                                                 
}
func(0.8,0,1)

## Xap xi Pi

pi_est <- function(n, seed=153){
  x1 <- runif(n, -1, 1)
  x2 <- runif(n, -1, 1)
  return(4*mean(x1^2) + x2^2 <= 1)
}
pi_est_n <- sapply(c(100,200,300), function(x) pi_est(x))