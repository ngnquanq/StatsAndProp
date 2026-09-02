# Checklist bài kiểm tra Mô hình thống kê tuyến tính

## Bối cảnh

- [ ] Sử dụng bộ dữ liệu `BirdLife.csv` (366 quan sát, 37 biến).
- [ ] Đề xuất một hoặc nhiều câu hỏi nghiên cứu phù hợp.
- [ ] Xác định ý nghĩa thống kê và ý nghĩa sinh học của câu hỏi nghiên cứu.
- [ ] Lựa chọn các biến phù hợp với mục tiêu nghiên cứu.

## 1. Tiền xử lý dữ liệu

- [ ] Kiểm tra và xử lý dữ liệu khuyết.
- [ ] Kiểm tra và xử lý dữ liệu trùng lặp.
- [ ] Kiểm tra và xử lý giá trị ngoại lai.
- [ ] Kiểm tra và chuẩn hóa kiểu dữ liệu.
- [ ] Kiểm tra các vấn đề chất lượng dữ liệu khác (nếu có).
- [ ] Ghi rõ tiêu chí và lý do lựa chọn các biến đưa vào phân tích.

## 2. Khám phá và trực quan hóa dữ liệu

- [ ] Thực hiện thống kê mô tả cho các biến được chọn.
- [ ] Xây dựng các biểu đồ phù hợp để khám phá đặc điểm dữ liệu.
- [ ] Khảo sát mối tương quan giữa các biến hình thái.
- [ ] Nhận diện dấu hiệu đa cộng tuyến.
- [ ] Thực hiện phép biến đổi biến nếu cần và giải thích lý do.

## 3. Xây dựng và đánh giá mô hình hồi quy

- [ ] Chọn một biến định lượng làm biến phản hồi.
- [ ] Chia dữ liệu phục vụ huấn luyện và đánh giá mô hình một cách phù hợp.
- [ ] Xây dựng mô hình hồi quy tuyến tính OLS.
- [ ] Xây dựng mô hình Ridge Regression.
- [ ] Xây dựng mô hình LASSO Regression.
- [ ] Xây dựng mô hình Principal Component Regression (PCR).

### Yêu cầu đối với từng mô hình

- [ ] Trình bày cơ sở lựa chọn biến.
- [ ] Kiểm tra các giả định của mô hình (nếu phù hợp).
- [ ] Đánh giá mô hình bằng các tiêu chuẩn thích hợp:
  - [ ] RMSE.
  - [ ] MAE.
  - [ ] \(R^2\).
  - [ ] Cross-validation.
- [ ] Diễn giải ý nghĩa của các hệ số hoặc thành phần chính.
- [ ] Ghi lại ưu điểm, hạn chế và nhận xét về kết quả.

### So sánh các mô hình hồi quy

- [ ] Đảm bảo các mô hình được đánh giá trên cùng một quy trình/tập dữ liệu.
- [ ] Lập bảng so sánh kết quả OLS, Ridge, LASSO và PCR.
- [ ] Xác định mô hình phù hợp nhất và giải thích lý do.

## 4. Phân tích phương sai nhiều nhân tố (Factorial ANOVA)

- [ ] Chọn một biến định lượng làm biến phản hồi.
- [ ] Chọn ít nhất hai biến phân loại làm nhân tố.
- [ ] Xây dựng mô hình ANOVA nhiều nhân tố.
- [ ] Kiểm tra các giả định của ANOVA.
- [ ] Phân tích ảnh hưởng riêng của từng nhân tố.
- [ ] Phân tích ảnh hưởng tương tác giữa các nhân tố (nếu có).
- [ ] Thực hiện kiểm định hậu nghiệm (post-hoc test) khi cần.
- [ ] Diễn giải ý nghĩa thực tiễn của các kết quả.

## 5. So sánh và thảo luận

- [ ] So sánh các phương pháp về khả năng dự báo.
- [ ] So sánh khả năng lựa chọn biến.
- [ ] So sánh khả năng xử lý đa cộng tuyến.
- [ ] So sánh khả năng diễn giải kết quả.
- [ ] So sánh phạm vi và điều kiện áp dụng.
- [ ] Rút ra các kết luận thống kê.
- [ ] Thảo luận ý nghĩa sinh học của các phát hiện.
- [ ] Đề xuất hướng cải tiến.
- [ ] Đề xuất các phương pháp phân tích khác có thể áp dụng cho bộ dữ liệu.

## 6. Kiểm tra trước khi nộp

- [ ] Câu hỏi nghiên cứu được phát biểu rõ ràng và được trả lời trong phần kết luận.
- [ ] Mọi quyết định xử lý dữ liệu và lựa chọn mô hình đều có giải thích.
- [ ] Bảng, biểu đồ và kết quả kiểm định có tiêu đề/nhãn rõ ràng.
- [ ] Các chỉ số đánh giá được trình bày nhất quán giữa các mô hình.
- [ ] Kết luận không vượt quá bằng chứng từ kết quả phân tích.
- [ ] Mã phân tích có thể chạy lại và tái tạo được kết quả.

