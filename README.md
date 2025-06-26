# Data Analysis & Insights from Cafe Sales Dataset: Optimizing Business Strategy with SQL
## Overview
Một dự án phân tích dữ liệu toàn diện được thực hiện trên tập dữ liệu dirty_cafe_sales.csv, một tập dữ liệu mô phỏng các giao dịch bán hàng tại một quán cà phê. Sử dụng SQL trong Azure Data Studio, tôi đã tiến hành đầy đủ quá trình làm sạch dữ liệu và phân tích khám phá dữ liệu (EDA) nhằm khám phá các thông tin chi tiết có thể hành động. Tập dữ liệu bao gồm các thông tin như mã giao dịch, mặt hàng đã bán, số lượng, giá cả, phương thức thanh toán, địa điểm (tại quán/mang đi), và ngày giao dịch. Thông qua dự án này, tôi đã xử lý các vấn đề về chất lượng dữ liệu (ví dụ: giá trị bị thiếu, dữ liệu trùng lặp, ngoại lệ) và phân tích các câu hỏi kinh doanh quan trọng liên quan đến sở thích khách hàng, hành vi theo địa điểm và xu hướng thanh toán. Kết quả phân tích được trình bày nhằm thể hiện khả năng của tôi trong việc chuyển đổi dữ liệu thô thành các khuyến nghị mang tính chiến lược, qua đó làm nổi bật kỹ năng phân tích dữ liệu và giải quyết vấn đề.
## Objective
Mục tiêu chính của dự án này là làm sạch và phân tích tập dữ liệu dirty_cafe_sales.csv để rút ra ba thông tin kinh doanh quan trọng: (1) xác định các sản phẩm phổ biến nhằm thúc đẩy chiến lược marketing (2) hiểu hành vi khách hàng theo từng địa điểm để tối ưu hiệu quả vận hành, và (3) đánh giá xu hướng phương thức thanh toán để đưa ra các cơ hội hợp tác tiềm năng. Bằng cách xử lý các thách thức về chất lượng dữ liệu và trả lời các câu hỏi trọng tâm thông qua truy vấn SQL, tôi hướng đến việc cung cấp các khuyến nghị dựa trên dữ liệu nhằm tăng doanh thu, nâng cao sự hài lòng của khách hàng và phù hợp với xu hướng thị trường. Dự án này thể hiện khả năng của tôi trong việc xử lý dữ liệu, viết truy vấn SQL, và chuyển hóa các hiểu biết từ dữ liệu thành giá trị kinh doanh — những kỹ năng thiết yếu đối với vai trò nhà phân tích dữ liệu
## SQL Code for Table Creation
```sql
CREATE TABLE dirty_cafe_sales (
    Transaction_ID NVARCHAR(50) PRIMARY KEY,
    Item NVARCHAR(100),
    Quantity INT,
    Price_Per_Unit float,
    Total_Spent float,
    Payment_Method NVARCHAR(50),
    Location NVARCHAR(50),
    Transaction_Date DATETIME
```
## Data Analysis & Findings

### 1. Xử lí dữ liệu (Data Cleaning)
Quá trình xử lí dữ liệu gồm 4 bước sau:
1. Xử lí các giá trị thiếu (NULL, trống, "UNKNOWN", hoặc "ERROR")
2. Kiểm tra giá trị trùng lặp => thường là khóa chính
3. Chuyển hóa kiểu dữ liệu
4.  Kiểm tra bất thường của dữ liệu và dữ liệu ngoại lai

**Process**

***1.Xử lí các giá trị thiếu (NULL, trống, "UNKNOWN", hoặc "ERROR")***

***1.1. Chuyển các giá trị trống, "UNKNOWN" hoăc "ERROR" thành Null***

```sql
--Cột Item
UPDATE dirty_cafe_sales
SET Item = NULL 
WHERE Item IN ('ERROR', 'UNKNOWN', '')

-- Cột Quantity 
ALTER TABLE dirty_cafe_sales
ALTER COLUMN Quantity VARCHAR(50); -- Chuyển dữ liệu cột Quantity từ tinyint sang varchar(50)

UPDATE dirty_cafe_sales
SET Quantity = NULL
WHERE Quantity IN ('ERROR', 'UNKNOWN', '') OR Quantity IS NULL -- chuyển giá trị trống, "UNKNOWN" hoăc "ERROR" thành Null

UPDATE dirty_cafe_sales
SET Quantity = CASE 
    WHEN ISNUMERIC(Quantity) = 1 THEN Quantity 
    ELSE NULL 
END;

ALTER TABLE dirty_cafe_sales
ALTER COLUMN Quantity INT; -- cập nhật lại kiểu dữ liệu

-- Thêm giá trị vào cột Total_Spent nào là NUll = Quantity * Price_Per_Unit
UPDATE dirty_cafe_sales
SET Total_Spent = Quantity * Price_Per_Unit
WHERE Total_Spent is NULL and Quantity is not null and Price_Per_Unit is not null

-- Cột Payment_Method
UPDATE dirty_cafe_sales
SET Payment_Method = NULL
WHERE Payment_Method IN ('ERROR', 'UNKNOWN', '')

-- Cột Location
UPDATE dirty_cafe_sales
SET Location = NULL
WHERE Location IN ('ERROR', 'UNKNOWN', '')
```
***1.2. Tính toán số lượng Null trên tổng số dữ liệu***

```sql
SELECT COUNT(*) AS total_rows_with_null
FROM dirty_cafe_sales
WHERE  Item IS NULL
   OR Quantity IS NULL
   OR Price_Per_Unit IS NULL
   OR Total_Spent IS NULL
   OR Payment_Method IS NULL
   OR Location IS NULL
   OR Transaction_Date IS NULL;
-- Tổng số lượng cột 
SELECT COUNT(*) AS total_rows
FROM dirty_cafe_sales 
-- Vì tỷ lệ % quá thấp chỉ dưới 1% nên quyết định là xóa 
DELETE FROM dirty_cafe_sales
WHERE Item IS NULL
   OR Quantity IS NULL
   OR Price_Per_Unit IS NULL
   OR Total_Spent IS NULL
   OR Payment_Method IS NULL
   OR Location IS NULL
   OR Transaction_Date IS NULL;
```
***2. Kiểm tra giá trị trùng lặp => thường là khóa chính***

```sql
SELECT Transaction_ID, COUNT(*) AS count
FROM dirty_cafe_sales
GROUP BY Transaction_ID
HAVING COUNT(*) > 1;
```
***3. Chuyển hóa kiểu dữ liệu***

```sql
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dirty_cafe_sales';
```

***4.Kiểm tra bất thường của dữ liệu và dữ liệu ngoại lai***

***4.1. Tính các chỉ số thống kê (min, max, avg, stddev) và kiểm tra phân phối***

```sql
SELECT 
    'Quantity' AS column_name,
    MIN(Quantity) AS min_value,
    MAX(Quantity) AS max_value,
    AVG(CAST(Quantity AS FLOAT)) AS avg_value,
    STDEV(CAST(Quantity AS FLOAT)) AS std_dev
FROM dirty_cafe_sales
WHERE Quantity IS NOT NULL
UNION ALL
SELECT 
    'Price_Per_Unit' AS column_name,
    MIN(Price_Per_Unit) AS min_value,
    MAX(Price_Per_Unit) AS max_value,
    AVG(Price_Per_Unit) AS avg_value,
    STDEV(Price_Per_Unit) AS std_dev
FROM dirty_cafe_sales
WHERE Price_Per_Unit IS NOT NULL
UNION ALL
SELECT 
    'Total_Spent' AS column_name,
    MIN(Total_Spent) AS min_value,
    MAX(Total_Spent) AS max_value,
    AVG(Total_Spent) AS avg_value,
    STDEV(Total_Spent) AS std_dev
FROM dirty_cafe_sales
WHERE Total_Spent IS NOT NULL;
```
***4.2. Xác định outlier bằng quy tắc IQR***

```sql
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price_Per_Unit) over() AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price_Per_Unit) over() AS Q3
    FROM dirty_cafe_sales
)
SELECT 
    Price_Per_Unit
FROM dirty_cafe_sales, stats
WHERE Price_Per_Unit < (Q1 - 1.5 * (Q3 - Q1))
   OR Price_Per_Unit > (Q3 + 1.5 * (Q3 - Q1)) 
```
























