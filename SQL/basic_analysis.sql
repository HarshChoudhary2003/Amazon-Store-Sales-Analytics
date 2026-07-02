-- =====================================================
-- Amazon Store Sales, Profitability & Returns Analytics
-- Basic SQL Analysis
-- =====================================================

-- 1. View sample data
SELECT *
FROM amazon_store_sales
LIMIT 10;

-- 2. Total order lines
SELECT COUNT(*) AS total_order_lines
FROM amazon_store_sales;

-- 3. Total unique orders
SELECT COUNT(DISTINCT `Order ID`) AS total_orders
FROM amazon_store_sales;

-- 4. Total sales
SELECT ROUND(SUM(Sales), 2) AS total_sales
FROM amazon_store_sales;

-- 5. Total profit
SELECT ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales;

-- 6. Total quantity sold
SELECT SUM(Quantity) AS total_quantity
FROM amazon_store_sales;

-- 7. Average order value
SELECT ROUND(
    SUM(Sales) / COUNT(DISTINCT `Order ID`),
    2
) AS average_order_value
FROM amazon_store_sales;

-- 8. Overall profit margin percentage
SELECT ROUND(
    SUM(Profit) * 100 / SUM(Sales),
    2
) AS profit_margin_percentage
FROM amazon_store_sales;

-- 9. Sales and profit by category
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY Category
ORDER BY total_sales DESC;

-- 10. Sales and profit by region
SELECT
    Region,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY Region
ORDER BY total_sales DESC;

-- 11. Sales and profit by customer segment
SELECT
    Segment,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY Segment
ORDER BY total_sales DESC;

-- 12. Payment mode performance
SELECT
    `Payment Mode`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Payment Mode`
ORDER BY total_sales DESC;

-- 13. Shipping mode performance
SELECT
    `Ship Mode`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Ship Mode`
ORDER BY total_sales DESC;

-- 14. Return status analysis
SELECT
    Returns,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY Returns
ORDER BY total_orders DESC;

-- 15. Top 10 products by sales
SELECT
    `Product Name`,
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Product Name`, Category
ORDER BY total_sales DESC
LIMIT 10;