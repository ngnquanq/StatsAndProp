# Đề xuất FE: lựa chọn hedge khi đường cong và loading không chắc chắn

**Tên dự kiến:** *Độ ổn định của lựa chọn hedge cho danh mục cashflow cố định dưới sai số ước lượng và phi tuyến định giá.*  
**Trạng thái:** đề xuất nghiên cứu độc lập sau luận văn Toán, deadline khoảng một năm muộn hơn. Public data + simulation; chưa có backtest hay kết quả thực nghiệm. Thiết kế theo WQU 690 Research Track là giả định cần xác nhận; không mặc định đây là solo thesis được chương trình chấp nhận.

## Quyết định tài chính cần giải

Với một danh mục cashflow giả định, nên chọn duration, key-rate hay factor hedge khi nhiều yếu tố được ước lượng từ dữ liệu hữu hạn? Lựa chọn đó còn ổn định khi loading thay đổi, shock lớn làm xấp xỉ tuyến tính kém, hoặc cách dựng yield curve thay đổi không?

Giá trị dự kiến là giải thích **vì sao** một hedge phức tạp hơn có thể để lại nhiều rủi ro hơn baseline, và chi phí/quy mô hedge nào làm thay đổi lựa chọn. Accuracy của forecast chỉ là intermediate metric; kết quả chính phải là residual economic-value risk. Không cần ép cybersecurity vào đề tài này: năng lực toán và thiết kế kiểm chứng từ đề tài trước là cầu nối.

## Phạm vi có thể hoàn thành

Một book giả định: tài sản fixed-rate amortizing 10 năm và một liability bullet 1 năm, cashflows định trước, book value được chuẩn hóa. Bốn hedge instruments giả định ở 2/5/10/30 năm, cùng valuation convention. Không có prepayment, credit spread hay funding-roll dynamics trong core; đó là phạm vi ngoài mô hình. Không gọi đây là dữ liệu bank book thật.

Core comparison gồm duration-only, key-rate và 3-factor PCA hedge; một ridge factor variant kiểm tra độ ổn định. Nelson–Siegel là baseline literature/optional variant, không triển khai đồng thời mọi model. Ước lượng trên yield **changes**, chia dữ liệu theo thời gian, khóa window và regularization trước evaluation. Cùng giới hạn gross hedge value ban đầu (dự kiến 2 lần book PV), cùng conventions và cost assumptions.

Core outcome là **shock revaluation tại thời điểm cố định**: repricing cùng cashflows dưới historical/simulated curve shocks. Điều này tránh trộn risk do yield với ageing/carry. Nếu mở rộng thành monthly model-marked P&L thì phải tính maturity ageing, coupon, financing và rebalancing riêng; chỉ gọi self-financing backtest khi đã triển khai đầy đủ accounting. GSW không cung cấp execution quotes.

## Dữ liệu và nguồn gần

[Fed GSW](https://www.federalreserve.gov/data/nominal-yield-curve.htm) cung cấp fitted zero curves/parameters; dữ liệu có thể bị revision, là staff research product. Lưu ngày tải, hash, schema và vintage. Website có CSV link nhưng download/schema/missing dates chưa được kiểm tra trong phiên này. Tập lịch sử dự kiến từ 1990 tới cutoff cố định trước analysis; cuối cùng phải báo cáo số monthly observations thực tế và sample ngoài training.

Một alternative-curve sensitivity là mục tiêu vòng hai: cùng dữ liệu đầu vào, so sánh một fit trơn và interpolation đã định để cô lập reconstruction choice trong mô phỏng; khi có nguồn public thứ hai phù hợp mới làm historical cross-source comparison. Treasury **par** yields phải chuyển đổi/bootstrapping với conventions rõ, không dùng trực tiếp như zero yields. Không suy luận từ GSW fit sáu tham số rằng hedge ba factors sẽ gần hoàn hảo.

Đề tài có hàng xóm rất gần: [Quaedvlieg–Schotman, Hedging Long-Term Liabilities](https://repub.eur.nl/pub/131883/RePub-131883-OA.pdf) đã phân tích loading estimation và factor hedging; [Mantilla-Garcia et al., regularized interest-rate hedging](https://doi.org/10.1080/0015198X.2022.2095193) nghiên cứu regularization. Vì vậy **đây là replication + attribution/sensitivity application dự kiến**, không tuyên bố tìm ra nguyên lý hedge mới. Nearest-paper matrix phải xác định phần đã có và phần application khác; khác dataset không tự tạo novelty.

## Phần phân tích có thể làm

Với factor exposure matrix (A), book exposure (b) và (\eta>0), hedge không ràng buộc dùng

\[
h=(A^\top A+\eta I)^{-1}A^\top b.
\]

Kế hoạch: tái chứng minh bound perturbation cho (\hat h-h) dưới error bounds của (A,b), dùng inverse norm (\le1/\eta). Đây là deterministic stability result đã có nền tảng, không tự tạo confidence interval. Ridge penalty phụ thuộc đơn vị: định trước normalization của hedge instruments và chuyển notionals về đơn vị gốc khi định giá. PCA factors phải cùng đơn vị và align signs/rotations trước so loading; nếu portfolio có active leverage constraints thì công thức inverse trên không trực tiếp mô tả constrained solution. Giữ theorem cho analytic benchmark, còn constrained decision đánh giá riêng.

Với continuous-compounded zero yields, (P(y)=\sum_j C_j e^{-t_jy_j}). Khi (|u_j|\le r_j), kế hoạch dựng remainder bound:

\[
|P(y+u)-P(y)-\nabla P(y)^\top u|
\le\tfrac12\sum_j|C_j|t_j^2e^{-t_jy_j+t_jr_j}r_j^2.
\]

Áp dụng cho book cộng hedge: bound bảo thủ cộng remainder của từng instrument với trọng số absolute notionals, nên có gross leverage. Có thể net cashflows cùng maturity để làm chặt bound nếu định giá và units hoàn toàn nhất quán. Trong known-truth simulation có thể phân rã oracle residual, loading-estimation effect và nonlinear repricing remainder. Trong dữ liệu thật không có oracle loading để xác nhận attribution như truth. Book/factor residuals còn có cross terms: không cộng các variances thành tổng nếu chưa xét covariance.

Đóng góp có thể review là phân tích sai số có điều kiện, một hedge engine tái lập và bản đồ quyết định theo estimation window/shock size/cost. Phần theorem không cần là core assessment của FE nếu chương trình ưu tiên code/report; không tái nộp martingale theorem từ luận văn Toán.

## Pilot, metrics và precision

Known-truth pilot: bốn scenarios từ factor curve nhỏ—ổn định với shock nhỏ; loading regime change; thêm yếu tố thứ tư yếu; shock lớn. Định nghĩa curves hợp lệ trong mô hình, truth loading, cashflows và discounting trước chạy. Dùng 2,000 independent paths/scenario, common random numbers giữa các hedge methods; timing 100 paths trước dự toán runtime. Tính exact repricing, linear approximation, oracle và estimated hedge. Runtime chưa đo.

| Metric | Cách đọc |
|---|---|
| Residual RMS/SD; stress loss | Primary risk outcomes; so cùng book/shocks/caps |
| Risk reduction (1-\mathrm{Var}(L_h)/\mathrm{Var}(L_0)) | (L_0) là book chưa hedge trên cùng evaluation sample; có thể âm |
| Gross hedge value, stability, turnover | Hiệu quả và mức độ thay đổi notionals |
| Cost sensitivity/break-even | Cost rates là giả định; chỉ báo break-even khi metric/net-result được định nghĩa rõ |
| ES95 nếu đủ dữ liệu | Secondary; ghi số tail observations, không dùng monthly 99% ES làm headline |

Đối với simulation, báo cáo paired Monte Carlo SE/intervals. Với lịch sử, monthly observations có phụ thuộc: dùng block-bootstrap hoặc HAC khi assumptions phù hợp, khóa choices trước xem kết quả; interval không là bảo đảm distribution-free. Nếu margins rộng, kết luận không đủ phân biệt thay vì chọn một winner. Có thể đặt vùng tương đương thực dụng ±10% residual SD, nhưng chỉ nói equivalence khi uncertainty nằm trong vùng; non-significance không đủ.

Go/no-go sau pilot: engine passes accounting/unit checks, literature fit được adviser chấp nhận, dữ liệu dùng được, và precision/runtime cho phép phân tích một quyết định cụ thể. Baseline thắng hoặc ranking không đổi vẫn là kết quả hợp lệ. Nếu second curve không có provenance/terms phù hợp, giữ sensitivity trên synthetic truth và công khai giới hạn; không bắt đề tài phụ thuộc dữ liệu options trả phí.

## Lộ trình sau luận văn Toán

| Giai đoạn | Đầu ra |
|---|---|
| Trước khi Toán kết thúc | Học fixed income theo coursework; đọc hai nearest papers; xác nhận capstone track/team, tránh mở hai implementation lớn cùng lúc |
| FE quý 1 | Scope một book; data manifest, units/valuation; reproduce một baseline |
| FE quý 2 | Hedge engine, known-truth pilot, oracle/error attribution |
| FE quý 3 | Historical shock replay, costs, regime/curve-construction sensitivity; khóa analysis |
| FE quý 4 | Report, code, presentation; review assumptions và buffer |

Fit [WQU curriculum](https://www.wqu.edu/programs/mscfe): Financial Data cho provenance, Financial Econometrics cho loading/time validation, Stochastic Modeling cho scenarios, Portfolio/Risk Management cho hedge và residual loss; pricing kiến thức hỗ trợ. Theo [catalog](https://www.wqu.edu/documents/wqu-catalog.pdf), 690 có yêu cầu code/report/presentation và group work. Có thể chia nhóm: data/curves; valuation/hedges; simulation/risk analysis, theo quy định thực tế. **692 adaptation:** critical review các phương pháp hedge và model risk, replication làm supporting evidence nếu chương trình cho phép; không hứa deliverable ngoài rubric.

**Backup duy nhất:** *Covariance uncertainty và turnover trong minimum-variance allocation ở fixed dimension.* Public French ten-industry portfolio returns + known-covariance simulation; tái lập shrinkage/cost mechanisms của [Hautsch–Voigt](https://arxiv.org/abs/1709.06296). Returns là constructed portfolios, không phải tradable execution. Phân biệt sampling/regime error và cost giả định; adding turnover không mới. Backup giảm khó khăn curve/valuation, nhưng differentiation thấp hơn và vẫn cần adviser chấp nhận replication/application.

Xem [bản đồ chuyển năng lực](transfer-map.md) và [checklist review](review-checklist.md).
