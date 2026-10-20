# Chuyển năng lực từ Cybersecurity → Toán → Financial Engineering

**Nguyên tắc:** hai nghiên cứu độc lập, cùng một thói quen làm nghiên cứu. Công việc cybersecurity cung cấp câu hỏi và hiểu biết về quy trình; luận văn Toán rèn suy luận, chứng minh và thiết kế thí nghiệm; đề tài FE dùng năng lực đó để giải một quyết định tài chính khác.

| Từ kinh nghiệm hiện tại | Rèn trong luận văn Toán | Dùng lại trong FE | Sản phẩm riêng của mỗi đề tài |
|---|---|---|---|
| Access review có chi phí và người review có thể bỏ sót | Xác định đại lượng cần suy luận, mô hình sai số và điều kiện nhận dạng | Phân biệt sai số ước lượng tham số với rủi ro của quyết định hedge | Toán: bảo đảm kiểm toán; FE: phân rã sai số hedge |
| Dashboard cho stakeholder cần một kết luận có điều kiện | Phát biểu chính xác xác suất chứng nhận sai, kể cả khi dừng sớm | Nêu điều kiện của giới hạn sai số và mức rủi ro còn lại | Hai bảng kết quả và hai kết luận riêng |
| Dữ liệu IAM có vai trò hiếm, nhóm và phụ thuộc | Phân biệt thiết kế lấy mẫu ngẫu nhiên với giả định iid về tổ chức | Dùng chia dữ liệu theo thời gian; xử lý loading thay đổi | Toán: quần thể cố định; FE: kịch bản đường cong |
| Automation, Python/SQL, kiểm tra chất lượng dữ liệu | Pipeline mô phỏng có seed, cấu hình, provenance, kiểm tra biên | Pipeline định giá cashflow, hedge và sensitivity có cùng chuẩn kỹ thuật | Có thể dùng utility chung, phải ghi nhận nguồn và phạm vi tái sử dụng |
| Báo cáo hiệu quả vận hành | Đếm số review, review lặp, độ chính xác và trường hợp không kết luận | Đo residual risk, quy mô hedge và chi phí giả định | Không chuyển kết quả tiết kiệm review thành lợi ích tài chính |

## Dùng kiến thức trong repo thế nào

Các mục dưới đây là bản đồ học tập dựa trên những nguồn đã khảo sát, không phải tuyên bố đã đọc hết mọi PDF, kể cả các tài liệu bị gitignore.

| Cụm kiến thức hiện có | Việc dùng trong Toán | Việc dùng trong FE | Phần cần học thêm |
|---|---|---|---|
| Probability Theory / Statistical Theory | Conditional expectation, concentration, giả thuyết và nhận dạng | Biến ngẫu nhiên, phân phối shock và uncertainty | Supermartingale, Ville, optional stopping với điều kiện đầy đủ |
| Computational Statistics; [Monte Carlo notes](<../../../../1. Computational Statistics/Lab/algorithms/monte_carlo/display.md>) | Mô phỏng quần thể biết truth; sai số Monte Carlo | So sánh oracle/estimated hedge trên cùng shock paths | Paired simulation, uncertainty của chênh lệch và kiểm tra sai số số học |
| Statistical Modeling / regression diagnostics | Kiểm tra score có ích cho hiệu quả lấy mẫu, không thay thế nhãn | Loading estimation, regularization, chẩn đoán model | Temporal validation, ridge perturbation và factor identifiability |
| [Multivariate lecture README](<../../../../3. High Dimensional Statistics/Lecture/README.md>) | Nền tảng fixed-dimension; không giả định đã học theory high-dimensional | PCA và ma trận covariance nhỏ | Perturbation/subspace analysis; không đặt high-dimensional asymptotics thành core |
| Nonparametric Statistics / EDF / bootstrap | Mô tả phân phối, nhưng không bootstrap để sửa nhãn sai | Phân phối residual loss; bootstrap có điều kiện phụ thuộc rõ | Block methods nếu dùng; sample size ở tail |
| Security/privacy paper reviews | Thói quen threat model, giả thiết và counterexample | Model-risk framing | Kiểm tra nguồn gốc từng claim; review note chưa phải bằng chứng novelty |
| Financial-engineering materials local/gitignored | Không cần ép vào chứng minh Toán | Bổ sung nền thị trường, fixed income và risk theo coursework | Zero curves, duration/key-rate/PCA hedge, valuation conventions |

NLP, deep learning, MCMC và causal inference vẫn có giá trị học tập, nhưng không cần đưa hết vào hai đề tài. Chọn công cụ vì câu hỏi cần nó; một luận văn chặt chẽ có thể chỉ dùng một phần nhỏ repo.

## Quản lý tri thức trong giai đoạn thực hiện

Giữ nguyên nơi lưu tài liệu gốc, bao gồm các thư mục gitignored. Tạo ghi chú nhỏ có thể review thay vì di chuyển hoặc đẩy PDF lên GitHub. Mỗi ghi chú nghiên cứu nên có: câu hỏi; nguồn/tác giả/năm/link hoặc đường dẫn local; phần đã đọc; giả thiết; kết quả đã có; phần tự chứng minh; counterexample; việc cần kiểm tra. Không chép nguyên tài liệu có giới hạn phân phối vào ghi chú công khai.

Khi bắt đầu thực hiện, dùng hai thư mục dự án riêng (chưa được tạo trong phiên brainstorm này), mỗi nơi có `question.md`, `claims.md`, `data-manifest.csv`, `experiment-plan.md`, `results/` và `decision-log.md`. Trong `claims.md`, phân biệt `established`, `planned`, `proved`, `empirical` và `unresolved`. Một claim chỉ chuyển sang `proved` khi có chứng minh đã review; kết quả mô phỏng không đủ để chuyển trạng thái.

Mỗi tuần cập nhật một trang: câu hỏi có thay đổi không; kết quả nào làm thay đổi quyết định; giả thiết nào thất bại; tuần tới giải quyết một bất định nào. Giữ cả kết quả âm và baseline thắng. Ghi phiên bản dữ liệu/model/cấu hình và seed; tài liệu ignored cần có đường dẫn và provenance để máy hiện tại tìm được, không cần phải có trong GitHub.

## Phân biệt hai bài nộp

- Toán có nhãn quyền truy cập mô phỏng, định lý kiểm toán và thí nghiệm review; FE có cashflow, yield shocks, hedge và kết quả định giá.
- Không tái dùng hình, bảng hay kết luận như một đóng góp mới trong bài còn lại. Utility chung phải có attribution và phiên bản rõ ràng, theo yêu cầu từng chương trình.
- Lộ trình học và tooling có thể liên tục; tiêu đề, câu hỏi chính, datasets, proofs/results, bản thảo và phần đánh giá phải riêng.
- Chấp nhận của supervisor và capstone track vẫn là các quyết định của chương trình; tài liệu này là đề xuất để review, chưa phải đề cương đã được phê duyệt.

Đọc tiếp: [đề xuất Toán](proposal-math.md), [đề xuất FE](proposal-fe.md), [các quyết định cần chốt](review-checklist.md).
