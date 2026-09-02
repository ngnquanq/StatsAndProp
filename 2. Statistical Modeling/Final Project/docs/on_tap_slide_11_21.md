# Ôn tập thuyết trình: Slide 11–21 (Xây dựng mô hình → Kết luận)

Tài liệu dạy lại kiến thức nền + số liệu thật cho phần thuyết trình của bạn.
Đọc kèm: `slide.tex` (frame 11–21), `qa_prep.md` (19 câu Q&A chi tiết),
`IBMHr_analysis.Rmd` (mục 2–6, code thật).

---

## PHẦN A — Bức tranh tổng thể

### Mạch kể 4 câu (thuộc lòng — đây là "xương sống" của phần bạn trình bày)

1. **Chia dữ liệu sạch:** 1.470 nhân viên chia phân tầng 70/30 (train 1.030, test 440,
   seed 123); mọi bước tiền xử lý (capping, chuẩn hóa, dummy) chỉ học từ train để
   **không rò rỉ dữ liệu**.
2. **So sánh 3 mô hình logistic:** mô hình nhân khẩu học (đối chứng), mô hình công việc
   (diễn giải), và mô hình LASSO dùng toàn bộ 30 biến (dự báo).
3. **LASSO thắng ngoài mẫu:** AUC 0,854, sensitivity 64,8% tại ngưỡng 0,30 — cao hơn cả
   hai mô hình logistic thường lẫn Random Forest (0,802) và GBM (0,841).
4. **Chọn ngưỡng theo mục tiêu + nêu giới hạn:** 0,30 cân bằng (F1 max), 0,17 khi bỏ sót
   rất đắt (Youden + chi phí); mô hình là công cụ hỗ trợ, chưa đủ điều kiện triển khai thật.

### Pipeline (slide 11 vẽ đúng sơ đồ này)

```
1.470 quan sát ──chia phân tầng 70/30──▶ train 1.030 (166 Yes) / test 440 (71 Yes)
        ──tiền xử lý FIT TRÊN TRAIN (IQR capping, z-score, dummy fullRank)──▶
        ──huấn luyện 3 mô hình logistic (1 LASSO, λ chọn bằng 10-fold CV)──▶
        ──đánh giá trên test: AUC, sensitivity, F1, ngưỡng──▶ kết luận + giới hạn
```

---

## PHẦN B — Dạy theo từng slide

### Slide 11 — Thiết kế đánh giá ngoài mẫu, hạn chế rò rỉ dữ liệu

**Slide nói gì:** sơ đồ pipeline 4 khối + 3 con số (1.030 train / 440 test / 10-fold CV)
+ hộp ghi chú "mọi tham số tiền xử lý học từ train, kiểm chứng bằng `stopifnot`".

**Lý thuyết cần hiểu:**
- **Đánh giá ngoài mẫu (out-of-sample):** hiệu suất chỉ có ý nghĩa khi đo trên dữ liệu
  mô hình *chưa từng thấy*. Nếu đo trên chính dữ liệu huấn luyện, mô hình phức tạp sẽ
  luôn "đẹp" — đó là ảo giác quá khớp (overfitting).
- **Chia phân tầng (stratified split):** giữ đúng tỷ lệ 16,12% Yes ở cả hai tập. Nếu chia
  ngẫu nhiên thường, tập test có thể lệch (ví dụ chỉ 10% Yes) làm ước lượng sai.
- **Rò rỉ dữ liệu (data leakage):** là khi thông tin của tập test "lọt" vào quá trình
  huấn luyện. Ví dụ: nếu tính trung bình/độ lệch chuẩn để chuẩn hóa trên **toàn bộ** dữ
  liệu rồi mới chia, thì giá trị của các quan sát test đã ảnh hưởng đến biến đầu vào của
  train → điểm số test bị thổi phồng. Vì vậy nhóm **xóa các biến dẫn xuất tính trước khi
  chia** và fit lại từ đầu trên train:
  - Ranh giới IQR capping (Q1/Q3 của MonthlyIncome) — tính từ train, áp cho cả test.
  - Tham số z-score (μ, σ của Age và Income đã capped) — fit `preProcess` trên train.
  - Bộ mã hóa dummy (`dummyVars`, fullRank) — fit trên train, áp cho test.
- **`stopifnot` là gì:** dòng code kiểm chứng tự động — nếu điều kiện sai thì dừng ngay.
  Nhóm kiểm tra: train sau chuẩn hóa có mean ≈ 0, sd ≈ 1; cột ma trận train/test trùng
  khớp; đúng 1.030/440 quan sát với 166/71 Yes.

**Số phải thuộc:** 1.470 → 1.030 + 440; Yes: 166 (train) / 71 (test); seed 123; 10-fold CV.

**Cô có thể hỏi:**
- *"Rò rỉ dữ liệu là gì, em chống thế nào?"* → định nghĩa 1 câu + 3 thứ fit trên train
  (capping, chuẩn hóa, dummy) + stopifnot kiểm chứng.
- *"Sao phải chia phân tầng?"* → dữ liệu mất cân bằng 16%, phân tầng giữ đúng tỷ lệ ở cả
  hai tập để đánh giá không bị lệch.

---

### Slide 12 — Ba đặc tả hồi quy logistic được so sánh

**Slide nói gì:** 3 cột — (1) logistic nhân khẩu học, AUC 0,656; (2) logistic công việc,
AUC 0,785; (3) logistic LASSO, AUC 0,854 — và công thức chung
log(p/(1−p)) = β₀ + Σβⱼxᵢⱼ.

**Lý thuyết cần hiểu — hồi quy logistic từ gốc:**
- Biến phản hồi nhị phân: Yᵢ = 1 nếu nghỉ việc. Ta mô hình hóa **xác suất**
  pᵢ = P(Yᵢ=1 | xᵢ), không mô hình hóa trực tiếp 0/1.
- Không dùng hồi quy tuyến tính thường vì dự báo có thể < 0 hoặc > 1 và sai giả định
  phương sai. Thay vào đó biến đổi qua **logit**:
  - **Odds** = p/(1−p): "tỷ lệ cược" — ví dụ p = 0,2 → odds = 0,25 (1 ăn 4).
  - **Logit** = log(odds) ∈ (−∞, +∞) — giờ vế trái đã "tự do" nên đặt bằng tổ hợp tuyến
    tính β₀ + Σβⱼxⱼ được.
- **Ước lượng bằng hợp lý cực đại (MLE):** không có nghiệm đóng như OLS; R giải lặp bằng
  thuật toán Fisher scoring (IRLS). Số vòng lặp in ở cuối `summary(glm)` — chi tiết này
  thành manh mối chẩn đoán ở slide 14.
- **Vai trò 3 mô hình (điểm hay để nói):** không phải "thử 3 cái cho vui" —
  - Mô hình 1 (5 biến nhân khẩu học) = **đối chứng**: đo xem chỉ thông tin cá nhân dự báo
    được đến đâu → trả lời câu "nhân khẩu học có đủ không?" (đáp: không, AUC 0,656).
  - Mô hình 2 (5 biến công việc/môi trường) = **diễn giải**: các yếu tố doanh nghiệp *can
    thiệp được* (OT, hài lòng, chức danh) → nguồn của mọi odds ratio ở slide 16.
  - Mô hình 3 (LASSO, 30 biến) = **dự báo chính**: tận dụng toàn bộ thông tin, phạt L1 tự
    chọn biến.

**Cô có thể hỏi:**
- *"Vì sao xây 3 mô hình mà không xây 1?"* → mỗi mô hình trả lời một câu hỏi khác nhau
  (đối chứng / diễn giải / dự báo); so sánh chúng cho thấy **điều kiện công việc mang tín
  hiệu hơn nhân khẩu học** — đó chính là kết luận số 1.
- *"Logistic khác hồi quy tuyến tính chỗ nào?"* → mô hình hóa xác suất qua logit, ước
  lượng bằng MLE thay vì bình phương tối thiểu.

---

### Slide 13 — Công thức của hai mô hình logistic không phạt

**Slide nói gì:** viết tường minh logit(pᵢ) cho mô hình 1 (AgeScaled, Gender,
MaritalStatus, Distance, Education) và mô hình 2 (JobRole, EnvironmentSatisfaction,
JobSatisfaction, OverTime, IncomeScaled); ghi chú nhóm tham chiếu.

**Lý thuyết cần hiểu — biến dummy và nhóm tham chiếu:**
- Biến phân loại K mức được mã thành K−1 biến giả 0/1; mức bị bỏ ra là **nhóm tham
  chiếu**. Mọi hệ số của biến giả đều đọc là "**so với nhóm tham chiếu**".
- Nhóm tham chiếu trong bài: **nữ** (Gender), **đã ly hôn** (MaritalStatus),
  **Healthcare Representative** (JobRole), **không làm thêm giờ** (OverTime).
- Ví dụ đọc hệ số: β của MaritalStatusSingle = 0,906 → OR = e^0,906 ≈ 2,47 → người độc
  thân có odds nghỉ việc gấp 2,47 lần **so với người đã ly hôn** (không phải so với
  "trung bình").
- Education trong mô hình 1 được đưa vào như biến số (thang 1–5), Satisfaction trong mô
  hình 2 cũng vậy (thang 1–4) — hệ số đọc theo "mỗi bậc tăng thêm".

**Cô có thể hỏi:**
- *"Hệ số của biến Single nghĩa là gì?"* → nhớ trả lời kèm "so với nhóm tham chiếu là đã
  ly hôn". Đây là bẫy kinh điển.
- *"Vì sao Age phải chuẩn hóa còn DistanceFromHome thì không?"* → chuẩn hóa không bắt
  buộc cho logistic; nhóm chuẩn hóa Age/Income để hệ số so sánh được theo đơn vị SD và để
  pipeline thống nhất với LASSO (LASSO nhạy với thang đo). Distance giữ nguyên nên hệ số
  đọc trực tiếp "mỗi km".

---

### Slide 14 — Chẩn đoán đa cộng tuyến cấu trúc ở mô hình công việc

**Slide nói gì:** câu chuyện lỗi–sửa: phiên bản đầu mô hình 2 có cả Department lẫn
JobRole → suy biến; loại Department → hội tụ, GVIF max ≈ 2,82 < 5.

**Lý thuyết cần hiểu:**
- **Đa cộng tuyến (multicollinearity):** các biến giải thích mang thông tin trùng nhau →
  mô hình không tách được đóng góp riêng của từng biến → hệ số ước lượng bất ổn, sai số
  chuẩn phồng to.
- **"Cấu trúc" ở đây nghĩa là gì:** Department bị **lồng (nested)** trong JobRole — biết
  JobRole thì suy ra được Department (mọi Sales Executive đều thuộc phòng Sales). Đây là
  trùng lặp gần hoàn hảo do *cấu trúc dữ liệu*, không phải tương quan ngẫu nhiên.
- **Triệu chứng đã quan sát (thuộc 4 con số này):**
  1. Hệ số phình bất thường: β ≈ 13–16 (bình thường cỡ ±2);
  2. Sai số chuẩn khổng lồ: ≈ 510–1.082;
  3. p-value → 1 (biến "trông như" vô nghĩa dù thực ra quan trọng);
  4. Fisher scoring cần **15 vòng lặp** (mô hình lành mạnh chỉ ~5–6 vòng).
- **Cách sửa:** loại Department, giữ JobRole vì JobRole chi tiết hơn và đã *bao phủ*
  thông tin phòng ban. Sau sửa: hội tụ sau 6 vòng, AIC 783,18 → 781,32.
- **VIF vs GVIF:** VIF đo mức phồng phương sai của một hệ số do tương quan với các biến
  còn lại; ngưỡng cảnh báo phổ biến là 5 (hoặc 10). Với biến phân loại nhiều bậc tự do,
  R trả về **GVIF** — bản tổng quát cho cả *nhóm* biến giả; để so với ngưỡng cũ ta dùng
  GVIF^(1/(2·df)) rồi bình phương. Kết quả: mô hình 1 max ≈ 1,05; mô hình 2 max ≈ 2,82 —
  đều an toàn.

**Cô có thể hỏi:**
- *"Sao biết là đa cộng tuyến chứ không phải lỗi khác?"* → kể 4 triệu chứng cùng lúc +
  nguyên nhân cơ học rõ ràng (nested) + sau khi bỏ 1 biến thì mọi triệu chứng biến mất.
- *"Sao giữ JobRole mà không giữ Department?"* → JobRole mịn hơn (9 mức vs 3 mức), chứa
  toàn bộ thông tin của Department; giữ biến thô hơn sẽ mất thông tin.

---

### Slide 15 — LASSO: chọn λ bằng 10-fold cross-validation

**Slide nói gì:** biểu đồ `cv.glmnet` + hai hộp: λ.min ≈ 0,0030 (log λ ≈ −5,80; 35 hệ số
≠ 0, dùng cho dự báo) và λ.1se (log λ ≈ −4,49; 29 biến, phương án gọn).

**Lý thuyết cần hiểu:**
- **Hàm mục tiêu:** LASSO cực tiểu hóa [− log-likelihood trung bình] + λ·Σ|βⱼ|.
  Thành phần thứ hai là **hình phạt L1** — phạt theo *tổng trị tuyệt đối* hệ số.
- **Vì sao L1 co hệ số về ĐÚNG 0 (khác Ridge):** hình phạt L1 có "góc nhọn" tại 0
  (miền ràng buộc hình thoi), nên nghiệm tối ưu thường rơi đúng vào đỉnh — tức một số
  βⱼ = 0 tuyệt đối → LASSO **vừa co hệ số vừa chọn biến**. Ridge (L2, miền tròn) chỉ co
  nhỏ chứ hiếm khi về đúng 0.
- **Vì sao bài này cần LASSO:** sau dummy hóa, ma trận đầu vào có ~40 cột; nhiều biến
  tương quan (tuổi – thâm niên – cấp bậc – thu nhập). Logistic thường sẽ bất ổn; LASSO
  chính quy hóa và tự loại biến nhiễu (chính nó đã co hệ số thu nhập về 0).
- **λ là gì và chọn thế nào:** λ điều khiển độ mạnh hình phạt — λ lớn → mô hình thưa
  (ít biến); λ nhỏ → gần logistic thường. Chọn **khách quan bằng 10-fold CV**: chia train
  thành 10 phần, luân phiên giữ 1 phần làm validation, đo binomial deviance trung bình
  cho từng λ.
  - **λ.min:** deviance CV nhỏ nhất → dùng cho dự báo (giữ 35 hệ số).
  - **λ.1se:** λ lớn nhất còn nằm trong 1 sai số chuẩn của điểm min → mô hình gọn hơn
    (29 biến), là đối chứng nếu ưu tiên triển khai đơn giản.
- **Đọc biểu đồ:** trục hoành dưới = log λ (sang phải = phạt mạnh hơn = ít biến); trục
  hoành trên = số biến ≠ 0; trục tung = binomial deviance CV (thấp = tốt); hai vạch đứt
  = λ.min và λ.1se.

**Cô có thể hỏi:**
- *"λ để làm gì?"* → nút vặn cân bằng giữa khớp dữ liệu và độ đơn giản; chọn bằng CV chứ
  không chọn tay.
- *"Sao không dùng stepwise?"* → stepwise bất ổn và làm hỏng suy luận sau chọn biến;
  LASSO chọn biến có kiểm soát, tham số phạt chọn khách quan bằng CV (chi tiết:
  `qa_prep.md` câu 7).
- *"LASSO khác Ridge?"* → L1 vs L2; L1 chọn biến (về đúng 0), L2 chỉ co.

---

### Slide 16 — Yếu tố công việc cung cấp tín hiệu mạnh nhất

**Slide nói gì:** 3 hộp OR từ **mô hình 2**: OT → odds ×4,67; hài lòng môi trường −30,3%/bậc;
hài lòng công việc −24,8%/bậc. Cột phải: 4 chức danh cần theo dõi + hộp cảnh báo "thu nhập
mất ý nghĩa sau khi kiểm soát chức danh (p = 0,968)". Chú thích: không diễn giải nhân quả.

**Lý thuyết cần hiểu:**
- **Odds ratio (OR) = e^β:** biến X tăng 1 đơn vị (hoặc chuyển từ nhóm tham chiếu sang
  nhóm đang xét) thì odds nhân với e^β.
  - OT: β = 1,542 → OR = e^1,542 ≈ 4,67 → làm thêm giờ có odds nghỉ việc **gấp 4,67 lần**
    so với không OT (giữ các biến khác cố định).
  - EnvironmentSatisfaction: β = −0,362 → OR ≈ 0,697 → mỗi bậc hài lòng tăng thêm, odds
    **giảm ~30,3%**. JobSatisfaction: β = −0,285 → OR ≈ 0,752 → giảm ~24,8%.
- **OR ≠ risk ratio:** OR nói về odds, không phải xác suất tuyệt đối; với biến cố hiếm
  chúng gần nhau nhưng 16% không quá hiếm → chỉ nói "odds gấp 4,67 lần", đừng nói "khả
  năng nghỉ việc gấp 4,67 lần".
- **Nghịch lý thu nhập (câu chuyện hay nhất của slide này):**
  - Ở EDA: Wilcoxon p = 2,95×10⁻¹⁴ — nhóm nghỉ việc lương thấp hơn rõ rệt.
  - Trong mô hình 2: Income_scaled p = 0,968 — không còn ý nghĩa!
  - Giải thích = **confounding**: thu nhập gắn chặt với chức danh/thâm niên. Kiểm định
    đơn biến đo *liên hệ thô*; hệ số hồi quy đo *đóng góp riêng phần sau khi đã kiểm soát
    JobRole, OT, hài lòng*. Hai câu hỏi khác nhau → hai kết quả không mâu thuẫn.
  - Bằng chứng độc lập: LASSO cũng tự co hệ số thu nhập về đúng 0.
- **Hai câu "rào" phải nhớ:** (1) các OR này lấy từ **mô hình 2**, không phải hệ số LASSO
  (hệ số LASSO bị co, không có p-value); (2) đây là **liên hệ dự báo**, dữ liệu quan sát
  cắt ngang — không kết luận nhân quả.

**Cô có thể hỏi:**
- *"OR 4,67 nghĩa là gì?"* → trả lời theo odds, kèm "giữ các biến khác cố định" và "so
  với nhóm không OT".
- *"Lương thấp thì nghỉ việc — sao bảo lương không có ý nghĩa?"* → kể nghịch lý thu nhập
  ở trên (đơn biến vs riêng phần, confounding).
- *"Vậy làm thêm giờ có GÂY nghỉ việc không?"* → không kết luận được nhân quả; chỉ là
  tín hiệu liên hệ mạnh, nhưng đủ để HR ưu tiên rà soát.

---

### Slide 17 — LASSO cho kết quả ngoài mẫu tốt nhất

**Slide nói gì:** bảng 5 mô hình trên cùng tập test, ngưỡng 0,30 + biểu đồ ROC:

| Mô hình | AUC | Accuracy | Sensitivity |
|---|---|---|---|
| Nhân khẩu học | 0,656 | 0,809 | 0,197 |
| Công việc | 0,785 | 0,818 | 0,465 |
| **LASSO** | **0,854** | **0,866** | **0,648** |
| Random Forest | 0,802 | 0,818 | 0,507 |
| GBDT | 0,841 | 0,859 | 0,465 |

Kèm: precision LASSO 0,575; F1 LASSO 0,609.

**Lý thuyết cần hiểu:**
- **Confusion matrix** (tại ngưỡng 0,30, LASSO trên test): TP 46, FN 25, FP 34, TN 335.
  - **Sensitivity (recall)** = TP/(TP+FN) = 46/71 = 64,8% — bắt được bao nhiêu % người
    *thực sự* nghỉ việc. Chỉ số quan trọng nhất với HR (bỏ sót là mất người).
  - **Specificity** = TN/(TN+FP) = 335/369 = 90,8% — nhận đúng người ở lại.
  - **Precision** = TP/(TP+FP) = 46/80 = 57,5% — trong số người bị cảnh báo, bao nhiêu %
    đúng. Precision thấp = nhiều báo động giả.
  - **F1** = trung bình điều hòa của precision và recall = 0,609 — cân bằng hai phía.
- **ROC và AUC:** đường ROC vẽ cặp (sensitivity, 1−specificity) khi quét *mọi* ngưỡng từ
  0→1. **AUC** = diện tích dưới đường — xác suất mô hình xếp hạng một người nghỉ việc
  ngẫu nhiên cao hơn một người ở lại ngẫu nhiên. AUC = 0,5 là đoán mò; 0,854 là mức tốt.
  AUC **không phụ thuộc ngưỡng** → dùng để so năng lực xếp hạng thuần túy giữa các mô hình.
- **Vì sao accuracy lừa dối:** baseline "luôn đoán No" đạt accuracy 83,88% nhưng
  sensitivity = 0%. Mô hình 1 (80,9%) và 2 (81,8%) thậm chí *dưới* baseline; chỉ LASSO
  (86,6%) vượt. Thứ tự ưu tiên metric của nhóm: **AUC → sensitivity → F1 → accuracy**.
- **Vì sao RF/GBM thua LASSO (nói thận trọng):** không kết luận overfitting vì chưa so
  train/CV vs test; khả năng hợp lý hơn là quan hệ trong dữ liệu khá tuyến tính sau dummy
  hóa và cỡ mẫu 1.030 chưa đủ cho cây học sâu. RF dùng class weight 1:5 nên đánh đổi
  precision (0,444) lấy recall.

**Cô có thể hỏi:**
- *"AUC để làm gì, khác accuracy chỗ nào?"* → AUC đo năng lực xếp hạng trên mọi ngưỡng,
  không bị mất cân bằng lớp đánh lừa; accuracy phụ thuộc ngưỡng và bị baseline 83,88% làm
  vô nghĩa.
- *"Mô hình bỏ sót 25 người thì có chấp nhận được không?"* → thẳng thắn: bắt được 46/71
  (64,8%) thay vì 0/71 nếu không có mô hình; muốn bắt nhiều hơn thì hạ ngưỡng xuống 0,17
  (slide 18) và chấp nhận thêm báo động giả.

---

### Slide 18 — Ngưỡng 0,30 cân bằng; 0,17 khi bỏ sót rất đắt

**Slide nói gì:** biểu đồ precision/recall/F1 theo ngưỡng + hai hộp: **0,30** (F1 max;
Sens 64,8%, Spec 90,8%) và **0,17** (tối ưu Youden J + hàm chi phí giả định). Gợi ý hai
tầng: ≥0,17 theo dõi rộng, ≥0,30 HR rà soát 1–1.

**Lý thuyết cần hiểu:**
- Mô hình xuất **xác suất**; muốn ra nhãn Yes/No phải chọn **ngưỡng cắt**. Ngưỡng mặc
  định 0,5 chỉ hợp lý khi hai lớp cân bằng và chi phí hai loại lỗi bằng nhau — ở đây cả
  hai điều kiện đều sai (16% Yes; bỏ sót đắt hơn báo nhầm).
- **Ba tiêu chí đã quét (ngưỡng 0,05→0,80):**
  1. **F1 cực đại** → chọn **0,30**: cân bằng precision–recall.
  2. **Youden's J** = Sensitivity + Specificity − 1, cực đại → **0,17**: điểm xa đường
     chéo ROC nhất, coi hai loại đúng ngang giá.
  3. **Hàm chi phí giả định** (FN = 15.000 USD — chi phí thay thế nhân viên; FP = 1.000
     USD — chi phí một buổi giữ chân) → tổng chi phí nhỏ nhất cũng tại **0,17**.
- **Thông điệp đúng của slide:** *không tồn tại một ngưỡng tối ưu cho mọi mục tiêu* —
  ngưỡng là quyết định kinh doanh, không phải hằng số thống kê. Nhóm đề xuất vận hành
  hai tầng.
- **Điểm yếu phải tự nhận nếu bị hỏi:** ngưỡng đang được khảo sát trên chính tập test —
  đúng chuẩn phải chọn trên validation riêng hoặc nested CV (đã ghi ở slide 20).
- Chi phí 15k/1k là **giả định minh họa**; kết luận định tính (FN đắt ⇒ ngưỡng tụt) không
  đổi khi thay số thực.

**Cô có thể hỏi:**
- *"Sao lại 0,30 mà không 0,5?"* → 3 lý do: mất cân bằng lớp, chi phí lệch, và kết quả
  quét 3 tiêu chí (chi tiết `qa_prep.md` câu 1).
- *"Ngưỡng 0,17 lấy đâu ra?"* → cực đại Youden J và cực tiểu hàm chi phí — hai tiêu chí
  độc lập cùng chỉ về ~0,17.

---

### Slide 19 — Từ mô hình đến hành động HR

**Slide nói gì:** 4 hành động: (1) kiểm soát OT; (2) can thiệp theo chức danh (stay
interview cho Lab Technician, Sales Rep/Exec, HR); (3) cải thiện trải nghiệm — hài lòng,
lộ trình, luân chuyển; (4) cảnh báo sớm **có giám sát con người**. Hộp đỏ: *không dùng
điểm rủi ro để kỷ luật/sa thải tự động; kiểm tra fairness, quyền riêng tư, pháp lý*.

**Ý cần nắm:** đề xuất bám đúng các biến **can thiệp được** mà mô hình chỉ ra (OT, hài
lòng, chức danh) — không đề xuất theo biến không can thiệp được (tuổi, hôn nhân). Điểm
rủi ro chỉ để *ưu tiên quan tâm giúp đỡ*, không để trừng phạt — vừa là đạo đức vừa tránh
mô hình bị "gamed".

**Cô có thể hỏi:** *"Mô hình này dùng làm gì trong thực tế?"* → chấm điểm định kỳ, hai
tầng ngưỡng, HR rà soát 1–1, đo lại chi phí thật để hiệu chỉnh ngưỡng.

---

### Slide 20 — Giới hạn cần xử lý trước khi triển khai

**Slide nói gì + ý nghĩa từng giới hạn (4 hộp):**
1. **Tính đại diện:** dữ liệu IBM là mô phỏng, lát cắt ngang, không có "thời gian đến khi
   nghỉ việc" → không khái quát cho doanh nghiệp cụ thể; muốn đúng phải học trên dữ liệu
   thật có yếu tố thời gian (hướng survival analysis).
2. **Đánh giá hiệu suất:** ngưỡng đang chọn trên test → cần validation riêng hoặc nested
   CV; mọi chỉ số là ước lượng điểm từ một lần chia (CI 95% accuracy LASSO: 0,830–0,896).
3. **Độ tin cậy xác suất:** cần thêm PR-AUC (phù hợp dữ liệu mất cân bằng hơn ROC),
   Brier score + calibration curve (xác suất 0,3 có thật nghĩa là 30% không?), bootstrap
   CI cho AUC.
4. **Quản trị mô hình:** kiểm định trên dữ liệu thật, theo dõi drift (phân phối thay đổi
   theo thời gian), fairness, hiệu chỉnh ngưỡng theo chi phí vận hành.

**Vì sao slide này "ăn điểm":** tự chỉ ra giới hạn đúng chỗ = hiểu phương pháp sâu hơn là
chỉ khoe kết quả. Khi cô hỏi "mô hình đủ tốt chưa" — câu trả lời nằm ở slide này.

---

### Slide 21 — Ba kết luận chính

1. **Điều kiện công việc quan trọng hơn nhân khẩu học** — OT, hài lòng, chức danh là tín
   hiệu rõ nhất (bằng chứng: AUC 0,656 → 0,785; OR ở slide 16).
2. **LASSO là lựa chọn cân bằng nhất** — AUC 0,854, sensitivity 64,8%, F1 0,609 tại
   ngưỡng 0,30 (thắng cả RF và GBM).
3. **Mô hình là công cụ hỗ trợ can thiệp** — ưu tiên cải thiện tải việc và trải nghiệm,
   không tự động gắn nhãn hay ra quyết định bất lợi.

Ba câu này = đáp án chuẩn khi cô nói *"nãy giờ tổng hợp lại thì là các ý vậy á?"*.

---

## PHẦN C — Trả lời mẫu cho 5 dạng câu cô hay hỏi

### 1. "Em làm gì trong bài?" (~45 giây)
> "Dạ, phần của em là xây dựng và đánh giá mô hình. Em chia 1.470 quan sát thành 70/30
> phân tầng, mọi bước tiền xử lý đều fit trên train để tránh rò rỉ dữ liệu. Em so sánh ba
> mô hình hồi quy logistic: mô hình nhân khẩu học làm đối chứng, mô hình công việc để
> diễn giải, và mô hình LASSO dùng toàn bộ biến để dự báo. Trên tập test, LASSO tốt nhất
> với AUC 0,854 và bắt được 64,8% ca nghỉ việc tại ngưỡng 0,30. Cuối cùng em khảo sát
> ngưỡng quyết định theo ba tiêu chí, đề xuất hành động HR và nêu các giới hạn trước khi
> triển khai."

### 2. "Chỉ số này để làm gì?" — trả lời 1 câu cho từng chỉ số
- **AUC:** đo năng lực xếp hạng đúng người nghỉ việc trên người ở lại, ở mọi ngưỡng —
  dùng để so các mô hình mà không bị mất cân bằng lớp đánh lừa.
- **AIC:** cân bằng độ khớp và độ phức tạp, so các mô hình MLE với nhau (giảm 858,89 →
  781,32); không tính được cho LASSO nên LASSO dùng CV thay.
- **Odds ratio:** dịch hệ số logistic sang "odds gấp mấy lần" để nói chuyện với HR.
- **VIF/GVIF:** phát hiện đa cộng tuyến — hệ số có bị phồng phương sai do biến trùng
  thông tin không; ngưỡng 5.
- **λ (LASSO):** độ mạnh hình phạt L1, quyết định giữ bao nhiêu biến; chọn bằng 10-fold CV.
- **Sensitivity:** % người thực sự nghỉ việc bị mô hình bắt trúng — quan trọng nhất với HR.
- **Precision:** % cảnh báo là đúng — kiểm soát chi phí báo động giả.
- **F1:** trung bình điều hòa hai cái trên — tiêu chí chọn ngưỡng 0,30.

### 3. "Tổng hợp lại là các ý vậy á?" → đọc đúng 3 kết luận ở slide 21.

### 4. "Em có hiểu tại sao lại làm như vậy không?" — 5 "tại sao" cốt lõi
- **Tại sao logistic?** Biến phản hồi nhị phân, cần mô hình xác suất diễn giải được bằng
  OR — phù hợp bài toán HR cần giải thích cho người không chuyên.
- **Tại sao 3 mô hình?** Ba vai trò: đối chứng – diễn giải – dự báo; so sánh chúng chính
  là cách trả lời câu hỏi nghiên cứu "yếu tố nào quan trọng".
- **Tại sao LASSO?** Nhiều biến tương quan sau dummy hóa; L1 vừa chính quy hóa chống quá
  khớp vừa tự chọn biến, λ chọn khách quan bằng CV.
- **Tại sao ngưỡng 0,30?** Lớp Yes chỉ 16%, chi phí bỏ sót cao hơn báo nhầm; 0,30 là điểm
  F1 cực đại trong dãy ngưỡng đã quét; kèm phương án 0,17 khi ưu tiên tránh bỏ sót.
- **Tại sao fit tiền xử lý trên train?** Để điểm test phản ánh đúng năng lực trên dữ liệu
  mới — nếu dùng cả test để tính tham số tiền xử lý thì kết quả bị thổi phồng.

### 5. "Em đánh giá mô hình của nhóm mình như thế nào, đủ tốt chưa?" (~60 giây — câu khó nhất, trả lời 2 vế)
> "Dạ, trong phạm vi đồ án em đánh giá mô hình đạt yêu cầu: AUC 0,854 trên tập test là
> mức tốt cho bài toán phân loại mất cân bằng, sensitivity 64,8% nghĩa là bắt được gần
> 2/3 ca nghỉ việc thay vì 0% nếu không có mô hình, và LASSO thắng cả Random Forest lẫn
> GBM trên cùng tập test. Quy trình cũng chặt: không rò rỉ dữ liệu, có kiểm tra đa cộng
> tuyến, chọn λ bằng CV.
> Nhưng để triển khai thật thì chưa đủ, và nhóm em nói rõ trong slide giới hạn: dữ liệu
> là mô phỏng và cắt ngang; ngưỡng đang khảo sát trên test thay vì validation riêng; chưa
> có PR-AUC, calibration và khoảng tin cậy bootstrap cho AUC; và cần kiểm tra fairness,
> drift trước khi dùng với nhân viên thật. Nên kết luận của em là: mô hình tốt như một
> minh chứng quy trình, và là điểm khởi đầu đúng, chứ chưa phải hệ thống sẵn sàng vận hành."

---

## PHẦN D — Bảng số thuộc lòng + bẫy cần tránh

### Số liệu tối thiểu phải nhớ (bảng đầy đủ ở cuối `qa_prep.md`)

| Nhóm | Con số |
|---|---|
| Mẫu | 1.470; Yes 237 (16,12%); train 1.030 (166 Yes) / test 440 (71 Yes); seed 123 |
| AUC test | M1 0,656 · M2 0,785 · **LASSO 0,854** · RF 0,802 · GBM 0,841 |
| LASSO @0,30 | Sens 64,8% · Spec 90,8% · Prec 57,5% · F1 0,609 · Acc 86,6% (baseline 83,88%) |
| Confusion | TP 46 · FN 25 · FP 34 · TN 335 |
| OR (mô hình 2) | OT 4,67 · EnvSat −30,3%/bậc · JobSat −24,8%/bậc · Income p = 0,968 |
| OR (mô hình 1) | Tuổi 0,68/SD · Độc thân 2,47 · Distance +3,1%/km |
| LASSO λ | λ.min ≈ 0,0030 (35 hệ số) · λ.1se (29 biến) · 10-fold CV |
| Đa cộng tuyến | β 13–16, SE 510–1.082, 15 vòng → sửa: 6 vòng, GVIF max 2,82 (M1: 1,05) |
| AIC | M1 858,89 · M2 781,32 (bản đầu có Department: 783,18) |
| Ngưỡng | 0,30 (F1 max) · 0,17 (Youden + chi phí FN 15k/FP 1k) |

### Bẫy phát ngôn — TUYỆT ĐỐI tránh
1. ❌ "OT **gây ra** nghỉ việc" → ✅ "có **liên hệ** mạnh với nghỉ việc; dữ liệu quan sát
   nên không kết luận nhân quả."
2. ❌ "Accuracy 86,6% chứng tỏ mô hình tốt" → ✅ "accuracy chỉ có nghĩa khi so với
   baseline 83,88%; nhóm ưu tiên AUC → sensitivity → F1."
3. ❌ Đọc OR 4,67 như thể là hệ số LASSO → ✅ OR lấy từ **mô hình 2** (logistic không
   phạt); hệ số LASSO bị co, không kèm p-value.
4. ❌ "Khả năng nghỉ việc gấp 4,67 lần" → ✅ "**odds** nghỉ việc gấp 4,67 lần."
5. ❌ Quên nhóm tham chiếu → ✅ Single 2,47 lần là **so với nhóm đã ly hôn**; OT là so với
   không OT; JobRole so với Healthcare Representative.
6. ❌ "Ngưỡng 0,30 là tối ưu" (tuyệt đối) → ✅ "0,30 tối ưu **theo F1**; Youden và chi phí
   chọn 0,17 — không có ngưỡng duy nhất cho mọi mục tiêu, và ngưỡng đang khảo sát trên
   test, đúng chuẩn phải chọn trên validation."
7. ❌ "Random Forest bị overfitting" → ✅ "chưa đủ bằng chứng kết luận overfitting vì chưa
   so train/CV với test; khả năng hợp lý hơn là dữ liệu khá tuyến tính và mẫu nhỏ."
8. ❌ Hứa mô hình dùng được ngay → ✅ luôn kèm giới hạn slide 20.

### Nếu bị hỏi sâu → bật slide backup nào
- VIF/GVIF chi tiết → **B1** · RF/GBM → **B2** · Ba tiêu chí ngưỡng → **B3**
- Mất cân bằng lớp, CI → **B4** · Confusion matrix LASSO → **B5**
- Vì sao chọn phương pháp → **B6** · LASSO giữ biến nào → **B7**
- Kết quả mô hình 1 → **B8** · Kết quả mô hình 2 → **B9**
