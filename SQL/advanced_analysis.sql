-- =====================================================
-- Amazon Store Sales, Profitability & Returns Analytics
-- Advanced SQL Analysis
-- =====================================================


-- 1. Rank regions by total sales
SELECT
    Region,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS sales_rank
FROM amazon_store_sales
GROUP BY Region;


-- 2. Rank categories by total profit
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    DENSE_RANK() OVER (ORDER BY SUM(Profit) DESC) AS profit_rank
FROM amazon_store_sales
GROUP BY Category;


-- 3. Top 3 products by sales in each category
WITH product_sales AS (
    SELECT
        Category,
        `Product Name`,
        ROUND(SUM(Sales), 2) AS total_sales,
        ROUND(SUM(Profit), 2) AS total_profit,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY SUM(Sales) DESC
        ) AS product_rank
    FROM amazon_store_sales
    GROUP BY Category, `Product Name`
)
SELECT
    Category,
    `Product Name`,
    total_sales,
    total_profit,
    product_rank
FROM product_sales
WHERE product_rank <= 3
ORDER BY Category, product_rank;


-- 4. Percentage contribution of each category to total sales
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(
        SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (),
        2
    ) AS sales_contribution_percentage
FROM amazon_store_sales
GROUP BY Category
ORDER BY total_sales DESC;


-- 5. Percentage contribution of each region to total profit
SELECT
    Region,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) * 100.0 / SUM(SUM(Profit)) OVER (),
        2
    ) AS profit_contribution_percentage
FROM amazon_store_sales
GROUP BY Region
ORDER BY total_profit DESC;


-- 6. Customer lifetime sales and customer rank
WITH customer_sales AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        Segment,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        ROUND(SUM(Sales), 2) AS lifetime_sales,
        ROUND(SUM(Profit), 2) AS lifetime_profit
    FROM amazon_store_sales
    GROUP BY `Customer ID`, `Customer Name`, Segment
)
SELECT
    `Customer ID`,
    `Customer Name`,
    Segment,
    total_orders,
    lifetime_sales,
    lifetime_profit,
    RANK() OVER (ORDER BY lifetime_sales DESC) AS customer_sales_rank
FROM customer_sales
ORDER BY customer_sales_rank
LIMIT 20;


-- 7. Customer segmentation based on lifetime sales
WITH customer_sales AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        Segment,
        ROUND(SUM(Sales), 2) AS lifetime_sales,
        ROUND(SUM(Profit), 2) AS lifetime_profit
    FROM amazon_store_sales
    GROUP BY `Customer ID`, `Customer Name`, Segment
)
SELECT
    `Customer ID`,
    `Customer Name`,
    Segment,
    lifetime_sales,
    lifetime_profit,
    CASE
        WHEN lifetime_sales >= 3000 THEN 'High Value Customer'
        WHEN lifetime_sales >= 1000 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END AS customer_value_segment
FROM customer_sales
ORDER BY lifetime_sales DESC;


-- 8. Find products that are profitable overall but have a negative-profit order line
WITH product_profit AS (
    SELECT
        `Product Name`,
        ROUND(SUM(Sales), 2) AS total_sales,
        ROUND(SUM(Profit), 2) AS total_profit
    FROM amazon_store_sales
    GROUP BY `Product Name`
),
negative_lines AS (
    SELECT DISTINCT
        `Product Name`
    FROM amazon_store_sales
    WHERE Profit < 0
)
SELECT
    p.`Product Name`,
    p.total_sales,
    p.total_profit
FROM product_profit p
INNER JOIN negative_lines n
    ON p.`Product Name` = n.`Product Name`
WHERE p.total_profit > 0
ORDER BY p.total_profit DESC;


-- 9. Compare each sub-category profit against its category average profit
WITH subcategory_profit AS (
    SELECT
        Category,
        `Sub-Category`,
        ROUND(SUM(Profit), 2) AS subcategory_profit
    FROM amazon_store_sales
    GROUP BY Category, `Sub-Category`
)
SELECT
    Category,
    `Sub-Category`,
    subcategory_profit,
    ROUND(
        AVG(subcategory_profit) OVER (PARTITION BY Category),
        2
    ) AS category_avg_profit,
    CASE
        WHEN subcategory_profit >
             AVG(subcategory_profit) OVER (PARTITION BY Category)
        THEN 'Above Category Average'
        ELSE 'Below Category Average'
    END AS profit_performance
FROM subcategory_profit
ORDER BY Category, subcategory_profit DESC;


-- 10. Top 5 states by profit within each region
WITH state_profit AS (
    SELECT
        Region,
        State,
        ROUND(SUM(Sales), 2) AS total_sales,
        ROUND(SUM(Profit), 2) AS total_profit,
        DENSE_RANK() OVER (
            PARTITION BY Region
            ORDER BY SUM(Profit) DESC
        ) AS state_profit_rank
    FROM amazon_store_sales
    GROUP BY Region, State
)
SELECT
    Region,
    State,
    total_sales,
    total_profit,
    state_profit_rank
FROM state_profit
WHERE state_profit_rank <= 5
ORDER BY Region, state_profit_rank;


-- 11. Running total of sales by order date
-- Run only if `Order Date` is stored as a DATE.
WITH daily_sales AS (
    SELECT
        `Order Date`,
        ROUND(SUM(Sales), 2) AS daily_sales
    FROM amazon_store_sales
    GROUP BY `Order Date`
)
SELECT
    `Order Date`,
    daily_sales,
    ROUND(
        SUM(daily_sales) OVER (
            ORDER BY `Order Date`
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS running_total_sales
FROM daily_sales
ORDER BY `Order Date`;


-- 12. Monthly sales and profit trend
-- Run only if `Order Date` is stored as a DATE.
SELECT
    DATE_FORMAT(`Order Date`, '%Y-%m') AS sales_month,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(DISTINCT `Order ID`) AS total_orders
FROM amazon_store_sales
GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
ORDER BY sales_month;


-- 13. Month-over-month sales change using LAG()
-- Run only if `Order Date` is stored as a DATE.
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(`Order Date`, '%Y-%m') AS sales_month,
        ROUND(SUM(Sales), 2) AS total_sales
    FROM amazon_store_sales
    GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
)
SELECT
    sales_month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales,
    ROUND(
        total_sales - LAG(total_sales) OVER (ORDER BY sales_month),
        2
    ) AS month_over_month_change
FROM monthly_sales
ORDER BY sales_month;


-- 14. Return rate by region
SELECT
    Region,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) * 100.0
        / COUNT(DISTINCT `Order ID`),
        2
    ) AS return_rate_percentage
FROM amazon_store_sales
GROUP BY Region
ORDER BY return_rate_percentage DESC;


-- 15. Return rate and profit by category
SELECT
    Category,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN Returns = 1 THEN `Order ID` END) * 100.0
        / COUNT(DISTINCT `Order ID`),
        2
    ) AS return_rate_percentage,
    ROUND(SUM(Profit), 2) AS total_profit
FROM amazon_store_sales
GROUP BY Category
ORDER BY return_rate_percentage DESC;