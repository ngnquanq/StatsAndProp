# Brief chung: hai đề tài độc lập theo lộ trình Cybersecurity → Toán → FE

Đây là phiên mới; giữ nguyên toàn bộ ghi chú ở thư mục cha. Người dùng làm data analyst cho cybersecurity trong ngân hàng, có phạm vi rộng; ưu tiên IAM/access governance và vulnerability/risk, cũng có thể làm SOC/detection. Không dùng tên ngân hàng hoặc thông tin định danh.

Mục tiêu: đề xuất đúng hai đề tài chính—một luận văn Toán/thống kê, một đề tài Financial Engineering—khác nhau về câu hỏi, dữ liệu, kết quả, đóng góp và bản thảo. Chuyển giao năng lực nghiên cứu/phương pháp là mong muốn; không thiết kế một bài viết nộp hai nơi. Mỗi đề tài có một phương án dự phòng.

Luận văn Toán còn khoảng 6–12 tháng, cần lý thuyết + ứng dụng. FE có deadline muộn hơn khoảng một năm. Public data + simulation là lựa chọn đã chốt; không phụ thuộc dữ liệu nội bộ, không yêu cầu dữ liệu ngân hàng. Không chạy thí nghiệm trong phiên này. Chỉ viết advisory proposals, không bản thảo để nộp.

Repo có probability/statistical theory/stochastic processes, bootstrap/EM/MCMC, regression diagnostics, EDF/KDE/projection/regression, classical multivariate inference, causal slides/LaLonde lab, NLP/OCR và security/privacy paper reviews. Lecture README dưới High Dimensional Statistics giới hạn fixed dimension/iid; không giả định đã học high-dimensional theory. Financial-engineering source PDFs ở 99. For fun/financial-engineering/ là local/gitignored và introductory. Tránh đọc credentials, .env, CV, private/, applications, admin/person-identifying documents.

Nguồn WQU đã mở ngày 2026-10-11:
- https://www.wqu.edu/programs/mscfe : Financial Markets, Financial Data, Financial Econometrics, Derivative Pricing, Stochastic Modeling, ML in Finance, DL for Finance, Portfolio Management, Risk Management; capstone 690 Project hoặc 692 Review.
- https://www.wqu.edu/documents/wqu-catalog.pdf : catalog amended July 7 2026; 690 research/practical tracks; code + report + presentation, group work up to three; thực tế capstone của người dùng chưa xác nhận. Tạm thiết kế theo 690 Research Track, ghi rõ conditional và outline thích ứng với 692; không giả định solo thesis được WQU chấp nhận.

Phiên trước xem xét một shared research program: ES overlap/scaling demoted to replication vì nguồn gần đã có; mortgage maturity còn conditional, synthetic inference và e-monitoring là reserve. Những kết luận đó chỉ là prior evidence, không ràng buộc lựa chọn mới. Không neo vào cặp cũ. Repo privacy notes có assertions chưa verified về novelty và target attack AUC; không chấp nhận chúng như fact, không yêu cầu kết quả dương.

Quy trình mới: bốn vòng, mỗi vòng cả GPT-6.1 Sol high và Claude Opus 5.5 high. V1 độc lập ba hướng Toán + ba hướng FE và các ghép cặp. V2 phản biện chéo, nearest-paper/data checks. V3 chọn cặp và backup. V4 audit evidence/feasibility/independence. Tiêu chí: statistical/theoretical substance, domain authenticity, data/computation feasibility, consequential outcomes, advisor/program fit, distinct primary contributions, transfer of skills. Không tuyên bố novelty, định lý mới, institutional acceptance hay empirical findings khi chưa kiểm chứng.

Mỗi ứng viên cần target/estimand, giả thiết, potential theorem/proof approach, nearest existing methods, public-data provenance limitations, known-truth pilot, outcomes/precision, fatal risk, backup. FE cần thật sự tài chính và map WQU courses. Chia biệt theorem planned vs established, analytic benchmark vs contribution, statistical validity vs model prediction, descriptive exposure vs real cyber harm, data snapshot vs event histories, portfolio returns vs tradable assets.

Notes nên concise (~1000–1400 words/round; final audit ~700). Memos có thể English; synthesis/proposal docs tiếng Việt. Chỉ Codex được ghi memo riêng theo task; Claude read-only, coordinator lưu CLI output. Không spawn thêm agents.
