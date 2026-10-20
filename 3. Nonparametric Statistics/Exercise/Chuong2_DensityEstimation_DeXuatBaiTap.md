# Chương 2 — Density Estimation: đề xuất bài tập

**Nguồn:** `Slides/Chap2_Density_estimation (handout).pdf` (37 slides, Hoàng Văn Hà)
**Tham chiếu:** [W] = Wasserman, *All of Nonparametric Statistics*, Ch. 6 · [T] = Tsybakov,
*Introduction to Nonparametric Estimation*, Ch. 1

> Danh sách các bài tập có thể làm, bám sát nội dung slide. Số trong ngoặc là slide tương ứng.
> Bộ đề nghị làm trước: **2, 4, 5, 7, 9, 10, 11, 12, 13, 17, 19, 22** — phủ hết các định lý
> trên slide cộng một bài kiểm chứng bằng mô phỏng.

---

## A. Risk & bias–variance (slides 6–11)

**A1. Phân rã rủi ro.** (sl. 7) Chứng minh $\mathrm{MSE}(\hat f_n(x)) = b^2(x) + \sigma^2(x)$,
rồi $\mathrm{MISE} = \int b^2 + \int \mathrm{Var}$, có biện luận việc đổi thứ tự
tích phân – kỳ vọng (Fubini). *(khởi động)*

**A2. Bổ đề đánh đổi tổng quát.** (sl. 8, 10) Cực tiểu hoá
$g(\lambda) = C_1\lambda^{2\beta} + C_2/(n\lambda)$ và chỉ ra
$\lambda^* \propto n^{-1/(2\beta+1)}$, $g(\lambda^*) \propto n^{-2\beta/(2\beta+1)}$.
Một phép tính này sau đó *đặc biệt hoá* cho histogram ($\beta = 1$, $n^{-2/3}$),
KDE ($\beta = 2$, $n^{-4/5}$) và projection — slide 15, 26, 32 đều dùng lại nó.

**A3. Vì sao CV hoạt động.** (sl. 11) Chứng minh $\hat J(h)$ là ước lượng không chệch của
$J(h) = \mathbb{E}L(h) - \int f^2$, tức là $\frac1n\sum_i \hat f^{(-i)}_n(X_i)$
không chệch cho $\mathbb{E}\int \hat f_n f$.

---

## B. Histogram (slides 12–18)

**B4. Khai triển độ chệch.** (sl. 13) Suy ra
$\mathbb{E}\hat f_n(x) - f(x) = f'(x)\big(h(j-\tfrac12) - x\big) + O(h^2)$
và tích phân ra $\frac{h^2}{12}\int_0^1 (f')^2$. Chỉ rõ hằng số $1/12$ đến từ
$\int_0^1 (u - \tfrac12)^2\,du$.

**B5. Phương sai tích phân chính xác.** (sl. 14) Chứng minh
$$\int_0^1 \mathrm{Var}(\hat f_n(x))\,dx = \frac{1}{nh}\Big(1 - \sum_j p_j^2\Big)
= \frac{1}{nh} - \frac1n\int f^2 + o(1/n),$$
tức $1/(nh)$ trên slide chỉ là số hạng chính.

**B6. Tính $h^*$ cụ thể.** (sl. 15) Tính $h^*$ và $\mathrm{MISE}(h^*)$ cho
(a) $f = \mathbf 1_{[0,1]}$ — chú ý $\int (f')^2 = 0$, công thức suy biến, giải thích vì sao;
(b) $f(x) = 2x$ trên $[0,1]$; (c) Beta(2,2). Sau đó so sánh số học với tốc độ $n^{-1/3}$.

**B7. Suy ra công thức CV.** (sl. 17) Từ định nghĩa leave-one-out, dẫn ra
$$\hat J(h) = \frac{2}{(n-1)h} - \frac{n+1}{(n-1)h}\sum_{j=1}^m \hat p_j^2 .$$
Slide chỉ phát biểu, không chứng minh — đây là bài tập kinh điển của [W].

**B8. Độ nhạy với gốc chia bin.** (sl. 18, hạn chế 2) Mô phỏng $n = 200$ từ hỗn hợp hai đỉnh,
dịch gốc lưới chạy trên $[0, h)$ và chỉ ra số mode ước lượng thay đổi. Đây là động lực dẫn
tới averaged-shifted histogram / KDE.

---

## C. Kernel density estimation (slides 19–29)

**C9. Danh mục nhân.** (sl. 20) Với uniform, triangular, Epanechnikov, Gaussian: kiểm tra
ba điều kiện của nhân, tính $\sigma_K^2$ và $R(K) = \int K^2$, xếp hạng theo phiếm hàm hiệu quả
$R(K)\sigma_K^{1/2}$, và chứng minh Epanechnikov cực tiểu hoá nó (bài toán biến phân với ràng buộc
$\int K = 1$, $\int u^2 K = \sigma_K^2$).

**C10. Bias & variance từ đầu.** (sl. 21) Suy ra $\frac12\sigma_K^2 h^2 f''(x) + O(h^4)$ và
$f(x)R(K)/(nh) + O(1/n)$ bằng đổi biến + khai triển Taylor.

**C11. Hằng số AMISE.** (sl. 26) Chứng minh
$h^* = \big(R(K)/(\sigma_K^4\int (f'')^2)\big)^{1/5} n^{-1/5}$ và
$$\mathrm{MISE}(h^*) = \tfrac54\big(\sigma_K R(K)\big)^{4/5}\Big(\int (f'')^2\Big)^{1/5} n^{-4/5}.$$
Hằng số này không có trên slide.

**C12. Dẫn ra hằng số 1.06 của Silverman.** (sl. 27) Thay $f = \mathcal N(0,\sigma^2)$ vào
$\int (f'')^2 = \frac{3}{8\sqrt\pi\,\sigma^5}$ với nhân Gaussian ($\sigma_K^2 = 1$,
$R(K) = 1/(2\sqrt\pi)$) để thu được $1.06\,\hat\sigma n^{-1/5}$. Sau đó mô phỏng cho thấy quy tắc này
*làm trơn quá mức* với mật độ hai đỉnh — lý do tồn tại của $\hat\sigma = \min(s, Q/1.34)$.

**C13. Độ chệch ở biên.** (sl. 35, dòng "boundary effects") Với $f$ có giá $[0,\infty)$, chứng minh
$\mathbb{E}\hat f_n(0) \to f(0)/2$: một nửa khối lượng nhân rơi ra ngoài giá, nên độ chệch tại biên là
$O(h)$ chứ không phải $O(h^2)$. Đề xuất và kiểm thử hiệu chỉnh phản xạ (reflection) hoặc boundary kernel.

**C14. Nhân bậc cao.** (sl. 22) Xây nhân bậc 3 từ Gaussian, ví dụ $K(u) = \tfrac12(3 - u^2)\varphi(u)$;
kiểm tra $\int u^j K = 0$, $j = 1,2,3$; chỉ ra độ chệch thành $O(h^4)$ và tốc độ $n^{-8/9}$;
rồi chỉ ra $\hat f_n$ có thể âm — cái giá phải trả cho tốc độ nhanh hơn.

**C15. Cross-validation cho KDE, có cài đặt.** (sl. 27) Dẫn ra công thức tổng đôi $\hat J(h)$,
lưu ý với nhân Gaussian thì $K^{(2)} = \varphi_{\sqrt2}$, rồi cài đặt. So sánh $\hat h_{CV}$ với
Silverman trên các mật độ một đỉnh / hai đỉnh / lệch.

**C16. Prop. 1.1–1.2 của Tsybakov.** (sl. 23–24) Điền đầy đủ mọi bước của hai proof sketch.
Câu hỏi tiếp theo (không có trên slide): nếu chọn $h \propto n^{-1/(2\tilde\beta+1)}$ với
$\tilde\beta$ **sai**, tốc độ thực sự thu được là gì? Phân tích mất mát theo cả hai chiều
$\tilde\beta < \beta$ và $\tilde\beta > \beta$.

**C17. Khoảng tin cậy điểm.** (sl. 28) Dùng CLT để dựng khoảng tin cậy $100(1-\alpha)\%$ cho
$f(x_0)$; giải thích vì sao khoảng **không** được canh tâm đúng khi $nh^5 \to \lambda > 0$,
và vì sao undersmoothing ($nh^5 \to 0$) là cách khắc phục thông thường.
Đây là phần tiếp nối trực tiếp của bài ECDF + Delta-method ở Chương 1.

---

## D. Projection estimator (slides 30–34)

**D18. Không chệch và phương sai.** (sl. 30, 32) Chứng minh $\hat a_j$ không chệch với
$\mathrm{Var}(\hat a_j) = \frac1n\big(\int \phi_j^2 f - a_j^2\big)$, rồi suy ra
$\mathbb{E}\|\hat f_D - f\|^2 = \sum_{j>D} a_j^2 + \frac1n\sum_{j\le D}(\cdot)$
và chặn trên $\varphi_0 D/n$.

**D19. Làm chặt Remark 2.** (sl. 31) Chứng minh rằng với $\phi_j = \sqrt D\,\mathbf 1_{B_j}$ thì
projection estimator **trùng khớp** với histogram $m = D$ bin.

**D20. Cơ sở lượng giác + lớp Sobolev.** (sl. 32) Với $f$ trong ellipsoid Sobolev, chứng minh
$\sum_{j>D} a_j^2 \le L^2 D^{-2\beta}$, từ đó $D^* \asymp n^{1/(2\beta+1)}$ và tốc độ minimax.

**D21. Cài đặt tiêu chuẩn phạt.** (sl. 33) Cài
$\hat D = \arg\min_D\{-\|\hat f_D\|^2 + \kappa\varphi_0 D/n\}$ và khảo sát độ nhạy theo $\kappa$ —
cho thấy hằng số $C$ trong oracle inequality (sl. 34) thực sự có vai trò.

---

## E. Lab mô phỏng (gộp mọi thứ lại)

**E22. Kiểm chứng tốc độ hội tụ bằng thực nghiệm.** Lấy mẫu từ một mật độ Marron–Wand,
tính MISE Monte-Carlo trên lưới $h$ với $n = 10^2, 10^3, 10^4$, rồi kiểm tra độ dốc trên đồ thị
log-log: $-4/5$ cho KDE so với $-2/3$ cho histogram.
*Bài tập đơn lẻ tốt nhất — kiểm chứng đồng thời slide 15, 16, 26.*

**E23. Lời nguyền số chiều.** (sl. 18, hạn chế 4) Với tốc độ $n^{-4/(4+d)}$, tính cỡ mẫu cần thiết
để đạt cùng MISE như trường hợp $d = 1$, $n = 100$, với $d = 2,\dots,10$.

**E24. Dữ liệu thật.** Old Faithful (hoặc một cột biểu hiện gene): histogram vs KDE vs projection,
ba bộ chọn bandwidth, và thảo luận xem đỉnh thứ hai có thật hay không.

---

## Ghi chú triển khai

- Bản `.tex` (nếu viết lời giải đầy đủ) theo template HMMT: `templates/hmmt-solution-template.tex`,
  trắng–đen, biên dịch bằng `xelatex`.
- Các bài mô phỏng (B8, C12, C13, C15, C21, E22–E24) nên để trong notebook R, kernel `ir460`.
