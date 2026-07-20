# Yêu cầu bài toán dự đoán tỷ lệ tội phạm bạo lực

## 1. Thông tin chung

- **Môn học:** Mô hình hóa thống kê
- **Đồ án:** Đồ án kết thúc học phần
- **Hạng mục:** Hoạt động 1 — Bài 1
- **Số điểm của Hoạt động 1:** 7 điểm
- **Bài toán:** Dự đoán tỷ lệ tội phạm bạo lực trong các cộng đồng ở Hoa Kỳ dựa trên các đặc điểm nhân khẩu học, kinh tế và xã hội.

## 2. Bộ dữ liệu

Sử dụng bộ dữ liệu **Communities and Crime** do **UCI Machine Learning Repository** công bố.

Dữ liệu tổng hợp thông tin của các cộng đồng tại Hoa Kỳ từ nhiều nguồn:

- Điều tra dân số Hoa Kỳ năm 1990 (*1990 U.S. Census*);
- Khảo sát về quản lý và tổ chức lực lượng thực thi pháp luật năm 1990 (*1990 U.S. Law Enforcement Management and Administrative Statistics — LEMAS*);
- Dữ liệu tội phạm của FBI trong *Uniform Crime Reports — UCR* năm 1995.

Bộ dữ liệu được xây dựng nhằm nghiên cứu mối quan hệ giữa:

- các đặc điểm kinh tế — xã hội;
- các đặc điểm nhân khẩu học;
- hoạt động của lực lượng cảnh sát;
- tỷ lệ tội phạm trong các cộng đồng.

### Cấu trúc dữ liệu

Tệp `communities.data` gồm:

- **1.994 quan sát**, mỗi quan sát tương ứng với một cộng đồng;
- **128 biến**, bao gồm:
  - 4 biến định danh: `state`, `county`, `community`, `communityname`;
  - 123 biến mô tả đặc điểm kinh tế, xã hội, nhân khẩu học và lực lượng cảnh sát;
  - 1 biến phản hồi: `ViolentCrimesPerPop`, biểu thị tỷ lệ tội phạm bạo lực trên đầu người.

Ý nghĩa của các biến được mô tả trong tệp `communities.names`.

## 3. Yêu cầu phân tích

### (a) Khám phá và tiền xử lý dữ liệu

- Thực hiện phân tích khám phá dữ liệu (EDA).
- Thực hiện tiền xử lý dữ liệu thích hợp.

### (b) Chia dữ liệu

Chia dữ liệu thành:

- tập huấn luyện (*training set*);
- tập kiểm định (*validation set*).

### (c) Xây dựng mô hình PCR

Sử dụng phương pháp **hồi quy trên thành phần chính (Principal Component Regression — PCR)** để dự đoán tỷ lệ tội phạm bạo lực của cộng đồng.

Cần thực hiện đầy đủ các bước, bao gồm:

- kiểm tra mức độ phù hợp của bộ dữ liệu với phương pháp PCR;
- lựa chọn các thành phần chính (PC) phù hợp;
- xây dựng mô hình dự đoán.

### (d) Xây dựng các mô hình đối chứng

Trên cùng bộ dữ liệu, xây dựng các mô hình:

- hồi quy tuyến tính theo phương pháp bình phương tối thiểu (**OLS**);
- **Ridge Regression**;
- **LASSO**.

### (e) Đánh giá và so sánh mô hình

Đánh giá và so sánh PCR, OLS, Ridge và LASSO trên tập validation bằng các chỉ số:

- RMSE;
- MAE;
- R².

### (f) Phân tích các thành phần chính

- Phân tích các thành phần chính thông qua ma trận tải (*loadings*).
- Thảo luận ý nghĩa của các nhóm biến có ảnh hưởng đến tỷ lệ tội phạm.

### (g) Chuyển đổi và diễn giải hệ số PCR

- Chuyển các hệ số hồi quy của mô hình PCR từ không gian các thành phần chính về không gian các biến gốc.
- Diễn giải ảnh hưởng của các biến gốc đến tỷ lệ tội phạm bạo lực của cộng đồng.

### (h) Thảo luận và lựa chọn mô hình

- Thảo luận ưu điểm và hạn chế của PCR, OLS, Ridge Regression và LASSO trong bối cảnh:
  - dữ liệu có nhiều biến;
  - có hiện tượng đa cộng tuyến.
- Từ kết quả phân tích, đề xuất mô hình phù hợp nhất.

### (i) Kết luận

- Trình bày kết luận của bài toán.
- Đề xuất hướng cải thiện mô hình nếu có.

## 4. Lưu ý bắt buộc trước khi xây dựng mô hình

Thực hiện tiền xử lý dữ liệu thích hợp, chẳng hạn:

- xử lý dữ liệu khuyết;
- loại bỏ các biến định danh;
- loại bỏ các biến không phù hợp với mô hình hồi quy;
- thực hiện các bước tiền xử lý cần thiết khác và giải thích lựa chọn.

## 5. Yêu cầu chung đối với báo cáo

### Hình thức làm bài và thời hạn

- Làm bài theo danh sách nhóm đã đăng ký.
- Các nhóm phải làm việc độc lập. Nếu các bài sao chép lẫn nhau, điểm sẽ được chia đều cho các thành viên liên quan.
- Nộp bài trên Moodle trước **23:59 ngày 30/07/2026**.
- Hệ thống tự động khóa sau thời hạn; bài nộp trễ không được chấp nhận.
- Giảng viên không nhận bài qua email.

### Tệp cần nộp

Mỗi nhóm chỉ nộp **một tệp `.zip`**, bao gồm:

1. Một báo cáo PDF, đặt tên `NhomXX-DoAn.pdf`;
2. Một thư mục hoặc tệp nén chứa toàn bộ mã nguồn (`.R`, `.Rmd` hoặc `.html`);
3. Một thư mục hoặc tệp nén chứa toàn bộ các bộ dữ liệu được sử dụng.

### Cấu trúc báo cáo

Báo cáo phải có đầy đủ:

1. Trang bìa;
2. Mục lục;
3. Đề bài;
4. Giới thiệu bộ dữ liệu và nguồn dữ liệu;
5. Phương pháp và kết quả phân tích;
6. Hình vẽ, bảng biểu và phần diễn giải kết quả;
7. Kết luận;
8. Tài liệu tham khảo.

### Các yêu cầu khác

- Trình bày rõ bảng phân công công việc, nhiệm vụ của từng thành viên và phần tự đánh giá mức độ hoàn thành. Nhóm không có bảng phân công sẽ bị trừ **2 điểm**.
- Báo cáo phải khoa học, rõ ràng và trích dẫn đầy đủ tài liệu cùng nguồn dữ liệu.
- Báo cáo không vượt quá **80 trang**, không tính phụ lục.
- Nêu rõ các giả định của mô hình thống kê, cách kiểm định các giả định, đồng thời diễn giải cả ý nghĩa thống kê và ý nghĩa thực tiễn của kết quả.
- Tất cả kết quả phân tích phải được thực hiện bằng **R**.
- Toàn bộ mã lệnh R phải được trình bày trong phụ lục để bảo đảm khả năng tái lập kết quả.

## 6. Yêu cầu báo cáo và thuyết trình liên quan

Theo tài liệu quy định buổi báo cáo:

- Báo cáo trực tuyến tại: <https://meet.google.com/yvf-ozec-ids>.
- Buổi báo cáo diễn ra ngày **01/08/2026**, bắt đầu lúc **08:00**.
- Mỗi nhóm cần chuẩn bị slide tóm tắt nội dung chính.
- Phần thuyết trình từ **15–20 phút** được quy định cho bộ dữ liệu của **Hoạt động 2**; tài liệu không quy định một phần thuyết trình riêng cho bài toán tội phạm thuộc Hoạt động 1.
- Các thành viên phải tham gia trình bày và trả lời câu hỏi. Thành viên vắng mặt nhận **0 điểm phần thuyết trình**.

Nội dung thuyết trình cần trình bày rõ:

- mục tiêu và ý nghĩa của đề tài;
- nguồn gốc, đặc điểm và các biến của bộ dữ liệu;
- phương pháp thống kê và phân tích dữ liệu được sử dụng;
- kết quả phân tích, đánh giá mô hình và diễn giải kết quả;
- kết luận và các phương pháp khác được đề xuất nếu có.

## 7. Cơ cấu đánh giá toàn đồ án

- **70% — Final Project Report:** gồm Hoạt động 1 và Hoạt động 2;
- **30% — Project Presentation:** dành cho Hoạt động 2, đánh giá chất lượng slide, nội dung, kỹ năng thuyết trình và khả năng trả lời câu hỏi.

## 8. Nguồn chuyển đổi

Nội dung trong tài liệu này được tổng hợp từ:

- `FinalProject_MHHTK_Toán_2025-2026.pdf`;
- `QUY ĐỊNH CHUNG VỀ BUỔI BÁO CÁO KẾT THÚC HỌC PHẦN.pdf`.

