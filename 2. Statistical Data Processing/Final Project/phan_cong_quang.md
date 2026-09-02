# OCR đề bài và phân công công việc của Quang

Nguồn:

- `Đồ Án - Xử Lý Số Liệu Thống Kê.pdf`
- `de_xuat_phan_tich_clickstream.Rmd`

> Bản OCR dưới đây giữ nguyên nội dung của PDF, đồng thời chuẩn hóa lỗi xuống
> dòng, ký hiệu công thức và bố cục để dễ đọc trong Markdown.

---

# 1. Bản OCR đầy đủ của PDF

## Trang 1

## Phần 1: Giới thiệu chung và Bản đề xuất phân tích

**Người phụ trách: NGHI**

Phần này giải quyết yêu cầu 1, 2 và 3.

### 1.1. Giới thiệu bộ dữ liệu

- Mô tả nguồn gốc dữ liệu, ngữ cảnh và lý do chọn bộ dữ liệu này.
- Giải thích ý nghĩa các biến số quan trọng, đặc biệt là các biến mục tiêu
  (target variables).

### 1.2. Các mục tiêu phân tích (Yêu cầu 2)

- Mục tiêu 1: Ví dụ, kiểm định sự khác biệt về doanh thu giữa hai nhóm khách
  hàng — sử dụng A/B Testing.
- Mục tiêu 2: Ví dụ, dự đoán giá trị đơn hàng hoặc doanh thu trong tương lai —
  sử dụng Linear Regression, GLM, GAM.
- Mục tiêu 3: Ví dụ, phân loại khách hàng có khả năng rời bỏ dịch vụ hay không
  — sử dụng mô hình phân loại.

### 1.3. Phương pháp và chiến lược phân tích (Yêu cầu 1 & 3)

Trình bày các bước thực hiện cho từng mục tiêu đã nêu trên:

- Chiến lược cho Mục tiêu 1:
  - Thiết lập giả thuyết \(H_0\) và \(H_1\).
  - Chọn mức ý nghĩa.
  - Thực hiện A/B Testing.
- Chiến lược cho Mục tiêu 2:
  - Tiền xử lý biến liên tục.
  - Xây dựng lần lượt các mô hình Linear Regression, GLM, GAM.
  - Đánh giá và so sánh hiệu suất các mô hình dựa trên \(R^2\), RMSE, AIC...
- Chiến lược cho Mục tiêu 3:
  - Xử lý mất cân bằng dữ liệu nếu có.
  - Xây dựng mô hình phân loại, chẳng hạn Logistic Regression.
  - Đánh giá mô hình bằng Confusion Matrix, Accuracy, Precision và Recall.

## Phần 2: Khám phá và Tổng hợp dữ liệu (EDA)

**Người phụ trách: NHƯ**

Phần này giải quyết yêu cầu 4.

### 2.1. Làm sạch dữ liệu (Data Cleaning)

- Báo cáo nhanh về việc xử lý dữ liệu khuyết thiếu (missing values), dữ liệu
  ngoại lai (outliers) và chuyển đổi kiểu dữ liệu.

### 2.2. Thống kê mô tả (Bảng tổng hợp)

- Trình bày bảng thống kê các đại lượng cơ bản (Mean, Median, Min, Max, độ lệch
  chuẩn) cho các biến liên tục.
- Lập bảng tần số cho các biến phân loại.

## Trang 2

### 2.3. Trực quan hóa dữ liệu (Biểu đồ)

- Biểu đồ phân phối của các biến quan trọng (Histogram, Bar chart).
- Biểu đồ thể hiện mối quan hệ giữa các biến (Scatter plot, Boxplot,
  Correlation matrix).
- Lưu ý: Chèn biểu đồ đẹp, có chú thích rõ ràng.

## Phần 3: Kết quả phân tích và Mô hình hóa

**Người phụ trách: QUANG**

Phần này giải quyết yêu cầu 5. Chỉ đưa ra bảng kết quả và biểu đồ, tuyệt đối
không dán code vào phần này.

### 3.1. Kết quả A/B Testing

- Trình bày bảng kết quả kiểm định (p-value, t-statistic...).
- Trình bày biểu đồ so sánh giữa hai nhóm.

### 3.2. Kết quả mô hình dự đoán (Linear Regression, GLM, GAM)

- Bảng tổng hợp so sánh các chỉ số đánh giá của ba mô hình. Ví dụ, bảng gồm các
  cột Model, \(R^2\), RMSE, AIC/BIC.
- Biểu đồ:
  - Đồ thị phần dư (Residual plots).
  - Đồ thị minh họa hàm trơn (smooth functions) của GAM.
  - Đồ thị so sánh giá trị dự đoán với giá trị thực tế.

### 3.3. Kết quả mô hình phân loại

- Bảng tổng hợp:
  - Ma trận nhầm lẫn (Confusion Matrix).
  - Accuracy.
  - F1-Score.
- Biểu đồ:
  - Đường cong ROC (ROC Curve).
  - Chỉ số AUC.

## Phần 4: Nhận xét và Kết luận

**Người phụ trách: CẢ 3 NGƯỜI**

Phần này giải quyết yêu cầu 6.

### 4.1. Nhận xét về kết quả phân tích

- Đánh giá mô hình nào hoạt động tốt nhất cho tập dữ liệu và giải thích lý do.
- Chỉ ra các biến có ảnh hưởng lớn nhất đến mô hình phân loại và mô hình dự
  đoán, dựa trên p-value hoặc variable importance.
- Kết luận về kết quả A/B Testing: bác bỏ hay chấp nhận giả thuyết \(H_0\).

### 4.2. Kết luận tổng thể và Khuyến nghị

- Rút ra những insight có giá trị thực tiễn từ quá trình phân tích.
- Đề xuất các giải pháp hoặc hành động cụ thể dựa trên insight.

## Trang 3

- **Quang:** Phụ trách tổng hợp lại nội dung báo cáo cả hai file Rmd và file báo
  cáo để nộp.
- **Như + Nghi:** Soạn lại nội dung và làm slide thuyết trình.

---

# 2. Phần Quang phụ trách

Theo PDF, Quang có hai trách nhiệm chính:

1. Thực hiện và trình bày **Phần 3: Kết quả phân tích và Mô hình hóa**.
2. Tổng hợp nội dung của hai file Rmd thành báo cáo hoàn chỉnh để nộp.

Trong báo cáo cuối:

- Được trình bày bảng, biểu đồ và phần diễn giải kết quả.
- Không dán code R vào Phần 3.
- Code vẫn cần tồn tại trong Rmd để tạo kết quả tái lập, nhưng phải được ẩn khi
  render báo cáo.

## Điều chỉnh đề bài PDF theo Rmd hiện tại

Các mục A/B Testing, dự đoán biến liên tục và phân loại trong PDF là ví dụ về
cách tổ chức báo cáo. `de_xuat_phan_tich_clickstream.Rmd` đã xác định một thiết
kế cụ thể khác:

- Target thống nhất là `Exit`, nhận giá trị 1 nếu click hiện tại là click cuối
  của session và 0 nếu session còn tiếp tục.
- Xác suất cần nghiên cứu là:

\[
P\{Exit_{it}=1 \mid \text{session đã tiếp tục đến click }t\}.
\]

- Ba phương pháp cần so sánh là:
  - Linear Probability Model (LPM).
  - Logistic GLM.
  - Binomial GAM.
- Rmd hiện có so sánh hai nhóm giá A/B trên dữ liệu quan sát, gồm risk
  difference, adjusted odds ratio, robust inference và kiểm tra dị biệt theo
  danh mục. Đây **không phải randomized A/B test** và không được diễn giải
  nhân quả.
- Phần 3 nên được tổ chức lại theo ba mục tiêu thực tế trong Rmd như dưới đây.

---

# 3. Checklist chi tiết dành cho Quang

## 3.0. Chuẩn bị dữ liệu và quy trình đánh giá

- [ ] Dùng một pipeline dữ liệu thống nhất cho cả ba phương pháp.
- [ ] Sắp xếp click theo `session_id` và `order`.
- [ ] Tạo `Exit = 1` duy nhất tại click cuối của mỗi session.
- [ ] Kiểm tra mỗi session có đúng một dòng `Exit = 1`.
- [ ] Không đưa `session_length` vào predictor vì đây là thông tin tương lai.
- [ ] Chuyển các biến có bản chất phân loại thành factor:
  `Country`, `Category`, `Colour`, `Location`, `Photography` và `Page`.
- [ ] Hiểu đúng `Location` là vị trí ảnh trong bố cục trang, không phải vị trí
  địa lý.
- [ ] Loại `year` vì không biến thiên.
- [ ] Không đưa đồng thời `Price` và `price_above_avg` vào mô hình chính.
- [ ] Không đưa trực tiếp `ProductModel` có 217 mức vào mô hình chính nếu chưa
  có quy tắc gộp mức hiếm.
- [ ] Không tự động xóa hoặc winsorize các session dài chỉ vì `Order` nằm ngoài
  râu boxplot; ưu tiên `log2(Order)` hoặc hàm trơn và báo cáo độ nhạy ở phần
  đuôi.
- [ ] Gộp mức hiếm của `Country` dựa trên train, sau đó áp dụng nguyên quy tắc
  sang test.
- [ ] Dùng tháng 4–6 làm train, tháng 7 làm validation để chọn mô hình và ngày
  1–12/8 làm temporal test cuối.
- [ ] Không dùng ngày 13/8 trong temporal test vì có khả năng là ngày thu thập
  chưa đầy đủ.
- [ ] Đảm bảo toàn bộ click của một session chỉ thuộc một tập dữ liệu.
- [ ] Chỉ dùng test một lần để đánh giá cuối cùng; chọn dạng biến, độ phức tạp
  GAM và threshold trên train.

## 3.1. Kết quả Mục tiêu 1 — Xác suất Exit theo tiến trình session

### Phân tích mô tả

- [ ] Tính tỷ lệ `Exit` tại từng `Order`.
- [ ] Tại `Order = t`, dùng số session đã tồn tại đến click \(t\) làm mẫu số,
  không dùng tổng số session ban đầu.
- [ ] Ở phần đuôi ít quan sát, gộp `Order` theo các nhóm:
  `1`, `2`, `3–4`, `5–7`, `8–12`, `13–20`, `>20`.
- [ ] Lập bảng gồm:
  - `Order` hoặc nhóm `Order`.
  - Số session còn tồn tại.
  - Số session kết thúc tại vị trí đó.
  - Tỷ lệ `Exit`.
  - Khoảng tin cậy 95%.
- [ ] Vẽ biểu đồ tỷ lệ `Exit` quan sát theo `Order`, có khoảng tin cậy và số
  session còn tồn tại.

### LPM, Logistic GLM và Binomial GAM

- [ ] Fit LPM cơ sở với `log2(Order) + Time + Country`.
- [ ] Tính cluster-robust covariance theo `session_id` cho LPM.
- [ ] Báo cáo hệ số, khoảng tin cậy 95% và tỷ lệ xác suất dự đoán nằm ngoài
  \([0,1]\).
- [ ] Fit Logistic GLM cơ sở với cùng predictor.
- [ ] Tính cluster-robust covariance theo `session_id` cho Logistic GLM.
- [ ] Báo cáo odds ratio, khoảng tin cậy, average marginal effect và xác suất
  dự đoán tại các vị trí đại diện như click 1, 5 và 10.
- [ ] Fit Binomial GAM cơ sở với
  `s(log2(Order)) + Time + Country`.
- [ ] Báo cáo edf, khoảng tin cậy và đồ thị hàm trơn của `Order`.
- [ ] Diễn giải p-value mặc định của smooth term một cách thận trọng vì các
  click trong cùng session không độc lập.
- [ ] Vẽ chung xác suất `Exit` dự đoán theo `Order` của ba mô hình trên một
  biểu đồ để đánh giá liệu quan hệ tuyến tính có đủ hay cần GAM.
- [ ] Không diễn giải `Order` như một tác động nhân quả; đây là quan hệ có điều
  kiện trong nhóm session còn tồn tại đến click hiện tại.

### Đầu ra bắt buộc cho Mục tiêu 1

- [ ] Một bảng tỷ lệ `Exit` quan sát theo `Order`/nhóm `Order`.
- [ ] Một bảng kết quả chính của LPM và Logistic GLM.
- [ ] Một bảng edf/smooth term của GAM.
- [ ] Một biểu đồ xác suất quan sát và dự đoán theo tiến trình session.
- [ ] Một biểu đồ partial effect của `Order` trong GAM.

## 3.2. Kết quả Mục tiêu 2 — Giá trị bổ sung của đặc điểm sản phẩm

### Các cặp mô hình

- [ ] Fit mô hình cơ sở và đầy đủ trên cùng tập quan sát cho từng phương pháp.
- [ ] Dùng bộ predictor cơ sở:

  ```text
  Order + Time + Country
  ```

- [ ] Dùng bộ predictor đầy đủ:

  ```text
  Order + Time + Country + Price + Category + Colour
  + Location + Photography + Page
  ```

- [ ] Với LPM và Logistic GLM, dùng dạng `log2(Order)` đã chốt trên train.
- [ ] Với GAM, giữ `Order` dưới dạng hàm trơn trong cả hai phiên bản và thêm
  `s(Price)` vào mô hình đầy đủ.

### Suy luận và trình bày

- [ ] Với LPM, dùng Wald test với cluster-robust covariance theo session để
  kiểm tra toàn bộ nhóm predictor bổ sung.
- [ ] Với Logistic GLM:
  - Dùng likelihood-ratio test, deviance và AIC như bằng chứng hỗ trợ.
  - Dùng Wald test cluster-robust làm suy luận chính.
  - Trình bày odds ratio, average marginal effects và predicted probabilities.
- [ ] Với GAM:
  - Báo cáo edf và khoảng tin cậy cho `s(Order)` và `s(Price)`.
  - Vẽ partial-effect plots cho hai hàm trơn.
  - Không kết luận chỉ dựa vào p-value mặc định của smooth term.
- [ ] Lập bảng so sánh mô hình cơ sở–đầy đủ gồm:
  - Phương pháp.
  - Phiên bản mô hình.
  - Số predictor hoặc effective degrees of freedom.
  - Wald/LR test phù hợp.
  - AIC khi có thể so sánh hợp lệ.
  - ROC–AUC, log loss và Brier score trên test.
- [ ] Kết luận nhóm đặc điểm sản phẩm có cung cấp giá trị dự báo bổ sung hay
  không dựa trên cả suy luận, hiệu năng test và calibration.
- [ ] Chỉ diễn giải mối liên quan có điều kiện; không kết luận thay đổi giá,
  danh mục hoặc vị trí ảnh sẽ gây ra thay đổi hành vi.

### Đầu ra bắt buộc cho Mục tiêu 2

- [ ] Một bảng so sánh cơ sở–đầy đủ cho cả ba phương pháp.
- [ ] Một bảng hiệu ứng chính của các predictor quan trọng.
- [ ] Partial-effect plot của `Order` và `Price` trong GAM đầy đủ.
- [ ] Một đoạn diễn giải biến/nhóm biến bổ sung thông tin dự báo đáng kể nhất.

## 3.3. Kết quả Mục tiêu 3 — So sánh ba phương pháp

### Đánh giá ngoài mẫu

- [ ] Dùng cùng train, test, target và pipeline tiền xử lý cho LPM, Logistic GLM
  và Binomial GAM.
- [ ] So sánh các mô hình đầy đủ bằng:
  - ROC–AUC — càng cao càng tốt.
  - Log loss — càng thấp càng tốt.
  - Brier score — càng thấp càng tốt.
  - Calibration intercept — lý tưởng gần 0.
  - Calibration slope — lý tưởng gần 1.
- [ ] Không dùng Accuracy làm tiêu chí chính vì lớp `Exit` ít hơn `Continue`.
- [ ] Nếu báo cáo Accuracy, Sensitivity, Specificity, Precision, Recall,
  F1-score và Confusion Matrix:
  - Chọn threshold trên train hoặc dự đoán out-of-fold của train.
  - Không tối ưu threshold trên test.
  - Ghi rõ threshold đã sử dụng.
- [ ] Không so sánh trực tiếp AIC của LPM Gaussian với AIC của Logistic GLM hoặc
  Binomial GAM.
- [ ] Chỉ so sánh AIC của Logistic GLM và Binomial GAM khi dùng cùng response,
  cùng tập quan sát và likelihood tương thích.

### Biểu đồ và kết luận lựa chọn mô hình

- [ ] Vẽ ROC curve của ba mô hình trên cùng hệ trục.
- [ ] Vẽ calibration plot với đường lý tưởng 45 độ.
- [ ] Nếu cần biểu đồ residual, dùng diagnostic phù hợp với outcome nhị phân;
  không dùng residual plot của hồi quy liên tục để thay thế đánh giá
  calibration.
- [ ] Lập bảng tổng hợp cuối cùng:

  | Model | ROC–AUC | Log loss | Brier score | Calibration intercept | Calibration slope | Tỷ lệ dự đoán ngoài [0,1] |
  |---|---:|---:|---:|---:|---:|---:|
  | LPM |  |  |  |  |  |  |
  | Logistic GLM |  |  |  |  |  | Không áp dụng |
  | Binomial GAM |  |  |  |  |  | Không áp dụng |

- [ ] Chọn mô hình cuối dựa trên sự cân bằng giữa:
  - Khả năng phân biệt.
  - Chất lượng xác suất dự đoán.
  - Calibration.
  - Khả năng diễn giải.
  - Tính hợp lý của dạng hàm.
- [ ] Không tuyên bố trước GAM hoặc Logistic GLM là tốt nhất khi chưa có kết
  quả test.

### Đầu ra bắt buộc cho Mục tiêu 3

- [ ] Một bảng metric dự đoán xác suất của ba mô hình.
- [ ] Một bảng metric phân loại bổ sung tại threshold đã khóa trên train.
- [ ] Một ROC plot.
- [ ] Một calibration plot.
- [ ] Một kết luận chọn mô hình kèm lý do dựa trên nhiều tiêu chí.

---

# 4. Checklist tổng hợp báo cáo để nộp

## Nhận đầu vào từ các thành viên

- [ ] Nhận phần giới thiệu, mục tiêu và phương pháp hoàn chỉnh từ Nghi.
- [ ] Nhận phần EDA hoàn chỉnh từ Như.
- [ ] Nhận file Rmd thứ hai; hiện thư mục chỉ có
  `de_xuat_phan_tich_clickstream.Rmd`.
- [ ] Xác nhận tất cả thành viên sử dụng cùng một phiên bản CSV và cùng cách đặt
  tên biến.

## Chuẩn hóa nội dung

- [ ] Giữ một setup chunk và một pipeline đọc/làm sạch dữ liệu duy nhất.
- [ ] Thống nhất target là `Exit` trong toàn bộ báo cáo.
- [ ] Thống nhất các tên:
  - `Category` = `PAGE 1`, danh mục sản phẩm chính.
  - `ProductModel` = `PAGE 2`, mã sản phẩm.
  - `Page` = biến `PAGE`, trang hiển thị 1–5.
  - `Location` = vị trí ảnh trong bố cục.
  - `Country` = quốc gia hoặc mã miền.
  - `Time` = biến lịch tạo từ year/month/day, không phải thời lượng.
- [ ] Sửa các đoạn EDA đang gọi `Location` là khu vực địa lý hoặc vị trí khách
  hàng.
- [ ] Không suy ra phân phối chuẩn chỉ vì mean gần median.
- [ ] Không kết luận hai biến “hoàn toàn độc lập” chỉ vì hệ số tương quan gần 0
  hoặc scatter plot không có xu hướng rõ.
- [ ] Không xem các mã factor như biến liên tục trong correlation matrix.
- [ ] Loại các kết luận marketing hoặc nhân quả không được hỗ trợ trực tiếp bởi
  dữ liệu.
- [ ] Xóa nội dung lặp giữa phần đề xuất phương pháp và phần EDA.

## Trình bày và render

- [ ] Render bản nộp với `show_code: false`; có thể giữ thêm bản kiểm tra
  `show_code: true` với code folding.
- [ ] Đánh số bảng và hình nhất quán; mỗi bảng/hình có tiêu đề và được nhắc đến
  trong phần diễn giải.
- [ ] Ghi rõ metric tính trên train hay test.
- [ ] Ghi rõ threshold của các metric phân loại.
- [ ] Không để output debug như `str()`, `print()` hoặc bảng trung gian trong
  bản nộp.
- [ ] Kiểm tra mọi công thức, dấu tiếng Việt, chú thích hình và tham chiếu chéo.
- [ ] Render báo cáo từ đầu trong một R session sạch.
- [ ] Kiểm tra báo cáo không phụ thuộc vào object còn sót lại trong Global
  Environment.
- [ ] Kiểm tra toàn bộ bảng/biểu đồ xuất hiện đúng và không bị cắt.

## Phối hợp Phần 4 với cả nhóm

- [ ] Cung cấp bảng so sánh mô hình và kết luận kỹ thuật để cả nhóm viết Phần 4.
- [ ] Nêu rõ biến nào liên quan mạnh nhất đến `Exit`, kèm cách đo hiệu ứng và
  mức bất định.
- [ ] Phân biệt insight dự báo với kết luận nhân quả.
- [ ] Đề xuất ứng dụng chỉ dựa trên kết quả thực nghiệm đã trình bày.
- [ ] Ghi hạn chế của dữ liệu:
  - Không có giao dịch, giỏ hàng hoặc thanh toán.
  - Không có giờ trong ngày hoặc thời lượng giữa các click.
  - Tháng 8 không đầy đủ.
  - Các click trong cùng session có phụ thuộc.
  - Quan hệ theo `Order` chịu cấu trúc chọn lọc của session còn tồn tại.

---

# 5. Danh sách file bàn giao dự kiến của Quang

- [ ] Rmd tổng hợp có thể chạy lại từ đầu.
- [ ] Báo cáo render cuối cùng để nộp.
- [ ] Bảng kết quả Mục tiêu 1.
- [ ] Bảng so sánh mô hình cơ sở–đầy đủ của Mục tiêu 2.
- [ ] Bảng metric ba mô hình của Mục tiêu 3.
- [ ] Biểu đồ xác suất `Exit` theo `Order`.
- [ ] Biểu đồ smooth effects của GAM.
- [ ] ROC plot.
- [ ] Calibration plot.
- [ ] Nội dung kỹ thuật đầu vào cho Phần 4 của cả nhóm.
