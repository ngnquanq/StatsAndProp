# Bài tập Thống kê phi tham số

**Lớp:** Cao học LT Thống kê Toán
**Chương 1:** Hàm mật độ xác suất tích lũy

> **Ghi chú:** Kí hiệu **[W]** nghĩa là tham khảo sách *All of Nonparametric Statistics* của Wasserman.

Mỗi bài gồm ba phần: **A. Motivation & Ý nghĩa** (tại sao), **B. Chi tiết Toán học** (làm thế nào), **C. Ví dụ Thực tế & Đa ngành** (dùng ở đâu).

---

## Bài 1. Khoảng tin cậy tiệm cận cho $\sqrt{F(x_0)}$

### Đề bài

Xét $X_1, \dots, X_n \overset{i.i.d}{\sim} F$, với $F$ là một phân phối xác suất chưa biết, $0 < F(x) < 1$ với $x \in S \subset \mathbb{R}$, $S$ là tập giá trị của $X$. Dựa trên mẫu ngẫu nhiên này, hãy **xây dựng một khoảng tin cậy tiệm cận** với độ tin cậy $100(1-\alpha)\%$ cho $\sqrt{F(x_0)}$ với $x_0$ cho trước thuộc $S$.

*Gợi ý: sử dụng hàm phân phối xác suất tích lũy thực nghiệm (ECDF) và phương pháp Delta (Delta-method).*

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Trong thống kê phi tham số (Nonparametric Statistics), hàm phân phối tích lũy thực nghiệm (ECDF) $\widehat{F}_n(x)$ là ước lượng không chệch và hội tụ hầu chắc chắn (Glivenko-Cantelli theorem) về $F(x)$.

Khi cần suy diễn thống kê cho một hàm phi tuyến của phân phối $\theta = g(F(x_0))$, cụ thể ở đây là phép biến đổi căn bậc hai $g(t) = \sqrt{t}$, ta không thể áp dụng trực tiếp Định lý Giới hạn Trung tâm (CLT) dạng chuẩn. **Phương pháp Delta (Delta-method)** đóng vai trò xấp xỉ tuyến tính bậc nhất (Taylor expansion) của $g$ quanh điểm $F(x_0)$, chuyển phân phối tiệm cận của ECDF thành phân phối tiệm cận của $\sqrt{\widehat{F}_n(x_0)}$ để xây dựng khoảng tin cậy tiệm cận (Asymptotic Confidence Interval).

---

#### B. Chi tiết Toán học (The "How")

*Bước 1: Phân phối tiệm cận của ECDF tại $x_0$*

* Định nghĩa biến chỉ thị $Y_i = \mathbb{I}(X_i \le x_0)$ với $i = 1, \dots, n$.
* Các biến $Y_i \overset{i.i.d}{\sim} \text{Bernoulli}(p)$, trong đó $p = \mathbb{P}(X_i \le x_0) = F(x_0)$.
* ECDF tại điểm cố định $x_0$:

$$\widehat{F}_n(x_0) = \frac{1}{n} \sum_{i=1}^n \mathbb{I}(X_i \le x_0) = \bar{Y}$$

* Kỳ vọng và phương sai mẫu:

$$\mathbb{E}[\widehat{F}_n(x_0)] = F(x_0)$$

$$\text{Var}(\widehat{F}_n(x_0)) = \frac{F(x_0)(1 - F(x_0))}{n}$$

* Theo CLT:

$$\sqrt{n}\Big(\widehat{F}_n(x_0) - F(x_0)\Big) \xrightarrow{d} \mathcal{N}\Big(0, F(x_0)(1 - F(x_0))\Big)$$

*Bước 2: Áp dụng Phương pháp Delta*

* Xét hàm $g(t) = \sqrt{t}$ trên khoảng $(0, 1)$. Đạo hàm của $g(t)$:

$$g'(t) = \frac{1}{2\sqrt{t}}$$

* Vì $0 < F(x_0) < 1$, hàm $g(t)$ khả vi liên tục tại $t = F(x_0)$ và $g'(F(x_0)) = \frac{1}{2\sqrt{F(x_0)}} \neq 0$.
* Theo Delta-method, nếu $\sqrt{n}(T_n - \theta) \xrightarrow{d} \mathcal{N}(0, \sigma^2)$ thì $\sqrt{n}(g(T_n) - g(\theta)) \xrightarrow{d} \mathcal{N}(0, [g'(\theta)]^2 \sigma^2)$.
* Tính phương sai tiệm cận:

$$\sigma_{\Delta}^2 = [g'(F(x_0))]^2 \cdot \text{Var}(Y_1) = \left(\frac{1}{2\sqrt{F(x_0)}}\right)^2 \cdot F(x_0)(1 - F(x_0)) = \frac{1}{4F(x_0)} \cdot F(x_0)(1 - F(x_0)) = \frac{1 - F(x_0)}{4}$$

* Ta thu được phân phối giới hạn:

$$\sqrt{n}\Big(\sqrt{\widehat{F}_n(x_0)} - \sqrt{F(x_0)}\Big) \xrightarrow{d} \mathcal{N}\left(0, \frac{1 - F(x_0)}{4}\right)$$

*Bước 3: Ước lượng phương sai & Bổ đề Slutsky*

* Tham số $F(x_0)$ chưa biết được thay thế bằng ước lượng vững $\widehat{F}_n(x_0)$.
* Theo luật số lớn (WLLN) và Định lý Ánh xạ Liên tục (CMT):

$$\sqrt{\frac{1 - \widehat{F}_n(x_0)}{4}} \xrightarrow{P} \sqrt{\frac{1 - F(x_0)}{4}}$$

* Theo Định lý Slutsky, thống kê chuẩn hóa có phân phối tiệm cận chuẩn tắc:

$$\frac{\sqrt{\widehat{F}_n(x_0)} - \sqrt{F(x_0)}}{\sqrt{\dfrac{1 - \widehat{F}_n(x_0)}{4n}}} \xrightarrow{d} \mathcal{N}(0, 1)$$

* Sai số chuẩn ước lượng (Estimated Standard Error):

$$\widehat{\text{se}} = \frac{\sqrt{1 - \widehat{F}_n(x_0)}}{2\sqrt{n}}$$

*Bước 4: Kết luận Khoảng tin cậy tiệm cận*

Khoảng tin cậy tiệm cận đối xứng $100(1-\alpha)\%$ cho $\sqrt{F(x_0)}$ là:

$$CI_{1-\alpha}\left(\sqrt{F(x_0)}\right) = \left[ \sqrt{\widehat{F}_n(x_0)} - z_{\alpha/2} \frac{\sqrt{1 - \widehat{F}_n(x_0)}}{2\sqrt{n}}, \; \sqrt{\widehat{F}_n(x_0)} + z_{\alpha/2} \frac{\sqrt{1 - \widehat{F}_n(x_0)}}{2\sqrt{n}} \right]$$

*(Trong đó $z_{\alpha/2}$ là giá trị tới hạn chuẩn tắc thỏa mãn $\Phi(z_{\alpha/2}) = 1 - \alpha/2$. Nếu các mút vượt ngoài khoảng $[0, 1]$, ta cắt tỉa (truncate) về $[0, 1]$).*

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Data Drift & Anomaly Detection (Security/IAM)**: Phép biến đổi căn bậc hai $\sqrt{F(x)}$ thường xuất hiện khi tính toán **Khoảng cách Hellinger (Hellinger Distance)** hoặc hệ số **Bhattacharyya** để so sánh phân phối xác suất hành vi đăng nhập/truy cập tài nguyên của User giữa tập baseline và tập dữ liệu thời gian thực. Khoảng tin cậy cho $\sqrt{F(x_0)}$ giúp thiết lập ngưỡng cảnh báo (dynamic thresholding) vững chắc khi phát hiện bất thường.
* **Variance Stabilization**: Khi $F(x_0) \to 0$ (sự kiện hiếm, ví dụ tỷ lệ rủi ro/fraud cực thấp), phương sai tiệm cận của $\sqrt{\widehat{F}_n(x_0)}$ là $\frac{1 - F(x_0)}{4n} \approx \frac{1}{4n}$, hầu như độc lập với giá trị $F(x_0)$, giúp ổn định phương sai cho các mô hình suy diễn chuỗi thời gian hoặc streaming data.

---

## Bài 2. Khoảng tin cậy Hoeffding cho tỷ lệ $p$

### Đề bài

Xét $X_1, \dots, X_n \overset{i.i.d}{\sim} \mathcal{B}(p)$. Với bất kỳ $\epsilon > 0$, ta có

$$\mathbb{P}\big(\vert{}\bar{X} - p\vert{} > \epsilon\big) \le 2 e^{-2n\epsilon^2}$$

với $\bar{X} = (1/n)\sum_{i=1}^n X_i$. Đây gọi là **bất đẳng thức Hoeffding** cho các biến ngẫu nhiên Bernoulli. Sử dụng bất đẳng thức này, hãy xây dựng một khoảng tin cậy $100(1-\alpha)\%$ cho tỷ lệ $p$. Viết 1 hàm trong **R** hoặc **Python** để tính khoảng tin cậy và tính **độ phủ (coverage)** thực tế của khoảng tin cậy tìm được.

*Ghi chú trên đề (viết tay): $\widehat{p} = \bar{X}$; mấu chốt là **chọn $\epsilon = ?$** — đi từ $\mathbb{P}(\vert{}\widehat{p}-p\vert{} \le \epsilon) \ge 1 - 2e^{-2n\epsilon^2} \to 1-\alpha$, suy ra $\widehat{p} - \epsilon \le p \le \widehat{p} + \epsilon$.*

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Trong thực tế xây dựng khoảng tin cậy, phương pháp cổ điển dựa trên Định lý Giới hạn Trung tâm (CLT/Wald Interval) chỉ đúng về mặt **tiệm cận** ($n \to \infty$). Khi kích thước mẫu $n$ nhỏ hoặc hữu hạn, độ phủ thực tế (actual coverage probability) của khoảng tin cậy dạng Wald thường thấp hơn độ tin cậy danh định $1 - \alpha$.

**Bất đẳng thức Hoeffding** cung cấp một chặn trên xác suất phi tham số, phi tiệm cận (**finite-sample distribution-free bound**). Khoảng tin cậy suy ra từ Hoeffding là một **khoảng tin cậy bảo thủ (conservative confidence interval)**: độ phủ thực tế luôn lớn hơn hoặc bằng $1 - \alpha$ với mọi $n \ge 1$, bất kể giá trị thực của tham số $p$.

---

#### B. Chi tiết Toán học (The "How")

*Bước 1: Thiết lập Bất đẳng thức Hoeffding*

* Cho $X_1, \dots, X_n \overset{i.i.d}{\sim} \text{Bernoulli}(p)$ với $X_i \in [0, 1]$.
* Ước lượng hợp lý cực đại cho $p$ là trung bình mẫu:

$$\widehat{p} = \bar{X} = \frac{1}{n} \sum_{i=1}^n X_i$$

* Bất đẳng thức Hoeffding dạng hai phía (two-sided) cho các biến ngẫu nhiên độc lập bị chặn trong đoạn $[0, 1]$:

$$\mathbb{P}\big(\vert{}\widehat{p} - p\vert{} > \varepsilon\big) \le 2e^{-2n\varepsilon^2}, \quad \forall \varepsilon > 0$$

*Bước 2: Tìm $\varepsilon$ theo mức ý nghĩa $\alpha$*

* Chuyển sang biến cố bù:

$$\mathbb{P}\big(\vert{}\widehat{p} - p\vert{} \le \varepsilon\big) = 1 - \mathbb{P}\big(\vert{}\widehat{p} - p\vert{} > \varepsilon\big) \ge 1 - 2e^{-2n\varepsilon^2}$$

* Ta muốn độ tin cậy đạt ít nhất $1 - \alpha$:

$$1 - 2e^{-2n\varepsilon^2} = 1 - \alpha \iff 2e^{-2n\varepsilon^2} = \alpha$$

* Giải phương trình tìm sai số $\varepsilon$:

$$e^{-2n\varepsilon^2} = \frac{\alpha}{2} \iff -2n\varepsilon^2 = \ln\left(\frac{\alpha}{2}\right) = -\ln\left(\frac{2}{\alpha}\right)$$

$$\varepsilon_n = \sqrt{\frac{1}{2n} \ln\left(\frac{2}{\alpha}\right)}$$

*Bước 3: Xây dựng Khoảng tin cậy*

* Biến cố $\vert{}\widehat{p} - p\vert{} \le \varepsilon_n$ tương đương với:

$$\widehat{p} - \varepsilon_n \le p \le \widehat{p} + \varepsilon_n$$

* Vì tham số $p \in [0, 1]$, ta cắt tỉa (truncate) các mút ra ngoài đoạn $[0, 1]$:

$$CI_{1-\alpha}(p) = \left[ \max\left(0, \, \widehat{p} - \sqrt{\frac{1}{2n}\ln\left(\frac{2}{\alpha}\right)}\right), \; \min\left(1, \, \widehat{p} + \sqrt{\frac{1}{2n}\ln\left(\frac{2}{\alpha}\right)}\right) \right]$$

---

*Bước 4: Cài đặt code tính Khoảng tin cậy và Độ phủ (Coverage)*

**Phiên bản Python:**

```python
import numpy as np

def hoeffding_ci_and_coverage(n, p, alpha=0.05, n_sim=10000, seed=42):
    """
    Tính khoảng tin cậy Hoeffding và empirical coverage qua mô phỏng Monte Carlo.
    """
    np.random.seed(seed)
    
    # 1. Tính epsilon từ bất đẳng thức Hoeffding
    eps = np.sqrt((1 / (2 * n)) * np.log(2 / alpha))
    
    # 2. Sinh n_sim mẫu Bernoulli(p), mỗi mẫu có kích thước n
    samples = np.random.binomial(n=1, p=p, size=(n_sim, n))
    p_hat = np.mean(samples, axis=1)
    
    # 3. Xây dựng cận dưới và cận trên
    lower_bound = np.clip(p_hat - eps, 0, 1)
    upper_bound = np.clip(p_hat + eps, 0, 1)
    
    # 4. Tính empirical coverage probability
    is_covered = (lower_bound <= p) & (p <= upper_bound)
    coverage = np.mean(is_covered)
    
    return {
        "epsilon": eps,
        "sample_ci_example": (lower_bound[0], upper_bound[0]),
        "nominal_confidence": 1 - alpha,
        "empirical_coverage": coverage
    }

# Chạy thử nghiệm với n = 100, p = 0.3, alpha = 0.05
res = hoeffding_ci_and_coverage(n=100, p=0.3, alpha=0.05)
print(f"Epsilon: {res['epsilon']:.4f}")
print(f"Ví dụ 1 CI: [{res['sample_ci_example'][0]:.4f}, {res['sample_ci_example'][1]:.4f}]")
print(f"Nominal Confidence: {res['nominal_confidence']:.2%}")
print(f"Empirical Coverage: {res['empirical_coverage']:.4%}")

```

**Phiên bản R (tương đương):**

```R
hoeffding_coverage <- function(n, p, alpha = 0.05, n_sim = 10000, seed = 42) {
  set.seed(seed)
  
  # Sai số Hoeffding
  eps <- sqrt((1 / (2 * n)) * log(2 / alpha))
  
  # Sinh dữ liệu mẫu & tính p_hat
  samples <- matrix(rbinom(n * n_sim, size = 1, prob = p), nrow = n_sim, ncol = n)
  p_hat <- rowMeans(samples)
  
  # Cận dưới và cận trên
  lower <- pmax(0, p_hat - eps)
  upper <- pmin(1, p_hat + eps)
  
  # Độ phủ thực tế
  coverage <- mean((lower <= p) & (p <= upper))
  
  return(list(
    epsilon = eps,
    example_CI = c(lower[1], upper[1]),
    nominal_confidence = 1 - alpha,
    empirical_coverage = coverage
  ))
}

# Chạy thử nghiệm
res_R <- hoeffding_coverage(n = 100, p = 0.3, alpha = 0.05)
print(res_R)

```

---

*Kết quả chạy thực tế (Python, `n_sim = 10000`, $\alpha = 0.05$, so sánh với khoảng Wald cổ điển):*

| $n$ | $p$ | $\varepsilon_n$ | Bề rộng $2\varepsilon_n$ | Coverage Hoeffding | Coverage Wald |
| --- | --- | --- | --- | --- | --- |
| 10 | 0.1 | 0.4295 | 0.8589 | 0.9998 | 0.6524 |
| 10 | 0.5 | 0.4295 | 0.8589 | 0.9978 | 0.8876 |
| 30 | 0.3 | 0.2480 | 0.4959 | 0.9976 | 0.9548 |
| 50 | 0.1 | 0.1921 | 0.3841 | 0.9999 | 0.8788 |
| 100 | 0.3 | 0.1358 | 0.2716 | 0.9967 | 0.9512 |
| 500 | 0.3 | 0.0607 | 0.1215 | 0.9974 | 0.9502 |
| 1000 | 0.5 | 0.0429 | 0.0859 | 0.9924 | 0.9449 |

**Nhận xét từ output thật:**

* Độ phủ thực tế của khoảng Hoeffding luôn $\ge 0.99 \gg 0.95$ ở mọi $(n, p)$ đã thử — đúng như lý thuyết dự đoán, đây là khoảng **bảo thủ (conservative)**: đảm bảo $\ge 1-\alpha$ nhưng "trả giá" bằng bề rộng lớn.
* Cái giá đó rất rõ ở mẫu nhỏ: với $n = 10$, bề rộng $2\varepsilon_n \approx 0.86$ gần như phủ trọn $[0,1]$ nên khoảng gần như vô dụng về mặt thông tin, dù coverage đạt $99.98\%$.
* Ngược lại, khoảng Wald chỉ đạt $0.65$ (khi $n=10, p=0.1$) và $0.88$ (khi $n=50, p=0.1$) — thấp hơn hẳn mức danh định $95\%$, minh họa đúng hiện tượng under-coverage của xấp xỉ CLT khi $n$ nhỏ hoặc $p$ gần biên.
* Khi $n$ tăng, coverage Wald mới tiến dần về $0.95$, còn Hoeffding vẫn giữ mức $\approx 0.99$; bề rộng Hoeffding giảm theo tốc độ $\mathcal{O}(1/\sqrt{n})$ đúng như công thức $\varepsilon_n = \sqrt{\ln(2/\alpha)/(2n)}$.

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Service Level Objectives & Threat Rate Bounds (Security/IAM)**: Khi đánh giá tỷ lệ đăng nhập thất bại do tấn công Credential Stuffing hoặc tỷ lệ request bất thường trên Gateway ($p$), ta thường có lượng mẫu kiểm thử nhỏ trong các khung giờ thấp điểm. Khoảng tin cậy Hoeffding đảm bảo một chặn trên chắc chắn 100% về mặt toán học (finite-sample bound) mà không cần giả định xấp xỉ phân phối chuẩn.
* **PAC Learning (Probably Approximately Correct Learning)**: Nền tảng của lý thuyết học máy sử dụng cận Hoeffding để chứng minh sai số tổng quát hóa (generalization error) của mô hình phân loại: với xác suất ít nhất $1 - \delta$, sai số thực tế không vượt quá sai số trên tập huấn luyện cộng thêm một lượng $\mathcal{O}\left(\sqrt{\frac{\ln(1/\delta)}{n}}\right)$.

---

## Bài 3. Phân phối giới hạn của $\sqrt{\widehat{F}_n(x)}$

### Đề bài

Xét $X_1, X_2, \dots, X_n \sim F$ và xét $\widehat{F}_n(x)$ là hàm phân phối tích lũy thực nghiệm. Với $x$ cố định, tìm **phân phối giới hạn** của $\sqrt{\widehat{F}_n(x)}$.

*HD: sử dụng phương pháp Delta với $g(x) = \sqrt{x}$, xem [W, chương 1, trang 4]. Cách làm giống Bài 1.*

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Bài toán này yêu cầu tìm **hành vi ngẫu nhiên tiệm cận (Asymptotic/Limiting Distribution)** của đại lượng $\sqrt{\widehat{F}_n(x)}$ khi kích thước mẫu $n \to \infty$.

Bản chất của bài toán:

* Định lý Giới hạn Trung tâm (CLT) chỉ cho ta biết phân phối giới hạn của chính hàm thực nghiệm $\widehat{F}_n(x)$ (bản chất là một trung bình mẫu).
* Tuy nhiên, trong nhiều bài toán thống kê và Machine Learning, ta cần làm việc với các hàm phi tuyến $g(\cdot)$ của phân phối (ví dụ như căn bậc hai $\sqrt{\cdot}$ trong việc tính khoảng cách Hellinger hoặc ổn định phương sai).
* Phương pháp Delta là công cụ vi phân xấp xỉ tuyến tính (Taylor bậc 1) giúp "truyền" phân phối chuẩn từ biến ban đầu sang hàm phi tuyến của nó.

---

#### B. Chi tiết Toán học (The "How")

*Bước 1: Phân phối tiệm cận gốc của ECDF theo CLT*

* Với điểm $x$ cố định, đặt biến chỉ thị $Y_i = \mathbb{I}(X_i \le x)$. Khi đó $Y_1, \dots, Y_n \overset{i.i.d}{\sim} \text{Bernoulli}(F(x))$.
* ECDF chính là trung bình mẫu:

$$\widehat{F}_n(x) = \frac{1}{n}\sum_{i=1}^n Y_i$$

* Theo Định lý Giới hạn Trung tâm (CLT):

$$\sqrt{n}\Big(\widehat{F}_n(x) - F(x)\Big) \xrightarrow{d} \mathcal{N}\Big(0, \sigma^2\Big)$$

trong đó phương sai gốc là:

$$\sigma^2 = \text{Var}(Y_i) = F(x)(1 - F(x))$$

*Bước 2: Áp dụng Phương pháp Delta (Delta-Method)*

* Giả sử $0 < F(x) < 1$.
* Xét hàm chuyển đổi phi tuyến: $g(t) = \sqrt{t} = t^{1/2}$.
* Tính đạo hàm bậc nhất tại điểm $t = F(x)$:

$$g'(t) = \frac{1}{2\sqrt{t}} \implies g'(F(x)) = \frac{1}{2\sqrt{F(x)}}$$

* Phương pháp Delta phát biểu: Nếu $\sqrt{n}(T_n - \theta) \xrightarrow{d} \mathcal{N}(0, \sigma^2)$ và $g'(\theta) \neq 0$, thì:

$$\sqrt{n}\Big(g(T_n) - g(\theta)\Big) \xrightarrow{d} \mathcal{N}\Big(0, [g'(\theta)]^2 \sigma^2\Big)$$

*Bước 3: Tính phương sai tiệm cận mới*

* Thay $g'(F(x))$ và $\sigma^2$ vào công thức phương sai tiệm cận $\sigma_{\Delta}^2$:

$$\sigma_{\Delta}^2 = [g'(F(x))]^2 \cdot \sigma^2 = \left(\frac{1}{2\sqrt{F(x)}}\right)^2 \cdot F(x)(1 - F(x))$$

$$\sigma_{\Delta}^2 = \frac{1}{4F(x)} \cdot F(x)(1 - F(x)) = \frac{1 - F(x)}{4}$$

*Bước 4: Kết luận Phân phối giới hạn*

Phân phối giới hạn chuẩn hóa của $\sqrt{\widehat{F}_n(x)}$ là:

$$\sqrt{n}\Big(\sqrt{\widehat{F}_n(x)} - \sqrt{F(x)}\Big) \xrightarrow{d} \mathcal{N}\left(0, \frac{1 - F(x)}{4}\right)$$

Hoặc viết dưới dạng xấp xỉ thực hành cho mẫu lớn:

$$\sqrt{\widehat{F}_n(x)} \underset{\text{approx}}{\sim} \mathcal{N}\left(\sqrt{F(x)}, \, \frac{1 - F(x)}{4n}\right)$$

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Variance Stabilizing Transformation (Biến đổi ổn định phương sai)**: Phương sai ban đầu của $\widehat{F}_n(x)$ là $\frac{F(x)(1-F(x))}{n}$ (phụ thuộc phức tạp vào cả $F(x)$ và $1-F(x)$). Khi áp dụng phép biến đổi căn bậc hai, phương sai tiệm cận trở thành $\frac{1 - F(x)}{4n}$. Phép biến đổi này giúp đơn giản hóa phân phối, làm giảm sự phụ thuộc của phương sai vào giá trị trung bình ở vùng xác suất nhỏ.
* **Goodness-of-Fit Testing (Kiểm định độ phù hợp mô hình)**: Phân phối giới hạn này là nền tảng để xây dựng thống kê kiểm định phi tham số dạng Freeman-Tukey hoặc khoảng cách Hellinger nhằm so sánh phân phối lý thuyết $F_0$ với dữ liệu quan sát thực nghiệm $\widehat{F}_n$ mà không lo ngại sự bùng nổ phương sai ở vùng đuôi dữ liệu.

---

## Bài 4. Hiệp phương sai của ECDF tại hai điểm

### Đề bài

Xét $x$ và $y$ là hai điểm phân biệt. Tìm $\text{Cov}\left(\widehat{F}_n(x), \widehat{F}_n(y)\right)$.

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Khi nghiên cứu hàm phân phối thực nghiệm $\widehat{F}_n(x)$, ta không chỉ xem xét nó như một biến ngẫu nhiên đơn lẻ tại một điểm $x$ cố định, mà là một **quá trình ngẫu nhiên (Empirical Process)** $\left\{ \widehat{F}_n(x) : x \in \mathbb{R} \right\}$.

Việc tính hiệp phương sai $\text{Cov}\big(\widehat{F}_n(x), \widehat{F}_n(y)\big)$ cho ta biết:

* Mức độ tương quan phụ thuộc giữa hai điểm $x$ và $y$ trên trục số.
* Cấu trúc ma trận hiệp phương sai của phân phối chuẩn nhiều chiều tiệm cận $\left(\widehat{F}_n(x_1), \dots, \widehat{F}_n(x_k)\right)^T$.
* Nền tảng cấu trúc hàm tự hiệp phương sai (autocovariance function) dẫn tới quá trình **Cầu Brownian (Brownian Bridge)** trong Định lý Donsker (Donsker's Theorem) – cốt lõi của các kiểm định phi tham số dạng Kolmogorov-Smirnov.

---

#### B. Chi tiết Toán học (The "How")

*Bước 1: Biểu diễn ECDF qua biến chỉ thị (Indicator Variables)*

* Đặt các biến chỉ thị:

$$I_i(x) = \mathbb{I}(X_i \le x) \quad \text{và} \quad I_j(y) = \mathbb{I}(X_j \le y)$$

* Khi đó:

$$\widehat{F}_n(x) = \frac{1}{n} \sum_{i=1}^n I_i(x), \qquad \widehat{F}_n(y) = \frac{1}{n} \sum_{j=1}^n I_j(y)$$

*Bước 2: Phân rã Hiệp phương sai (Bilinear Property)*

* Sử dụng tính chất tuyến tính kép của hiệp phương sai:

$$\text{Cov}\left(\widehat{F}_n(x), \widehat{F}_n(y)\right) = \text{Cov}\left(\frac{1}{n}\sum_{i=1}^n I_i(x), \; \frac{1}{n}\sum_{j=1}^n I_j(y)\right) = \frac{1}{n^2} \sum_{i=1}^n \sum_{j=1}^n \text{Cov}\big(I_i(x), I_j(y)\big)$$

* Do $X_1, X_2, \dots, X_n$ độc lập cùng phân phối ($i.i.d$):
* Khi $i \neq j$: $I_i(x)$ và $I_j(y)$ độc lập $\implies \text{Cov}\big(I_i(x), I_j(y)\big) = 0$.
* Khi $i = j$: Ta chỉ còn tổng của $n$ số hạng có chỉ số giống nhau:

$$\text{Cov}\left(\widehat{F}_n(x), \widehat{F}_n(y)\right) = \frac{1}{n^2} \sum_{i=1}^n \text{Cov}\big(I_i(x), I_i(y)\big) = \frac{1}{n} \text{Cov}\big(I_1(x), I_1(y)\big)$$

*Bước 3: Tính hiệp phương sai của một cặp biến chỉ thị đơn lẻ*

* Theo định nghĩa hiệp phương sai:

$$\text{Cov}\big(I_1(x), I_1(y)\big) = \mathbb{E}\big[I_1(x) \cdot I_1(y)\big] - \mathbb{E}[I_1(x)] \cdot \mathbb{E}[I_1(y)]$$

* Tính từng thành phần:
1. $\mathbb{E}[I_1(x)] = \mathbb{P}(X_1 \le x) = F(x)$.
2. $\mathbb{E}[I_1(y)] = \mathbb{P}(X_1 \le y) = F(y)$.
3. Tích hai biến chỉ thị:

$$I_1(x) \cdot I_1(y) = \mathbb{I}(X_1 \le x \text{ và } X_1 \le y) = \mathbb{I}(X_1 \le \min(x, y))$$

Do đó:

$$\mathbb{E}\big[I_1(x) \cdot I_1(y)\big] = \mathbb{P}\big(X_1 \le \min(x, y)\big) = F\big(\min(x, y)\big)$$

* Thay vào công thức:

$$\text{Cov}\big(I_1(x), I_1(y)\big) = F\big(\min(x, y)\big) - F(x)F(y)$$

*Bước 4: Kết luận*

Với hai điểm phân biệt $x, y$:

$$\text{Cov}\left(\widehat{F}_n(x), \widehat{F}_n(y)\right) = \frac{F(\min(x, y)) - F(x)F(y)}{n}$$

> **Kiểm tra tính nhất quán (Sanity Check):**
> Nếu giả sử $x = y$, công thức cho ra $\frac{F(x) - F(x)^2}{n} = \frac{F(x)(1 - F(x))}{n} = \text{Var}\big(\widehat{F}_n(x)\big)$ (khớp hoàn toàn với phương sai của phân phối Bernoulli).

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Định lý Donsker & Quá trình Brownian Bridge**: Quá trình ngẫu nhiên chuẩn hóa $G_n(t) = \sqrt{n}\big(\widehat{F}_n(t) - F(t)\big)$ hội tụ theo luật sang quá trình Gauss $G(t)$ có kỳ vọng 0 và hàm tự hiệp phương sai:

$$K(s, t) = F(\min(s, t)) - F(s)F(t)$$

Phép đổi biến xác suất $u = F(t)$ chuyển quá trình này về đúng **Cầu Brownian** $B(u)$ trên $[0, 1]$ với $\text{Cov}(B(u), B(v)) = \min(u, v) - uv$. Đây chính là cơ sở toán học của kiểm định Kolmogorov-Smirnov dùng để phát hiện trôi dữ liệu (Data Drift).
* **Multi-threshold Monitoring (Hệ thống cảnh báo Security/Metrics)**: Khi thiết lập đồng thời nhiều ngưỡng cảnh báo $x < y$ (ví dụ: ngưỡng *Warning* $x$ và ngưỡng *Critical* $y$ cho thời gian phản hồi hoặc kích thước payload), tỷ lệ vi phạm thực nghiệm $\widehat{F}_n(x)$ và $\widehat{F}_n(y)$ luôn có tương quan dương bằng $\frac{F(x)(1 - F(y))}{n}$. Việc nắm rõ cấu trúc hiệp phương sai giúp tính toán chính xác xác suất kích hoạt báo động giả đồng thời trên cả hai ngưỡng.

---

## Bài 5. Phiếm hàm Lipschitz theo chuẩn sup & Glivenko–Cantelli

### Đề bài

Giả sử rằng

$$\vert{}T(F) - T(G)\vert{} \le C \Vert{}F - G\Vert{}_\infty \tag{$*$}$$

với một hằng số $0 < C < \infty$, trong đó $\Vert{}F - G\Vert{}_\infty = \sup_x \vert{}F(x) - G(x)\vert{}$.

**(a)** Chứng minh rằng $T(\widehat{F}_n) \xrightarrow{a.s.} T(F)$.

**(b)** Giả sử thêm rằng $\vert{}X\vert{} \le M < \infty$. Hãy chứng minh rằng $T(F) = \int x \, dF(x)$ thỏa mãn điều kiện $(*)$.

*HD: sử dụng định lý Glivenko–Cantelli.*

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Trong thống kê phi tham số, rất nhiều đại lượng ước lượng (như trung bình, phương sai, quantiles, trimmed mean) có thể biểu diễn dưới dạng một **phiếm hàm thống kê (Statistical Functional)** $T(F)$.

Bài toán này khảo sát hai ý niệm nền tảng:

1. **Tính trơn/Tính Lipschitz của phiếm hàm $T(\cdot)$ theo chuẩn supremum $\Vert{}\cdot\Vert{}_\infty$**: Nếu một phiếm hàm $T$ thỏa mãn tính chất Lipschitz đối với chuẩn sup, thì sự hội tụ đều của hàm phân phối sẽ trực tiếp kéo theo sự hội tụ mạnh (hầu chắc chắn - *almost surely*) của ước lượng dạng cắm mẫu (plug-in estimator) $T(\widehat{F}_n) \xrightarrow{a.s.} T(F)$.
2. **Cơ chế hoạt động của Định lý Glivenko-Cantelli (Định lý cơ bản của Thống kê)**: Cung cấp sự bảo đảm rằng $\widehat{F}_n$ tiến đều về $F$. Nhờ đó, ta dễ dàng chứng minh luật số lớn mạnh (SLLN) cho các đại lượng bị chặn thông qua cấu trúc giải tích của hàm tích lũy.

---

#### B. Chi tiết Toán học (The "How")

Bài toán gồm 2 phần chứng minh độc lập:

---

##### Phần 1: Chứng minh $T(\widehat{F}_n) \xrightarrow{a.s.} T(F)$

*Bước 1: Áp dụng Định lý Glivenko-Cantelli*

* Theo Định lý Glivenko-Cantelli (định lý cơ bản của thống kê thực nghiệm), khi $n \to \infty$, khoảng cách sup giữa ECDF $\widehat{F}_n$ và hàm phân phối lý thuyết $F$ hội tụ hầu chắc chắn về 0:

$$\Vert{}\widehat{F}_n - F\Vert{}_\infty = \sup_{x \in \mathbb{R}} \vert{}\widehat{F}_n(x) - F(x)\vert{} \xrightarrow{a.s.} 0$$

*Bước 2: Sử dụng điều kiện Lipschitz (*)*

* Thay $G = \widehat{F}_n$ vào điều kiện $(*)$:

$$\vert{}T(\widehat{F}_n) - T(F)\vert{} \le C \Vert{}\widehat{F}_n - F\Vert{}_\infty$$

* Vì $0 < C < \infty$ là một hằng số hữu hạn và $\Vert{}\widehat{F}_n - F\Vert{}_\infty \xrightarrow{a.s.} 0$, ta có:

$$0 \le \lim_{n \to \infty} \vert{}T(\widehat{F}_n) - T(F)\vert{} \le C \cdot \lim_{n \to \infty} \Vert{}\widehat{F}_n - F\Vert{}_\infty = C \cdot 0 = 0 \quad (\text{hầu chắc chắn})$$

* Suy ra:

$$T(\widehat{F}_n) \xrightarrow{a.s.} T(F)$$

---

##### Phần 2: Chứng minh $T(F) = \int x \, dF(x)$ thỏa mãn điều kiện (*) khi $\vert{}X\vert{} \le M < \infty$

Giả thiết $\vert{}X\vert{} \le M < \infty$ đồng nghĩa với việc phân phối xác suất của $X$ được nâng đỡ hoàn toàn trên đoạn $[-M, M]$.
Do đó:

* $F(x) = 0$ với mọi $x < -M$
* $F(x) = 1$ với mọi $x \ge M$
*(Tương tự với phân phối $G$ bất kỳ cũng được hỗ trợ trên $[-M, M]$)*

*Bước 1: Tích phân từng phần (Integration by Parts)*

* Xét tích phân Riemann-Stieltjes của kỳ vọng:

$$T(F) = \int_{-M}^M x \, dF(x)$$

* Áp dụng công thức tích phân từng phần: $\int u\, dv = uv - \int v\, du$:

$$T(F) = \Big[ x F(x) \Big]_{-M}^{M} - \int_{-M}^M F(x) \, dx$$

* Thay cận tại $M$ và $-M$:

$$\Big[ x F(x) \Big]_{-M}^{M} = M \cdot F(M) - (-M) \cdot F(-M) = M \cdot 1 - (-M) \cdot 0 = M$$

* Do đó, ta biểu diễn được phiếm hàm kỳ vọng thuần túy qua diện tích dưới hàm $F$:

$$T(F) = M - \int_{-M}^M F(x) \, dx$$

*Bước 2: Thiết lập đánh giá sai phân $\vert{}T(F) - T(G)\vert{}$*

* Tương tự với phân phối $G$:

$$T(G) = M - \int_{-M}^M G(x) \, dx$$

* Lấy hiệu hai phiếm hàm:

$$T(F) - T(G) = \left( M - \int_{-M}^M F(x) \, dx \right) - \left( M - \int_{-M}^M G(x) \, dx \right) = \int_{-M}^M \big(G(x) - F(x)\big) \, dx$$

*Bước 3: Lấy trị tuyệt đối và đánh giá chặn trên*

* Dùng bất đẳng thức tích phân:

$$\vert{}T(F) - T(G)\vert{} = \left\vert{} \int_{-M}^M \big(F(x) - G(x)\big) \, dx \right\vert{} \le \int_{-M}^M \vert{}F(x) - G(x)\vert{} \, dx$$

* Với mọi $x \in [-M, M]$, theo định nghĩa của chuẩn sup:

$$\vert{}F(x) - G(x)\vert{} \le \sup_{t \in \mathbb{R}} \vert{}F(t) - G(t)\vert{} = \Vert{}F - G\Vert{}_\infty$$

* Do đó:

$$\vert{}T(F) - T(G)\vert{} \le \int_{-M}^M \Vert{}F - G\Vert{}_\infty \, dx = \Vert{}F - G\Vert{}_\infty \int_{-M}^M 1 \, dx = 2M \Vert{}F - G\Vert{}_\infty$$

*Bước 4: Kết luận*

* Chọn hằng số $C = 2M < \infty$, ta có:

$$\vert{}T(F) - T(G)\vert{} \le C \Vert{}F - G\Vert{}_\infty$$

* Vậy phiếm hàm $T(F) = \int x \, dF(x)$ thỏa mãn trọn vẹn điều kiện $(*)$.

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Robust Statistics & Influence Functions (Thống kê Vững)**: Tính chất Lipschitz đối với chuẩn $\Vert{}\cdot\Vert{}_\infty$ liên quan mật thiết đến tính ổn định của ước lượng thống kê trước nhiễu hoặc dữ liệu dị biệt (outliers/data poisoning). Nếu một thống kê $T(F)$ có tính Lipschitz theo $\Vert{}\cdot\Vert{}_\infty$, giá trị ước lượng sẽ không bị bùng nổ khi dữ liệu bị chèn một tỷ lệ phần trăm nhỏ các bản ghi tấn công độc hại.
* **Bounded Reward in Reinforcement Learning & Security**: Trong các bài toán học tăng cường (RL) hoặc tính toán tổn thất rủi ro gian lận tài chính mà Reward/Loss bị chặn trong khoảng $[-M, M]$, việc xấp xỉ hàm phân phối xác suất môi trường $F$ bằng mô hình thực nghiệm $\widehat{F}_n$ đảm bảo giá trị kỳ vọng tích lũy hội tụ đều hầu chắc chắn với tốc độ co được kiểm soát bởi $2M$.

---

## Bài 6. Tính và phác họa ECDF

### Đề bài

**Tính hàm phân phối thực nghiệm (ECDF):**

**(a)** Với mẫu số liệu $\{2.3,\ 1.7,\ 4.1,\ 3.5,\ 2.3,\ 5.0\}$, hãy tính và phác họa hàm phân phối thực nghiệm (ECDF).

**(b)** Tính giá trị của ECDF tại $x = 3.0$ và $x = 4.5$.

**(c)** Xác định trung vị mẫu và phân vị thứ 75% dựa vào ECDF.

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Hàm phân phối thực nghiệm (ECDF - Empirical Cumulative Distribution Function) $\widehat{F}_n(x)$ là hàm từng đoạn dạng bậc thang (step function) gán trọng số đều $\frac{1}{n}$ cho mỗi quan sát trong mẫu.

* ECDF là ước lượng phi tham số (nonparametric) cho phân phối tích lũy lý thuyết $F(x)$ mà không đòi hỏi bất kỳ giả định nào về dạng hàm phân phối (không cần giả định chuẩn, đều, mũ...).
* Các thống kê thứ tự (order statistics) và phân vị mẫu (quantiles/median) được định nghĩa trực tiếp từ hàm ngược suy rộng của ECDF: $\widehat{F}_n^{-1}(p) = \inf \{x : \widehat{F}_n(x) \ge p\}$.

---

#### B. Chi tiết Toán học (The "How")

Cho mẫu số liệu $n = 6$: $\{2.3, 1.7, 4.1, 3.5, 2.3, 5.0\}$.

*Sắp xếp mẫu theo thứ tự tăng dần (Order Statistics):*

$$X_{(1)} = 1.7, \quad X_{(2)} = 2.3, \quad X_{(3)} = 2.3, \quad X_{(4)} = 3.5, \quad X_{(5)} = 4.1, \quad X_{(6)} = 5.0$$

---

*(a) Tính và phác họa hàm phân phối thực nghiệm $\widehat{F}_n(x)$*

Công thức định nghĩa:

$$\widehat{F}_n(x) = \frac{1}{n} \sum_{i=1}^n \mathbb{I}(X_i \le x) = \frac{\text{Số quan sát } \le x}{6}$$

Xác định giá trị tại từng khoảng:

* Nếu $x < 1.7$: không có điểm nào $\implies \widehat{F}_n(x) = 0$.
* Nếu $1.7 \le x < 2.3$: có 1 điểm ($1.7$) $\implies \widehat{F}_n(x) = \frac{1}{6} \approx 0.1667$.
* Nếu $2.3 \le x < 3.5$: có 3 điểm ($1.7, 2.3, 2.3$) do $2.3$ lặp lại 2 lần $\implies$ bước nhảy có độ cao $\frac{2}{6}$, $\widehat{F}_n(x) = \frac{3}{6} = 0.5$.
* Nếu $3.5 \le x < 4.1$: có 4 điểm ($1.7, 2.3, 2.3, 3.5$) $\implies \widehat{F}_n(x) = \frac{4}{6} = \frac{2}{3} \approx 0.6667$.
* Nếu $4.1 \le x < 5.0$: có 5 điểm $\implies \widehat{F}_n(x) = \frac{5}{6} \approx 0.8333$.
* Nếu $x \ge 5.0$: cả 6 điểm đều $\le x$ $\implies \widehat{F}_n(x) = \frac{6}{6} = 1.0$.

Tổng hợp biểu thức của $\widehat{F}_n(x)$:

$$\widehat{F}_n(x) = \begin{cases}  0, & x < 1.7 \\  \frac{1}{6}, & 1.7 \le x < 2.3 \\  \frac{1}{2}, & 2.3 \le x < 3.5 \\  \frac{2}{3}, & 3.5 \le x < 4.1 \\  \frac{5}{6}, & 4.1 \le x < 5.0 \\  1, & x \ge 5.0  \end{cases}$$

*Phác họa đồ thị bậc thang:*

```text
  F_hat(x)
    1.0 |                                         ●======
    5/6 |                                 ●------○
    4/6 |                         ●------○
    3/6 |                 ●------○
    1/6 |         ●------○
      0 +---------○
        +---------+-------+-------+-------+-------+------> x
                 1.7     2.3     3.5     4.1     5.0

```

*(Dấu $\bullet$ biểu thị điểm đóng thuộc khoảng tại mút trái, dấu $\circ$ biểu thị điểm mở tại mút phải do tính liên tục phải của CDF)*.

---

*(b) Tính giá trị của ECDF tại $x = 3.0$ và $x = 4.5$*

* **Tại $x = 3.0$:**
Vì $2.3 \le 3.0 < 3.5$, các phần tử trong mẫu thỏa mãn $X_i \le 3.0$ gồm $\{1.7, 2.3, 2.3\}$ (3 phần tử).

$$\widehat{F}_n(3.0) = \frac{3}{6} = 0.5$$

* **Tại $x = 4.5$:**
Vì $4.1 \le 4.5 < 5.0$, các phần tử thỏa mãn $X_i \le 4.5$ gồm $\{1.7, 2.3, 2.3, 3.5, 4.1\}$ (5 phần tử).

$$\widehat{F}_n(4.5) = \frac{5}{6} \approx 0.8333$$

---

*(c) Xác định Trung vị mẫu (Sample Median) và Phân vị thứ 75% (75th Percentile)*

Theo định nghĩa phân vị phi tham số chuẩn tắc $\widehat{q}(p) = \widehat{F}_n^{-1}(p) = \inf \{x : \widehat{F}_n(x) \ge p\}$:

* **Trung vị mẫu ($p = 0.5$):**
Ta tìm giá trị $x$ nhỏ nhất sao cho $\widehat{F}_n(x) \ge 0.5$.
Nhìn vào bảng giá trị: $\widehat{F}_n(x) = 0.5$ bắt đầu đạt được chính xác tại $x = 2.3$.

$$\text{Sample Median} = 2.3$$

*(Nếu áp dụng định nghĩa nội suy trung bình hai điểm giữa cho $n=6$ chẵn: $\frac{X_{(3)} + X_{(4)}}{2} = \frac{2.3 + 3.5}{2} = 2.9$. Tuy nhiên, theo định nghĩa trực tiếp từ ECDF Step Function, trung vị chuẩn là $2.3$)*.
* **Phân vị thứ 75% ($p = 0.75$):**
Ta tìm $x$ nhỏ nhất sao cho $\widehat{F}_n(x) \ge 0.75$.
* Tại khoảng $[3.5, 4.1)$, $\widehat{F}_n(x) = \frac{4}{6} \approx 0.6667 < 0.75$.
* Tại điểm $x = 4.1$, hàm nhảy lên $\widehat{F}_n(4.1) = \frac{5}{6} \approx 0.8333 \ge 0.75$.

$$\text{75th Percentile } (\widehat{q}_{0.75}) = 4.1$$

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **SLA & Latency Percentile Monitoring (DevOps / Network Security)**: Khi đo đạc độ trễ API (response time), ECDF được xây dựng trực tiếp trên các log request streaming. Các ngưỡng P50 (median) và P75 (hoặc P99) suy ra trực tiếp từ ECDF mà không cần giả định phân phối log-normal, giúp hệ thống phát hiện chính xác tình trạng suy thoái hiệu năng hệ thống.

---

## Bài 7. Kiểm định phù hợp Kolmogorov–Smirnov

### Đề bài

**Kiểm định sự phù hợp (Goodness-of-Fit Test):**

**(a)** Sử dụng mẫu dữ liệu ở Bài 5, hãy kiểm định giả thuyết rằng dữ liệu tuân theo phân phối đều trên khoảng $[1, 5]$ bằng kiểm định Kolmogorov–Smirnov (K–S test).

**(b)** Tính thống kê kiểm định K–S và xấp xỉ giá trị p-value bằng phân phối tiệm cận.

**(c)** Diễn giải kết quả kiểm định ở mức ý nghĩa 5%.

> *Lưu ý:* đề ghi "mẫu dữ liệu ở Bài 5", nhưng mẫu số liệu $\{2.3, 1.7, 4.1, 3.5, 2.3, 5.0\}$ thực chất nằm ở **Bài 6**. Lời giải dưới đây dùng mẫu đó.

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Kiểm định Kolmogorov-Smirnov (K-S test) là một trong những phương pháp kiểm định độ phù hợp (Goodness-of-Fit) phi tham số kinh điển nhất.

* **Bản chất**: Thay vì nhóm dữ liệu thành các khoảng rời rạc (bins) như kiểm định Chi-bình phương ($\chi^2$), K-S test so sánh trực tiếp khoảng cách lớn nhất (chuẩn supremum $\Vert{}\cdot\Vert{}_\infty$) giữa hàm phân phối thực nghiệm $\widehat{F}_n(x)$ và hàm phân phối lý thuyết $F_0(x)$.
* **Ưu điểm**: Phù hợp với các biến ngẫu nhiên liên tục, bảo toàn toàn bộ thông tin của từng điểm dữ liệu riêng lẻ và độc lập với phân phối lý thuyết được kiểm định (distribution-free under $H_0$).

---

#### B. Chi tiết Toán học (The "How")

Cho mẫu số liệu $n = 6$ (sắp xếp tăng dần):

$$X_{(1)} = 1.7, \quad X_{(2)} = 2.3, \quad X_{(3)} = 2.3, \quad X_{(4)} = 3.5, \quad X_{(5)} = 4.1, \quad X_{(6)} = 5.0$$

---

*(a) Thiết lập bài toán kiểm định*

* **Giả thuyết**:
* $H_0$: Dữ liệu tuân theo phân phối đều trên khoảng $[1, 5]$, tức $X \sim U[1, 5]$.
* $H_1$: Dữ liệu không tuân theo phân phối đều trên $[1, 5]$.

* **Hàm phân phối tích lũy lý thuyết dưới $H_0$**:

$$F_0(x) = \begin{cases}    0, & x < 1 \\    \frac{x - 1}{5 - 1} = \frac{x - 1}{4}, & 1 \le x \le 5 \\    1, & x > 5    \end{cases}$$

---

*(b) Tính thống kê kiểm định $D_n$ và xấp xỉ p-value*

*Bước 1: Tính các độ lệch tại từng điểm quan sát*
Thống kê K-S hai phía được định nghĩa bởi:

$$D_n = \sup_{x} \vert{}\widehat{F}_n(x) - F_0(x)\vert{} = \max_{1 \le i \le n} \left\{ \max\left( \left\vert{}\frac{i}{n} - F_0(X_{(i)})\right\vert{}, \; \left\vert{}F_0(X_{(i)}) - \frac{i-1}{n}\right\vert{} \right) \right\} = \max(D_n^+, D_n^-)$$

trong đó:

$$D_n^+ = \max_{1 \le i \le n} \left(\frac{i}{n} - F_0(X_{(i)})\right), \qquad D_n^- = \max_{1 \le i \le n} \left(F_0(X_{(i)}) - \frac{i-1}{n}\right)$$

Bảng tính chi tiết với $n = 6$ (lưu ý $\frac{1}{6} \approx 0.1667$):

| $i$ | $X_{(i)}$ | $\frac{i-1}{6}$ | $F_0(X_{(i)}) = \frac{X_{(i)}-1}{4}$ | $\frac{i}{6}$ | $D_i^+ = \frac{i}{6} - F_0(X_{(i)})$ | $D_i^- = F_0(X_{(i)}) - \frac{i-1}{6}$ |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 1.7 | $0.0000$ | $\frac{0.7}{4} = 0.1750$ | $0.1667$ | $-0.0083$ | **$0.1750$** |
| 2 | 2.3 | $0.1667$ | $\frac{1.3}{4} = 0.3250$ | $0.3333$ | $0.0083$ | $0.1583$ |
| 3 | 2.3 | $0.3333$ | $\frac{1.3}{4} = 0.3250$ | $0.5000$ | **$0.1750$** | $-0.0083$ |
| 4 | 3.5 | $0.5000$ | $\frac{2.5}{4} = 0.6250$ | $0.6667$ | $0.0417$ | $0.1250$ |
| 5 | 4.1 | $0.6667$ | $\frac{3.1}{4} = 0.7750$ | $0.8333$ | $0.0583$ | $0.1083$ |
| 6 | 5.0 | $0.8333$ | $\frac{4.0}{4} = 1.0000$ | $1.0000$ | $0.0000$ | $0.1667$ |

*Bước 2: Xác định giá trị thống kê $D_6$*

* $D_6^+ = \max_i \{D_i^+\} = 0.1750$
* $D_6^- = \max_i \{D_i^-\} = 0.1750$

$$\implies D_6 = \max(D_6^+, D_6^-) = 0.1750$$

*Bước 3: Xấp xỉ phân phối tiệm cận và p-value*

* Theo định lý Kolmogorov, khi $H_0$ đúng:

$$\sqrt{n} D_n \xrightarrow{d} K \quad \text{với } \mathbb{P}(K > z) = 2 \sum_{k=1}^{\infty} (-1)^{k-1} e^{-2 k^2 z^2}$$

* Giá trị chuẩn hóa quan sát:

$$z = \sqrt{n} D_n = \sqrt{6} \times 0.1750 \approx 2.4495 \times 0.1750 \approx 0.4287$$

* Vì $z \approx 0.4287$ rất nhỏ (độ lệch giữa thực nghiệm và lý thuyết không đáng kể), giá trị $p\text{-value}$ tiệm cận xấp xỉ gần bằng $1$ ($p\text{-value} \approx 0.99$).

* **Kiểm chứng bằng máy** (`scipy.stats.kstest(x, 'uniform', args=(1,4))`):

```text
D_n = 0.17500        (khớp đúng giá trị tính tay)
p-value (chính xác, cỡ mẫu nhỏ) = 0.9756
z = sqrt(6) * D_n = 0.42866
p-value (tiệm cận Kolmogorov)   = 0.9929
```

Xấp xỉ tiệm cận cho $0.9929$ so với giá trị chính xác $0.9756$ — với $n = 6$ sai lệch này là bình thường (xấp xỉ tiệm cận chỉ tốt khi $n$ lớn, thường khuyến nghị $n \ge 30$), nhưng cả hai đều dẫn tới cùng một kết luận.

---

*(c) Diễn giải kết quả ở mức ý nghĩa $\alpha = 0.05$*

* **Giá trị tới hạn tiệm cận (Asymptotic Critical Value)**:

$$c_{0.05} = \frac{\sqrt{-\frac{1}{2} \ln(\alpha/2)}}{\sqrt{n}} \approx \frac{1.36}{\sqrt{6}} \approx 0.5552$$

*(Hoặc tra bảng phân phối chính xác cho cỡ mẫu nhỏ $n = 6$: $D_{6; \, 0.05} \approx 0.5193$)*.
* **Quy tắc quyết định**:

$$D_6 = 0.1750 < 0.5193 \quad (\text{hoặc } p\text{-value} \gg 0.05)$$

* **Kết luận**: Chưa có đủ bằng chứng thống kê để bác bỏ giả thuyết $H_0$. Mẫu dữ liệu trên hoàn toàn phù hợp với phân phối đều $U[1, 5]$ ở mức ý nghĩa 5%.

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Pseudorandom Number Generator (PRNG) Testing (Cryptography & Security)**: Trong các hệ thống bảo mật sinh khóa mật mã hoặc session tokens, kiểm định K-S trên phân phối đều $U[0, 1]$ (sau khi chuẩn hóa) là bài kiểm tra tiêu chuẩn (NIST SP 800-22) để xác định xem bộ sinh số ngẫu nhiên có bị lệch (bias) hay không.
* **Continuous Feature Drift Detection (MLOps / Data Drift)**: K-S test là thuật toán lõi được sử dụng trong các hệ thống giám sát pipeline ML (như Evidently AI, Great Expectations) để tự động phát hiện độ lệch phân phối giữa tập Train và tập Serving thời gian thực cho các biến liên tục.

---

## Bài 8. Hàm phân phối thực nghiệm có trọng số (Weighted ECDF)

### Đề bài

**Hàm phân phối thực nghiệm có trọng số (Weighted ECDF):** Xét một phiên bản có trọng số của ECDF:

$$\widehat{F}_n^w(x) = \sum_{i=1}^n w_i \, \mathbb{I}(X_i \le x),$$

trong đó $w_i \ge 0$ và $\sum_{i=1}^n w_i = 1$.

**(a)** Hãy tìm độ chệch và phương sai của ước lượng có trọng số này.

**(b)** Với những điều kiện nào trên các trọng số thì ước lượng này là ước lượng vững?

### Lời giải

#### A. Motivation & Ý nghĩa (The "Why")

Trong thống kê và phân tích dữ liệu thực tế, các quan sát không phải lúc nào cũng có vai trò và độ tin cậy ngang nhau:

* **Importance Sampling / Survey Sampling**: Các mẫu thu thập từ phân tầng không đồng đều (stratified sampling) cần gán trọng số nghịch đảo xác suất chọn mẫu (inverse propensity weights) để hiệu chỉnh sai số chọn mẫu (selection bias).
* **Exponential Smoothing trong Time Series**: Các dữ liệu log bảo mật/hệ thống gần nhất thường chứa nhiều thông tin cập nhật hơn dữ liệu quá khứ, nên cần gán trọng số giảm dần theo thời gian.

**Weighted ECDF ($\widehat{F}_n^w$)** mở rộng ECDF truyền thống bằng cách thay trọng số đồng đều $\frac{1}{n}$ bằng bộ trọng số linh hoạt $w_i \ge 0$ (với $\sum_{i=1}^n w_i = 1$).

---

#### B. Chi tiết Toán học (The "How")

Giả thiết: Mẫu ngẫu nhiên $X_1, X_2, \dots, X_n \overset{i.i.d}{\sim} F(x)$.
Đặt biến chỉ thị $I_i(x) = \mathbb{I}(X_i \le x) \sim \text{Bernoulli}(F(x))$, suy ra:

$$\mathbb{E}[I_i(x)] = F(x), \qquad \text{Var}(I_i(x)) = F(x)(1 - F(x))$$

Các biến $I_1(x), \dots, I_n(x)$ độc lập với nhau.

---

*(a) Tìm độ chệch (Bias) và phương sai (Variance)*

* **1. Kỳ vọng và Độ chệch:**

$$\mathbb{E}\left[\widehat{F}_n^w(x)\right] = \mathbb{E}\left[ \sum_{i=1}^n w_i I_i(x) \right] = \sum_{i=1}^n w_i \mathbb{E}[I_i(x)]$$

Vì $\mathbb{E}[I_i(x)] = F(x)$ với mọi $i$:

$$\mathbb{E}\left[\widehat{F}_n^w(x)\right] = F(x) \sum_{i=1}^n w_i = F(x) \cdot 1 = F(x)$$

Do đó, **độ chệch** là:

$$\text{Bias}\left(\widehat{F}_n^w(x)\right) = \mathbb{E}\left[\widehat{F}_n^w(x)\right] - F(x) = F(x) - F(x) = 0$$

*(Ước lượng luôn không chệch - Unbiased với mọi bộ trọng số thỏa mãn $\sum w_i = 1$)*.
* **2. Phương sai:**
Do các $X_i$ độc lập, các biến chỉ thị $I_i(x)$ cũng độc lập:

$$\text{Var}\left(\widehat{F}_n^w(x)\right) = \text{Var}\left( \sum_{i=1}^n w_i I_i(x) \right) = \sum_{i=1}^n w_i^2 \text{Var}(I_i(x))$$

Thay $\text{Var}(I_i(x)) = F(x)(1 - F(x))$ ra ngoài làm nhân tử chung:

$$\text{Var}\left(\widehat{F}_n^w(x)\right) = F(x)(1 - F(x)) \sum_{i=1}^n w_i^2$$

---

*(b) Điều kiện trên các trọng số để ước lượng là ước lượng vững (Consistency)*

Ước lượng $\widehat{F}_n^w(x)$ là ước lượng vững cho $F(x)$ nếu $\widehat{F}_n^w(x) \xrightarrow{P} F(x)$ khi $n \to \infty$.

* **Đánh giá qua Sai số toàn phương trung bình (MSE):**
Vì ước lượng không chệch ($\text{Bias} = 0$), ta có:

$$\text{MSE}\left(\widehat{F}_n^w(x)\right) = \text{Var}\left(\widehat{F}_n^w(x)\right) = F(x)(1 - F(x)) \sum_{i=1}^n w_i^2$$

* **Áp dụng Bất đẳng thức Chebyshev:**
Với mọi $\varepsilon > 0$:

$$\mathbb{P}\left(\left\vert{}\widehat{F}_n^w(x) - F(x)\right\vert{} \ge \varepsilon\right) \le \frac{\text{Var}\left(\widehat{F}_n^w(x)\right)}{\varepsilon^2} = \frac{F(x)(1 - F(x))}{\varepsilon^2} \sum_{i=1}^n w_i^2$$

* **Điều kiện cần và đủ:**
Để vế phải tiến về $0$ với mọi phân phối $F$ khi $n \to \infty$, điều kiện bắt buộc là:

$$\lim_{n \to \infty} \sum_{i=1}^n w_i^2 = 0$$

* **Ý nghĩa trực giác & Điều kiện tương đương:**
Ta luôn có đánh giá kẹp giữa chuẩn $\Vert{}\cdot\Vert{}_2^2$ và chuẩn $\Vert{}\cdot\Vert{}_\infty$:

$$\max_{1 \le i \le n} w_i^2 \le \sum_{i=1}^n w_i^2 \le \left(\max_{1 \le i \le n} w_i\right) \sum_{i=1}^n w_i = \max_{1 \le i \le n} w_i$$

Do đó, điều kiện $\sum_{i=1}^n w_i^2 \to 0$ tương đương với:

$$\lim_{n \to \infty} \max_{1 \le i \le n} w_i = 0$$

*(Nghĩa là khi số mẫu $n$ tăng vô hạn, không có bất kỳ quan sát đơn lẻ nào được phép thống trị hoặc giữ tỷ trọng trọng số hữu hạn không đổi)*.

---

#### C. Ví dụ Thực tế & Đa ngành (The "Where")

* **Online Fraud Detection & Concept Drift (Security / Streaming)**: Trong các hệ thống giám sát gian lận hoặc anomaly detection theo thời gian thực, người ta thường dùng **Decaying Weights** $w_i \propto \lambda^{n-i}$ với hệ số suy giảm $0 < \lambda < 1$.
* Khi cố định $\lambda < 1$, $\sum_{i=1}^n w_i^2 \not\to 0$, ước lượng không hội tụ (non-consistent) nhưng lại thích nghi nhanh với drift (tracking ability).
* Để vừa có tính vững vừa thích nghi, hệ số suy giảm phải phụ thuộc vào kích thước mẫu $\lambda_n \to 1$ với tốc độ đảm bảo $\sum w_i^2 \to 0$.

* **Covariate Shift / Propensity Score Weighting (Machine Learning)**: Khi phân phối đầu vào giữa tập huấn luyện và môi trường thực tế bị lệch $P_{\text{test}}(x) \neq P_{\text{train}}(x)$, ta dùng trọng số $w_i = \frac{P_{\text{test}}(X_i)}{P_{\text{train}}(X_i)}$ để tái cân bằng phân phối thực nghiệm. Điều kiện $\sum w_i^2 \to 0$ đảm bảo mô hình ước lượng phân phối mục tiêu hội tụ vững chắc.

---
