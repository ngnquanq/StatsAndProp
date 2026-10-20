# TH2 — Thực hành MANOVA

Làm việc chính trên **`TH2_MANOVA.Rmd`**: mã tính toán, công thức và diễn giải được đặt cùng nhau theo từng bước. Dữ liệu dùng là `penguins_size.csv`, theo sáu yêu cầu của `TH2.pdf`.

- `TH2_PLAN.md`: kế hoạch phân tích.
- `TH2_MANOVA.Rmd`: nguồn báo cáo tiếng Việt, tự chạy lại phân tích khi render.
- `TH2_MANOVA.html`: báo cáo tự chứa, có hình và mã có thể thu gọn.
- `TH2_MANOVA.pdf`: bản in bằng XeLaTeX.
- `TH2_MANOVA.R`: trình chạy các chunk tính toán trích từ `.Rmd`, không có thuật toán sao chép riêng.
- `TH2_output/tables/`: dữ liệu phân tích và các bảng CSV chưa làm tròn.
- `TH2_output/figures/`: hình PNG.
- `TH2_output/results.rds`, `sessionInfo.txt`: kết quả đầy đủ và môi trường R.

## Chạy lại

Mở `.Rmd` trong RStudio, chạy từng chunk theo thứ tự hoặc Knit to HTML. Trong thư mục này có thể chạy:

```sh
Rscript -e 'rmarkdown::render("TH2_MANOVA.Rmd", output_format="html_document")'
```

R cần `car`, `knitr`, `rmarkdown`; render cần Pandoc; PDF cần XeLaTeX. Xuất cả HTML/PDF hoặc chỉ chạy tính toán:

```sh
Rscript -e 'rmarkdown::render("TH2_MANOVA.Rmd", output_format="all")'
Rscript TH2_MANOVA.R
```

Mã không tự cài gói hoặc tải dữ liệu. Các file trong `TH2_output/` được tạo lại khi chạy. `source_row` là thứ tự dòng dữ liệu gốc, không tính tiêu đề.

## Kết quả chính

344 dòng ban đầu, 342 dòng có đủ bốn số đo: Adelie 151, Chinstrap 68, Gentoo 123. Không loại dòng chỉ vì thiếu giới tính. Nhãn giới tính `.` được coi là thiếu nhưng không tham gia mô hình.

Pillai V = 1,63664765; F(8,674) = 379,4872; p ≈ 8,62e-244. Wilks lambda = 0,01878543. Box's M có ý nghĩa, vì vậy báo cáo ưu tiên Pillai và thêm Welch–Holm cho 12 so sánh; không khẳng định các vi phạm giả định đã được khắc phục.

Cả bốn ANOVA có ý nghĩa sau Holm. Welch–Holm chung trên 12 cặp cho cùng kết luận như Tukey: Gentoo khác hai loài còn lại trên cả bốn biến; Chinstrap và Adelie khác về dài mỏ và dài vây, chưa có bằng chứng khác nhau về sâu mỏ và khối lượng.

Mỗi kiểm định trong `.Rmd` nêu rõ tham số, H0/H1, giả định, thống kê, phân phối tham chiếu, cách lấy đuôi p-value, họ hiệu chỉnh và giới hạn kết luận. Phân biệt rõ chuẩn biên với chuẩn đa biến; Brown–Forsythe với giả thuyết phương sai; chẩn đoán Mahalanobis với kiểm định ngoại lệ; ý nghĩa thống kê với ý nghĩa thực tiễn.

Kiểm tra tính toán trong các chunk `.Rmd`: T=E+H; Wilks/Pillai khớp `manova()`; biến đổi F và đuôi Pillai khớp công thức; t, bậc tự do và p-value Welch của 12 cặp khớp công thức. Phép kiểm tra số học không bảo đảm giả định thống kê đúng.
