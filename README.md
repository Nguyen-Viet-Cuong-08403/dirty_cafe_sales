# Data Analysis & Insights from Cafe Sales Dataset: Optimizing Business Strategy with SQL
## Overview
Một dự án phân tích dữ liệu toàn diện được thực hiện trên tập dữ liệu dirty_cafe_sales.csv, một tập dữ liệu mô phỏng các giao dịch bán hàng tại một quán cà phê. Sử dụng SQL trong Azure Data Studio, tôi đã tiến hành đầy đủ quá trình làm sạch dữ liệu và phân tích khám phá dữ liệu (EDA) nhằm khám phá các thông tin chi tiết có thể hành động. Tập dữ liệu bao gồm các thông tin như mã giao dịch, mặt hàng đã bán, số lượng, giá cả, phương thức thanh toán, địa điểm (tại quán/mang đi), và ngày giao dịch. Thông qua dự án này, tôi đã xử lý các vấn đề về chất lượng dữ liệu (ví dụ: giá trị bị thiếu, dữ liệu trùng lặp, ngoại lệ) và phân tích các câu hỏi kinh doanh quan trọng liên quan đến sở thích khách hàng, hành vi theo địa điểm và xu hướng thanh toán. Kết quả phân tích được trình bày nhằm thể hiện khả năng của tôi trong việc chuyển đổi dữ liệu thô thành các khuyến nghị mang tính chiến lược, qua đó làm nổi bật kỹ năng phân tích dữ liệu và giải quyết vấn đề.
## Objective
Mục tiêu chính của dự án này là làm sạch và phân tích tập dữ liệu dirty_cafe_sales.csv để rút ra ba thông tin kinh doanh quan trọng: (1) xác định các sản phẩm phổ biến nhằm thúc đẩy chiến lược marketing (2) hiểu hành vi khách hàng theo từng địa điểm để tối ưu hiệu quả vận hành, và (3) đánh giá xu hướng phương thức thanh toán để đưa ra các cơ hội hợp tác tiềm năng. Bằng cách xử lý các thách thức về chất lượng dữ liệu và trả lời các câu hỏi trọng tâm thông qua truy vấn SQL, tôi hướng đến việc cung cấp các khuyến nghị dựa trên dữ liệu nhằm tăng doanh thu, nâng cao sự hài lòng của khách hàng và phù hợp với xu hướng thị trường. Dự án này thể hiện khả năng của tôi trong việc xử lý dữ liệu, viết truy vấn SQL, và chuyển hóa các hiểu biết từ dữ liệu thành giá trị kinh doanh — những kỹ năng thiết yếu đối với vai trò nhà phân tích dữ liệu
## SQL Code for Table Creation
```sql
CREATE TABLE dirty_cafe_sales (
    Transaction_ID VARCHAR(50) PRIMARY KEY,
    Item VARCHAR(100),
    Quantity INT,
    Price_Per_Unit DECIMAL(10, 2),
    Total_Spent DECIMAL(10, 2),
    Payment_Method VARCHAR(50),
    Location VARCHAR(50),
    Transaction_Date DATETIME
);
```
