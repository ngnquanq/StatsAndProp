my_perm_test <- function(dataA, dataB, fun = mean, R = 10000) {
  nA <- length(dataA)
  nB <- length(dataB)

  # step 1
  t_diff <- fun(dataA) - fun(dataB)

  # step 2
  data_all <- c(dataA, dataB)
  n <- nA + nB

  # step 3-4-5
  t_perm <- replicate(R, {
    perm    <- sample(data_all)          
    fun(perm[1:nA]) - fun(perm[(nA+1):n]) 
  })

  # step 6
  p_value <- mean(abs(t_perm) >= abs(t_diff))

  return(list(t_diff = t_diff, t_perm = t_perm, p_value = p_value))
}


