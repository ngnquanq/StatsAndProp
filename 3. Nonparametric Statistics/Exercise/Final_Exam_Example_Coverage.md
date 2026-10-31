# Đối chiếu toàn bộ ví dụ và bài tập trên slide ôn thi

Phạm vi: C1 ECDF và CDF làm nền; C2P ước lượng chiếu; C3 hồi quy NW/local polynomial; C5 kiểm định. C2 chỉ giữ histogram khi dùng như phép chiếu. Ví dụ KDE mật độ độc lập không thuộc phạm vi.

| Slide | Ví dụ/bài tập trên slide | Câu trong PDF | Mức giải |
|---|---|---:|---|
| C1 7 | CDF đều, mũ và biến hỗn hợp | 97 | Công thức từng miền, bước nhảy |
| C1 9 | Mô phỏng mũ bằng nghịch đảo CDF | 93 | Giải nghịch đảo và kiểm tra CDF |
| C1 12 | ECDF của 1, 1.2, 1.5, 2, 2.5 | 90 | Hàm từng khoảng, bước nhảy, xác suất khoảng |
| C1 15 | 100 quan sát đều [0,2], ECDF tại 0.8 | 91 | Phân phối nhị thức, kỳ vọng, phương sai |
| C1 21, 26 | Wald và Hoeffding: n=100, p̂=0.4 | 92 | Sai số chuẩn, bán kính, hai khoảng |
| C1 29–35 | Ví dụ phiếm hàm và plug-in | 11, 56, 98 | Công thức cho từng phiếm hàm; slide không cho mẫu số liệu |
| C1 45 | Hình minh họa kiểm định hai mẫu | 99 | Công thức/diễn giải hai tình huống, hình gốc; slide không cho mẫu số liệu |
| C2P 25–26 | N(4,25), n=1000, lượng giác D=3/5, histogram D=10 | 31, 34, 95 | Từng công thức hệ số và đổi thang; slide không cho 1000 giá trị hoặc seed nên không thể có kết quả số của estimator |
| C3 8–10 | Dữ liệu mcycle và NW | 84 | R tính CV/GCV và đồ thị |
| C3 26–28 | Mô phỏng seed 2025, ba băng thông, CV | 94 | R tái lập, so sánh và đồ thị |
| C3 44–47 | Local linear, local quadratic, sai số ở biên | 94, 100 | R tái lập, moment và đồ thị |
| C3 48, bài 1–2 | NW là bình phương tối thiểu cục bộ; tổng trọng số | 37 | Đạo hàm hàm mục tiêu, chuẩn hóa |
| C3 49, bài 3 | Thiết kế cố định: kỳ vọng, phương sai, băng thông | 38 | Công thức chính xác và xấp xỉ có điều kiện |
| C3 49, bài 4 | Nghiệm hệ chuẩn local linear | 42, 81 | Nghịch đảo ma trận, trọng số |
| C3 50, bài 5 | Tái tạo đa thức | 63 | Moment rời rạc và chứng minh |
| C3 50, bài 6 | Công thức CV bỏ một quan sát | 40 | NW và local polynomial, điều kiện áp dụng |
| C3 50, bài 7 | mcycle NW/local linear, CV/GCV | 84 | R tái lập và đồ thị |
| C5 5 | Gán hạng cho (5,2,6,3,8,1) | 96 | Sắp và trả về thứ tự gốc |
| C5 10–11, ví dụ 1 | Kiểm định dấu 10 thời gian phản hồi | 44 | Từng hiệu, đuôi nhị thức, kết luận |
| C5 12–13, ví dụ 2 | Kiểm định dấu cho 12 cặp cân nặng | 80 | Bảng trước–sau, bỏ hiệu 0, đuôi trái |
| C5 19–21, ví dụ 3 | Wilcoxon 12 thay đổi nhịp tim | 46 | Bảng hạng, tổng hạng, p chính xác |
| C5 26–28, ví dụ 4 | Mann–Whitney hai nhóm thuốc | 49 | Hạng gộp, hai U, p chính xác |
| C5 32–33, ví dụ 5 | Spearman 8 cặp giờ học và điểm | 65, 86 | Bảng hạng, rho, p hoán vị; hiệu chỉnh số sai trên slide |
| C5 35–36, ví dụ 6 | Kendall từ cùng 8 cặp | 86 | Đếm hai cặp nghịch thế, tau, p hoán vị |

Các hình hoặc mệnh đề lý thuyết khác không có dữ liệu hay bài tập riêng được giải ở phần câu hỏi chứng minh tương ứng. Với ví dụ chiếu C2P 25–26, không thể khôi phục ước lượng số từ hình vì slide không cho mẫu hoặc seed; tài liệu chỉ khẳng định những số tính được từ thông tin đã cho.
