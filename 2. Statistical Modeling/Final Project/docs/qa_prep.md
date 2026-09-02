# Chuẩn bị hỏi–đáp: Phân tích HR Employee Attrition

Tài liệu ôn trước buổi bảo vệ. Mỗi câu gồm: câu hỏi cô có thể hỏi → ý trả lời
(3–5 câu, nói được trong ~30 giây) → slide backup cần bật (nếu có).
Mọi con số đã đối chiếu với báo cáo và tái lập từ pipeline (seed 123).

---

## Nhóm 1 — Ngưỡng phân loại và mất cân bằng lớp

**1. Vì sao chọn ngưỡng 0,30 mà không phải 0,5?**
Lớp nghỉ việc chỉ chiếm 16,12%, nên ngưỡng 0,5 mặc định bỏ sót phần lớn ca nghỉ
việc trong khi chi phí bỏ sót (mất nhân viên) cao hơn nhiều chi phí báo động nhầm.
Chúng em quét ngưỡng từ 0,05 đến 0,80 theo ba tiêu chí: F1 cực đại chọn 0,30;
Youden's J và hàm chi phí giả định (FN = 15.000 USD, FP = 1.000 USD) cùng chọn 0,17.
Kết luận trong báo cáo là không có ngưỡng tối ưu duy nhất — 0,30 được dùng làm
ngưỡng cân bằng, 0,17 cho tầng theo dõi rộng. → **Backup B3**

**2. Vì sao không dùng SMOTE/ROSE để xử lý mất cân bằng?**
Chúng em chủ động xử lý bằng ba cách khác: chia phân tầng giữ đúng tỷ lệ 16% ở cả
hai tập, hạ ngưỡng quyết định về 0,30, và chọn metric nhạy với lớp thiểu số
(AUC, sensitivity, F1) thay cho accuracy; Random Forest dùng thêm trọng số lớp 1:5.
Giữ phân phối gốc giúp xác suất dự báo phản ánh tỷ lệ thật; mẫu tổng hợp của SMOTE
có rủi ro thêm nhiễu. SMOTE/ROSE được nêu trong báo cáo là hướng cải thiện tiếp theo,
tức có cân nhắc chứ không phải bỏ sót. → **Backup B4**

**3. Chỉ chia train/test một lần thì kết quả có đáng tin không?**
Đúng là mọi chỉ số là ước lượng điểm trên một lần chia 70/30 (seed 123) — chúng em
thừa nhận điều này trong phần giới hạn. Điểm tựa hiện có: chia phân tầng, tập test
440 quan sát, và khoảng tin cậy 95% cho accuracy của LASSO là [0,830; 0,896], cao hơn
đáng kể mức nền 0,839 ở cận trên và cạnh tranh ở cận dưới. Hướng nâng cấp đã nêu:
repeated k-fold CV cho toàn pipeline và bootstrap CI cho AUC. → **Backup B4, B5**

**4. Accuracy 86,6% chỉ nhỉnh hơn baseline 83,88% một chút, có đáng kể không?**
Accuracy không phải thước đo chính vì baseline "luôn dự báo ở lại" đạt 83,88% nhưng
phát hiện 0% ca nghỉ việc. Giá trị của mô hình nằm ở sensitivity 64,8% và F1 0,609
tại cùng mức accuracy — tức phát hiện được gần 2/3 ca nghỉ việc thay vì 0%.
Trong ba mô hình logistic, chỉ LASSO vượt baseline về accuracy, nhưng thứ tự ưu tiên
metric của chúng em là AUC → sensitivity → F1 → accuracy. → **Backup B5**

## Nhóm 2 — LASSO và lựa chọn mô hình

**5. LASSO giữ lại những biến nào?**
Tại λ.min có 35 hệ số khác 0. Nhóm hệ số dương lớn nhất: BusinessTravel-Frequently
(+1,77), OverTime (+1,67), Sales Representative (+1,08), Độc thân (+0,95),
Laboratory Technician (+0,94); nhóm âm mạnh: Research Director (−0,93),
JobInvolvement (−0,39), hai biến hài lòng (−0,38/−0,34), WorkLifeBalance (−0,27).
Đáng chú ý: thu nhập bị co về đúng 0 — nhất quán với p = 0,968 ở mô hình công việc.
→ **Backup B7**

**6. Vì sao dùng λ.min mà không phải λ.1se?**
Mục tiêu chính của mô hình 3 là năng lực dự báo, nên chọn λ.min (sai số CV nhỏ nhất,
giữ 35 hệ số). λ.1se giữ 29 biến, đơn giản và ổn định hơn, được báo cáo làm đối chứng
cho phương án triển khai gọn — báo cáo nêu rõ cả hai và lý do chọn. → **Backup B6, slide LASSO CV**

**7. Vì sao không dùng stepwise/AIC để chọn biến?**
Stepwise không ổn định (kết quả đổi theo thứ tự đưa biến vào) và làm sai lệch suy luận
sau chọn biến — p-value in ra không còn đúng nghĩa. Phạt L1 của LASSO là cách chọn biến
có kiểm soát chính quy hóa, tham số phạt chọn khách quan bằng 10-fold CV. → **Backup B6**

**8. Vì sao trục chính là logistic mà không phải ML (RF/GBM)?**
Vì bài toán HR cần diễn giải được: hệ số logistic chuyển thành odds ratio để nói chuyện
với bộ phận nhân sự. Đồng thời kết quả thực nghiệm ủng hộ: LASSO đạt AUC 0,854, cao hơn
cả Random Forest (0,802) lẫn GBM (0,841) trên cùng tập test. → **Backup B2**

**9. Vì sao Random Forest thua LASSO? Có phải overfitting?**
Chúng em không kết luận overfitting vì chưa so sánh hiệu suất train/CV với test — báo cáo
ghi rõ điều này. Khả năng hợp lý hơn: quan hệ trong dữ liệu này khá tuyến tính sau khi
dummy hóa, cỡ mẫu 1.030 chưa đủ cho cây học sâu, và trọng số lớp 1:5 đánh đổi precision
(0,444) để tăng recall. → **Backup B2**

## Nhóm 3 — Giả định và chẩn đoán mô hình

**10. Các giả định của hồi quy logistic đã kiểm tra chưa?**
Bốn giả định: (1) biến phản hồi nhị phân — thỏa; (2) quan sát độc lập — thỏa, mỗi dòng
một nhân viên; (3) không đa cộng tuyến nặng — kiểm tra bằng GVIF, lớn nhất ≈ 1,05 (mô hình 1)
và ≈ 2,82 (mô hình 2), đều dưới 5; (4) tuyến tính trên thang logit — chưa kiểm tra thực nghiệm,
chúng em thừa nhận đây là giới hạn và nêu binned residual plot là bước tiếp theo;
LASSO một phần giảm rủi ro này qua chính quy hóa. → **Backup B1**

**11. Đa cộng tuyến được xử lý thế nào? (câu chuyện Department)**
Phiên bản đầu của mô hình công việc đưa cả Department lẫn JobRole: hệ số phình tới 13–16,
sai số chuẩn 510–1.082, p → 1, Fisher scoring cần 15 vòng — dấu hiệu suy biến do
Department lồng hoàn toàn trong JobRole (mọi Sales Executive đều thuộc Sales).
Xử lý: loại Department, giữ JobRole chi tiết hơn; sau sửa hội tụ trong 6 vòng,
AIC giảm 783,18 → 781,32, GVIF quy đổi lớn nhất 2,82 < 5. → **Slide chính + Backup B1**

**12. Vì sao thu nhập khác biệt rõ ở EDA (p = 2,95e-14) nhưng mất ý nghĩa trong mô hình (p = 0,968)?**
Đây là minh họa kinh điển của confounding: thu nhập gắn chặt với chức danh và thâm niên.
Khi mô hình đã kiểm soát JobRole, OverTime và mức hài lòng, thu nhập không còn đóng góp
thông tin riêng. Kiểm định đơn biến đo liên hệ thô; hệ số hồi quy đo đóng góp riêng phần —
hai câu hỏi khác nhau, không mâu thuẫn. LASSO cũng độc lập co hệ số thu nhập về 0.

**13. Vì sao dùng Wilcoxon mà không phải t-test?**
Shapiro–Wilk bác bỏ tính chuẩn của thu nhập trong nhóm nghỉ việc (thu nhập lệch phải mạnh,
trung bình 6.503 > trung vị 4.919), nên t-test không phù hợp; Wilcoxon rank-sum là lựa chọn
phi tham số tương ứng. Trình tự "kiểm tra giả định trước, chọn phép kiểm sau" là chủ đích
của quy trình.

**14. Đây có phải quan hệ nhân quả không?**
Không. Dữ liệu quan sát, cắt ngang, không có can thiệp ngẫu nhiên — mọi kết quả là liên hệ
dự báo. Báo cáo và slide đều ghi chú rõ (ví dụ OR của OverTime là tín hiệu liên hệ, không
chứng minh làm thêm giờ *gây* nghỉ việc). Đề xuất HR vì vậy tập trung vào điều kiện có thể
cải thiện và luôn cần con người rà soát.

## Nhóm 4 — Dữ liệu và quy trình

**15. Pipeline có rò rỉ dữ liệu không?**
Không, và đây là điểm chúng em làm kỹ: ranh giới IQR capping, tham số chuẩn hóa
(center/scale) và bộ mã hóa dummy đều fit chỉ trên train rồi áp lại cho test; các biến
dẫn xuất tính trước khi chia đã bị xóa và tính lại. Có `stopifnot` kiểm chứng tự động:
train mean ≈ 0, sd ≈ 1, cột train/test trùng khớp.

**16. Chi phí FN = 15.000 USD, FP = 1.000 USD lấy từ đâu?**
Là giả định minh họa dựa trên thực tế chi phí thay thế một nhân viên (tuyển dụng, đào tạo,
mất năng suất) lớn hơn nhiều chi phí một buổi trao đổi giữ chân. Thông điệp chính không phụ
thuộc con số cụ thể: khi FN đắt hơn FP nhiều lần, ngưỡng tối ưu chi phí tụt xuống ~0,17.
Khi triển khai cần thay bằng chi phí thực của tổ chức. → **Backup B3**

**17. Dữ liệu là mô phỏng (fictional) thì phân tích còn ý nghĩa gì?**
Bộ IBM HR Analytics là dữ liệu mô phỏng chuẩn của Kaggle, phù hợp cho mục tiêu môn học:
trình diễn quy trình mô hình hóa thống kê đúng chuẩn (EDA → kiểm định → pipeline không rò rỉ
→ so sánh mô hình → chọn ngưỡng). Kết luận quản trị mang tính minh họa; báo cáo ghi rõ cần
kiểm định lại trên dữ liệu thật trước khi áp dụng.

**18. Mô hình đã triển khai thực tế được chưa?**
Chưa, và slide giới hạn nói thẳng điều đó: cần dữ liệu thật có yếu tố thời gian,
chọn ngưỡng trên validation thay vì test, bổ sung PR-AUC/calibration/bootstrap CI,
và kiểm tra fairness + cơ sở pháp lý. Mô hình chỉ nên là công cụ hỗ trợ, không tự động
ra quyết định bất lợi cho nhân viên.

**19. (Nếu bị soi kỹ) Trong ma trận LASSO có cả Age lẫn Age_scaled?**
Đúng — do bước tiền xử lý giữ cả biến gốc và biến chuẩn hóa, hai cột cộng tuyến hoàn hảo
cùng vào LASSO (Age −0,013 và Age_scaled −0,055 chia sẻ hệ số). Với phạt L1 điều này
không phá mô hình (LASSO xử lý được cộng tuyến), tổng tín hiệu "tuổi tăng — nguy cơ giảm"
không đổi, nhưng bản làm sạch nên bỏ biến gốc — chúng em ghi nhận là điểm cải thiện.

---

## Ghi nhớ nhanh các con số

| Chỉ số | Giá trị |
|---|---|
| Mẫu | 1.470 nhân viên, 35 biến; No/Yes = 1.233/237 (16,12%) |
| Chia dữ liệu | 70/30 phân tầng, seed 123 → train 1.030 (166 Yes), test 440 (71 Yes) |
| Kiểm định | Wilcoxon p = 2,95e-14; Chi-square p = 0,0045 |
| Mô hình 1 | AUC 0,656; AIC 858,89; Tuổi OR 0,68; Độc thân OR 2,47 |
| Mô hình 2 | AUC 0,785; AIC 781,32; OverTime OR 4,67; hài lòng −30,3%/−24,8% |
| LASSO | AUC 0,854; λ.min ≈ 0,0030 (35 hệ số); λ.1se (29 biến) |
| Test @0,30 | TP 46, FN 25, FP 34, TN 335 → Sens 64,8%, Spec 90,8%, Prec 57,5%, F1 0,609 |
| RF / GBM | AUC 0,802 / 0,841 |
| GVIF | M1 max ≈ 1,05; M2 max ≈ 2,82 (đều < 5) |
