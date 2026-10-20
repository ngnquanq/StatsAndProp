# Exercise 3 — Johnson & Wichern, Chương 4–5

Lời giải tiếng Việt theo định dạng Exercise 2: Latin Modern, đen trắng, đề và lời giải tách rõ, đáp số đóng khung.

Nguồn đối chiếu: Richard A. Johnson & Dean W. Wichern, *Applied Multivariate Statistical Analysis*, 6th edition, [bản sách trên website University of Chicago](https://www.stat.uchicago.edu/~lekheng/courses/331/books/Johnson-Wichern%20-%20Applied%20Multivariate%20Analysis.pdf). Số trang tham chiếu là số in trên sách, không phải chỉ số trang PDF.

Phạm vi: 4.3–4.7, 4.16–4.17, 4.19–4.22; 5.1–5.3, 5.5–5.9, 5.18–5.20.

Tái lập trong thư mục này:

```sh
python compute_results.py
latexmk -xelatex -interaction=nonstopmode -halt-on-error 25c23002_NguyenNhatQuang_btvn.tex
```

Python cần NumPy, SciPy và Matplotlib. Các hình được xuất cả PDF và PNG. `numerical_results.json` chứa số liệu chưa làm tròn; các file trong `generated/` được tạo từ phép tính, không sửa tay.

Các điểm đã đối chiếu với đề gốc:

| Bài | Dữ kiện dùng trong lời giải |
| --- | --- |
| 4.16 | Các hệ số của hai tổ hợp đều có độ lớn 1/4. |
| 4.22 | Tổng thể không nhất thiết chuẩn; số chiều p tổng quát. |
| 5.1 | n = 4, không phải n = 3. |
| 5.2 | Ví dụ 5.1 cho trung bình giả thuyết (9, 5). |
| 5.3 | Phân biệt tỉ số hợp lý Λ với Wilks' lambda Λ^(2/n). |
| 5.5, 5.8 | Dùng ma trận nghịch đảo được in riêng trong Ví dụ 5.3; ghi rõ khác biệt do độ chính xác so với S được làm tròn. |
| 5.9 | Phần tử s66 = 21.26 theo sách, khác 21.16 trong ảnh Exercise 2. |
| 5.18 | Tính từ 87 dòng Bảng 5.2: tổng cột đầu 45813, trung bình 526.586207; số tóm tắt 526.29 trong Ví dụ 5.5 không khớp bảng. |
| 5.20 | Hai giá trị trong sách là 187 và 268, khác 287 và 168 trong ảnh Exercise 2. |

Các bài 5.18–5.20 có đầy đủ Q–Q plots, biểu đồ phân tán và nhận xét giả thiết chuẩn. Bài 5.19 có thêm bảng khoảng T²/Bonferroni để đáp ứng phạm vi ôn luyện được yêu cầu.

Dữ liệu gốc được chép từ sách: `data/sweat.csv` (Bảng 5.1, 20 dòng), `data/college.csv` (Bảng 5.2, 87 dòng), `data/lumber.csv` (Bảng 5.11, 30 dòng), `data/birds.csv` (Bảng 5.12, 45 dòng). Thứ tự quan sát có thể khác bố cục cột in của bảng; các cặp/toạ độ của mỗi quan sát được giữ nguyên.
