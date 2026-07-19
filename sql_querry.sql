-- Section 1: Business KPIs
-- 1. What is the total sales revenue?
select sum(sales) 
as Total_revenue
from sales
-- 2. What is the total profit?
select round(sum(profit):: numeric,3) 
as Total_profit
from sales
-- 3. How many unique customers and orders does the company have?
select count(distinct("customer_name")) 
as total_unique_customers 
from sales

-- 4. What is the average order value?
select round(sum(sales)/count(distinct(order_id))::numeric,3)
as Average_order_value 
from sales
-- Section 2: Sales Performance
-- 5. What are the yearly sales and profits?
select year,sum(sales) as total_Sales_during_year
,round(sum(profit)::numeric,3) as total_profit_during_year ,
round(round(sum(profit)::numeric,3)/sum(sales)::numeric,3)*100 as percent_profit_per_year
from sales group by year
-- 6. What are the monthly sales trends?
select month
,sum(sales) as sales_per_month 
from sales group by month order by sum(sales) desc
-- 7. Which quarter generates the highest sales?
select quarter,
sum(sales) as total_sales_as_per_quarter
from sales group by quarter order by sum(sales) desc limit(1)

-- 8. Which month records the highest sales?
select month
,sum(sales) as sales_per_month 
from sales group by month order by sum(sales) desc limit(1)
-- 9. Calculate the Month-over-Month (MoM) sales growth.
WITH monthly_sales AS (
    SELECT
        year,month_num,month,
        SUM(sales) AS total_sales
    FROM sales
    GROUP BY "year","month_num",month
)

SELECT
    "year",month_num,month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY "year","month_num") AS previous_month_sales,
    ROUND(
        (
            (total_sales - LAG(total_sales) OVER (ORDER BY  "year","month_num"))
            / LAG(total_sales) OVER (ORDER BY  "year","month_num")
        ) * 100,
        2
    ) AS mom_growth
FROM monthly_sales
ORDER BY  "year","month_num";

-- Section 3: Product Analysis
-- 10. Which are the top 10 products by sales?
select product_name
,sum(sales) as total_sale_from_product 
from sales group by product_name order by sum(sales) desc limit(10)
-- 11. Which are the top 10 products by profit?
select product_name
,round(sum(profit)::numeric,3) as total_profit_from_product 
from sales group by product_name order by sum(profit) desc limit(10)
-- 12. Which products are generating losses?
with profit_by_product 
as(
select product_name
,sum(profit) as profit_sum
from sales group by product_name
) 
select 
product_name,profit_sum
from profit_by_product
where profit_sum<0 order by profit_sum

-- 13. Which category contributes the highest sales and profit?
select 
category,
sum(sales) as sale_sum,
sum(profit) as profit_sum
from sales group by category order by sum(sales)desc
-- 14. Which sub-category has the lowest profit?
select 
sub_category,round(sum(profit)::numeric,2) as profit_sum 
from sales group by sub_category order by profit_sum limit 1
--Bonus Question: what are profit margins of each category?
select 
category,
round(round(sum(profit)::numeric,3)/sum(sales)::numeric,3)*100 as profit_percent
from sales group by category order by profit_percent desc 
-- Section 4: Customer Analysis
-- 15. Who are the top 10 customers by sales?
select
customer_name,
sum(sales) as Total_sale 
from sales group by customer_name order by Total_sale desc limit(10)
-- 16. Which customer segment contributes the highest revenue?
select
segment,
sum(sales) as total_sales 
from sales group by segment order by total_sales desc limit(1)
-- 17. Which customers placed the most orders?
select 
customer_name,count(distinct(order_id)) as no_of_orders 
from sales group by customer_name order by no_of_orders desc 
limit 10
-- 18. Rank customers based on total sales using DENSE_RANK().
select 
customer_name,
sum(sales) as total_sale,
dense_rank() over 
(order by sum(sales) desc) as Customer_rank 
from sales group by customer_name limit(10)
-- Section 5: Regional Analysis
-- 19. Which region generates the highest sales and profit?
select region,
round(sum(sales)::numeric,3) as HighestSales
from sales group by region order by sum(sales) desc Limit(1)
select region,
round(sum(profit)::numeric,3) as HighestProfit 
from sales group by region order by sum(profit) desc limit(1)

-- 20. Which states contribute the highest revenue?
SELECT
    "state",
    SUM("sales") AS total_revenue
FROM sales
GROUP BY "state"
ORDER BY total_revenue DESC
LIMIT 10;

-- 21. Which cities generate the highest profit?
SELECT
    "city",
    SUM("profit") AS total_profit
FROM sales
GROUP BY "city"
ORDER BY total_profit DESC
LIMIT 10;
-- Section 6: Shipping & Discount
-- 22. Which shipping mode is used most frequently?
SELECT
    "ship_mode",
    COUNT(*) AS total_shipments
FROM sales
GROUP BY "ship_mode"
ORDER BY total_shipments DESC;
-- 23. What is the average shipping time by region?
SELECT
    "region",
    ROUND(
        AVG(EXTRACT(EPOCH FROM ("ship_date" - "order_date")) / 86400),
        2
    ) AS avg_shipping_days
FROM sales
GROUP BY "region"
ORDER BY avg_shipping_days DESC;
-- Section 7: Advanced SQL
-- 24. Calculate a running total of monthly sales.
WITH monthly_sales AS (
    SELECT
        "YearMonth",
        SUM("sales") AS total_sales
    FROM sales
    GROUP BY "YearMonth"
)

SELECT
    "YearMonth",
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY "YearMonth"
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales
FROM monthly_sales
ORDER BY "YearMonth";
-- 25. Find the best-selling product within each category using a window function.
WITH product_sales AS
(
    SELECT
        "category",
        "product_name",
        SUM("sales") AS total_sales,
        ROW_NUMBER() OVER
        (
            PARTITION BY "category"
            ORDER BY SUM("sales") DESC
        ) AS rn
    FROM sales
    GROUP BY "category", "product_name"
)

SELECT
    "category",
    "product_name",
    total_sales
FROM product_sales
WHERE rn = 1;