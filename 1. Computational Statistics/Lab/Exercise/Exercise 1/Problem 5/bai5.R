n <- 100

#hàm runif(n, a, b) để tạo mẫu ngẫu nhiên của Xi.

Xi <- runif(n,0,pi)

#1) --> m(x)
mx<- function(x){
  ifelse(x==0,2,1 + sin(x^2)/x^2)
}

#2)--->độ lệch chuẩn
ox <- function(x){
  abs(mx(x))/8
}
sd <- ox(Xi) #sd là dãy kết quả độ lệch chuẩn

#hàm rnorm(n, mean, sd) để khởi tạo sai số εi
Ei <- rnorm(n,0,sd)

Yi <- mx(Xi)+Ei
#xong câu a--------------------------------------

#kernel
epane <- function(u){ifelse(abs(u) <= 1, 0.75*(1-u^2), 0)}
gaus <- function(x){
  (exp((x^2)/-2))/sqrt(2*pi)
  
}

#Theo phương pháp plug-in rule of thumb
h_ROT <- 1.06*sd*n^(-1/5) # cả gau và epane

#hàm hồi quy tuyến tính địa phương
X <- Xi
Y <- Yi
mLL <- function(x, X, Y, h, k){
  n <- length(X)
  u  <- (x - X)/h
  ku <- sapply(u, k)
  
  sb0 <- mean(ku)
  sb1 <- mean((X - x) * ku)
  sb2 <- mean((X - x)^2 * ku)
  
  denom <- sb2*sb0 - sb1^2
  if(denom <= 0 || sb0 == 0) return(NA)
  
  W1 <- (sb2 - sb1*(X - x)) / (n*denom) * ku
  sum(W1 * Y)
}


#p=1
CV1 <- function(h, X, Y, k){
  n  <- length(X)
  k0 <- k(0)
  val <- numeric(n)
  
  for(i in 1:n){
    u  <- (X[i] - X)/h
    ku <- sapply(u, k)
    
    sb0 <- mean(ku)
    sb1 <- mean((X - X[i]) * ku)
    sb2 <- mean((X - X[i])^2 * ku)
    
    denom <- sb2*sb0 - sb1^2
    if(denom <= 0 || sb0 == 0){
      val[i] <- NA
    } else {
      Wii  <- (sb2/(n*denom)) * k0
      mhat <- mLL(X[i], X, Y, h, k)
      val[i] <- ((Y[i] - mhat)/(1 - Wii))^2
    }
  }
  mean(val, na.rm = TRUE)
}

GCV1 <- function(h, X, Y, k){
  n  <- length(X)
  k0 <- k(0)
  
  fit <- numeric(n)
  Wii <- numeric(n)
  
  for(i in 1:n){
    u  <- (X[i] - X)/h
    ku <- sapply(u, k)
    
    sb0 <- mean(ku)
    sb1 <- mean((X - X[i]) * ku)
    sb2 <- mean((X - X[i])^2 * ku)
    
    denom <- sb2*sb0 - sb1^2
    if(denom <= 0 || sb0 == 0){
      fit[i] <- NA
      Wii[i] <- NA
    } else {
      Wii[i] <- (sb2/(n*denom)) * k0
      fit[i] <- mLL(X[i], X, Y, h, k)
    }
  }
  
  num <- sum((Y - fit)^2, na.rm = TRUE)
  den <- (n - sum(Wii, na.rm = TRUE))^2
  num / den
}

hh_seq <- seq(0.05, 1, length=n)
# Epane
CV_epa  <- sapply(hh_seq, CV1,  X, Y, k=epane)
GCV_epa <- sapply(hh_seq, GCV1, X, Y, k=epane)
h_CV_epa  <- hh_seq[which.min(CV_epa)]
h_GCV_epa <- hh_seq[which.min(GCV_epa)]

# Gaussian
CV_gau  <- sapply(hh_seq, CV1,  X, Y, k=gaus)
GCV_gau <- sapply(hh_seq, GCV1, X, Y, k=gaus)
h_CV_gau  <- hh_seq[which.min(CV_gau)]
h_GCV_gau <- hh_seq[which.min(GCV_gau)]

BangThong <- data.frame(
  Kernel = c("Epane","Gauss"),
  h_ROT  = c(h_ROT, h_ROT),
  h_CV   = c(h_CV_epa, h_CV_gau),
  h_GCV  = c(h_GCV_epa, h_GCV_gau)
)
print(BangThong)
# Xong câu b----------------------------------------
# Câu (c): vẽ 6 đường (ROT/CV/GCV) x (Epane/Gauss

xg <- seq(0, pi, length = n)

# Epane
m_epa_ROT <- sapply(xg, mLL, X, Y, h=h_ROT,     k=epane)
m_epa_CV  <- sapply(xg, mLL, X, Y, h=h_CV_epa,  k=epane)
m_epa_GCV <- sapply(xg, mLL, X, Y, h=h_GCV_epa, k=epane)

# Gauss
m_gau_ROT <- sapply(xg, mLL, X, Y, h=h_ROT,     k=gaus)
m_gau_CV  <- sapply(xg, mLL, X, Y, h=h_CV_gau,  k=gaus)
m_gau_GCV <- sapply(xg, mLL, X, Y, h=h_GCV_gau, k=gaus)

# Vẽ dữ liệu + 6 đường
plot(Xi, Yi, pch=16, col="grey", xlab="X", ylab="Y", main="Local linear: 6 duong")

lines(xg, m_epa_ROT, lwd=2, col="blue")
lines(xg, m_epa_CV,  lwd=2, col="blue", lty=2)
lines(xg, m_epa_GCV, lwd=2, col="blue", lty=3)

lines(xg, m_gau_ROT, lwd=2, col="red")
lines(xg, m_gau_CV,  lwd=2, col="red", lty=2)
lines(xg, m_gau_GCV, lwd=2, col="red", lty=3)

legend("topright",
       c("Epane-ROT","Epane-CV","Epane-GCV",
         "Gauss-ROT","Gauss-CV","Gauss-GCV"),
       col=c("blue","blue","blue","red","red","red"),
       lty=c(1,2,3,1,2,3), lwd=2)

#xong câu c----------------------------------
#Lặp 100 lần ý (a)-(b)


B <- 100
H <- matrix(NA, B, 5)
colnames(H) <- c("ROT","CV_epa","GCV_epa","CV_gau","GCV_gau")

for(b in 1:B){
  Xi <- runif(n,0,pi)
  Yi <- mx(Xi) + rnorm(n,0,ox(Xi))
  
  #H[b,1] <- 1.06 *sd* n^(-1/5)
  H[b,2] <- hh_seq[which.min(sapply(hh_seq, CV1,  X, Y, k=epane))]
  H[b,3] <- hh_seq[which.min(sapply(hh_seq, GCV1, X, Y, k=epane))]
  H[b,4] <- hh_seq[which.min(sapply(hh_seq, CV1,  X, Y, k=gaus))]
  H[b,5] <- hh_seq[which.min(sapply(hh_seq, GCV1, X, Y, k=gaus))]
}

matplot(H, type="l", lty=1, lwd=2, xlab="Lan lap", ylab="h")
legend("topright", colnames(H), lty=1, lwd=2, cex=0.8)
boxplot(H, main="Bandwidths (100 lan lap)", ylab="h")
