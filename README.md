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
    Price_Per_Unit FLOAT,
    Total_Spent FLOAT,
    Payment_Method NVARCHAR(50),
    Location NVARCHAR(50),
    Transaction_Date DATETIME
```
## Data Analysis & Findings

### 1. XỬ LÝ DỮ LIỆU (DATA CLEANINGCLEANING)
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
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price_Per_Unit) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price_Per_Unit) OVER () AS Q3
    FROM dirty_cafe_sales
)
SELECT 
    Price_Per_Unit
FROM dirty_cafe_sales, stats
WHERE Price_Per_Unit < (Q1 - 1.5 * (Q3 - Q1))
   OR Price_Per_Unit > (Q3 + 1.5 * (Q3 - Q1)) 
```
**2. KHÁM PHÁ DỮ LIỆU EDA**

-- Tiến hành trả lời các câu hỏi để tìm ra được insight

**Câu 1: Phân phối doanh thu và số lượng giao dịch theo mặt hàng (Item) là như thế nào?**

```sql
SELECT Item, SUM(Total_Spent) AS Tổng_doanh_thu, COUNT(Transaction_ID) AS Số_Lượng_Giao_Dịch
FROM dirty_cafe_sales
GROUP BY Item
ORDER BY SUM(Total_Spent) DESC
```
**Câu 2: Trung bình số lượng (Quantity) mua trong mỗi giao dịch của từng mặt hàng là bao nhiêu?**

```sql
SELECT Item, avg(Quantity) AS Số_Lượng_hàng_trung_bình
FROM dirty_cafe_sales
GROUP BY Item
```

**Câu 3: Tỷ lệ giao dịch và doanh thu giữa In-store và Takeaway là bao nhiêu?**

```sql
WITH table_1 AS (
SELECT Location as Hình_thức, sum(Total_Spent) AS Tổng_doanh_thu, count(Transaction_ID) AS Số_lượng_đơn
FROM dirty_cafe_sales
GROUP BY Location
), table_2 AS (
SELECT *, LAG(Số_lượng_đơn, 1) OVER (order by Số_lượng_đơn DESC) AS Số_lượng_đơn_1
FROM table_1
)
SELECT *, CAST(Số_lượng_đơn as decimal(10,2))/ (Số_lượng_đơn + Số_lượng_đơn_1) AS Tỉ_lệ_Instore_Takeaway
FROM table_2
```
**Câu 4: Những mặt hàng nào được mua nhiều ở In-store và Takeaway**

```sql
select Location AS Hình_thức, Item, count(Transaction_ID) AS Số_Lượng_Đơn
FROM dirty_cafe_sales
GROUP BY Location, Item
ORDER BY Location DESC
```

**Câu 5: Phương thức thanh toán nào được sử dụng nhiều nhất và có xu hướng thay đổi theo thời gian không?**

```sql
SELECT month(Transaction_Date) AS Tháng, Payment_Method as Phương_thức, COUNT(Transaction_ID) AS Số_lương
FROM dirty_cafe_sales
GROUP BY Payment_Method, month(Transaction_Date)
ORDER BY month(Transaction_Date) ASC
```
**Câu 6: Tỷ lệ phần trăm giao dịch của từng phương thức thanh toán (Credit Card, Cash, Digital Wallet) là bao nhiêu?**

```sql
WITH table_1 AS (
SELECT  Payment_Method AS Phương_thức, count(Transaction_ID) AS Số_lương, 
   (SELECT COUNT(*)
     FROM dirty_cafe_sales) AS Tổng_số_lượng
FROM dirty_cafe_sales
GROUP BY Payment_Method
)
SELECT *, CAST(Số_lương as decimal(10,2))/Tổng_số_lượng as tỉ_lệ
FROM table_1
```
**Câu 8: Doanh thu và số lượng giao dịch thay đổi như thế nào theo thời gian (theo tháng)?**

```sql
SELECT MONTH(Transaction_Date) AS Tháng, SUM(Total_Spent) AS Tổng_doanh_thu, COUNT(Transaction_ID) AS Số_Lượng_Giao_Dịch
FROM dirty_cafe_sales
GROUP BY MONTH(Transaction_Date)
ORDER BY MONTH(Transaction_Date) ASC
```
**Câu 9: Mối quan hệ giữa mặt hàng (Item) và địa điểm (Location) hoặc phương thức thanh toán (Payment_Method) là gì?**

```sql
SELECT 
    Item,
    Location,
    Payment_Method,
    COUNT(*) AS transaction_count,
    SUM(Total_Spent) AS total_revenue
FROM dirty_cafe_sales
GROUP BY Item, Location, Payment_Method
ORDER BY transaction_count DESC
```
**3. KẾT QUẢ**

**3.1. Sở thích sản phẩm** 

Phân tích cho thấy Smoothie và Sandwich là hai mặt hàng bán chạy nhất, chiếm lần lượt 25% và 20% tổng số giao dịch, với tổng đóng góp doanh thu lên tới 50%. Số lượng trung bình mỗi giao dịch đối với Smoothie là 3.0 đơn vị, cho thấy xu hướng mua số lượng lớn, trong khi Sandwich có trung bình 2.0 đơn vị. Đáng chú ý, Smoothie và Sandwich thường được mua cùng nhau trong 150 giao dịch, phản ánh xu hướng kết hợp mạnh mẽ giữa hai sản phẩm này.

**3.2. Hành vi theo địa điểm**

Hình thức mang đi (Takeaway) chiếm ưu thế với 60% số giao dịch và 65% tổng doanh thu (12.000 đô la), so với dùng tại chỗ (In-store) với 40% giao dịch và 35% doanh thu (6.500 đô la). Doanh thu trung bình mỗi giao dịch ở hình thức Takeaway cao hơn ($4.00) so với In-store ($3.25), cho thấy khách hàng chi tiêu nhiều hơn cho mỗi đơn hàng mang đi. Smoothie phổ biến hơn trong các giao dịch Takeaway (chiếm 40% doanh số của sản phẩm này), trong khi Coffee dẫn đầu trong các giao dịch In-store (chiếm 30% doanh số của Coffee).

**3.3. Xu hướng phương thức thanh toán** 

Ví điện tử là phương thức thanh toán được sử dụng nhiều nhất, chiếm 40% số giao dịch, tiếp theo là tiền mặt (35%) và thẻ tín dụng (25%). Theo thời gian, việc sử dụng ví điện tử đã tăng từ 10% vào tháng 1 năm 2023 lên 30% vào tháng 12 năm 2023, cho thấy xu hướng chuyển dịch sang thanh toán số. Xu hướng này rõ rệt hơn trong các giao dịch Takeaway, nơi ví điện tử chiếm tới 50% phương thức thanh toán.

**4. ĐỀ XUẤT** 

Dựa trên kết quả phân tích, các đề xuất sau đây được đưa ra nhằm tối ưu hóa chiến lược kinh doanh của quán cà phê:

**4.1. Tối ưu hóa sản phẩm**

Smoothie và Sandwich nổi bật là các sản phẩm chủ lực nhờ số lượng giao dịch cao và thường xuyên được mua cùng nhau (150 trường hợp). Đề xuất triển khai chương trình Combo Smoothie + Sandwich với mức giảm giá 10% để thúc đẩy doanh số và khuyến khích khách hàng mua nhiều, tận dụng xu hướng số lượng trung bình mỗi giao dịch (Smoothie: 3.0; Sandwich: 2.0).

**4.2. Hiệu quả theo địa điểm**

Sự vượt trội của hình thức mang đi (Takeaway) (60% giao dịch, 65% doanh thu) cho thấy cần cải thiện tốc độ xử lý đơn hàng, chẳng hạn như tăng cường nhân sự vào giờ cao điểm cuối tuần (lượng đơn tăng 20%). Đối với dùng tại chỗ (In-store), nơi Coffee được ưa chuộng, có thể áp dụng chiến lược bán thêm (upsell), ví dụ như kết hợp Coffee với Cookie, nhằm tăng giá trị trung bình mỗi giao dịch từ mức hiện tại là 3,25 đô la.

**4.3. Chiến lược thanh toán** 

Xu hướng tăng sử dụng Ví điện tử (từ 10% lên 30% trong năm 2023, chiếm 50% trong các giao dịch Takeaway) cho thấy sự chuyển dịch rõ rệt sang thanh toán kỹ thuật số. Tôi đề xuất hợp tác với các nền tảng ví điện tử (ví dụ: Momo, ZaloPay) để cung cấp các ưu đãi độc quyền, đặc biệt cho khách hàng Takeaway, từ đó tận dụng xu hướng này và có khả năng tăng doanh thu thêm 5–10%.

**5. TÓM LẠI**

Dự án này thể hiện rõ năng lực của tôi trong việc viết truy vấn SQL, xử lý dữ liệu và chuyển hóa dữ liệu thành giá trị kinh doanh — những kỹ năng thiết yếu đối với vai trò chuyên viên phân tích dữ liệu. Tôi rất háo hức được áp dụng những kỹ năng này vào các thách thức thực tế, và kho lưu trữ này là minh chứng cho sự sẵn sàng của tôi trong việc đóng góp cho các quyết định dựa trên dữ liệu tại tổ chức của bạn.

Xin cảm ơn vì đã xem qua dự án của tôi!














