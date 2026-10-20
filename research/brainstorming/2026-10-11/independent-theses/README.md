# Hai đề tài độc lập: Cybersecurity → Toán → Financial Engineering

**Đề xuất sau bốn vòng mỗi model:** dùng kinh nghiệm IAM để làm luận văn Toán về bảo đảm kiểm toán có reviewer error; khoảng một năm sau làm FE về quyết định hedge rủi ro lãi suất. Mối liên kết là năng lực suy luận và kiểm chứng, với hai câu hỏi, dữ liệu và đóng góp riêng.

Đây là brainstorming đã phản biện, chưa phải đề cương được supervisor/program chấp nhận. Không có thí nghiệm hay empirical finding; không tuyên bố publication novelty. Giữ nguyên [phiên brainstorming trước](../README.md).

## Bắt đầu review ở đây

| | Đề tài chính | Backup duy nhất | Giá trị cần kiểm chứng |
|---|---|---|---|
| **Toán, 6–12 tháng** | [IAM audit assurance khi reviewer có thể bỏ sót](proposal-math.md) | Exact-label stratified finite-population audit | Chứng nhận sai được kiểm soát tới đâu; điều kiện nào khiến không thể kết luận; ngân sách review |
| **FE, khoảng +1 năm** | [Treasury hedge dưới loading/valuation uncertainty](proposal-fe.md) | Fixed-dimensional covariance/turnover replication | Hedge nào giảm residual risk, và lựa chọn có ổn định theo model/shock/cost không |

Các bản đề xuất có estimand, assumptions, proof targets, public-data limitations, pilot, metrics và lộ trình. Đọc thêm [bản đồ chuyển năng lực và quản lý tri thức](transfer-map.md), [checklist quyết định](review-checklist.md), [literature matrix](literature-matrix.csv) và [source-check record](evidence.md).

## Vì sao giữ cặp này

Toán gắn với human access review có chi phí, không phải mismatch có thể tính tự động. Randomized finite-population sampling tránh giả định cả tổ chức là iid; reviewer sensitivity vẫn là giả thiết mạnh. Amazon chỉ cung cấp cấu trúc grants, nhãn vi phạm và review là synthetic. Gói chứng minh phải gồm foundations, identifiability boundary và stopping analysis có điều kiện, thay vì chỉ một dòng martingale.

FE chuyển sang một quyết định tài chính thực chất: hedge notionals cho cashflow book giả định. Dữ liệu GSW là fitted/revised curves; core historical analysis là shock replay, không phải lợi nhuận giao dịch thực thi. Loading perturbation và cashflow Taylor remainder hỗ trợ attribution. Literature gần đã nghiên cứu factor uncertainty/regularization: scope là replication + sensitivity application có ích, novelty còn mở.

Hai bài khác nhau ở đối tượng (grants/cashflows), đích suy luận (violation rate/residual risk), dữ liệu (IAM structure/yield curves), lý thuyết (sequential audit/matrix + valuation analysis) và kết quả. Dùng lại kỹ năng simulation, proof discipline, provenance và precision planning; không nộp cùng theorem/results hai lần.

## Các điểm phản biện làm thay đổi quyết định

- **Loại EPSS calibration từ KEV additions:** CISA dateAdded là ngày vào catalog, không xác định exploitation trong 30 ngày dự báo. Anchor gần publication không sửa được lỗi nhãn.
- **Loại entitlement mismatch làm legitimacy truth:** quyền đã cấp và quyền bị remove không chứng minh quyền phù hợp/không phù hợp.
- **Không tuyên bố weighted audit/regularized hedge là mới:** nearest papers đã có các cơ chế này. Master's value phải đến từ phân tích đầy đủ, ranh giới assumptions và ứng dụng có thể tái lập, nếu supervisor chấp nhận.
- **Không dùng planted labels để tự chứng minh reviewer sensitivity:** cần binomial/dependence assumptions và transfer of difficulty; hiện chỉ dùng trong mô phỏng.
- **Giữ kết quả âm:** weighted không thắng, không chứng nhận được, hedge baseline tốt nhất hoặc không đủ precision đều là kết quả cần báo cáo.

## Chỗ hai model còn khác nhau và quyết định tổng hợp

Cả hai thống nhất cặp chính. Claude muốn KEV time-to-listing làm math backup để có observable real outcome; Codex muốn exact-label stratified audit để giảm reviewer-noise complexity. **Bản tổng hợp chọn backup của Codex:** target/theory rõ hơn và cùng domain. Nó không giải quyết việc supervisor bác synthetic application. KEV time-to-listing được giữ trong memo như reserve cần scoping lại; không tự động thay thế một luận văn Toán chỉ bằng survival plots và lower-bound một dòng.

Claude ưu tiên cross-curve comparison ở FE, Codex ưu tiên loading/nonlinearity attribution. Bản tổng hợp giữ attribution làm core, curve-construction làm sensitivity bước hai. Không bắt buộc nguồn curve thứ hai chưa validated để hoàn thành core. Cả hai thống nhất FE covariance/turnover làm backup; discrete option hedging ở reserve vì literature/data conventions khó hơn.

## Hồ sơ tám lượt review

Models theo cấu hình đã duyệt: **GPT-6.1 Sol, high** và **Claude Opus 5.5, high**. Claude read-only qua CLI; coordinator lưu JSON/output, kiểm tra primary sources và viết các tài liệu review. Claude không có web access trong các rounds; memo phân biệt source đã đọc và recollection. Xem [manifest](session-manifest.md).

| Vòng | Mục đích | Codex | Claude |
|---|---|---|---|
| 1 | Các ứng viên độc lập | [Memo](codex-round-1.md) | [Memo](claude-round-1.md) |
| 2 | Phản biện chéo, sửa target/data | [Memo](codex-round-2.md) | [Memo](claude-round-2.md) |
| 3 | Cặp chính, backups, pilot/lộ trình | [Memo](codex-round-3.md) | [Memo](claude-round-3.md) |
| 4 | Audit assumptions, depth, feasibility | [Memo](codex-round-4.md) | [Memo](claude-round-4.md) |

Các memo giữ nguyên diễn tiến, kể cả đề xuất bị bác; **hai proposal và README là khuyến nghị tổng hợp cuối**. Những claims cũ trong memo không được hiểu là đã được chấp nhận.

Việc cần chốt trước nhất: supervisor Toán có nhận proof synthesis + synthetic application không; WQU thực tế là 690/692 và yêu cầu nhóm nào; lịch khả dụng cho pilot. Checklist chia việc thành bốn tuần để đưa các câu hỏi đó thành quyết định có bằng chứng.
