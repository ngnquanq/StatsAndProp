integ_trap <- function(x, f, ...){
  # x is vector point
  # f is class func
  result <- 0
  y <- f(x = x, ...)
  for(idx in 1: (length(x)-1)){
    result <- result + (x[idx+1]-x[idx]) * (y[idx +1] + y[idx] )
  }
  return (result * 0.5)
}






