source(file="./algorithms/mean_shift_clustering/reImplemnt.R")

# mcycle data -----
data(mcycle, package = "MASS")
head(mcycle)

plot(x=mcycle$times, y=mcycle$accel, pch=16)

range(mcycle$times)

x_plot <- seq(0,60, length.out=201)
y_hat <- kernel_reg(x=mcycle$times, y=mcycle$accel, x_eval = x_plot, h=10)
plot(x=mcycle$times, y=mcycle$accel, pch=16, cex=0.7)
lines(x = x_plot, y=y_hat, col="blue")

## cv --------------
cv_bandwidth(x = mcycle$times, y=mcycle$accel, h=0.5)
h_plot<- seq(0.1,4,length.out=21)
cv1_est <- cv_bandwidth(x=mcycle$times, y=mcycle$accel,h=h_plot)

plot(x=h_plot,y=cv1_est, type="b", pch=16)

system.time(
  {
    cv1_est <- cv_bandwidth(x=mcycle$times, y=mcycle$accel,h=h_plot)
  }
)

## cv 2 ----------------------
cv_bandwidth_2(x = mcycle$times, y=mcycle$accel, h=0.5)
h_plot<- seq(0.1,4,length.out=21)
cv2_est <- cv_bandwidth_2(x=mcycle$times, y=mcycle$accel,h=h_plot)
plot(x=h_plot,y=cv2_est, type="b", pch=16)
system.time(
  {
    cv2_est <- cv_bandwidth_2(x=mcycle$times, y=mcycle$accel,h=h_plot)
  }
)


