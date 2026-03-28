
#Bài tập 3:==========================
print("Bài tập 3")
#Bài tập 3:
# Câu a
n_sim3 <- 10000000
#x <- rnorm (n=n_sim, mean = 0, sd=1)
x3 <- rexp(n_sim3, rate=1/3)
#hàm h(t)
h_t3 <- function (x){
  h <- (exp(-x/3))/3
  return(h)
}

g_t3 <- function(x)
  {h <- (exp(-x/3))/3
return(h)
}
w3 <- h_t3(x3)/g_t3(x3)
out_tu <- mean(1*w3)
#out_tu <- 1
out_mau <- mean(w3*x3^(-2/3))
I_IS3 <- out_tu/out_mau

cat("Kết quả bài tập 3a:",I_IS3, "\n")
#x2 <- (sqrt(-2*log(u)))*cos(2*pi*u)
#var2 <- var(I_IS3)
#var3 <- var(w3 / out_mau) / n_sim3
#cat("Phương sailà", var3, "\n")


# Lấy mẫu theo hàm gama
a <- 1/3
w <- gamma(a)/(a^a)
tp3 <- 3/w
cat("Kết quả theo hàm gamma",tp3,"\n")
#==========================
print("Bài tập 3b")

h_x3b <- function(x){
  f <- exp(-(abs(x)^3)/3)
  return(f)
}
n <- n_sim3
set.seed(42)
a <- -5
b <- 5
x3b <- runif(n,min =a,max= b)
x_sort <-  sort(x3b)
x_i <- x_sort[1: (n-1)]
x_i_1 <- x_sort[2:n]
tu<- function(x){
  # s <- 0
  #for (i in 0:n) {
  x <- x_i_1-x_i
  g <- (x_i^2)*x*h_x3b(x_i)
  #    s <- s+g
  s <- sum(g)
  #}
  return(s)
}

mau <- function(x){
  #  s <- 0
  #  for (i in 0:n) {
  x <- x_i_1-x_i
  g <- x*h_x3b(x_i)
  #    s <- s+g
  s <- sum(g)
  #}
  return(s)
}
b_3 <- tu()/mau()
cat("Kết quả bài 3b là:",b_3,"\n" )
#=====================


I_est_IS <- function(n_sim) {
  x_tmp <- rexp(n_sim, rate = 1/3)
  out_tu <- 1
  out_mau <- mean(1 * x_tmp^(-2/3))
  return(out_tu / out_mau)
}

I_est_Riemann <- function(n_sim) {
  x3b_tmp <- sort(runif(n_sim, min = -5, max = 5))
  x_i <- x3b_tmp[1:(n_sim - 1)]
  x_i_1 <- x3b_tmp[2:n_sim]
  delta_x <- x_i_1 - x_i
  
  tu_val <- sum((x_i^2) * delta_x * h_x3b(x_i))
  mau_val <- sum(delta_x * h_x3b(x_i))
  return(tu_val / mau_val)
}

# ==========================================
# So sánh sự hiệu quả (Câu 3c)
print("Mô phỏng Monte Carlo cho bài tập 3")

n_reps <- 1000  
n_size <- 500   

# Mô phỏngImportance Sampling
out_sim_IS <- sapply(1:n_reps, function(i, n_sim) {
  return(I_est_IS(n_sim))
}, n_sim = n_size)

# Mô phỏng cho Rieman
out_sim_Riemann <- sapply(1:n_reps, function(i, n_sim) {
  return(I_est_Riemann(n_sim))
}, n_sim = n_size)

var_a <- var(out_sim_IS)
var_b <- var(out_sim_Riemann)

cat("Phương sai của Importance Sampling (a):", var_a, "\n")
cat("Phương sai của Riemann (b):", var_b, "\n")
if (var_a < var_b) {
  cat("Importance Sampling hiệu quả hơn vì có phương sai nhỏ hơn.\n")
} else {
  cat("Riemann hiệu quả hơn.\n")
}

