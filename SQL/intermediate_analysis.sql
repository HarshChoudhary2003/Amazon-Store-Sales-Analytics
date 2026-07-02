-- =====================================================
-- Amazon Store Sales, Profitability & Returns Analytics
-- Intermediate SQL Analysis
-- =====================================================

-- 1. Sales, profit, and profit margin by sub-category
SELECT
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) * 100 / SUM(Sales), 2) AS profit_margin_percentage
FROM amazon_store_sales
GROUP BY `Sub-Category`
ORDER BY total_profit DESC;


-- 2. Loss-making sub-categories
SELECT
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY total_profit;


-- 3. Top 10 states by sales
SELECT
    State,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY State
ORDER BY total_sales DESC
LIMIT 10;


-- 4. Top 10 states by profit
SELECT
    State,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY State
ORDER BY total_profit DESC
LIMIT 10;


-- 5. States generating losses
SELECT
    State,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY State
HAVING SUM(Profit) < 0
ORDER BY total_profit;


-- 6. Customer segment profitability
SELECT
    Segment,
    COUNT(DISTINCT `Customer ID`) AS total_customers,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY Segment
ORDER BY total_profit DESC;


-- 7. Average sales and profit per order by category
SELECT
    Category,
    ROUND(SUM(Sales) / COUNT(DISTINCT `Order ID`), 2) AS avg_sales_per_order,
    ROUND(SUM(Profit) / COUNT(DISTINCT `Order ID`), 2) AS avg_profit_per_order
FROM amazon_store_sales
GROUP BY Category
ORDER BY avg_sales_per_order DESC;


-- 8. Return rate by category
SELECT
    Category,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) * 100.0
        / COUNT(DISTINCT `Order ID`),
        2
    ) AS return_rate_percentage
FROM amazon_store_sales
GROUP BY Category
ORDER BY return_rate_percentage DESC;


-- 9. Return rate by shipping mode
SELECT
    `Ship Mode`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) * 100.0
        / COUNT(DISTINCT `Order ID`),
        2
    ) AS return_rate_percentage
FROM amazon_store_sales
GROUP BY `Ship Mode`
ORDER BY return_rate_percentage DESC;


-- 10. Payment mode sales and profit analysis
SELECT
    `Payment Mode`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) * 100 / SUM(Sales), 2) AS profit_margin_percentage
FROM amazon_store_sales
GROUP BY `Payment Mode`
ORDER BY total_profit DESC;


-- 11. Products with sales above the average product sales
SELECT
    `Product Name`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Product Name`
HAVING SUM(Sales) > (
    SELECT AVG(product_sales)
    FROM (
        SELECT SUM(Sales) AS product_sales
        FROM amazon_store_sales
        GROUP BY `Product Name`
    ) AS product_sales_summary
)
ORDER BY total_sales DESC;


-- 12. Products with negative total profit
SELECT
    `Product Name`,
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Product Name`, Category, `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC;


-- 13. Customer purchase frequency
SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY `Customer ID`, `Customer Name`
ORDER BY total_orders DESC, total_sales DESC
LIMIT 20;


-- 14. High-value orders
SELECT
    `Order ID`,
    `Customer Name`,
    Region,
    ROUND(SUM(Sales), 2) AS order_sales,
    ROUND(SUM(Profit), 2) AS order_profit,
    CASE
        WHEN SUM(Sales) >= 1000 THEN 'High Value'
        WHEN SUM(Sales) >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_value_segment
FROM amazon_store_sales
GROUP BY `Order ID`, `Customer Name`, Region
ORDER BY order_sales DESC;


-- 15. Shipping time analysis
-- This works only if Order Date and Ship Date are stored as DATE values.
SELECT
    `Ship Mode`,
    ROUND(AVG(DATEDIFF(`Ship Date`, `Order Date`)), 2) AS average_shipping_days,
    MIN(DATEDIFF(`Ship Date`, `Order Date`)) AS minimum_shipping_days,
    MAX(DATEDIFF(`Ship Date`, `Order Date`)) AS maximum_shipping_days
FROM amazon_store_sales
GROUP BY `Ship Mode`
ORDER BY average_shipping_days;

