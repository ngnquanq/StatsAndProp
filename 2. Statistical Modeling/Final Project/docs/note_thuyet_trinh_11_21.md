# NOTE THUYẾT TRÌNH — Slide 11 → 21 + Q&A

> Note dạng đọc-là-nói-được. Mỗi slide có: **[NÓI]** — đoạn có thể đọc gần nguyên văn,
> **[SỐ]** — con số phải bật ra không cần nghĩ, **[HỎI]** — câu dễ bị hỏi ngay slide đó.
> Cuối file: kho trả lời nhanh Q&A + bảng số + bẫy phát ngôn.

---

## MẠCH TỔNG — thuộc 4 câu này là không bao giờ lạc

1. Chia dữ liệu **sạch** (70/30 phân tầng, tiền xử lý fit trên train — không rò rỉ).
2. So **3 mô hình logistic**: nhân khẩu học (đối chứng) → công việc (diễn giải) → LASSO (dự báo).
3. **LASSO thắng ngoài mẫu**: AUC 0,854, bắt 64,8% ca nghỉ việc — hơn cả RF và GBM.
4. **Ngưỡng theo mục tiêu** (0,30 cân bằng / 0,17 chống bỏ sót) + nêu giới hạn, không nói quá.

---

## SLIDE — Tiền xử lý dữ liệu: bốn quyết định chính (slide mới, ngay trước slide thiết kế đánh giá)

**[NÓI]** "Trước khi mô hình hóa, nhóm em thực hiện bốn quyết định tiền xử lý. Một,
loại bốn biến không mang thông tin: ba biến hằng có phương sai bằng 0 và mã định danh
nhân viên. Hai, dữ liệu không có giá trị khuyết nên không cần imputation. Ba, thu nhập
lệch phải nặng — trung bình 6.503 lớn hơn trung vị 4.919 đô — nên nhóm em giới hạn
ngoại lệ bằng capping tại ranh giới 1,5 IQR thay vì xóa quan sát, để không mất dữ liệu.
Bốn, chuẩn hóa z-score cho tuổi và thu nhập, dummy hóa full rank cho biến phân loại.
Điểm quan trọng: mọi tham số của các bước này đều được fit lại chỉ trên tập train —
thiết kế chống rò rỉ ở slide tiếp theo."

**[SỐ]** 4 biến bị loại · 0 NA · capping 1,5×IQR, trần train ≈ 16.563 USD ·
74 ca train + 40 ca test bị ghim trần · mean 6.503 > median 4.919 USD.

**[ĐỊNH NGHĨA] Capping outlier (winsorizing) — cơ chế và con số thật**

Code: tính Q1, Q3 của `MonthlyIncome` **từ tập train** → ranh giới = Q1 − 1,5·IQR và
Q3 + 1,5·IQR → giá trị vượt ranh giới bị **ghi đè thành đúng ranh giới** (ghim trần/sàn).

Số thật (train, seed 123): Q1 = 2.905 · Q3 = 8.369 · IQR = 5.463 → **trần = 16.563 USD**;
sàn = −5.290 (âm, lương min 1.009 → không ai bị ghim sàn). Kết quả: **74 ca train (~7%)
và 40 ca test** có lương 16.563–19.999 bị kéo về đúng 16.563.

- **KHÔNG xóa dòng nào** (train vẫn 1.030, test vẫn 440) và **KHÔNG loại biến nào** —
  ngược lại tạo THÊM cột `MonthlyIncome_Capped`, rồi z-score thành `Income_scaled`.
  (Cột gốc `MonthlyIncome` chỉ bị bỏ khỏi ma trận LASSO để tránh 2 cột trùng lặp —
  đó là dọn trùng, không phải xử lý outlier.)
- **Vì sao ghim thay vì xóa:** outlier là lương THẬT của quản lý cấp cao — xóa là mất
  7% mẫu và méo quần thể (mất hẳn nhóm lãnh đạo); để nguyên thì đuôi 17–20k có đòn bẩy
  lớn, kéo lệch μ/σ của z-score và hệ số. Ghim = giữ người, kìm đòn bẩy — thông tin
  "thuộc nhóm lương cao nhất" vẫn còn (nằm ở trần).
- **Chống rò rỉ:** ranh giới tính từ train, áp nguyên xi cho test — không tính lại
  trên test hay trên toàn bộ dữ liệu.

**[HỎI]**
- *Capping có làm mất quan sát/biến không?* → Không — không xóa dòng, không loại biến;
  chỉ ghi đè giá trị vượt trần của MỘT biến (MonthlyIncome) thành giá trị trần.
- *Sao capping mà không xóa outlier?* → Outlier lương cao là giá trị THẬT (quản lý cấp
  cao), xóa là mất ~7% mẫu và méo quần thể; capping giữ quan sát nhưng kìm ảnh
  hưởng đòn bẩy lên mô hình.
- *Sao phải chuẩn hóa?* → Không bắt buộc cho logistic, nhưng giúp hệ số đọc theo đơn vị
  SD và cần cho LASSO (hình phạt L1 nhạy với thang đo — biến thang lớn sẽ bị phạt
  "oan" nếu không chuẩn hóa).

## SLIDE 11 — Thiết kế đánh giá ngoài mẫu, hạn chế rò rỉ dữ liệu

**[NÓI]** "1.470 quan sát được chia phân tầng 70/30 thành 1.030 huấn luyện và 440 kiểm
thử, giữ đúng tỷ lệ nghỉ việc 16% ở cả hai tập. Điểm nhóm em làm kỹ là chống rò rỉ dữ
liệu: ranh giới capping ngoại lệ, tham số chuẩn hóa và bộ mã hóa dummy đều chỉ học từ
tập train rồi áp lại cho test — nếu tính trên toàn bộ dữ liệu trước khi chia thì thông
tin của test đã lọt vào train và điểm số sẽ bị thổi phồng. Toàn bộ được kiểm chứng tự
động bằng stopifnot."

**[SỐ]** 1.470 → train 1.030 (166 Yes) / test 440 (71 Yes); seed 123; 10-fold CV cho λ.

**[HỎI]**
- *Rò rỉ dữ liệu là gì?* → Thông tin tập test lọt vào quá trình huấn luyện (ví dụ tính
  μ, σ chuẩn hóa trên cả dữ liệu trước khi chia) → điểm test đẹp giả tạo.
- *Sao phải phân tầng?* → Lớp Yes chỉ 16%; chia thường có thể lệch tỷ lệ ở test → đánh
  giá méo. Phân tầng khóa đúng 16% ở cả hai tập.

---

## SLIDE 12 — Ba đặc tả hồi quy logistic được so sánh

**[NÓI]** "Nhóm em so sánh ba đặc tả cùng họ logistic. Mô hình 1 dùng 5 biến nhân khẩu
học — tuổi, giới tính, hôn nhân, khoảng cách, học vấn — đóng vai trò đối chứng, AUC test
chỉ 0,656. Mô hình 2 dùng 5 biến công việc — chức danh, hai biến hài lòng, làm thêm giờ,
thu nhập — để diễn giải các yếu tố can thiệp được, AUC 0,785. Mô hình 3 là LASSO với
toàn bộ 30 biến gốc, hình phạt L1 giữ lại 35 hệ số khác 0, AUC 0,854. Cả ba cùng một
phương trình logit nên so sánh là công bằng — khác biệt AUC phản ánh giá trị của thông
tin đưa vào."

**[SỐ]** AUC: 0,656 → 0,785 → 0,854. Vai trò: đối chứng – diễn giải – dự báo.

**[HỎI]**
- *Công thức dưới slide là gì?* → log(p/(1−p)) = β₀ + Σβⱼxⱼ: log-odds nghỉ việc là hàm
  tuyến tính của đặc điểm nhân viên. Phải qua logit vì xác suất bị chặn [0,1] còn vế
  phải chạy (−∞,∞); giải ngược ra p là hàm sigmoid, luôn nằm trong (0,1).
- *Có phải OLS không?* → Không. OLS là cho hồi quy tuyến tính (y liên tục, cực tiểu tổng
  bình phương). Logistic ước lượng bằng **hợp lý cực đại (MLE)** — thuật toán Fisher
  scoring; LASSO là MLE **có phạt** L1. Không tồn tại "logistic OLS".
- *Sao không so bằng AIC?* → AIC chỉ định nghĩa cho MLE không phạt (cần likelihood tại
  cực đại + số tham số đếm được). LASSO co hệ số lệch khỏi điểm MLE nên AIC không áp
  dụng; nó dùng 10-fold CV — đo trực tiếp thứ AIC chỉ xấp xỉ. Sân chơi chung cả ba: AUC test.
  (AIC so M1 vs M2: 858,89 → 781,32, giảm >77 điểm, ΔAIC>10 = vượt trội rõ.)

---

## SLIDE 13 — Công thức hai mô hình logistic không phạt

**[NÓI]** "Đây là hai đặc tả viết tường minh. Biến phân loại được dummy hóa full rank —
K mức thành K−1 biến giả, mức bỏ ra làm nhóm tham chiếu. Nhóm tham chiếu ở đây là nữ,
đã ly hôn, Healthcare Representative và không làm thêm giờ — nên mọi hệ số dummy đều đọc
là 'so với nhóm tham chiếu'."

**[HỎI]**
- *Dummy hóa full rank là gì?* → K mức → K−1 cột 0/1. Nếu tạo đủ K cột thì các cột cộng
  luôn bằng 1, trùng cột chặn → đa cộng tuyến hoàn hảo ("bẫy biến giả"), ma trận không
  đủ hạng. Full rank = đủ hạng, ước lượng được, hệ số đọc theo nhóm tham chiếu.
- *Sao Age chuẩn hóa mà Distance thì không?* → Chuẩn hóa không bắt buộc; làm để hệ số
  so được theo đơn vị SD và thống nhất pipeline với LASSO (L1 nhạy thang đo). Distance
  giữ nguyên để đọc "mỗi km".

**[ĐỌC BẢNG HỆ SỐ] — công thức đọc β₀ và β, áp cho mọi dòng của B8/B9**

*Hằng số (β₀ / intercept):* là **log-odds của "người gốc"** — người thuộc tất cả nhóm
tham chiếu và có các biến số = 0. Quy đổi: odds gốc = e^β₀; p gốc = odds/(1+odds).
- **Mô hình 1:** β₀ = −2,4969 → odds = e^−2,4969 ≈ 0,082 → p ≈ **7,6%**. Người gốc: nữ,
  đã ly hôn, tuổi trung bình (Age_scaled = 0 = mean ~37), distance 0, education 0.
- **Mô hình 2:** β₀ = −1,4438 → odds ≈ 0,236 → p ≈ **19,1%**. Người gốc: Healthcare
  Representative, không OT, thu nhập trung bình, hai thang hài lòng = 0.
- ⚠ Education = 0 và hài lòng = 0 nằm NGOÀI thang thật (1–5, 1–4) → β₀ chủ yếu là
  **điểm neo toán học** để các OR nhân dần lên, không diễn giải như một người có thật.
  p-value của hằng số không cần diễn giải; không được bỏ intercept khỏi mô hình.

*Template 4 bước đọc MỘT hệ số β bất kỳ:*
① Dấu → hướng (+ tăng rủi ro, − giảm) → ② OR = e^β → ③ nêu ĐƠN VỊ (dummy: "so với
nhóm tham chiếu X"; liên tục: "mỗi 1 km / 1 bậc / 1 SD") → ④ chốt "giữ các biến khác
cố định". Luôn nói **odds**, không nói "khả năng/xác suất".

*Ví dụ mẫu — Mô hình 1 (B8):*
- `Age_scaled` β = −0,3905 → OR = e^−0,39 ≈ **0,68**: già thêm **1 SD ≈ 9 năm tuổi**,
  odds nghỉ việc nhân 0,68 (giảm ~32%), giữ các biến khác cố định.
- `Độc thân` β = +0,9057 → OR ≈ **2,47**: người độc thân có odds gấp 2,47 lần **so với
  nhóm tham chiếu đã ly hôn**, giữ các biến khác cố định.

*Ví dụ mẫu — Mô hình 2 (B9):*
- `Làm thêm giờ` β = +1,5420 → OR ≈ **4,67**: người OT có odds gấp 4,67 lần **so với
  không OT**, giữ các biến khác cố định.
- `Hài lòng môi trường` β = −0,3619 → OR ≈ **0,70**: mỗi **1 bậc** hài lòng tăng thêm
  (thang 1–4), odds nhân 0,70 (giảm ~30%), giữ các biến khác cố định.

→ Mọi dòng khác trong B8/B9 đọc y hệt template này: tra dấu → e^β → đơn vị/nhóm tham
chiếu → "giữ biến khác cố định". (Nhóm tham chiếu: nữ · ly hôn · Healthcare Rep · không OT.)

---

## SLIDE 14 — Chẩn đoán đa cộng tuyến cấu trúc

**[NÓI]** "Phiên bản đầu của mô hình công việc đưa cả Phòng ban lẫn Chức danh, nhưng
Phòng ban bị lồng hoàn toàn trong Chức danh — mọi Sales Executive đều thuộc Sales — nên
thông tin trùng lặp gần hoàn hảo. Mô hình phát bốn triệu chứng: hệ số phình tới 13–16,
sai số chuẩn hàng trăm tới hơn nghìn, p-value dạt về 1, và Fisher scoring cần 15 vòng
thay vì 5. Nhóm em loại Phòng ban, giữ Chức danh vì nó chi tiết hơn và đã bao phủ thông
tin phòng ban. Sau sửa: hội tụ trong 6 vòng, AIC giảm 783,18 xuống 781,32, GVIF hiệu
chỉnh lớn nhất 2,82 — dưới ngưỡng 5."

**[SỐ]** β 13–16 · SE 510–1.082 · p→1 · 15 vòng → sau sửa: 6 vòng · AIC 783,18→781,32 ·
GVIF max 2,82 (mô hình 1: 1,05).

**[HỎI]**
- *Fisher scoring là gì?* → Thuật toán lặp cực đại hóa log-likelihood (logistic không có
  nghiệm đóng như OLS). Mỗi vòng: đạo hàm bậc nhất chỉ hướng, thông tin Fisher (độ cong
  kỳ vọng) chỉnh cỡ bước; tương đương giải lặp bình phương tối thiểu có trọng số (IRLS).
  Lành mạnh: 5–6 vòng; 15 vòng = mặt likelihood có vùng phẳng do cộng tuyến → dùng làm
  dấu hiệu chẩn đoán.
- *p ≈ 0,99 sao không bỏ luôn biến?* → Bẫy! Khi SE bị phồng, p-value không tin được;
  sau sửa các dummy JobRole có p < 0,05 rõ (Sales Rep p < 0,001).
- *GVIF là gì?* → VIF tổng quát cho nhóm biến giả của biến phân loại; lấy cột
  GVIF^(1/(2·Df)) bình phương lên để so ngưỡng 5. Bảng đầy đủ: **backup B1**.

**[SLIDE KẾ TIẾP] VIF/GVIF trước và sau khi loại Department** (bằng chứng định lượng)

| Biến | TRƯỚC | SAU |
|---|---|---|
| Department | GVIF **3,8×10¹³** ← bệnh | (đã loại) |
| JobRole | GVIF **1,1×10¹⁴** | GVIF **2,935** ← max sau sửa |
| EnvironmentSatisfaction | 1,042 | 1,042 |
| JobSatisfaction | 1,014 | 1,013 |
| OverTime | 1,088 | 1,090 |
| Income_scaled | 2,772 | 2,816 |

**[NÓI]** "Đây là bằng chứng định lượng cho quyết định loại Phòng ban. Trước khi sửa,
GVIF của Phòng ban và Chức danh lên tới cỡ 10¹³–10¹⁴ — hai biến kéo nhau vì thông tin
trùng lặp. Sau khi loại Phòng ban, giá trị lớn nhất chỉ còn 2,94 ở Chức danh, dưới ngưỡng
tham khảo 5. Đáng chú ý là các biến không liên quan như hài lòng hay làm thêm giờ gần như
không đổi — khẳng định cộng tuyến khu trú đúng ở cặp Phòng ban–Chức danh chứ không lan ra
cả mô hình."

**[HỎI]**
- *Sao cột VIF để trống ở Department/JobRole?* → VIF chỉ định nghĩa cho biến **một bậc tự
  do**; biến phân loại nhiều mức chiếm nhiều cột dummy nên không có một VIF đơn lẻ — phải
  dùng GVIF (bản tổng quát). Với biến 1 bậc tự do thì GVIF trùng đúng VIF.
- ⚠ **Nguồn số:** cột SAU có trong báo cáo (chunk `vif_check_updated`). Cột TRƯỚC được tái
  lập từ pipeline seed 123, **báo cáo không in**. Nếu cô hỏi: *"Dạ, bảng sau khi sửa in ở
  mục 2.3; cột trước khi sửa em chạy thêm `vif()` trên đúng đặc tả đầu với cùng seed."*

---

## SLIDE 15 — LASSO: chọn λ bằng 10-fold CV

**[NÓI]** "LASSO cực tiểu hóa log-likelihood âm cộng hình phạt λ nhân tổng trị tuyệt đối
hệ số. Nhờ hình phạt L1 có góc nhọn tại 0, các biến yếu bị co hệ số về đúng 0 — tức vừa
chính quy hóa vừa chọn biến tự động. λ được chọn khách quan bằng 10-fold cross-validation
trên tập train: λ.min cho sai số CV nhỏ nhất, giữ 35 hệ số, dùng cho dự báo; λ.1se là
phương án gọn hơn với 29 biến. Lý do cần LASSO: sau dummy hóa có khoảng 40 cột, nhiều
biến tương quan — tuổi, thâm niên, cấp bậc, thu nhập."

**[SỐ]** λ.min ≈ 0,0030 (log λ ≈ −5,80; 35 hệ số) · λ.1se (log λ ≈ −4,49; 29 biến).

**[HỎI]**
- *Đọc biểu đồ thế nào?* → Trục dưới log λ (phải = phạt mạnh = ít biến); trục trên = số
  biến ≠ 0; trục tung = binomial deviance CV (thấp = tốt); 2 vạch đứt = λ.min và λ.1se.
- *LASSO khác Ridge?* → L1 (|β|) co về đúng 0 → chọn biến; L2 (β²) chỉ co nhỏ.
- *Sao không stepwise?* → Bất ổn, phá suy luận sau chọn biến; L1 + CV khách quan hơn. → **B6**
- *Code?* → `cv.glmnet(x_train, y_train, family="binomial", alpha=1)`; alpha=1 = LASSO;
  dự báo `s="lambda.min"`. glm thường: `glm(formula, family="binomial")`.

---

## SLIDE 16 — Yếu tố công việc cung cấp tín hiệu mạnh nhất

**[NÓI]** "Các odds ratio này lấy từ mô hình công việc. Làm thêm giờ là tín hiệu mạnh
nhất: odds nghỉ việc gấp 4,67 lần so với không làm thêm giờ, giữ các biến khác cố định.
Hai biến hài lòng tác động ngược: mỗi bậc hài lòng môi trường tăng thêm, odds giảm
30,3%; hài lòng công việc giảm 24,8%. Bốn chức danh cần theo dõi là Lab Technician, Sales
Representative, Sales Executive và Human Resources. Đáng chú ý: thu nhập khác biệt rõ ở
EDA nhưng mất ý nghĩa khi đã kiểm soát chức danh — p bằng 0,968 — và LASSO cũng độc lập
co hệ số thu nhập về 0. Đây là liên hệ dự báo, không phải quan hệ nhân quả."

**[SỐ]** OT ×4,67 · EnvSat −30,3%/bậc · JobSat −24,8%/bậc · Income p = 0,968.

**[HỎI]**
- *OR đọc thế nào?* → OR = e^β; nhân vào **odds** (= p/(1−p)), không phải xác suất; nêu
  đủ: đơn vị (1 bậc? 1 SD ≈ 9 năm tuổi? so nhóm tham chiếu nào?) + "giữ biến khác cố định".
  Ví dụ mô hình 1: tuổi OR 0,68/SD (già thêm ~9 năm → odds ×0,68); độc thân OR 2,47 **so
  với nhóm ly hôn**.
- *Lương thấp thì nghỉ — sao bảo lương vô nghĩa?* → Confounding: lương gắn chức danh/thâm
  niên. Wilcoxon đơn biến (p = 2,95e-14) đo liên hệ THÔ; hệ số hồi quy đo đóng góp RIÊNG
  PHẦN sau khi kiểm soát JobRole/OT/hài lòng. Hai câu hỏi khác nhau — không mâu thuẫn.
- *OT có GÂY nghỉ việc?* → Không kết luận nhân quả (dữ liệu quan sát, cắt ngang); là tín
  hiệu liên hệ đủ mạnh để HR ưu tiên rà soát.

---

## SLIDE 17 — LASSO cho kết quả ngoài mẫu tốt nhất

**[NÓI]** "Trên cùng tập test 440 quan sát và cùng ngưỡng 0,30: mô hình nhân khẩu học
AUC 0,656 và chỉ bắt được 19,7% ca nghỉ việc; mô hình công việc lên 0,785 và 46,5%;
LASSO đạt AUC 0,854, accuracy 86,6% và sensitivity 64,8% — cao nhất ở cả ba chỉ số.
Hai mô hình cây thử nghiệm thêm không vượt được: Random Forest 0,802, Gradient Boosting
0,841. Lưu ý accuracy phải so với mức nền 83,88% — mô hình luôn đoán 'ở lại' đã đạt
mức đó mà không bắt được ai; chỉ LASSO vượt nền một cách thực chất."

**[SỐ]** Bảng AUC/Acc/Sens: M1 0,656/0,809/0,197 · M2 0,785/0,818/0,465 ·
**LASSO 0,854/0,866/0,648** · RF 0,802/0,818/0,507 · GBM 0,841/0,859/0,465.
Precision LASSO 0,575 · F1 0,609.

**[HỎI]**
- *AUC tính thế nào, để làm gì?* → Diện tích dưới đường ROC (quét mọi ngưỡng, mỗi ngưỡng
  chấm điểm (Sensitivity, 1−Specificity)). Diễn giải đẹp: xác suất mô hình chấm điểm 1
  người nghỉ việc ngẫu nhiên CAO HƠN 1 người ở lại ngẫu nhiên = 0,854. Không phụ thuộc
  ngưỡng → dùng so sánh mô hình. (Toán học tương đương thống kê Mann–Whitney U — cùng họ
  Wilcoxon dùng ở EDA.)
- *Sensitivity tính thế nào?* → TP/(TP+FN) = 46/71 = 64,8% — trong 71 người thực sự nghỉ,
  bắt trúng 46. Chỉ số vận hành quan trọng nhất vì bỏ sót (FN) là lỗi đắt nhất với HR.
  Confusion matrix đầy đủ @0,30: TP 46 · FN 25 · FP 34 · TN 335 (Spec 90,8%). → **B5**

**[ĐỊNH NGHĨA] Sensitivity & Specificity — cặp chỉ số soi hai nửa ma trận nhầm lẫn**

Confusion matrix @0,30 (LASSO, test 440 người):

|  | Thực tế NGHỈ (71) | Thực tế Ở LẠI (369) |
|---|---|---|
| Dự báo Nghỉ | **TP = 46** ✓ | FP = 34 (báo động giả) |
| Dự báo Ở lại | FN = 25 (bỏ sót!) | **TN = 335** ✓ |

- **Sensitivity (độ nhạy, = Recall)** = TP/(TP+FN) = 46/71 = **64,8%**
  → Trong những người **THỰC SỰ NGHỈ**, mô hình bắt trúng bao nhiêu %?
  Chỉ nhìn cột trái. Sensitivity thấp = bỏ sót nhiều = mất người mà không kịp giữ.
  "Sensitivity" = mức độ *nhạy* với tín hiệu rủi ro.
- **Specificity (độ đặc hiệu)** = TN/(TN+FP) = 335/369 = **90,8%**
  → Trong những người **THỰC SỰ Ở LẠI**, mô hình nhận đúng bao nhiêu %?
  Chỉ nhìn cột phải. Specificity thấp = nhiều báo động giả = HR tốn công đi "giữ chân"
  người vốn không định đi. (1 − Specificity = tỷ lệ báo động giả = trục hoành ROC.)
- **Quan hệ bập bênh:** hạ ngưỡng (0,30 → 0,17) thì Sensitivity tăng, Specificity giảm —
  cảnh báo rộng tay hơn thì bắt được nhiều người nghỉ hơn nhưng cũng oan nhiều người ở lại
  hơn. Đường ROC chính là bản đồ của sự đánh đổi này trên mọi ngưỡng.
- **Mẹo nhớ:** Sensitivity soi nhóm **bệnh** (nghỉ việc), Specificity soi nhóm **lành**
  (ở lại) — thuật ngữ mượn từ y khoa: test nhạy thì ít sót bệnh, test đặc hiệu thì ít
  chẩn oan người khỏe.
- *Sao RF thua LASSO — overfitting à?* → Không kết luận được (chưa so train/CV vs test);
  khả năng hợp lý hơn: dữ liệu khá tuyến tính sau dummy hóa, mẫu 1.030 nhỏ cho cây,
  class weight 1:5 đánh đổi precision (0,444). → **B2**

---

## SLIDE — Chọn ngưỡng quyết định 0,30 bằng tiêu chí F1

**[NÓI]** "Mô hình xuất xác suất; muốn ra nhãn phải chọn ngưỡng cắt. Ngưỡng 0,5 mặc
định không phù hợp vì lớp nghỉ việc chỉ chiếm 16% — cắt tại 0,5 sẽ bỏ sót phần lớn ca
rủi ro. Nhóm em quét dãy ngưỡng từ 0,05 đến 0,80 và chọn 0,30 theo tiêu chí cực đại
F1 — điểm cân bằng giữa phát hiện và báo động giả. Tại ngưỡng này F1 đạt 0,609,
sensitivity 64,8% và specificity 90,8%."

**[SỐ]** 0,30: F1 max = 0,609 · Sens 64,8% · Spec 90,8%.

**[HỎI]**
- *Sao lại tin F1?* → F1 = trung bình điều hòa precision–recall, phù hợp lớp thiểu số:
  phạt cả bỏ sót lẫn báo động giả, không bị lớp đa số thổi phồng như accuracy.
- *Có tiêu chí khác không?* → Có, đã khảo sát ở phụ lục B3: Youden's J và hàm chi phí
  giả định (FN 15k/FP 1k USD) cho ngưỡng thấp hơn ≈ 0,17 — nếu tổ chức coi bỏ sót là
  cực đắt thì hạ ngưỡng; ngưỡng là quyết định kinh doanh, 0,30 là lựa chọn cân bằng.
- *Điểm yếu?* → Tự nhận: ngưỡng đang khảo sát trên test; chuẩn hơn phải chọn trên
  validation riêng / nested CV — đã ghi ở slide giới hạn.

---

## SLIDE 19 — Từ mô hình đến hành động HR

**[NÓI]** "Bốn nhóm hành động, bám đúng các biến can thiệp được: một — kiểm soát làm
thêm giờ, theo dõi OT theo nhóm và phân bổ lại tải việc; hai — can thiệp theo chức danh,
stay interview cho các vai trò rủi ro cao; ba — cải thiện trải nghiệm: hài lòng, lộ
trình, luân chuyển; bốn — hệ thống cảnh báo sớm nhưng luôn có con người rà soát. Nhóm em
nhấn mạnh: không dùng điểm rủi ro để kỷ luật hay sa thải tự động — cần kiểm tra fairness,
quyền riêng tư và cơ sở pháp lý trước khi triển khai."

**[HỎI]** *Dùng thực tế thế nào?* → Chấm điểm định kỳ + hai tầng ngưỡng + HR nói chuyện
1-1; hiệu chỉnh ngưỡng bằng chi phí thật của tổ chức.

---

## SLIDE 20 — Giới hạn cần xử lý trước khi triển khai

**[NÓI]** "Bốn giới hạn. Tính đại diện: dữ liệu IBM là mô phỏng, lát cắt ngang, không có
thời gian đến khi nghỉ việc. Đánh giá hiệu suất: ngưỡng đang khảo sát trên test, cần
chuyển sang validation hoặc nested CV. Độ tin cậy xác suất: cần bổ sung PR-AUC, Brier
score, calibration curve và khoảng tin cậy bootstrap cho AUC. Và quản trị mô hình: kiểm
định trên dữ liệu thật, theo dõi drift và fairness."

**[HỎI]** *Mô hình đủ tốt chưa?* → Trả lời 2 vế: (1) Trong phạm vi đồ án: đạt — AUC
0,854, bắt 2/3 ca nghỉ thay vì 0, quy trình không rò rỉ, thắng RF/GBM. (2) Để triển
khai: chưa — đọc đúng 4 giới hạn trên. Chốt: "tốt như minh chứng quy trình và điểm khởi
đầu, chưa phải hệ thống sẵn sàng vận hành."
(CI 95% accuracy LASSO: [0,830; 0,896] so nền 0,839 — điểm tựa khi bị hỏi độ tin cậy. → **B4**)

---

## SLIDE 21 — Ba kết luận chính

**[NÓI — cũng là đáp án khi cô bảo "tổng hợp lại"]**
1. "Điều kiện công việc quan trọng hơn nhân khẩu học — làm thêm giờ, sự hài lòng và chức
   danh cho tín hiệu dự báo rõ nhất."
2. "LASSO là lựa chọn cân bằng nhất — AUC 0,854, sensitivity 64,8%, F1 0,609 tại ngưỡng 0,30."
3. "Mô hình là công cụ hỗ trợ can thiệp — ưu tiên cải thiện tải việc và trải nghiệm,
   không tự động gắn nhãn hay ra quyết định bất lợi."

---

# PHẦN RIÊNG — DIỄN GIẢI HỆ SỐ β THEO ODDS

> Đây là kỹ năng bị hỏi nhiều nhất. Cô có thể chỉ vào **bất kỳ dòng nào** của bảng hệ số
> và bảo "đọc dòng này cho cô". Học thuộc cái thang 3 bậc + câu mẫu 4 thành phần là trả
> lời được mọi dòng.

## 1. Thang 3 bậc: từ β đến câu nói

| Bậc | Đại lượng | Công thức | Ví dụ OverTime (β = 1,542) |
|---|---|---|---|
| ① | **β** — thay đổi của **log-odds** | hệ số in trong bảng | 1,542 (log-odds tăng 1,542) |
| ② | **OR** — odds nhân lên mấy lần | **OR = e^β** | e^1,542 = **4,67 lần** |
| ③ | **% đổi** của odds | (e^β − 1)×100% | +367% |

Dấu của β cho hướng ngay: **β > 0 → OR > 1 → tăng rủi ro**; **β < 0 → OR < 1 → giảm rủi ro**;
β = 0 → OR = 1 → không tác dụng.

## 2. Câu mẫu 4 thành phần (thiếu 1 là bị bắt lỗi)

> **"[Nhóm/đơn vị thay đổi]** có **odds** nghỉ việc **[gấp X lần / giảm Y%]**
> **so với [nhóm tham chiếu]**, khi **giữ các biến khác cố định**."

① nói **odds** (không nói "khả năng/xác suất") · ② đúng **đơn vị** của biến ·
③ nêu **nhóm tham chiếu** nếu là dummy · ④ kèm **"giữ các biến khác cố định"**.

## 3. Bốn ví dụ mẫu — phủ đủ 4 kiểu biến

**(a) Dummy 0/1** — `OverTime`, β = +1,542 → OR = 4,67
> "Nhân viên **phải làm thêm giờ** có **odds** nghỉ việc **gấp 4,67 lần** **so với nhóm
> không làm thêm giờ**, khi **giữ các biến khác cố định**."

**(b) Dummy nhiều mức** — `MaritalStatus: Single`, β = +0,906 → OR = 2,47
> "Nhân viên **độc thân** có odds nghỉ việc **gấp 2,47 lần** **so với nhóm tham chiếu là
> người đã ly hôn**, giữ các biến khác cố định."
> (JobRole so với **Healthcare Representative**: Sales Rep β = 2,25 → OR ≈ 9,5.)

**(c) Biến liên tục đã chuẩn hóa** — `Age_scaled`, β = −0,390 → OR = 0,68
> "Tuổi tăng thêm **1 độ lệch chuẩn, tức khoảng 9 năm**, thì odds nghỉ việc **nhân 0,68 —
> giảm khoảng 32%**, giữ các biến khác cố định."

**(d) Thang bậc (Likert 1–4)** — `EnvironmentSatisfaction`, β = −0,362 → OR = 0,70
> "**Mỗi bậc** hài lòng môi trường tăng thêm, odds nghỉ việc **giảm khoảng 30%**, giữ các
> biến khác cố định." (JobSatisfaction β = −0,285 → OR 0,75 → giảm ~25%.)

## 4. Ba biến thể hay bị hỏi thêm

- **Tăng c đơn vị:** OR = e^(c·β) — **nhân chứ không cộng**. VD `DistanceFromHome`
  β = 0,0304: xa thêm 10 km → e^0,304 ≈ 1,36 → odds tăng ~36% (KHÔNG phải 3,1%×10 = 31%).
- **Khoảng tin cậy của OR:** lũy thừa hai đầu CI của β → [e^(β−1,96·SE); e^(β+1,96·SE)].
  VD OverTime: e^(1,542 ± 1,96×0,195) → OR ∈ **[3,19; 6,85]**. Không chứa 1 ⟺ p < 0,05
  (vì OR = 1 tương đương β = 0).
- **Đổi ra xác suất (nếu cô ép):** odds → p = odds/(1+odds). VD người gốc của mô hình 2
  có β₀ = −1,444 → odds 0,236 → p ≈ 19%; nếu người đó làm thêm giờ: odds 0,236×4,67 =
  1,10 → p ≈ 52%. Lưu ý: cùng một OR cho ra mức tăng xác suất **khác nhau** tùy điểm xuất
  phát — đó chính là lý do phải nói "odds" chứ không nói "xác suất gấp 4,67 lần".

## 5. Nhẩm nhanh e^β (để phản xạ trước bảng hệ số)

| β | e^β | Mẹo |
|---|---|---|
| 0 | 1 | không tác dụng |
| ±0,1 | 1,10 / 0,90 | \|β\| < 0,2: %đổi ≈ β×100 |
| **±0,7** | **2 / 0,5** | **mốc vàng: β ≈ 0,7 → odds gấp đôi** |
| ±1,6 | 5 / 0,2 | OverTime 1,54 → gần 5 |
| ±2,3 | 10 / 0,1 | Sales Rep 2,25 → gần 10 |

Kiểm chứng: Single β = 0,906 ≈ 0,7 + 0,2 → 2 × 1,22 ≈ 2,45 (thực tế 2,47 ✓).

## 6. Bốn lỗi chết người khi diễn giải

1. ❌ "khả năng/xác suất gấp 4,67 lần" → ✅ "**odds** gấp 4,67 lần".
2. ❌ quên nhóm tham chiếu ("độc thân gấp 2,47 lần" — gấp so với ai?).
3. ❌ quên đơn vị chuẩn hóa (Age là **1 SD ≈ 9 năm**, không phải 1 năm).
4. ❌ nói nhân quả ("làm thêm giờ **gây** nghỉ việc") → ✅ "**liên hệ** với odds cao hơn".

⚠ Và nhớ: mọi OR ở trên lấy từ **mô hình 2 (logistic không phạt)**; hệ số LASSO bị co
nên không kèm p-value và không diễn giải theo cách này.

# KHO Q&A TRẢ LỜI NHANH (flashcard — che cột phải tự kiểm tra)

| Hỏi | Đáp lõi |
|---|---|
| Em làm gì trong bài? | Chia 70/30 sạch → so 3 logistic (đối chứng/diễn giải/dự báo) → LASSO thắng test (AUC 0,854, Sens 64,8%) → khảo sát ngưỡng 3 tiêu chí → hành động HR + giới hạn. |
| logit là gì? | log(odds) = log[p/(1−p)]; cầu nối để xác suất [0,1] khớp với tổ hợp tuyến tính (−∞,∞). |
| Odds vs xác suất? | odds = p/(1−p). p=0,2 → odds 0,25 ("1 ăn 4"). OR nhân vào odds, KHÔNG nhân vào p. |
| OR = ? | e^β. >1 tăng rủi ro, <1 giảm. Luôn kèm: đơn vị + nhóm tham chiếu + "giữ biến khác cố định". |
| Có phải OLS? | Không — OLS cho y liên tục. Logistic = MLE (Fisher scoring); LASSO = MLE có phạt L1. |
| MLE là gì? | Tìm β làm dữ liệu quan sát "hợp lý nhất": max Σ[y·log p + (1−y)·log(1−p)]. |
| Fisher scoring? | Thuật toán lặp leo dốc likelihood (score chỉ hướng, thông tin Fisher chỉnh bước) ≈ IRLS. 5–6 vòng bình thường; 15 vòng = báo động cộng tuyến. |
| Dummy full rank? | K mức → K−1 cột, tránh bẫy biến giả (K cột cộng = 1 trùng intercept); hệ số đọc so nhóm tham chiếu. |
| Đa cộng tuyến cấu trúc? | Department lồng trong JobRole → trùng tin gần hoàn hảo; 4 triệu chứng: β 13–16, SE 510–1.082, p→1, 15 vòng. Sửa: bỏ Department. GVIF max 2,82 < 5. |
| GVIF? | VIF tổng quát cho nhóm dummy; bình phương cột GVIF^(1/(2Df)) để so ngưỡng 5. |
| Vì sao LASSO? | ~40 cột tương quan → L1 vừa chính quy hóa vừa chọn biến tự động (λ bằng CV); bằng chứng: thắng mọi mô hình trên test. |
| LASSO vs Ridge? | L1 co về ĐÚNG 0 (chọn biến) vs L2 chỉ co nhỏ. |
| λ.min vs λ.1se? | min: sai số CV nhỏ nhất, 35 hệ số, dùng dự báo. 1se: gọn hơn (29), đối chứng triển khai đơn giản. |
| LASSO có bảng hồi quy không? | Có phương trình + 35 hệ số (B7: BusinessTravel +1,77, OT +1,67…) nhưng KHÔNG có SE/p — hệ số co lệch khỏi MLE nên suy luận cổ điển không áp dụng; diễn giải thì dùng mô hình 2. |
| Vì sao LASSO không có AIC? | AIC cần likelihood tại cực đại MLE + số tham số rõ; LASSO phạt nên cả hai không còn đúng → dùng CV (đo trực tiếp thứ AIC xấp xỉ). |
| Sao không có R²? | R² thuộc OLS (tổng bình phương phần dư). Logistic thay bằng: deviance (M1: rỗng 909,69 → 844,89), LRT (Δ=64,8, df 6, p<0,001), AIC; muốn số kiểu R² thì pseudo-R² McFadden = 1−844,89/909,69 ≈ 0,07 (thang khác: 0,2–0,4 đã là rất tốt). Mục tiêu là dự báo → ưu tiên AUC ngoài mẫu. |
| AUC? | Diện tích dưới ROC = P(chấm điểm người nghỉ > người ở lại) = 0,854; không phụ thuộc ngưỡng, dùng so mô hình. |
| Sensitivity? | TP/(TP+FN) = 46/71 = 64,8% — trong người THỰC SỰ nghỉ, bắt trúng bao nhiêu %; đo tỷ lệ bỏ sót — lỗi đắt nhất với HR. |
| Specificity? | TN/(TN+FP) = 335/369 = 90,8% — trong người THỰC SỰ ở lại, nhận đúng bao nhiêu %; 1−Spec = tỷ lệ báo động giả. Hạ ngưỡng → Sens tăng, Spec giảm (bập bênh). |
| Sao không dùng accuracy? | Baseline "luôn đoán No" = 83,88% mà bắt 0 ca. Thứ tự metric: AUC → Sens → F1 → Acc. |
| Ngưỡng 0,30? | F1 max (= 0,609) trong dãy quét 0,05–0,80 — cân bằng phát hiện vs báo động giả; tiêu chí thay thế (Youden, chi phí → ≈0,17) ở phụ lục B3 nếu bị hỏi. |
| Sao không SMOTE? | Đã xử lý bằng phân tầng + hạ ngưỡng + metric phù hợp + class weight (RF); giữ phân phối gốc để xác suất thật; SMOTE là hướng cải thiện đã nêu. |
| Thu nhập nghịch lý? | EDA p=2,95e-14 (liên hệ thô) vs model p=0,968 (đóng góp riêng sau kiểm soát JobRole/OT) = confounding; LASSO cũng co về 0. |
| Nhân quả? | Không — dữ liệu quan sát, cắt ngang; chỉ là liên hệ dự báo. |
| Wilcoxon sao không t-test? | Shapiro–Wilk bác bỏ chuẩn (thu nhập lệch phải, mean 6.503 > median 4.919) → chọn phi tham số. |
| Capping outlier là gì? | Ghi đè lương vượt Q3+1,5·IQR (trần train ≈ 16.563 USD) thành đúng trần — 74 ca train/40 ca test; KHÔNG xóa dòng, KHÔNG loại biến; giữ người, kìm đòn bẩy; ranh giới tính từ train. |
| Đủ tốt chưa? | 2 vế: đạt trong phạm vi đồ án / chưa đủ triển khai (4 giới hạn slide 20). |

---

# BẢNG SỐ THUỘC LÒNG

| Nhóm | Số |
|---|---|
| Mẫu | 1.470 · Yes 237 (16,12%) · train 1.030 (166) / test 440 (71) · seed 123 |
| AUC test | 0,656 · 0,785 · **0,854** · RF 0,802 · GBM 0,841 |
| LASSO @0,30 | Sens 64,8 · Spec 90,8 · Prec 57,5 · F1 0,609 · Acc 86,6 (nền 83,88) |
| Confusion | TP 46 · FN 25 · FP 34 · TN 335 |
| OR mô hình 2 | OT 4,67 · EnvSat −30,3%/bậc · JobSat −24,8%/bậc · Income p 0,968 |
| OR mô hình 1 | Tuổi 0,68/SD (~9 năm) · Độc thân 2,47 (vs ly hôn) · Distance +3,1%/km |
| LASSO | λ.min ≈ 0,0030 → 35 hệ số · λ.1se → 29 biến · top: BusinessTravel +1,77, OT +1,67 |
| Cộng tuyến | β 13–16 · SE 510–1.082 · 15→6 vòng · AIC 783,18→781,32 · GVIF 2,82 (M1 1,05) |
| AIC | M1 858,89 · M2 781,32 (LASSO: không có — dùng CV) |
| Ngưỡng | 0,30 (F1) · 0,17 (Youden + chi phí FN 15k/FP 1k) |
| EDA | Wilcoxon p 2,95e-14 · Chi-square p 0,0045 · tuổi TB nghỉ 33,6 vs ở lại 37,6 |

# BẪY PHÁT NGÔN — TUYỆT ĐỐI TRÁNH

1. ❌ "OT **gây** nghỉ việc" → ✅ "**liên hệ** mạnh; không kết luận nhân quả."
2. ❌ "khả năng gấp 4,67 lần" → ✅ "**odds** gấp 4,67 lần."
3. ❌ Quên nhóm tham chiếu (Single 2,47 là **vs ly hôn**; JobRole vs Healthcare Rep).
4. ❌ "Accuracy 86,6% nên mô hình tốt" → ✅ so với nền 83,88%; ưu tiên AUC/Sens/F1.
5. ❌ Đọc OR như hệ số LASSO → ✅ OR từ **mô hình 2**; LASSO không có p-value.
6. ❌ "0,30 là ngưỡng tối ưu" (tuyệt đối) → ✅ "tối ưu **theo F1**; tiêu chí khác chọn 0,17;
   và ngưỡng đang khảo sát trên test."
7. ❌ "RF bị overfitting" → ✅ "chưa đủ bằng chứng; chưa so train/CV với test."
8. ❌ "Hồi quy logistic OLS" (có trong Rmd — lỗi dùng từ) → ✅ "logistic không phạt / MLE thuần."
9. ❌ Hứa triển khai được ngay → ✅ luôn kèm giới hạn slide 20.

# MAP SLIDE BACKUP (bị hỏi sâu thì bật)

B1 VIF/GVIF đầy đủ · B2 RF/GBM chi tiết · B3 ba tiêu chí ngưỡng · B4 mất cân bằng + CI ·
B5 confusion matrix LASSO · B6 vì sao chọn phương pháp · B7 LASSO giữ biến nào ·
(Lưu ý cấu trúc mới của mạch chính: bảng OUTPUT ĐẦY ĐỦ của đặc tả đầu còn Department —
nguồn của β 13–16 / SE 510–1.082 / p→1 / 15 vòng — giờ là slide NGAY TRƯỚC slide chẩn
đoán đa cộng tuyến; hai bảng hệ số mô hình 1 & 2 sau sửa nằm ngay sau slide chẩn đoán;
backup B8 hiện là "AIC và các giả định".)
