my_boots <- function(data, R=500){

  if(is.null(dim(data))){
    n <- length(data)
    data_bts <- matrix(0, nrow = n, ncol = R)
    id_bts <- replicate(n = R, sample(1:n, size = n, replace = TRUE))
    for (i in 1: R){
      data_bts[, i] <- data[id_bts[, i]]
    }
  }
  else{
    n <- dim(data)[1] # or nrow(data)
    data_bts <- list()
    id_bts <- replicate(n = R, sample(1:n, size = n, replace = TRUE))
    for (i in 1: R){
      data_bts[[i]] <- data[id_bts[, i], ]
    }

  }
  return (data_bts)
}

my_ci_boot <- function(data, boot_sample, fun, alpha = 0.05, ci_type = c("quantile", "bca"), ...) {
  ci_type <- match.arg(ci_type)
  est_boot <- sapply(boot_sample, function(x) fun(x, ...))
  est_boot_st <- sort(est_boot)
  R <- length(boot_sample)
  alpha2 <- alpha / 2

  if (ci_type == "quantile") {
    i_lo <- max(1, floor(R * alpha2))
    i_hi <- min(R, floor(R * (1 - alpha2)))
    ci_boot <- est_boot_st[c(i_lo, i_hi)]
  }

  if (ci_type == "bca") {
    # Uoc luong tren mau goc
    est_sample <- fun(data, ...)
    # Bias correction b
    b_est <- qnorm(mean(est_boot <= est_sample))
    # Jackknife de tinh acceleration a
    n <- if (is.null(dim(data))) length(data) else nrow(data)
    est_jack <- sapply(1:n, function(i) {
      if (is.null(dim(data))) fun(data[-i], ...) else fun(data[-i, ], ...)
    })
    est_jack2 <- mean(est_jack)
    u <- est_jack2 - est_jack
    a_est <- (1/6) * sum(u^3) * sum(u^2)^(-3/2)
    # Tinh beta1, beta2
    z_alp <- qnorm(alpha2)
    beta1_est <- pnorm(b_est + 1/(1/(b_est + z_alp) - a_est))
    beta2_est <- pnorm(b_est + 1/(1/(b_est - z_alp) - a_est))
    i_lo <- max(1, floor(R * beta1_est))
    i_hi <- min(R, floor(R * beta2_est))
    ci_boot <- est_boot_st[c(i_lo, i_hi)]
  }

  return(list(est_boot = est_boot, ci_type = ci_type, ci_boot = ci_boot))
}


