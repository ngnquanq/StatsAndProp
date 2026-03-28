#Bài tập 2:======================
# Importance sampling
n_sim <- 1000000
#x <- rnorm (n=n_sim, mean = 0, sd=1)
x <- rexp(n_sim, rate=1/3)+1
# hàm g(x) = x^2
g_x <- function(x){
  g <- x^2
  return (g)
}
#g_x(2)
# Hàm f(x)
f_x <- function (x) {
  f <- (exp(-0.5*x^2))/(sqrt(2*pi))
  return (f)
}
f_x(1)
#hàm h(x)
h_x <- function (x,n){
  h <- n*exp(-n*(x-1))
  return(h)
}
#h_x(0,1/3)
#exp(1)/3
w <- f_x(x)/h_x(x,1/3)
print ("Bài tập 2")
I_IS2 <- mean(g_x(x)*w)
cat("Kết quả tích phân bài tập 2:",I_IS2, "\n")
#x2 <- (sqrt(-2*log(u)))*cos(2*pi*u)
#var2 <- var(g_x(x)*w)/n_sim
#cat("Phương sai của tích phân là", var2, "\n")

