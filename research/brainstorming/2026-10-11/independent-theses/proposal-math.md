# Đề xuất luận văn Toán: bảo đảm thống kê cho access review có sai số

**Tên dự kiến:** *Kiểm toán tuần tự một quần thể quyền truy cập hữu hạn khi người review có thể bỏ sót.*  
**Trạng thái:** đề xuất để trao đổi với supervisor; chưa có thí nghiệm, chứng minh hoàn chỉnh hay novelty đã xác nhận. Thời gian: 6–12 tháng. Chỉ dùng dữ liệu công khai và mô phỏng.

## Câu hỏi và giá trị

Với một chiến dịch access recertification, có thể kết luận tỷ lệ quyền không phù hợp thấp hơn ngưỡng đã định mà vẫn kiểm soát xác suất kết luận sai, kể cả khi quyết định dừng review dựa trên kết quả đang thấy không? Khi reviewer bỏ sót hoặc score chọn mẫu sai, bảo đảm và ngân sách review thay đổi thế nào?

Đây là câu hỏi tự nhiên từ IAM/governance: review toàn bộ có chi phí, ưu tiên theo score có thể bỏ qua nhóm hiếm, và kết luận đóng chiến dịch cần điều kiện rõ. Giá trị dự kiến là một quy trình có thể giải thích khi nào kết luận được và khi nào phải để **không đủ bằng chứng**. Không suy diễn tỷ lệ quyền sai thành xác suất breach hay tiền tổn thất.

## Đại lượng và giả thiết cốt lõi

Cố định một danh sách gồm (N) user–entitlement grants và một rubric trước khi review. Nhãn ẩn (Y_i\in\{0,1\}) cho biết grant (i) không phù hợp; mục tiêu là (\theta=N^{-1}\sum_iY_i). Workforce/rubric thay đổi thì mở chiến dịch khác.

Tại lượt (t), chọn (I_t) **có hoàn lại**, với xác suất biết trước từ lịch sử (q_t(i)\ge\gamma/N), (0<\gamma\le1). Nhận review mới (R_t\in\{0,1\}), giả định đủ mạnh:

\[
E[R_t\mid\mathcal F_{t-1},I_t=i]\ge sY_i,\qquad s>0.
\]

(s) là lower bound sensitivity có lý do bên ngoài hoặc tham số mô phỏng. Không học nó từ grant/removal records. Reviewer có thể phụ thuộc lịch sử nếu điều kiện trên luôn còn đúng; lấy lại một nhãn sai cố định ở lần chọn lặp không đáp ứng mô hình review mới. Các grants có thể tương quan theo manager/role vì suy luận dựa trên randomization, không giả định tổ chức là iid.

Điều kiện yếu hơn đủ dùng là average **conditional** sensitivity của toàn bộ grants thật sự sai không dưới (s); một average accuracy đo trong quá khứ không bảo đảm điều đó. Planted items dễ hơn quyền sai thật cũng không bảo đảm. Phương án seeding chỉ là sensitivity experiment tùy chọn; exchangeability đơn thuần không đủ để dùng khoảng binomial.

## Gói toán cần phát triển

Đặt (Z_t=R_t/[Nq_t(I_t)]), (B=1/\gamma). Khi đó (0\le Z_t\le B) và (E[Z_t\mid\mathcal F_{t-1}]\ge s\theta). Với (H_0:\theta\ge\tau), xét

\[
M_t=\prod_{j=1}^t\{1+\lambda_j(s\tau-Z_j)\},\qquad 0\le\lambda_j\le\gamma,
\]

trong đó (\lambda_j) predictable. Kế hoạch chứng minh nonnegative supermartingale và dùng Ville: chứng nhận (\theta<\tau) khi (M_t\ge1/\alpha) sẽ có xác suất chứng nhận sai **ở bất kỳ lúc nào trong chiến dịch** không quá (\alpha), dưới các giả thiết. Đây là error contract cho một ngưỡng cố định; nhiều ngưỡng/nhóm cần phân bổ error budget riêng. Hết ngân sách chưa vượt ngưỡng trả về inconclusive.

Để đủ chiều sâu, luận văn phải có nhiều hơn phép tính expectation:

1. Tái xây dựng các kết quả nền của martingale và weighted finite-population audit, nêu chính xác chỗ khác giữa with/without replacement.
2. Chứng minh ranh giới nhận dạng: nếu không có lower bound sensitivity dương, dựng hai quần thể có (\theta) khác nhau nhưng cùng phân phối review quan sát được.
3. Phân tích thời gian dừng dưới **giả thiết thay thế bổ sung** (E[Z_t\mid past]\le s\tau-\Delta). Với (\lambda=\Delta/(2B^2)), dự kiến log-drift ít nhất (g=\Delta^2/(4B^2)), dẫn tới bound qua bounded overshoot:
   \[
   E[T]\le\frac{\log(1/\alpha)+\log(1+\lambda s\tau)}{g}.
   \]
   Phải hoàn thiện proof và điều kiện; bound có thể rất lỏng. Variance-sensitive refinement là mục tiêu sâu hơn nếu thời gian cho phép.
4. Counterexamples: (\theta<\tau) không tự bảo đảm log-drift dương khi (s) bảo thủ hoặc có false positives. Bảo đảm đúng có thể đi cùng khả năng kết luận rất thấp.

**Đã có:** [ALPHA](https://arxiv.org/abs/2201.02707), [Shekhar et al.](https://arxiv.org/abs/2305.06884), [finite-population confidence sequences](https://arxiv.org/abs/2006.04347) và [robust confidence sequences](https://arxiv.org/abs/2301.09573) khiến sampling/betting/noise tự thân không phải ý tưởng mới. Cần đối chiếu thêm [sequential audit 2026](https://arxiv.org/abs/2604.06116). Đóng góp dự kiến là proof synthesis, ranh giới giả thiết và ứng dụng mô phỏng có kiểm soát; tính mới của specialization chưa xác nhận. Supervisor phải chấp nhận mức đóng góp này trước khi triển khai dài hạn.

## Dữ liệu và pilot đề xuất

[UCI Amazon Access Samples](https://archive.ics.uci.edu/dataset/216/amazon) có snapshot quyền và lịch sử add/remove, license CC BY 4.0. Nó cung cấp **cấu trúc**, không có truth về quyền không phù hợp. Không gán removal = violation. Metadata đã đọc; archive/schema thực tế chưa tải kiểm tra.

Pilot đầu dùng quần thể hoàn toàn synthetic (N=5{,}000), ngưỡng (\tau=2\%), (\alpha=.05), số lượt cap 5,000. Bốn core cells: (\theta\in\{1\%,2\%\}\) và score hữu ích/đảo chiều. Chọn đúng số positives trong mỗi quần thể, rồi giữ nhãn cố định. Review mới có sensitivity .9, false-positive rate .001, bound giả định (s=.8); (q_t) là mixture uniform/score với (\gamma=.5). Đây là tham số thiết kế, không phải ước lượng từ doanh nghiệp.

So sánh uniform và weighted với cùng error budget/cap; thêm fixed-budget baseline có bảo đảm phù hợp cho **cùng noisy-label model**. Không dùng Clopper–Pearson như latent-label bound một cách tự động. Vòng sau mới thêm rare-role concentration, score drift và reviewer sensitivity thấp hơn bound để khảo sát misspecification.

Chạy dự kiến 2,000 repetitions độc lập/cell, sau khi timing 100 repetitions. Tại xác suất .05, MC SE khoảng .0049, 95% half-width khoảng .0096. Báo cáo binomial intervals, số review tổng, grants khác nhau, số lặp, tỷ lệ kết luận và capped effort; không chỉ lấy mean của các runs kết luận thành công. Mô phỏng kiểm tra hành vi, không chứng minh định lý; nhiều cells cần xem xét multiplicity. Không yêu cầu weighted thắng hay misspecification phải gây inflation. Runtime chưa đo.

Sau đó dùng Amazon structure với **nhãn và reviewer synthetic rõ ràng**; phân tích điều kiện nào tạo kết quả, không báo cáo tỷ lệ quyền sai thật. Sản phẩm: proof notes, simulation specification/code, bảng validity/effort và limitations.

## Lộ trình và quyết định tiếp tục

| Mốc | Sản phẩm/điều kiện |
|---|---|
| Tháng 1 | Supervisor chấp nhận synthetic application + contribution ladder; nearest-paper comparison; proof setup và counterexamples |
| Tháng 2–4 | Proof package, runtime pilot, core simulations; chuyển scope nếu chỉ còn one-line martingale hoặc assumptions không hợp lý |
| Tháng 5–6 | Public structural application, sensitivity, bản viết lần đầu; bản 6 tháng giữ optional refinement ngoài core |
| Tháng 7–9 | Hoàn thiện stopping analysis/refinement có giới hạn; không bắt buộc noisy WoR extension |
| Tháng 10–12 | Review chứng minh, viết và buffer |

**Backup duy nhất:** *Kiểm toán phân tầng với nhãn chính xác cho quần thể IAM hữu hạn.* Hai strata định trước, sample không hoàn lại, counts hypergeometric; dựng composite-null test bằng tối đa hóa lower-tail probability theo các violation totals nguyên, chứng minh monotonicity bằng coupling và phân tích phân bổ ngân sách. Enumerate quần thể nhỏ trước khi scale. Vẫn là synthesis, dùng oracle synthetic labels; giải quyết khó khăn reviewer-noise, **không** giải quyết việc supervisor không chấp nhận simulation/synthesis. Khi đó cần chọn lại hướng với supervisor, không tự chuyển sang KEV với nhãn sai.

Xem [đề xuất FE](proposal-fe.md) và [checklist review](review-checklist.md).
