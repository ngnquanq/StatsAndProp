# CLAUDE.md — quy ước chung của repo

## LaTeX: luôn dùng template HMMT ở `templates/hmmt-solution-template.tex`

Mọi file `.tex` sinh ra trong repo này (lời giải bài tập, đề cương, báo cáo ngắn) phải
theo phong cách *Harvard–MIT Math Tournament solutions sheet*. Trước khi viết một file
`.tex` mới, đọc `templates/hmmt-solution-template.tex` và sao chép phần preamble của nó.

Quy tắc bắt buộc:

1. **Chỉ trắng và đen.** Không `xcolor`, không `tcolorbox`, không khung, không nền màu,
   không đổ bóng, không bo góc.
2. **Tiêu đề gọn ở giữa trang**, 3 dòng: tên môn (đậm) / ngày / tên tài liệu + tên người
   viết. Không trang bìa, không `\maketitle`, không `abstract`, không kẻ ngang trang trí.
3. **Font Latin Modern** (`lmroman10-*.otf` + `latinmodern-math.otf`) qua `fontspec` +
   `unicode-math`, `polyglossia` với `\setdefaultlanguage{vietnamese}`.
   → **biên dịch bằng `xelatex`**, không phải pdflatex.
4. **Đề bài chạy dòng**: môi trường `problem` in nhãn đậm ngay đầu đoạn
   (`\begin{problem}` tự đánh số, `\begin{problem}[Bài 2.1.]` để tự đặt nhãn).
   Không dùng `\section` cho từng bài.
5. **Lời giải run-in**: môi trường `solution` mở đầu bằng **Lời giải:** ngay trong dòng,
   nối liền sau đề bài, không chèn dòng trống, không ký hiệu $\blacksquare$/$\square$.
6. **Đáp số cuối cùng đóng khung** bằng `\answer{...}` (tức `\boxed{...}`).
7. **Lý thuyết nhắc lại** dùng `amsthm` kiểu `definition` (`thm`, `dfn`) — chữ đứng,
   run-in, không khung.
8. **Đoạn văn thụt đầu dòng** (`\parindent=1.5em`, `\parskip=0pt`) — không dùng gói
   `parskip`; mật độ chữ dày như bản HMMT gốc.
9. **Lề rộng, khối chữ gọn giữa trang**: `top/bottom 3.0cm`, `left/right 3.2cm`.
   Chân trang chỉ có số trang canh giữa (`\pagestyle{plain}`), không running header.
10. Sau khi sinh file, **luôn chạy `xelatex` để kiểm tra biên dịch**, rồi xoá `.aux`/`.log`.
