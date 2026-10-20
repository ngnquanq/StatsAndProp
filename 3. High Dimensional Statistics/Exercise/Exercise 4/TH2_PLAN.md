# Kế hoạch thực hành TH2 — MANOVA

Phạm vi: sáu yêu cầu trong `TH2.pdf`, dữ liệu `penguins_size.csv`. Mức ý nghĩa 0,05.

1. Đọc dữ liệu, xác nhận 344 quan sát; kiểm tra kiểu, giá trị thiếu, nhãn và miền giá trị. Chỉ dùng complete cases của `species` và bốn biến hình thái; giữ lại chỉ số dòng gốc.
2. Tóm tắt cỡ mẫu, trung bình, độ lệch chuẩn theo loài; trực quan hóa boxplot, scatterplot và PCA trên biến chuẩn hóa.
3. Đánh giá tính độc lập từ thiết kế lấy mẫu (không thể chứng minh bằng dữ liệu); kiểm tra tương quan, hạng và điều kiện ma trận; Q–Q plots trong từng nhóm, Shapiro–Wilk từng biến, khoảng cách Mahalanobis và Box's M. Không coi các kiểm tra chuẩn đơn biến là đủ để chứng minh chuẩn đa biến.
4. Kiểm định H0: ba vector trung bình bằng nhau bằng MANOVA một nhân tố; báo cáo cả bốn thống kê, ưu tiên Pillai nếu giả định hiệp phương sai bị vi phạm.
5. Nếu kiểm định tổng thể có ý nghĩa: ANOVA từng biến với Holm trên bốn p-value; Tukey HSD cho từng biến (hiệu chỉnh trong từng biến); Welch t-test với Holm chung cho 12 so sánh để đánh giá độ nhạy với phương sai không bằng nhau. Nêu rõ phạm vi kiểm soát sai lầm của từng phương pháp.
6. Viết kết luận theo câu hỏi nghiên cứu, phân biệt ý nghĩa thống kê và độ lớn khác biệt; thảo luận tính quan sát, giới tính/đảo, giả định và giới hạn suy rộng.
7. Chạy mã R từ dữ liệu gốc, kiểm tra đẳng thức phân rã SSCP và đối chiếu Wilks/Pillai từ trị riêng; kết xuất báo cáo HTML/PDF và giữ các bảng CSV để kiểm tra.

Sản phẩm chính: `TH2_MANOVA.Rmd`, chứa mã theo từng bước và phần diễn giải. `TH2_MANOVA.R` chỉ chạy các chunk trích từ R Markdown. Báo cáo HTML/PDF, thư mục `TH2_output/` và `README_TH2.md` được giữ để xem và tái lập.

Yêu cầu trình bày toán học: trước mỗi bảng kiểm định phải nêu tham số, H0/H1, giả định, thống kê, phân phối dưới H0 (chính xác hay xấp xỉ), phía lấy p-value và quy tắc bác bỏ/hiệu chỉnh. Khi giả định không phù hợp, nêu giới hạn ngay tại kết luận liên quan. Đã bổ sung mô hình xác suất, cơ chế thiếu, Wishart/Pillai, ANOVA, Tukey–Kramer, Welch–Satterthwaite, Holm, Shapiro–Wilk, Box's M và Brown–Forsythe.
