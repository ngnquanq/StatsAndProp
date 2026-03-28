

# 1. Khởi tạo dữ liệu mẫu x_1, ..., x_n
set.seed(42)  
n_samples <- 100
x_obs <- rt(n_samples, df = 3) + 2





# IMPORTANCE SAMPLING

f_denom <- function(x, data) {
  sapply(x, function(m) {
     prod((3 + (data - m)^2)^(-2))
  })
}
g_mu <- f_denom
mu_prop_mean <- mean(x_obs)
mu_prop_sd <- sd(x_obs)
q_mu <- function(mu) {
  dnorm(mu, mean = mu_prop_mean, sd = mu_prop_sd)
}

N_mc <- 10000
mu_samples <- rnorm(N_mc, mean = mu_prop_mean, sd = mu_prop_sd)
weights <- g_mu(x = mu_samples, data = x_obs) / q_mu(mu_samples)
expected_mu_mc <- sum(mu_samples * weights) / sum(weights)

cat("Output: ", expected_mu_mc, "\n")

