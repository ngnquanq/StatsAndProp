# Bài giảng tự học thống kê nhiều chiều

Tài liệu tiếng Việt về phân phối chuẩn nhiều chiều và suy diễn cho vectơ trung bình, theo Johnson & Wichern, ấn bản thứ sáu, Pearson New International Edition, ©2014. Bản PDF nguồn ở thư mục `../Book/` có tên chứa `2013`; năm tham khảo được lấy từ trang bản quyền.

- `main.pdf`: bài giảng để đọc hoặc in.
- `main.tex`, `sections/`: mã nguồn, font Latin Modern (họ Computer Modern mặc định của LaTeX), toán Latin Modern Math.
- `verify_examples.py`: kiểm tra các ví dụ và đáp án bằng NumPy/SciPy; chỉ in kết quả, không sửa mã nguồn.

Biên dịch trong thư mục này:

```sh
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
```

Cần XeLaTeX với `fontspec`, `polyglossia`, `unicode-math`, `amsmath`, `amsthm`, `geometry`, `booktabs`, `enumitem`, `hyperref` và TikZ. Hình được vẽ trực tiếp trong LaTeX; không cần PGFPlots, ảnh tải ngoài hoặc BibTeX.

Kiểm tra số liệu:

```sh
python3 verify_examples.py
```

Python cần NumPy và SciPy. Trong môi trường soạn tài liệu hiện tại có thể dùng `/opt/anaconda3/bin/python verify_examples.py`.

Đọc các phần 1–8 theo thứ tự, làm 12 bài ở phần 9, rồi xem phụ lục chứng minh và đáp án. Ví dụ số liệu giả định được ghi rõ và không được nhầm với bảng quan sát BTVN. Số bài BTVN và số Result trong sách là hai hệ đánh số khác nhau.

Bản bổ sung có dẫn xuất MLE từ hàm hợp lý, chứng minh cực đại và tính bất biến của thống kê/giá trị p/quyết định Hotelling ngay trong bài chính. Phần miền tin cậy hướng dẫn tính trục elip, dựng chữ nhật, kiểm tra điểm và so sánh ba loại miền. Hình đối chiếu tương quan −0.5, 0, 0.5 giữ phương sai thành phần cố định để giải thích vai trò của hiệp phương sai chéo. Các hình Bonferroni cho hai trung bình dùng `m=2`, được phân biệt với ví dụ ba hoặc bốn tổ hợp.

Trích dẫn dùng số trang in trên sách. Trong Chương 4–5 của PDF nguồn, chỉ số trang PDF bằng số trang in cộng 5. Bản đồ tham chiếu chi tiết ở phụ lục cuối bài giảng.

Tài liệu tập trung suy diễn một mẫu, số chiều cố định, mẫu iid. Không mở rộng các ngưỡng cổ điển sang dữ liệu phụ thuộc, hiệp phương sai suy biến hoặc thống kê cao chiều khi chưa có lý thuyết tương ứng.
