select *
from dirty_cafe_sales 
-- Xử lí dữ liệu (Clearning Data)
-- 1. Xử lí các giá trị thiếu (NULL, trống, "UNKNOWN", hoặc "ERROR") 
-- 1.1. Chuyển các giá trị trống, "UNKNOWN" hoăc "ERROR" thành Null
UPDATE dirty_cafe_sales
SET Item = NULL -- Cột Item
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
-- 1.2. Tính toán số lượng Null trên tổng số dữ liệu 
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
-- 2 Kiểm tra giá trị trùng lặp => thường là khóa chính
SELECT Transaction_ID, COUNT(*) AS count
FROM dirty_cafe_sales
GROUP BY Transaction_ID
HAVING COUNT(*) > 1; 
-- 3. Chuyển hóa kiểu dữ liệu
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dirty_cafe_sales';
-- 4. Kiểm tra bất thường của dữ liệu và dữ liệu ngoại lai 
-- 4.1 Tính các chỉ số thống kê (min, max, avg, stddev) và kiểm tra phân phối
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
-- 4.2. Xác định outlier bằng quy tắc IQR
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
-- Khám phá dữ liệu EDA
-- Tiến hành trả lời các câu hỏi để tìm ra được insight
--1. Phân phối doanh thu và số lượng giao dịch theo mặt hàng (Item) là như thế nào?
select Item, sum(Total_Spent) as Tổng_doanh_thu, Count(Transaction_ID) as Số_Lượng_Giao_Dịch
from dirty_cafe_sales
group by Item
order by sum(Total_Spent) DESC
--2. Trung bình số lượng (Quantity) mua trong mỗi giao dịch của từng mặt hàng là bao nhiêu?
select Item, avg(Quantity) as Số_Lượng_hàng_trung_bình
from dirty_cafe_sales
group by Item
--3. Tỷ lệ giao dịch và doanh thu giữa In-store và Takeaway là bao nhiêu?
with table_1 as (
select Location as Hình_thức, sum(Total_Spent) as Tổng_doanh_thu, count(Transaction_ID) as Số_lượng_đơn
from dirty_cafe_sales
group by Location
), table_2 as (
select *, lag(Số_lượng_đơn, 1) over (order by Số_lượng_đơn DESC) as Số_lượng_đơn_1
from table_1
)
select *, cast(Số_lượng_đơn as decimal(10,2))/ (Số_lượng_đơn + Số_lượng_đơn_1) as Tỉ_lệ_Instore_Takeaway
from table_2
--5. Những mặt hàng nào được mua nhiều ở In-store và Takeaway 
select Location as Hình_thức, Item, count(Transaction_ID) as Số_Lượng_Đơn
from dirty_cafe_sales
group by Location, Item
order by Location DESC
--6. Phương thức thanh toán nào được sử dụng nhiều nhất và có xu hướng thay đổi theo thời gian không?
Select month(Transaction_Date) as Tháng, Payment_Method as Phương_thức, count(Transaction_ID) as Số_lương
from dirty_cafe_sales
group by Payment_Method, month(Transaction_Date)
order by month(Transaction_Date) ASC
--7. Tỷ lệ phần trăm giao dịch của từng phương thức thanh toán (Credit Card, Cash, Digital Wallet) là bao nhiêu?
with table_1 as (
Select  Payment_Method as Phương_thức, count(Transaction_ID) as Số_lương, 
   (select count(*)
     from dirty_cafe_sales) as Tổng_số_lượng
from dirty_cafe_sales
group by Payment_Method
)
select *, cast(Số_lương as decimal(10,2))/Tổng_số_lượng as tỉ_lệ
from table_1
--8. Doanh thu và số lượng giao dịch thay đổi như thế nào theo thời gian (theo tháng)?
Select month(Transaction_Date) as Tháng, sum(Total_Spent) as Tổng_doanh_thu, count(Transaction_ID) as Số_Lượng_Giao_Dịch
from dirty_cafe_sales
group by month(Transaction_Date)
order by month(Transaction_Date) ASC
--9. Mối quan hệ giữa mặt hàng (Item) và địa điểm (Location) hoặc phương thức thanh toán (Payment_Method) là gì?
SELECT 
    Item,
    Location,
    Payment_Method,
    COUNT(*) AS transaction_count,
    SUM(Total_Spent) AS total_revenue
FROM dirty_cafe_sales
GROUP BY Item, Location, Payment_Method
ORDER BY transaction_count DESC