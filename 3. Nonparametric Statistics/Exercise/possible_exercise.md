Dưới đây là **danh sách toàn bộ các bài tập, câu hỏi lý thuyết và đề bài chứng minh** có thể xuất hiện trong chương **Thống kê phi tham số & Ước lượng mật độ bằng Nhân (Kernel Density Estimation - KDE)**, được tổng hợp đầy đủ từ bài giảng và giáo trình trong tài liệu của bạn.

Bạn có thể copy trực tiếp danh sách các câu hỏi này để gửi cho ChatGPT giải hoặc dùng làm checklist ôn tập.

---

### **PHẦN 1: HÀM PHÂN PHỐI THỰC NGHIỆM (EDF) & STATISTICAL FUNCTIONALS**

* **Bài 1.1 (Tính chất cơ bản của EDF)**: Cho \\(X_1, \dots, X_n \sim F\\) i.i.d. Định nghĩa Hàm phân phối thực nghiệm \\(\hat{F}_n(x) = \frac{1}{n} \sum_{i=1}^n \mathbf{1}(X_i \le x)\\). Tại một điểm \\(x_0\\) cố định:
  1. Tính kỳ vọng \\(E[\hat{F}_n(x_0)]\\), phương sai \\(\text{Var}(\hat{F}_n(x_0))\\) và sai số bình phương trung bình \\(\text{MSE}(\hat{F}_n(x_0))\\).
  2. Xác định phân phối của biến ngẫu nhiên \\(n \hat{F}_n(x_0)\\).
* **Bài 1.2 (Tính chất tiệm cận của EDF)**: Chứng minh các tính chất của \\(\hat{F}_n(x_0)\\):
  1. Tính không lệch (Unbiasedness).
  2. Tính nhất quán (Consistency) theo luật số lớn.
  3. Tính chuẩn tiệm cận (Asymptotic Normality) theo Định lý Giới hạn Trung tâm (CLT).
* **Bài 1.3 (Hiệp phương sai của EDF)**: Cho hai điểm \\(x < y\\), hãy tính hiệp phương sai \\(\text{Cov}(\hat{F}_n(x), \hat{F}_n(y))\\).
* **Bài 1.4 (Định lý Glivenko–Cantelli & Bất đẳng thức DKW)**:
  1. Phát biểu Định lý Glivenko–Cantelli về sự hội tụ đều của \\(\hat{F}_n(x)\\) về \\(F(x)\\).
  2. Phát biểu Bất đẳng thức Dvoretzky–Kiefer–Wolfowitz (DKW) đối với khoảng cách \\(\sup_x |\hat{F}_n(x) - F(x)|\\).
* **Bài 1.5 (Xây dựng khoảng tin cậy cho CDF)**:
  1. Sử dụng Bất đẳng thức DKW để xây dựng Băng tin cậy (Confidence Band) không tiệm cận (finite-sample guarantee) mức \\(1-\alpha\\) cho toàn bộ hàm \\(F(x)\\).
  2. So sánh độ rộng của khoảng tin cậy DKW với khoảng tin cậy tiệm cận Wald và Hoeffding tại điểm cố định \\(x_0\\).
* **Bài 1.6 (Nguyên lý Thế - Plug-in Principle)**:
  1. Phân biệt Functional tuyến tính \\(T(F) = \int a(x) dF(x)\\) và Functional phi tuyến.
  2. Chứng minh công thức chung của ước lượng Plug-in cho Functional tuyến tính: \\(T(\hat{F}_n) = \frac{1}{n} \sum_{i=1}^n a(X_i)\\).
* **Bài 1.7 (Ứng dụng ước lượng Plug-in)**: Viết công thức ước lượng Plug-in \\(T(\hat{F}_n)\\) cho các đại lượng sau:
  1. Trung bình \\(\mu\\) và Phương sai \\(\sigma^2\\).
  2. Hệ số bất đối xứng (Skewness) \\(\kappa = \frac{E[(X-\mu)^3]}{\sigma^3}\\).
  3. Hệ số tương quan (Correlation) \\(\rho\\).
  4. Phân vị (Quantile) \\(F^{-1}(p)\\).
* **Bài 1.8 (So sánh Phương sai)**: So sánh ước lượng Plug-in của phương sai \\(\hat{\sigma}^2 = \frac{1}{n} \sum_{i=1}^n (X_i - \bar{X})^2\\) với phương sai mẫu hiệu chỉnh \\(S^2 = \frac{1}{n-1} \sum_{i=1}^n (X_i - \bar{X})^2\\).

---

### **PHẦN 2: ƯỚC LƯỢNG MẬT ĐỘ BẰNG HISTOGRAM**

* **Bài 2.1 (Tính tích phân)**: Cho ước lượng Histogram \\(\hat{f}_n(x) = \frac{p_j}{h}\\) với \\(x \in B_j\\) (độ rộng thùng \\(h = 1/m\\), \\(p_j\\) là tỷ lệ điểm rơi vào thùng \\(B_j\\)). Chứng minh rằng \\(\int \hat{f}_n(x) dx = 1\\).
* **Bài 2.2 (Khai triển Bias của Histogram)**: Với \\(x \in B_j\\), sử dụng khai triển Taylor cho \\(f(u)\\) quanh điểm \\(x\\) để chứng minh:
  1. \\(\text{Bias}(\hat{f}_n(x)) = E[\hat{f}_n(x)] - f(x) = f'(x) \left[ h\left(j - \frac{1}{2}\right) - x \right] + O(h^2)\\).
  2. Integrated Squared Bias: \\(\int_0^1 \text{Bias}^2(x) dx = \frac{h^2}{12} \int_0^1 (f'(x))^2 dx + o(h^2)\\).
* **Bài 2.3 (Phương sai của Histogram)**: Chứng minh rằng \\(\text{Var}(\hat{f}_n(x)) \approx \frac{f(x)}{nh}\\) và Integrated Variance \\(\approx \frac{1}{nh}\\).
* **Bài 2.4 (Độ rộng thùng tối ưu & Tốc độ hội tụ)**:
  1. Lập biểu thức MISE cho Histogram: \\(\text{MISE}(h) \approx \frac{h^2}{12} \int (f'(x))^2 dx + \frac{1}{nh}\\).
  2. Tìm \\(h^*\\) tối thiểu hóa MISE và chứng minh \\(h^* \propto n^{-1/3}\\).
  3. Chứng minh tốc độ hội tụ tiệm cận của MISE tại \\(h^*\\) là \\(O(n^{-2/3})\\).
* **Bài 2.5 (Cross-Validation cho Histogram)**: Chứng minh công thức điểm Leave-One-Out Cross-Validation cho Histogram:
  \\[\hat{J}(h) = \frac{2}{(n-1)h} - \frac{n+1}{(n-1)h} \sum_{j=1}^m \hat{p}_j^2\\]

---

### **PHẦN 3: ƯỚC LƯỢNG MẬT ĐỘ BẰNG NHÂN (KERNEL DENSITY ESTIMATION - KDE)**

* **Bài 3.1 (Tính chất Mật độ hợp lệ)**: Cho ước lượng KDE \\(\hat{f}_n(x) = \frac{1}{nh} \sum_{i=1}^n K\left(\frac{x - X_i}{h}\right)\\). Chứng minh rằng nếu \\(K(u) \ge 0\\) và \\(\int K(u) du = 1\\) thì \\(\hat{f}_n(x) \ge 0, \forall x\\) và \\(\int_{-\infty}^{\infty} \hat{f}_n(x) dx = 1\\).
* **Bài 3.2 (Chứng minh công thức Bias của KDE)**: Giả sử \\(f'' \in L_2\\) và Nhân \\(K(u)\\) đối xứng (thỏa mãn \\(\int K(u) du = 1\\), \\(\int u K(u) du = 0\\), \\(\int u^2 K(u) du = \sigma_K^2\\)). Dùng khai triển Taylor chứng minh:
  \\[\text{Bias}(\hat{f}_n(x)) = E[\hat{f}_n(x)] - f(x) = \frac{1}{2} h^2 \sigma_K^2 f''(x) + O(h^4)\\]
* **Bài 3.3 (Chứng minh công thức Phương sai của KDE)**: Chứng minh rằng:
  \\[\text{Var}(\hat{f}_n(x)) = \frac{f(x) \int K^2(u) du}{nh} + O\left(\frac{1}{n}\right)\\]
* **Bài 3.4 (Công thức AMISE của KDE)**: Lập công thức Mean Integrated Squared Error tiệm cận (AMISE):
  \\[\text{AMISE}(\hat{f}_n, f) = \frac{1}{4} h^4 \sigma_K^4 \int (f''(x))^2 dx + \frac{\int K^2(u) du}{nh}\\]
* **Bài 3.5 (Bán kính mịn tối ưu \\(h^*\\) và Tốc độ hội tụ)**:
  1. Lấy đạo hàm AMISE theo \\(h\\) để tìm \\(h^* = \left( \frac{\int K^2(u) du}{\sigma_K^4 \int (f''(x))^2 dx} \right)^{1/5} n^{-1/5}\\).
  2. Thay \\(h^*\\) vào AMISE để chứng minh tốc độ hội tụ tiệm cận của KDE là \\(O(n^{-4/5})\\).
  3. So sánh tốc độ \\(O(n^{-4/5})\\) của KDE với \\(O(n^{-2/3})\\) của Histogram.
* **Bài 3.6 (Higher-Order Kernels)**: Giả sử \\(K(u)\\) là nhân cấp \\(\ell\\) (Kernel of order \\(\ell\\), thỏa mãn \\(\int u^j K(u) du = 0\\) với \\(j=1,\dots,\ell-1\\)). 
  1. Chứng minh Bias giảm xuống mức \\(O(h^\ell)\\).
  2. Tìm tốc độ hội tụ tối ưu của MISE ứng với nhân cấp \\(\ell\\) (đạt \\(O(n^{-2\ell/(2\ell+1)})\\)).
* **Bài 3.7 (Quy tắc Silverman - Normal Reference Rule)**: Giả sử hàm mật độ thực \\(f(x)\\) là phân phối chuẩn \\(\mathcal{N}(\mu, \sigma^2)\\) và Nhân \\(K(u)\\) là nhân chuẩn Gaussian \\(\mathcal{N}(0,1)\\). Chứng minh rằng \\(h^* = 1.06 \hat{\sigma} n^{-1/5}\\), trong đó \\(\hat{\sigma} = \min\left(s, \frac{IQR}{1.34}\right)\\).
* **Bài 3.8 (Leave-One-Out Cross-Validation Score)**: Định nghĩa hàm tiêu chuẩn \\(J(h) = \int \hat{f}_n^2(x) dx - 2 \int \hat{f}_n(x) f(x) dx\\). 
  1. Chứng minh tiêu chuẩn điểm LOOCV:
     \\[\hat{J}(h) = \int \hat{f}_n^2(x) dx - \frac{2}{n} \sum_{i=1}^n \hat{f}_{(-i)}(X_i)\\]
     là một ước lượng không lệch của \\(E[J(h)]\\).
  2. Biến đổi \\(\hat{J}(h)\\) về dạng tính toán thực tế:
     \\[\hat{J}(h) = \frac{1}{n^2 h} \sum_{i=1}^n \sum_{j=1}^n K^{(2)}\left(\frac{X_i - X_j}{h}\right) + \frac{2}{nh} K(0)\\]
     trong đó \\(K^{(2)}(z) = \int K(z-y) K(y) dy\\).
* **Bài 3.9 (Tính nhất quán & Chuẩn tiệm cận)**:
  1. Phát biểu điều kiện đối với \\(h_n\\) để \\(\hat{f}_n(x) \xrightarrow{P} f(x)\\) (Tính nhất quán điểm).
  2. Phát biểu phân phối tiệm cận của \\(\sqrt{nh_n} \left( \hat{f}_n(x) - f(x) \right)\\) khi \\(n h_n^5 \to \lambda\\).

---

### **PHẦN 4: HỒI QUY PHI THAM SỐ (NONPARAMETRIC REGRESSION)**

* **Bài 4.1 (Ước lượng Nadaraya-Watson)**: Cho mô hình \\(Y_i = r(X_i) + \varepsilon_i\\). 
  1. Xây dựng ước lượng Nadaraya-Watson \\(\hat{r}_n(x) = \frac{\sum_{i=1}^n K\left(\frac{x - X_i}{h}\right) Y_i}{\sum_{j=1}^n K\left(\frac{x - X_j}{h}\right)}\\) bằng cách giải bài toán bình phương tối thiểu trọng số cục bộ (Locally Constant):
     \\[\min_a \sum_{i=1}^n K\left(\frac{x - X_i}{h}\right) (Y_i - a)^2\\]
  2. Chỉ ra thành phần "Design Bias" \\(2 \frac{r'(x) f'(x)}{f(x)}\\) trong công thức Bias của Nadaraya-Watson và giải thích hiện tượng "Boundary Bias" (lệch ở biên).
* **Bài 4.2 (Local Linear Regression)**:
  1. Xây dựng ước lượng Hồi quy Tuyến tính Cục bộ bằng cách giải:
     \\[\min_{a_0, a_1} \sum_{i=1}^n K\left(\frac{x - X_i}{h}\right) \left[ Y_i - a_0 - a_1(X_i - x) \right]^2\\]
  2. Chứng minh rằng Local Linear Regression loại bỏ được Design Bias và triệt tiêu Boundary Bias (Bias đạt \\(O(h^2)\\) ở cả điểm trong lẫn điểm biên).
* **Bài 4.3 (Cross-Validation cho Hồi quy)**: Định nghĩa điểm LOOCV \\(CV(h) = \frac{1}{n} \sum_{i=1}^n (Y_i - \hat{r}_{(-i)}(X_i))^2\\). Đối với Linear Smoothers (\\(\hat{\mathbf{Y}} = L \mathbf{Y}\\)), chứng minh công thức tính nhanh:
  \\[CV(h) = \frac{1}{n} \sum_{i=1}^n \left( \frac{Y_i - \hat{r}_n(X_i)}{1 - L_{ii}} \right)^2\\]
  với \\(L_{ii}\\) là phần tử đường chéo thứ \\(i\\) của ma trận làm mịn \\(L\\).
* **Bài 4.4 (Generalized Cross-Validation - GCV)**: Viết công thức GCV bằng cách thay \\(L_{ii}\\) bằng trung bình vết \\(\nu / n = \text{tr}(L)/n\\).

---

### **PHẦN 5: ƯỚC LƯỢNG CHIẾU (PROJECTION ESTIMATOR) & KIỂM ĐỊNH PHI THAM SỐ**

* **Bài 5.1 (Ước lượng Chiếu)**: Cho hệ cơ sở trực chuẩn \\(\{\varphi_j\}_{j \ge 1}\\) trên \\(L_2()\\). Định nghĩa ước lượng chiếu \\(\hat{f}_D(x) = \sum_{j=1}^D \hat{a}_j \varphi_j(x)\\).
  1. Chứng minh \\(\hat{a}_j = \frac{1}{n} \sum_{i=1}^n \varphi_j(X_i)\\) là ước lượng không lệch của hệ số Fourier \\(a_j = E[\varphi_j(X)]\\).
  2. Chứng minh ước lượng Histogram thực chất là một trường hợp đặc biệt của ước lượng chiếu trên hệ hàm bước (Step-function basis).
* **Bài 5.2 (So sánh KDE và Projection Estimator)**: So sánh KDE và Ước lượng chiếu về: tham số làm mịn (\\(h\\) vs \\(D\\)), tốc độ hội tụ tối ưu (\\(n^{-4/5}\\) vs \\(n^{-2\beta/(2\beta+1)}\\)), và cách tính toán.
* **Bài 5.3 (Kiểm định sự phù hợp Goodness-of-Fit)**: So sánh 3 thống kê kiểm định phi tham số cho \\(H_0: F = F_0\\):
  1. Kolmogorov-Smirnov (KS): \\(\sqrt{n} \sup_x |\hat{F}_n(x) - F_0(x)|\\).
  2. Cramér–von Mises (CvM): \\(n \int (\hat{F}_n(x) - F_0(x))^2 dF_0(x)\\).
  3. Anderson–Darling (AD): \\(n \int \frac{(\hat{F}_n(x) - F_0(x))^2}{F_0(x)(1 - F_0(x))} dF_0(x)\\).
  *(Giải thích tại sao CvM và AD thường có sức mạnh kiểm định - power lớn hơn KS, và khi nào nên ưu tiên dùng AD)*.

---

Bạn có thể đưa toàn bộ danh sách này hoặc chọn riêng từng phần để nhờ ChatGPT giải chi tiết từng bài!