# Note vấn đáp đồ án clickstream

Tài liệu này dùng để trả lời miệng cho đồ án **“Phân tích và dự đoán xác suất kết thúc session từ dữ liệu clickstream”**. Nội dung được đối chiếu với:

- `[Nhom E]_final_project/de_xuat_phan_tich_clickstream.Rmd`;
- báo cáo LaTeX trong `Statistical Data Processing/`.

Quy ước: trong code, biến mục tiêu được đặt tên là `exit`; trong phần trình bày, báo cáo gọi là `Exit`.

## 1. Bài nói tổng quan trong 60 giây

Nhóm phân tích 165.474 click thuộc 24.026 session của một cửa hàng quần áo trực tuyến, thu thập từ 01/04 đến 13/08/2008. Mỗi dòng là một click. Nhóm tạo target `Exit = 1` nếu click đó là click cuối của session và `Exit = 0` nếu session còn tiếp tục. Mục tiêu là ước lượng xác suất kết thúc tại click hiện tại, với điều kiện session đã tồn tại đến vị trí đó.

Nhóm thực hiện ba việc. Thứ nhất, so sánh xác suất Exit giữa sản phẩm có giá cao hơn trung bình danh mục và nhóm còn lại. Đây chỉ là so sánh quan sát dạng A/B, không phải A/B test ngẫu nhiên. Thứ hai, nhóm đánh giá giá trị bổ sung của đặc điểm click hiện tại và lịch sử duyệt đã quan sát. Thứ ba, nhóm so sánh LPM, Logistic GLM và Binomial GAM.

Dữ liệu được chia theo thời gian: tháng 4–6 để huấn luyện, tháng 7 để validation và chọn mô hình, ngày 01–12/08 làm temporal test cuối. Logistic GLM history-enhanced được chọn vì có hiệu năng gần bằng GAM nhưng đơn giản, dễ diễn giải hơn và tạo xác suất hợp lệ. Trên temporal test, mô hình đạt ROC–AUC 0,666, log loss 0,379 và Brier 0,113. Đây là hiệu năng trung bình, chưa đủ để triển khai ngay.

## 2. Các con số cần nhớ

| Nội dung | Giá trị |
|---|---:|
| Tổng số click | 165.474 |
| Tổng số session | 24.026 |
| Tỷ lệ Exit | 14,52% |
| Train tháng 4–6 | 116.095 click, 17.031 session |
| Validation tháng 7 | 35.231 click, 5.071 session |
| Temporal test 01–12/08 | 13.948 click, 1.903 session |
| Ngày 13/08 bị loại | 200 click, 21 session |
| Exit nhóm giá A trên tháng 7 | 13,77% |
| Exit nhóm giá B trên tháng 7 | 14,96% |
| Chênh lệch thô B–A | 1,19 điểm phần trăm |
| Adjusted risk difference | 0,82 điểm phần trăm |
| Adjusted odds ratio | 1,071 |
| Logistic GLM temporal-test ROC–AUC | 0,666 |
| Logistic GLM temporal-test AP | 0,230 |
| Logistic GLM temporal-test log loss | 0,379 |
| Logistic GLM temporal-test Brier/BSS | 0,113 / 0,039 |
| Logistic calibration intercept/slope | −0,127 / 0,934 |
| Logistic threshold | 0,162 |
| Logistic precision/recall/F1 | 20,94% / 60,17% / 31,07% |

## 3. Bài toán, dữ liệu và target

### Câu 1. Tại sao chọn bộ dữ liệu này?

**Trả lời ngắn:** Dữ liệu đủ lớn, có cấu trúc tuần tự theo session và gồm cả biến liên tục lẫn phân loại. Vì vậy nó phù hợp để vừa làm suy luận thống kê, vừa so sánh LPM, Logistic GLM và GAM trên cùng một target.

**Nếu thầy hỏi sâu:** Bộ dữ liệu có 165.474 click và 24.026 session, đủ để chia theo thời gian mà vẫn còn nhiều quan sát. Hạn chế là dữ liệu từ năm 2008, chỉ thuộc một cửa hàng và không có thông tin giao dịch.

**Đối chiếu:** Rmd mục 1.1; báo cáo mục 1.1 và 5.1.

### Câu 2. Đơn vị quan sát là click hay session?

**Trả lời ngắn:** Một dòng là một click, nhưng các click được nhóm thành session bằng `session_id`. Mô hình dự đoán ở cấp click, còn sự phụ thuộc và bootstrap được xử lý ở cấp session.

**Nếu thầy hỏi sâu:** Không thể coi 165.474 click là hoàn toàn độc lập vì nhiều click thuộc cùng một session. Đó là lý do nhóm dùng cluster-robust covariance, cluster bootstrap và chia cross-validation theo session.

### Câu 3. Tại sao chọn `Exit` làm target?

**Trả lời ngắn:** Dữ liệu không có biến mua hàng hay chuyển đổi, nhưng có thứ tự click đầy đủ trong từng session. Vì vậy target quan sát được và tái lập là click hiện tại có phải click cuối session hay không.

**Nếu thầy hỏi sâu:** `Exit` không đồng nghĩa với thất vọng hoặc churn. Session có thể kết thúc vì khách mua hàng, rời website hoặc vì một lý do không quan sát được. Nhóm chỉ dự đoán điểm kết thúc kỹ thuật của session.

### Câu 4. `Exit` được tạo như thế nào?

**Trả lời ngắn:** Sau khi sắp xếp theo `session_id` và `order`, nhóm tính `session_length`; `Exit = 1` khi `order == session_length`, ngược lại bằng 0. Mỗi session được kiểm tra có đúng một dòng Exit.

**Nếu thầy hỏi sâu:** `session_length` chỉ dùng để gán nhãn trong dữ liệu lịch sử. Nó không được đưa vào predictor vì tại thời điểm dự đoán, ta chưa biết session cuối cùng sẽ dài bao nhiêu.

### Câu 5. Xác suất đang nghiên cứu chính xác là gì?

**Trả lời ngắn:** Đó là xác suất nguy cơ rời rạc

\[
P\{Exit_{it}=1\mid \text{session đã tiếp tục đến click }t\}.
\]

**Nếu thầy hỏi sâu:** Tại `Order = t`, mẫu số chỉ gồm các session sống sót đến click thứ `t`. Vì vậy xu hướng theo Order chịu sự chọn lọc của các session còn tồn tại và không phải hiệu ứng nhân quả của việc tăng số click.

### Câu 6. Tại sao tỷ lệ Exit bằng khoảng 14,52%?

**Trả lời ngắn:** Mỗi session đóng góp đúng một click Exit, nên số Exit bằng số session. Tỷ lệ theo click xấp xỉ `24.026 / 165.474 = 14,52%`.

**Nếu thầy hỏi sâu:** Đây là prevalence ở cấp click, không phải tỷ lệ session “rời bỏ”, vì mọi session theo định nghĩa đều có một click cuối.

## 4. Tiền xử lý và chống rò rỉ dữ liệu

### Câu 7. Nhóm đã kiểm tra chất lượng dữ liệu như thế nào?

**Trả lời ngắn:** Nhóm kiểm tra missing value, dòng trùng hoàn toàn, tính liên tục của `order`, đúng một Exit trong mỗi session và sự chồng lấn session giữa các tập. Tất cả số vi phạm đều bằng 0.

**Nếu thầy hỏi sâu:** Các điều kiện này được viết thành `stopifnot()` trong Rmd, nên pipeline dừng ngay nếu dữ liệu không thỏa giả định.

### Câu 8. Tại sao phải sắp xếp theo `session_id` và `order`?

**Trả lời ngắn:** Việc sắp xếp bảo đảm click đúng trình tự trước khi tạo target và các feature lịch sử. Nếu thứ tự sai, các biến như quay lại sản phẩm, chuyển danh mục hay giá trung bình quá khứ đều sai.

### Câu 9. Tại sao chuyển các mã category, colour, location, photography và page thành factor?

**Trả lời ngắn:** Các mã này là nhãn phân loại, không phải đại lượng có khoảng cách số học. Dùng factor tránh giả định sai rằng, ví dụ, `Category 4` gấp đôi `Category 2`.

**Nếu thầy hỏi sâu:** Riêng `location` là vị trí ảnh trên bố cục trang, không phải vị trí địa lý. `country` mới là thông tin quốc gia hoặc loại tên miền.

### Câu 10. Tại sao loại `year`?

**Trả lời ngắn:** Tất cả quan sát đều thuộc năm 2008 nên `year` không biến thiên và không cung cấp thông tin dự báo.

### Câu 11. Tại sao không đưa `session_length` vào mô hình?

**Trả lời ngắn:** Đây là thông tin tương lai. Biết độ dài cuối cùng của session gần như cho biết trực tiếp click nào là cuối, nên dùng nó sẽ gây target leakage.

**Nếu thầy hỏi sâu:** Target có thể được tạo từ thông tin hoàn chỉnh trong dữ liệu lịch sử, nhưng predictor tại click `t` chỉ được dùng thông tin có sẵn đến thời điểm `t`.

### Câu 12. Tại sao không đưa `product_model` vào mô hình chính?

**Trả lời ngắn:** Biến này có 217 mức. Đưa trực tiếp vào sẽ tạo rất nhiều hệ số, nhiều mức hiếm và nguy cơ overfitting hoặc mức mới khi dự báo.

**Nếu thầy hỏi sâu:** Đây là một hạn chế vì có thể bỏ sót thông tin sản phẩm. Hướng phát triển là gộp mức hiếm dựa trên train rồi đánh giá phần thông tin bổ sung bằng cùng pipeline.

### Câu 13. Tại sao không xóa các session dài như outlier?

**Trả lời ngắn:** Các session dài có trình tự hợp lệ, không phải lỗi nhập liệu. Xóa chỉ vì nằm ngoài râu boxplot sẽ loại hành vi thật và làm sai phần đuôi của phân phối.

**Nếu thầy hỏi sâu:** Nhóm xử lý độ lệch phải bằng `log2(order)` trong LPM/Logistic và hàm trơn trong GAM. Khi mô tả, phần đuôi được gộp thành các khoảng để tránh tỷ lệ quá dao động.

### Câu 14. Tại sao dùng `log2(order)`?

**Trả lời ngắn:** `order` lệch phải mạnh và tác động biên không hợp lý nếu giả định tuyến tính trên thang gốc. Log cơ số 2 nén phần đuôi và cho diễn giải thuận tiện: tăng gấp đôi Order tương ứng với một thay đổi cố định trên thang log.

**Nếu thầy hỏi sâu:** Trong Logistic GLM history-enhanced, mỗi lần Order tăng gấp đôi có OR 0,640, khi giữ các biến khác cố định. Đây là liên hệ có điều kiện, không phải tác động nhân quả.

### Câu 15. Tại sao chia giá cho 10?

**Trả lời ngắn:** `price_10 = price/10` giúp hệ số và OR được diễn giải theo mỗi 10 USD thay vì mỗi 1 USD. Phép đổi đơn vị không thay đổi fit hay ý nghĩa thống kê của mô hình.

### Câu 16. Tại sao gộp country có dưới 100 click thành `Other`?

**Trả lời ngắn:** Các mức quá hiếm cho hệ số không ổn định và dễ gây vấn đề khi áp dụng sang dữ liệu tương lai. Ngưỡng 100 tạo số quan sát tối thiểu thực dụng cho mỗi mức.

**Nếu thầy hỏi sâu:** Quy tắc được học chỉ trên train rồi áp dụng nguyên trạng sang validation và temporal test. Không dùng dữ liệu tương lai để quyết định mức nào được giữ.

### Câu 17. Tại sao không chuẩn hóa tất cả biến số?

**Trả lời ngắn:** LPM, Logistic GLM và GAM trong bài không cần chuẩn hóa để tối ưu bằng gradient như một số thuật toán khác. Nhóm chỉ đổi thang ở những nơi giúp dạng quan hệ hoặc khả năng diễn giải, như `log2(order)`, `price/10` và `time_30`.

### Câu 18. Các history feature gồm những gì và tại sao cần chúng?

**Trả lời ngắn:** Chúng gồm số sản phẩm/danh mục duy nhất đã xem, quay lại sản phẩm, chuyển danh mục/trang, thay đổi giá và các tỷ lệ hành vi tích lũy. Chúng mô tả tiến trình thực tế của session tốt hơn chỉ nhìn click hiện tại.

**Nếu thầy hỏi sâu:** Trên validation, thêm history feature vào Logistic GLM làm ROC–AUC tăng khoảng 0,050 và log loss giảm khoảng 0,012 so với current-click model.

### Câu 19. History feature có gây leakage không?

**Trả lời ngắn:** Không, vì tại click `t` chúng chỉ dùng click 1 đến `t`. Chúng không dùng click sau `t` hoặc độ dài cuối cùng của session.

**Nếu thầy hỏi sâu:** Ví dụ `prior_mean_price` được tạo bằng cách lag trung bình tích lũy; cờ chuyển danh mục và chuyển trang chỉ so với click ngay trước đó.

### Câu 20. Có điểm nào cần thận trọng trong cách tạo history feature không?

**Trả lời ngắn:** Một số feature cùng mô tả tiến trình session nên có thể chồng lấn thông tin. Nhóm kiểm tra GVIF cho Logistic và concurvity cho GAM; `s(unique_products)` đã bị loại khỏi GAM vì gần trùng với Order và `repeat_rate`.

## 5. Chia dữ liệu và quy trình đánh giá

### Câu 21. Tại sao chia theo thời gian thay vì chia ngẫu nhiên?

**Trả lời ngắn:** Dự báo thực tế dùng quá khứ để dự đoán tương lai. Chia theo thời gian kiểm tra được temporal generalization và tránh để hành vi tương lai hỗ trợ mô hình trong quá khứ.

**Nếu thầy hỏi sâu:** Tháng 4–6 là train, tháng 7 là validation, ngày 01–12/08 là temporal test cuối. Temporal test không tham gia chọn mô hình hoặc threshold.

### Câu 22. Tại sao ngày 13/08 bị loại?

**Trả lời ngắn:** Ngày đó chỉ có 200 click và 21 session, rất khác các ngày còn lại, nhiều khả năng là ngày thu thập chưa hoàn tất. Dùng nó trong test có thể đánh giá mô hình trên một lát dữ liệu bị cắt dở.

**Nếu thầy hỏi sâu:** Nhóm không kết luận cả tháng 8 suy giảm lưu lượng vì dữ liệu tháng 8 vốn không đầy đủ.

### Câu 23. Tại sao phải giữ toàn bộ một session trong cùng một tập?

**Trả lời ngắn:** Các click trong session phụ thuộc nhau và các history feature được tích lũy trong session. Nếu một session xuất hiện ở cả train và test, mô hình có thể hưởng lợi từ thông tin rất gần nhau, làm kết quả lạc quan giả.

### Câu 24. Trong Rmd, tại sao object `test` lại là tháng 7?

**Trả lời ngắn:** Đây chỉ là tên object ngắn trong code. Về vai trò thống kê, `test` là **validation tháng 7**, còn `sensitivity` là **temporal test 01–12/08**. Khi trình bày phải gọi theo vai trò, không gọi tháng 7 là test cuối.

### Câu 25. Tại sao dùng five-fold CV theo session để chọn threshold?

**Trả lời ngắn:** Prediction ngoài fold giúp chọn threshold trên các quan sát không được dùng để fit mô hình tương ứng. Chia fold theo session ngăn các click của cùng một phiên rơi vào cả phần fit và phần dự đoán ngoài fold.

### Câu 26. Tại sao test cuối chỉ được dùng một lần?

**Trả lời ngắn:** Nếu liên tục xem test rồi chỉnh mô hình, test sẽ trở thành một phần của quá trình huấn luyện. Khóa mô hình và threshold trước khi mở test giúp kết quả phản ánh khả năng khái quát hóa trung thực hơn.

## 6. So sánh hai nhóm giá dạng A/B

### Câu 27. Đây có phải A/B test thật không?

**Trả lời ngắn:** Không. Đây là so sánh hai nhóm **dạng A/B trên dữ liệu quan sát** vì nhóm giá không được gán ngẫu nhiên.

**Nếu thầy hỏi sâu:** Hai nhóm khác nhau về nhiều covariate theo balance diagnostics. Điều chỉnh hồi quy chỉ xử lý yếu tố đã quan sát, nên residual confounding vẫn có thể tồn tại.

### Câu 28. Tại sao tạo nhóm giá theo trung bình của từng category?

**Trả lời ngắn:** Mặt bằng giá khác rõ giữa các danh mục. So với trung bình chung sẽ dễ đồng nhất “giá cao” với một category vốn có giá cao; so trong category tạo khái niệm giá tương đối hợp lý hơn.

**Nếu thầy hỏi sâu:** Dù vậy, `price_above_avg` vẫn là thuộc tính sản phẩm, không phải treatment. Không được diễn giải kết quả như tác động của việc tăng giá.

### Câu 28b. Thầy hỏi: “Một session xem nhiều mức giá thì chia A/B như thế nào?”

**Trả lời ngắn:** Trong phân tích hiện tại, nhóm A/B được gán ở **cấp click theo sản phẩm đang xem**, nên một session có thể xuất hiện ở cả A và B. Đây là lý do số session ở hai hàng không cộng thành tổng số session. Nhóm không giả vờ biến dữ liệu quan sát này thành hai treatment độc lập.

**Cách xử lý trong bài hiện tại:** Mỗi click được gắn `high_price` theo sản phẩm của click đó. Khi ước lượng adjusted OR/RD, mô hình điều chỉnh các covariate và dùng cluster-robust covariance theo `session_id`; cluster bootstrap cũng lấy mẫu nguyên session. Vì vậy ta thừa nhận các click cùng session phụ thuộc nhau.

**Nếu muốn phân tích ở cấp session:** Phải định nghĩa trước một exposure duy nhất cho mỗi session, chẳng hạn giá của sản phẩm đầu tiên đủ điều kiện, hoặc một quy tắc “đã từng xem nhóm B”. Nhưng mỗi quy tắc trả lời một câu hỏi khác và không được chọn sau khi xem kết quả. Không nên tùy ý gán cả session vào A hoặc B chỉ dựa trên tỷ lệ thuận tiện.

**Nếu làm A/B test thật:** Randomize ở cấp session và giữ mỗi session trong đúng một nhánh suốt vòng đời. Ví dụ control giữ giao diện giá hiện tại, treatment thêm thông điệp giá trị/ưu đãi vận chuyển; không để cùng một session lúc ở A lúc ở B. Primary outcome sau đó phân tích ở cấp session theo intention-to-treat.

**Câu chốt:** Một session xem nhiều giá không phải lỗi dữ liệu; nó chỉ cho thấy phân tích hiện tại là click-level observational exposure, không phải treatment A/B ở cấp session.

### Câu 29. Giả thuyết kiểm định là gì?

**Trả lời ngắn:** Kiểm định hai phía ở mức 5%:

\[
H_0:P(Exit=1\mid A)=P(Exit=1\mid B),\qquad
H_1:P(Exit=1\mid A)\ne P(Exit=1\mid B).
\]

**Nếu thầy hỏi sâu:** Nhóm dùng kiểm định hai phía vì không khóa trước một hướng nhân quả và giả thuyết nhóm giá được định hướng sau EDA.

### Câu 30. Kết quả so sánh giá chính là gì?

**Trả lời ngắn:** Trên tháng 7, Exit của A là 13,77%, B là 14,96%, chênh lệch thô 1,19 điểm phần trăm. Sau điều chỉnh, RD là 0,82 điểm phần trăm và OR là 1,071 với robust CI 95% 1,002–1,144, `p = 0,043`.

**Nếu thầy hỏi sâu:** Có bằng chứng về khác biệt ở mức 5%, nhưng hiệu ứng nhỏ và không chứng minh quan hệ nhân quả.

### Câu 31. Tại sao báo cáo cả risk difference và odds ratio?

**Trả lời ngắn:** Risk difference dễ hiểu theo điểm phần trăm; odds ratio phù hợp với hệ số Logistic nhưng khó trực giác hơn. Báo cáo cả hai giúp phân biệt ý nghĩa thống kê và độ lớn thực tế.

**Nếu thầy hỏi sâu:** OR 1,071 nghĩa là odds Exit cao hơn khoảng 7,1% khi giữ các covariate cố định; nó không có nghĩa xác suất cao hơn 7,1 điểm phần trăm.

### Câu 32. Tại sao dùng Wilson CI cho tỷ lệ thô?

**Trả lời ngắn:** Wilson CI có tính chất tốt hơn khoảng Wald đơn giản cho tỷ lệ nhị phân, đặc biệt khi tỷ lệ không gần 50%. Tuy nhiên nó vẫn chỉ mô tả theo click và chưa giải quyết phụ thuộc trong session.

### Câu 33. Tại sao dùng cluster-robust SE và cluster bootstrap?

**Trả lời ngắn:** Các click trong cùng session không độc lập. Cluster-robust SE hiệu chỉnh covariance của hệ số; cluster bootstrap lấy mẫu lại cả session để giữ cấu trúc phụ thuộc bên trong phiên.

**Nếu thầy hỏi sâu:** Nếu bootstrap từng click độc lập, khoảng tin cậy có thể quá hẹp vì giả vờ rằng số quan sát độc lập là 165.474.

### Câu 34. Tại sao mô hình A/B phải điều chỉnh covariate?

**Trả lời ngắn:** Vì hai nhóm không được randomize và balance diagnostics cho thấy chúng không tương đương. Nhóm điều chỉnh Order, thời gian, country và đặc điểm sản phẩm để giảm confounding quan sát được.

**Nếu thầy hỏi sâu:** Điều chỉnh không biến phân tích thành thử nghiệm ngẫu nhiên và không loại được confounding từ biến không quan sát.

### Câu 35. Tại sao dùng Holm correction khi xét từng category?

**Trả lời ngắn:** Kiểm định nhiều category làm tăng xác suất có ít nhất một kết quả dương tính giả. Holm kiểm soát family-wise error rate và mạnh hơn Bonferroni đơn giản trong nhiều trường hợp.

**Nếu thầy hỏi sâu:** Joint interaction test có `p = 0,051`, nên bằng chứng về dị biệt giữa category chỉ ở mức sát ngưỡng. Không nên chỉ chọn riêng kết quả Trousers rồi khẳng định chắc chắn.

### Câu 36. Kết quả có ổn định theo thời gian không?

**Trả lời ngắn:** Chênh lệch B–A cùng chiều trong train, tháng 7 và đầu tháng 8. Điều này hỗ trợ tính ổn định của mối liên hệ, nhưng vẫn không chứng minh giá cao gây Exit.

## 7. Lựa chọn mô hình

### Câu 37. Tại sao so sánh LPM, Logistic GLM và GAM?

**Trả lời ngắn:** Ba mô hình tạo một dải từ đơn giản đến linh hoạt: LPM là benchmark tuyến tính dễ hiểu, Logistic bảo đảm xác suất trong `[0,1]`, còn GAM kiểm tra xem quan hệ phi tuyến có cải thiện dự báo hay không.

**Nếu thầy hỏi sâu:** So sánh trên cùng dữ liệu, cùng target và cùng các tầng predictor giúp tách lợi ích của dạng mô hình khỏi lợi ích của feature.

### Câu 37b. GAM là gì?

**Trả lời ngắn:** GAM là **Generalized Additive Model**, tiếng Việt thường gọi là **mô hình cộng tổng quát**. Đây là mở rộng của GLM, trong đó một số biến liên tục được mô hình hóa bằng các hàm trơn thay vì bắt buộc có quan hệ đường thẳng với biến đáp ứng.

Với target nhị phân `Exit`, dạng tổng quát trong bài là:

\[
\operatorname{logit}\{P(Exit=1)\}
=\beta_0+s_1(\log_2(Order))+s_2(Price)+s_3(RepeatRate)
 +\text{các biến phân loại và biến tuyến tính khác}.
\]

Trong đó `s(...)` là hàm trơn được ước lượng từ dữ liệu. GAM vẫn dùng link logit và phân phối Binomial, nên xác suất dự đoán luôn nằm trong `[0,1]`.

**Nếu thầy hỏi sâu:** “Additive” nghĩa là các thành phần được cộng lại; GAM không tự động chứa tương tác giữa các biến nếu ta không chỉ định tương tác. Trong Rmd, nhóm dùng `bam(..., family = binomial(), method = "fREML", discrete = TRUE)` để fit GAM hiệu quả trên dữ liệu lớn.

### Câu 37c. Tại sao không chỉ dùng Logistic GLM mà phải thử GAM?

**Trả lời ngắn:** Logistic GLM giả định dạng tuyến tính trên thang log-odds đối với các biến liên tục. GAM cho phép kiểm tra xem quan hệ giữa Order, Price hoặc history feature với xác suất Exit có cong/phi tuyến hay không, mà không cần chọn trước một công thức đa thức cụ thể.

**Nếu thầy hỏi sâu:** GAM linh hoạt hơn nhưng khó diễn giải hơn và có nguy cơ concurvity. Trong bài, GAM không cải thiện đáng kể log loss hoặc Brier so với Logistic GLM, trong khi concurvity lên tới 0,994; vì vậy Logistic GLM được ưu tiên.

### Câu 38. LPM có vai trò gì nếu có thể dự đoán ngoài `[0,1]`?

**Trả lời ngắn:** LPM là baseline dễ diễn giải và cho thấy mức độ mà một mô hình tuyến tính đơn giản có thể đạt được. Nó không được chọn cuối vì trên temporal test có 1,706% dự đoán ngoài `[0,1]` và calibration kém hơn.

### Câu 39. Tại sao Logistic GLM phù hợp với target này?

**Trả lời ngắn:** Target là nhị phân nên Logistic GLM mô hình hóa log-odds và luôn sinh xác suất trong `[0,1]`. Nó vẫn tương đối dễ diễn giải bằng odds ratio và hỗ trợ robust inference.

### Câu 40. Tại sao thử GAM?

**Trả lời ngắn:** GAM cho phép Order, Price và một số biến lịch sử có quan hệ phi tuyến với xác suất Exit mà không phải chỉ định trước dạng hàm. Nó dùng để kiểm tra liệu tính linh hoạt có mang lại cải thiện dự báo hay không.

**Nếu thầy hỏi sâu:** Các smooth của GAM được ước lượng bằng `bam`, Binomial-logit, phương pháp fREML. Kết quả cho thấy GAM gần như không cải thiện so với Logistic sau khi đã biến đổi `log2(order)`.

### Câu 41. Ba tầng predictor có ý nghĩa gì?

**Trả lời ngắn:** Baseline gồm `log2(order)`, thời gian và country; current-click thêm đặc điểm sản phẩm hiện tại; history-enhanced thêm hành vi đã xảy ra trong session. Cấu trúc tăng dần giúp đo giá trị bổ sung của từng nhóm thông tin.

#### Bảng biến được sử dụng trong từng mô hình

Biến phụ thuộc của tất cả mô hình dưới đây là `Exit` (`exit` trong code), với `1` là click cuối session và `0` là session còn tiếp tục. `session_id` **không phải predictor**; nó chỉ dùng để chia fold và tính cluster-robust covariance/bootstrap.

| Tầng mô hình | Biến được sử dụng |
|---|---|
| Baseline | `log2_order`, `time_30`, `country_group` |
| Current-click | Toàn bộ baseline + `price_10`, `category`, `colour`, `location`, `photography`, `page` |
| History-enhanced của LPM và Logistic GLM | Toàn bộ current-click + `unique_products`, `unique_categories`, `repeat_current`, `category_switch`, `page_switch`, `price_delta_10`, `abs_price_delta_10`, `price_vs_prior_mean_10`, `repeat_rate`, `category_switch_rate` |
| History-enhanced của GAM | `s(log2_order)`, `s(price)`, `time_30`, `country_group`, `category`, `colour`, `location`, `photography`, `page`, `s(repeat_rate)`, `s(abs_price_delta_10)`, `unique_categories`, `repeat_current`, `category_switch`, `page_switch`, `price_delta_10`, `price_vs_prior_mean_10`, `category_switch_rate` |

Trong GAM, ký hiệu `s(...)` nghĩa là biến được ước lượng bằng hàm trơn. GAM không giữ `unique_products` vì biến này gần trùng thông tin với `Order` và `repeat_rate`, gây concurvity cao.

#### Ý nghĩa các biến đã biến đổi và biến lịch sử

| Biến | Ý nghĩa |
|---|---|
| `log2_order` | Log cơ số 2 của vị trí click trong session |
| `time_30` | Số ngày từ ngày đầu dữ liệu, chia cho 30 |
| `country_group` | Country; mức có dưới 100 click trên train được gộp thành `Other` |
| `price_10` | Giá sản phẩm tính theo mỗi 10 USD |
| `unique_products` | Số sản phẩm khác nhau đã xem từ đầu session đến click hiện tại |
| `unique_categories` | Số danh mục khác nhau đã xem đến click hiện tại |
| `repeat_current` | Bằng 1 nếu sản phẩm hiện tại đã xuất hiện trước đó trong session |
| `category_switch` | Bằng 1 nếu click hiện tại đổi danh mục so với click trước |
| `page_switch` | Bằng 1 nếu click hiện tại đổi page so với click trước |
| `price_delta_10` | Chênh lệch giá với click trước, theo mỗi 10 USD |
| `abs_price_delta_10` | Độ lớn tuyệt đối của chênh lệch giá với click trước |
| `price_vs_prior_mean_10` | Giá hiện tại trừ giá trung bình của lịch sử trước đó, theo mỗi 10 USD |
| `repeat_rate` | Tỷ lệ click quay lại sản phẩm đã xem tính đến hiện tại |
| `category_switch_rate` | Tỷ lệ chuyển danh mục tích lũy tính đến hiện tại |

#### Biến trong mô hình so sánh giá dạng A/B

Mô hình A/B chính trên validation tháng 7 dùng:

```text
Exit ~ high_price + log2_order + time_30 + country_group
       + category + colour + location + photography + page
```

Trong đó `high_price = 1` nếu giá sản phẩm cao hơn trung bình của category và bằng 0 nếu không. Mô hình này **không đưa `price` vào cùng `high_price`**, vì `high_price` đã được tạo từ giá và mục tiêu là ước lượng chênh lệch giữa hai nhóm giá.

Mô hình kiểm tra dị biệt theo category thêm tương tác `high_price × category`. Các mô hình kiểm tra độ ổn định theo thời gian dùng đặc tả gọn hơn:

```text
Exit ~ high_price + log2_order + time_30 + country_group
```

Do đặc tả điều chỉnh khác nhau, OR trong bảng ổn định theo thời gian không được so trực tiếp như thể nó là cùng một ước lượng với adjusted OR 1,071 của mô hình A/B chính.

#### Những biến cố ý không đưa vào predictor

| Biến | Lý do không sử dụng |
|---|---|
| `session_id` | Chỉ là mã cụm, không có ý nghĩa dự báo khái quát hóa |
| `session_length` | Thông tin tương lai, gây target leakage |
| `year` | Không biến thiên, vì toàn bộ dữ liệu thuộc năm 2008 |
| `product_model` | Có 217 mức và chưa có quy tắc gộp mức hiếm được kiểm chứng |
| `price_above_avg_code`/`high_price` trong mô hình dự báo chính | Chỉ dùng cho phân tích hai nhóm giá; mô hình dự báo chính sử dụng giá liên tục |
| Giá trị tương lai sau click hiện tại | Không tồn tại tại thời điểm dự báo và sẽ gây leakage |

### Câu 42. Tại sao không chọn mô hình chỉ theo p-value?

**Trả lời ngắn:** p-value trả lời về bằng chứng liên hệ, không trực tiếp đo chất lượng dự báo hoặc calibration. Mẫu lớn cũng có thể tạo p-value rất nhỏ cho cải thiện thực tế rất nhỏ.

### Câu 43. Tại sao không so sánh AIC của LPM với Logistic/GAM?

**Trả lời ngắn:** LPM dùng likelihood Gaussian, còn Logistic và GAM dùng likelihood Binomial. AIC chỉ có ý nghĩa so sánh các mô hình fit trên cùng response với likelihood tương thích; vì vậy báo cáo để trống AIC của LPM trong bảng so sánh đó.

### Câu 44. GVIF và concurvity dùng để làm gì?

**Trả lời ngắn:** GVIF đánh giá collinearity trong Logistic GLM; concurvity là khái niệm tương tự cho các hàm trơn trong GAM. GVIF điều chỉnh lớn nhất của Logistic là 2,424, còn concurvity của GAM lên đến 0,994.

**Nếu thầy hỏi sâu:** Concurvity cao làm partial effect của GAM khó diễn giải riêng. Vì vậy GAM được giữ như đối chứng dự báo phi tuyến, không dùng để đưa ra kết luận riêng cho từng smooth.

**Thuật ngữ tiếng Việt:** Có thể gọi là **tính đồng tuyến phi tuyến** hoặc **mức chồng lấn/phụ thuộc phi tuyến giữa các hàm trơn**. “Concurvity” chưa có một bản dịch tiếng Việt hoàn toàn thống nhất, nên khi vấn đáp nên nói cả thuật ngữ tiếng Anh trong ngoặc.

**Ngưỡng diễn giải:** `mgcv::concurvity()` trả về chỉ số trong khoảng 0–1; 0 là không có vấn đề và 1 là gần như thiếu khả năng nhận dạng riêng giữa các term. Không có cutoff chính thức áp dụng cho mọi bài, nhưng có thể dùng quy tắc kinh nghiệm sau:

| Concurvity | Diễn giải thực hành |
|---:|---|
| `< 0,5` | Thấp, thường chấp nhận được |
| `0,5–0,8` | Trung bình, cần kiểm tra các term và độ ổn định |
| `> 0,8` | Cao, cần thận trọng khi diễn giải |
| `> 0,9` | Rất cao/nghiêm trọng; nên xem xét loại, gộp hoặc tái biểu diễn biến |

Trong bài, giá trị **0,994** thuộc mức rất cao. Vì vậy nhóm không nói rằng GAM “sai” hoặc không thể dự báo; nhóm chỉ hạn chế việc diễn giải partial effect của từng smooth như một hiệu ứng riêng biệt. GAM được giữ làm đối chứng dự báo phi tuyến, còn Logistic GLM được ưu tiên vì dễ diễn giải hơn.

### Câu 44b. Tại sao bài này phải đánh giá concurvity?

**Trả lời ngắn:** Vì nhóm đã đưa GAM vào so sánh và GAM dùng các hàm trơn để mô hình hóa quan hệ phi tuyến. Các predictor trong bài đều mô tả tiến trình session, nên có khả năng chứa thông tin chồng lấn. Concurvity giúp kiểm tra liệu từng smooth có còn nhận dạng và diễn giải được riêng hay không.

**Nếu thầy hỏi sâu:** Trong bài, `log2_order`, `unique_products`, `unique_categories` và `repeat_rate` đều liên quan đến mức độ session đã diễn ra bao lâu. Nếu không kiểm tra, ta có thể gán nhầm tín hiệu chung của tiến trình cho một biến cụ thể. Kết quả 0,994 giải thích vì sao nhóm loại `s(unique_products)` khỏi GAM và không diễn giải các partial-effect plot như hiệu ứng độc lập.

**Điểm cần phân biệt:** Concurvity không đo mô hình dự báo tốt hay xấu. ROC–AUC, log loss, Brier và calibration mới đánh giá chất lượng dự báo. Concurvity chỉ đánh giá vấn đề chồng lấn và khả năng nhận dạng/diễn giải của các term trong GAM. Với Logistic GLM, nhóm dùng GVIF vì đó là chẩn đoán phù hợp cho collinearity của các term tuyến tính/factor.

### Câu 45. Tại sao cuối cùng chọn Logistic GLM?

**Trả lời ngắn:** Logistic và GAM gần như bằng nhau về ROC–AUC, log loss và Brier. Logistic được chọn vì đơn giản, dễ diễn giải hơn, xác suất hợp lệ và không gặp concurvity nghiêm trọng như GAM.

**Nếu thầy hỏi sâu:** Trên validation, quy tắc là giữ mô hình trong 1% log loss tốt nhất, sau đó 1% Brier tốt nhất; nếu còn hòa thì ưu tiên Logistic, rồi GAM, cuối cùng LPM. Quy tắc được đặt trước khi xem temporal test.

### Câu 45b. Quy tắc “top 1% tốt nhất” dựa trên cơ sở nào?

**Trả lời ngắn:** Đây là một ngưỡng **dung sai tương đối** được đặt trước để xem những mô hình có hiệu năng gần như tương đương là cùng một nhóm ứng viên. Nó không phải p-value, không phải khoảng tin cậy và không phải quy luật thống kê bắt buộc.

**Cách tính đúng trong code:** Nếu metric tốt nhất là `m_min`, nhóm giữ các mô hình thỏa:

\[
m_i\leq 1{,}01\times m_{min},
\]

vì log loss và Brier càng thấp càng tốt. Sau đó nhóm lọc tiếp theo Brier; nếu vẫn còn nhiều ứng viên thì chọn Logistic GLM vì đơn giản và dễ diễn giải hơn GAM.

**Tại sao chọn 1%?** Chênh lệch rất nhỏ giữa các mô hình có thể không có ý nghĩa thực tế, đặc biệt khi các khoảng tin cậy chồng lấn. Ngưỡng 1% giúp tránh tuyên bố một mô hình “tốt hơn” chỉ vì thắng một lượng rất nhỏ do biến động mẫu, rồi áp dụng nguyên tắc parsimony để chọn mô hình dễ giải thích hơn.

**Nếu thầy hỏi “cơ sở chính xác của con số 1% là gì?”:** Không có định lý nào buộc phải dùng đúng 1%. Đây là một lựa chọn thực hành cần được nêu rõ là quy ước trước phân tích. Có thể làm phân tích độ nhạy với 0,5% và 2%; nếu mô hình được chọn vẫn là Logistic GLM thì kết luận bền vững hơn. Trong bài, nhóm dùng 1% nhất quán và không điều chỉnh quy tắc sau khi xem temporal test.

## 8. Metric, threshold và kết quả dự báo

### Câu 46. Tại sao Accuracy không phải metric chính?

**Trả lời ngắn:** Exit chỉ chiếm 14,52%. Mô hình luôn đoán Continue đã có Accuracy 85,48% nhưng không phát hiện được Exit nào, nên Accuracy dễ gây hiểu nhầm.

**Nếu thầy hỏi sâu:** Tại threshold tối đa F1, Accuracy của các mô hình chỉ khoảng 62–64%, thấp hơn naive baseline, nhưng đổi lại Recall Exit đạt khoảng 59–62%.

### Câu 47. Tại sao báo cáo cả ROC–AUC và Average Precision?

**Trả lời ngắn:** ROC–AUC đo khả năng xếp hạng giữa lớp dương và âm; AP tập trung hơn vào chất lượng phát hiện lớp Exit hiếm. Mốc ngẫu nhiên của AP xấp xỉ prevalence Exit, nên dễ đánh giá mức cải thiện trong dữ liệu mất cân bằng.

### Câu 48. Tại sao cần log loss và Brier nếu đã có AUC?

**Trả lời ngắn:** AUC chỉ quan tâm thứ hạng, không đánh giá độ lớn xác suất. Log loss phạt mạnh dự đoán tự tin nhưng sai; Brier đo sai số bình phương của xác suất.

### Câu 49. Brier Skill Score 0,039 có nghĩa gì?

**Trả lời ngắn:** Mô hình Logistic cải thiện Brier khoảng 3,9% so với dự báo hằng bằng prevalence train. Đây là cải thiện dương nhưng khiêm tốn, nên mô hình chưa sẵn sàng triển khai.

### Câu 50. Calibration intercept và slope được hiểu thế nào?

**Trả lời ngắn:** Lý tưởng là intercept bằng 0 và slope bằng 1. Logistic trên temporal test có intercept −0,127 và slope 0,934, cho thấy xác suất hơi cao và hơi cực đoan so với dữ liệu thực tế, nhưng gần lý tưởng hơn LPM.

### Câu 51. Tại sao threshold khoảng 0,162 chứ không phải 0,5?

**Trả lời ngắn:** Threshold được chọn để tối đa F1 trên prediction ngoài fold của train. Vì prevalence Exit thấp và phân phối xác suất tập trung ở mức thấp, threshold 0,5 sẽ bỏ sót phần lớn Exit.

**Nếu thầy hỏi sâu:** 0,5 không phải ngưỡng mặc định tối ưu cho mọi mục tiêu. Ngưỡng vận hành phải phụ thuộc chi phí false positive/false negative; bài dùng F1 vì chưa có ma trận chi phí kinh doanh.

### Câu 51b. Tại sao dùng F1 làm tiêu chí?

**Trả lời ngắn:** Vì lớp `Exit = 1` chỉ chiếm 14,52%, nên Accuracy có thể cao dù mô hình không phát hiện Exit. F1 là trung bình điều hòa của Precision và Recall, giúp cân bằng hai mục tiêu: cảnh báo đúng và không bỏ sót quá nhiều Exit.

**Điểm phải nói thật rõ:** Trong bài, F1 **không phải tiêu chí chính để chọn mô hình**. Nhóm chọn mô hình bằng log loss và Brier trên validation; F1 chỉ được tối đa hóa để chọn threshold phân loại sau khi mô hình đã được fit.

**Nếu thầy hỏi sâu:** Threshold được chọn từ prediction out-of-fold của five-fold CV theo session trên train, sau đó khóa trước validation và temporal test. Cách này tránh chọn threshold trực tiếp trên test cuối.

**Tại sao không dùng Accuracy?** Mô hình luôn đoán Continue đạt Accuracy 85,48% nhưng Recall của Exit bằng 0. Accuracy không phản ánh mục tiêu phát hiện lớp thiểu số.

**Tại sao không mặc định dùng F2 hoặc F0,5?** F1 giả định Precision và Recall quan trọng tương đối ngang nhau. Nếu doanh nghiệp coi bỏ sót Exit nghiêm trọng hơn cảnh báo nhầm, F2 có thể phù hợp; nếu muốn giảm cảnh báo nhầm, F0,5 có thể phù hợp. Bài không có ma trận chi phí thực tế nên dùng F1 như lựa chọn trung tính và phải thừa nhận đây là một giả định.

**Hạn chế:** F1 không xét `TN` và phụ thuộc threshold. Vì vậy nhóm vẫn báo cáo ROC–AUC, Average Precision, log loss, Brier và calibration để đánh giá đầy đủ cả xếp hạng lẫn chất lượng xác suất.

### Câu 51c. Thầy hỏi: “Tại sao dùng F1 mà không dùng hàm chi phí?”

**Trả lời ngắn:** Nếu có chi phí kinh doanh đáng tin cậy, hàm chi phí sẽ phù hợp hơn F1. Tuy nhiên bộ dữ liệu không có thông tin về chi phí của false positive và false negative, nên nhóm không tự đặt các con số chủ quan. Nhóm dùng F1 như một tiêu chí trung tính, minh bạch để chọn threshold, đồng thời ghi rõ đây chưa phải threshold tối ưu cho một quyết định kinh doanh cụ thể.

**Nếu thầy hỏi sâu:** Với chi phí `C_FP` cho cảnh báo nhầm và `C_FN` cho bỏ sót Exit, ta có thể chọn threshold trên validation bằng cách tối thiểu hóa:

\[
\text{Expected Cost}=C_{FP}\,FP+C_{FN}\,FN.
\]

Nếu `C_FN` lớn hơn `C_FP`, threshold thường nên thấp hơn để tăng Recall; nếu `C_FP` lớn hơn, threshold nên cao hơn để giảm cảnh báo nhầm. Chi phí phải được xác định trước từ mục tiêu vận hành và chỉ dùng validation, không tối ưu trực tiếp trên temporal test.

**Điểm cần phân biệt:** Hàm chi phí phù hợp với một quyết định triển khai cụ thể; F1 phù hợp hơn cho báo cáo phương pháp khi chưa có utility kinh doanh. Do đó nhóm không khẳng định F1 là tối ưu tuyệt đối, mà chỉ là lựa chọn tạm thời có thể thay thế khi có cost matrix.

### Câu 52. Precision khoảng 21% có quá thấp không?

**Trả lời ngắn:** Nó cho thấy cứ khoảng năm click bị cảnh báo thì chỉ một click thực sự là Exit. Đây là hạn chế vận hành quan trọng và là lý do nhóm không tuyên bố mô hình sẵn sàng triển khai.

**Nếu thầy hỏi sâu:** Recall khoảng 60% nghĩa là mô hình phát hiện được khoảng ba phần năm Exit, nhưng phải đánh đổi bằng nhiều false positive. Muốn chọn ngưỡng tốt hơn cần biết chi phí của hai loại sai lầm.

### Câu 53. AUC 0,666 có tốt không?

**Trả lời ngắn:** Tốt hơn ngẫu nhiên nhưng chỉ ở mức trung bình. Nó cho thấy mô hình có tín hiệu xếp hạng, không đủ để khẳng định hiệu năng cao hoặc khả năng triển khai.

### Câu 54. GAM và Logistic có AUC bằng nhau; có thể nói Logistic tốt hơn không?

**Trả lời ngắn:** Không nên nói Logistic tốt hơn về AUC. Hai mô hình gần tương đương về hiệu năng; Logistic được **ưu tiên** vì parsimony và khả năng diễn giải, không phải vì thắng có ý nghĩa thống kê.

### Câu 55. Những biến nào liên hệ mạnh nhất với Exit?

**Trả lời ngắn:** Theo robust Wald statistic trên mỗi bậc tự do, năm nhóm nổi bật là `log2(Order)`, số danh mục duy nhất đã xem, quay lại sản phẩm cũ, Page và Country.

**Nếu thầy hỏi sâu:** Đây là thứ hạng bằng chứng liên hệ dự báo, không phải thứ hạng tác động nhân quả. Không nên so sánh trực tiếp độ lớn OR giữa các biến có đơn vị khác nhau.

### Câu 56. Tại sao xác suất Exit quan sát giảm theo Order?

**Trả lời ngắn:** Các session tiếp tục sâu thường thuộc nhóm có mức gắn kết cao hơn, nên hazard quan sát giảm từ 20,47% ở click đầu xuống 7,64% ở nhóm trên 20. Đây có thể là hỗn hợp của thay đổi hành vi và survivor selection.

## 9. Hạn chế và hướng phát triển

### Câu 57. Hạn chế nghiêm trọng nhất là gì?

**Trả lời ngắn:** Dữ liệu không có mua hàng, giỏ hàng hoặc thanh toán. Vì vậy `Exit` không phân biệt phiên kết thúc thành công với phiên bỏ đi vì thất vọng.

### Câu 58. Cluster-robust SE đã xử lý hoàn toàn phụ thuộc trong session chưa?

**Trả lời ngắn:** Chưa. Nó hiệu chỉnh sai số chuẩn cho suy luận nhưng không mô hình hóa trực tiếp cấu trúc phụ thuộc. Mixed-effects model hoặc discrete-time survival model là hướng phát triển phù hợp hơn.

### Câu 59. Tại sao đề xuất survival model?

**Trả lời ngắn:** Bài toán thực chất là discrete-time hazard: tại mỗi click, session có thể kết thúc nếu đã sống sót đến đó. Survival model mô tả trực tiếp risk set và selection theo tiến trình session.

### Câu 60. Tại sao không dùng Random Forest hoặc Gradient Boosting ngay?

**Trả lời ngắn:** Mục tiêu đồ án gồm so sánh LPM, GLM và GAM, đồng thời cần khả năng diễn giải và suy luận. Mô hình cây có thể được dùng sau như benchmark phi tham số để kiểm tra trần dự báo của feature hiện có.

### Câu 61. A/B test thật nên thiết kế như thế nào?

**Trả lời ngắn:** Randomize ở cấp session, lưu `experiment_id` và giữ mỗi session trong đúng một nhánh. Treatment khả thi là cách trình bày thông tin giá hoặc ưu đãi vận chuyển, không tùy tiện thay giá sản phẩm.

**Nếu thầy hỏi sâu:** Phân tích theo intention-to-treat, khóa trước primary outcome và cửa sổ click, dùng kiểm định hai phía ở mức 5%, không dừng sớm theo p-value chưa điều chỉnh.

### Câu 62. Tại sao báo cáo không đưa ra cỡ mẫu cho A/B test tương lai?

**Trả lời ngắn:** Tỷ lệ hiện tại được tính ở cấp click, trong khi thí nghiệm tương lai randomize và phân tích ở cấp session. Muốn tính power phải khóa trước outcome window, baseline rate cấp session, minimum detectable effect và tỷ lệ hao hụt.

### Câu 63. Nếu có thêm dữ liệu, ưu tiên bổ sung biến nào?

**Trả lời ngắn:** Ưu tiên trạng thái giỏ hàng/mua hàng, thời gian giữa các click, user ID xuyên session và thông tin thiết bị. Đây là các biến giúp target có ý nghĩa kinh doanh hơn và có thể nâng khả năng dự báo.

## 10. Các câu nói dễ bị thầy bắt lỗi

| Không nên nói | Nên nói |
|---|---|
| “Exit là khách bỏ mua hàng.” | “Exit là click cuối session; dữ liệu không cho biết có mua hàng hay không.” |
| “Giá cao làm khách rời đi.” | “Nhóm giá cao có liên hệ với Exit cao hơn; thiết kế quan sát không chứng minh nhân quả.” |
| “Đây là một A/B test.” | “Đây là so sánh hai nhóm dạng A/B; chưa có randomization.” |
| “Ta chấp nhận hoàn toàn giả thuyết.” | “Ta bác bỏ hoặc chưa đủ bằng chứng bác bỏ \(H_0\) tại mức ý nghĩa đã chọn.” |
| “OR 1,071 nghĩa là xác suất tăng 7,1%.” | “Odds tăng khoảng 7,1%; adjusted risk difference chỉ khoảng 0,82 điểm phần trăm.” |
| “Order tăng làm Exit giảm.” | “Order liên hệ với hazard Exit thấp hơn trong các session còn tồn tại; không phải kết luận nhân quả.” |
| “GAM tốt nhất vì linh hoạt nhất.” | “GAM linh hoạt nhưng không cải thiện đáng kể và có concurvity cao.” |
| “Logistic có AUC cao hơn GAM.” | “Hai mô hình gần như bằng nhau; chọn Logistic vì đơn giản và dễ diễn giải.” |
| “Accuracy thấp nên mô hình vô dụng.” | “Accuracy không thích hợp để chọn mô hình khi lớp mất cân bằng; tuy vậy precision và BSS cho thấy hiệu năng vận hành còn hạn chế.” |
| “Accuracy 85,48% là rất tốt.” | “Đó là naive accuracy khi luôn đoán Continue và Recall Exit bằng 0.” |
| “P-value nhỏ chứng minh hiệu ứng lớn.” | “P-value đo bằng chứng chống lại \(H_0\); effect size và CI mới mô tả độ lớn.” |
| “Robust SE đã loại hết confounding.” | “Robust SE xử lý covariance theo cụm, không loại confounding.” |
| “Validation tháng 7 là test cuối.” | “Tháng 7 dùng chọn mô hình; 01–12/08 mới là temporal test cuối.” |
| “Có thể so AIC của cả ba mô hình.” | “Không so AIC của Gaussian LPM với các mô hình Binomial trong bảng này.” |
| “Tháng 8 có lưu lượng giảm.” | “Dữ liệu tháng 8 chưa đầy đủ nên không thể kết luận về tổng lưu lượng tháng.” |

## 11. Mẫu kết luận khi thầy hỏi “Vậy đóng góp chính là gì?”

**Câu trả lời gợi ý:**

> Đóng góp chính của nhóm không phải là tạo ra một mô hình có độ chính xác rất cao, mà là xây dựng một quy trình đánh giá đúng cấu trúc session và thời gian. Nhóm tạo target không rò rỉ tương lai, xây dựng feature lịch sử chỉ từ thông tin đã quan sát, hiệu chỉnh phụ thuộc theo session và giữ temporal test độc lập. Kết quả cho thấy lịch sử duyệt bổ sung tín hiệu đáng kể, nhưng hiệu năng cuối chỉ ở mức trung bình. Logistic GLM được chọn vì đạt hiệu năng gần GAM với cấu trúc đơn giản và xác suất dễ diễn giải hơn. So sánh nhóm giá chỉ cho thấy liên hệ, và cần A/B test ngẫu nhiên thật sự trước khi đưa ra quyết định nhân quả.

## 12. Checklist trước khi vào vấn đáp

- Nhớ phân biệt **click**, **session** và **user**.
- Nhớ `Exit` không phải conversion, churn hay cart abandonment.
- Nhớ tháng 7 là validation; 01–12/08 là temporal test cuối.
- Nhớ giải thích leakage trước khi kể tên feature.
- Khi nói về A/B, luôn thêm cụm “dữ liệu quan sát, không chứng minh nhân quả”.
- Khi đọc OR, không đổi nhầm sang điểm phần trăm.
- Khi nói mô hình tốt nhất, nói “được chọn vì hiệu năng gần tương đương nhưng đơn giản hơn”.
- Chủ động thừa nhận AUC 0,666, BSS 0,039 và precision khoảng 21% là còn khiêm tốn.
- Nếu không chắc một diễn giải, quay về ba lớp: **mô tả – liên hệ dự báo – nhân quả**.
