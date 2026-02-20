describe sales_data.sales_data_clean1;
ALTER TABLE sales_data.sales_data_clean1 
MODIFY COLUMN ORDER_DATE DATE;
------------------------------------------------------------
select * from sales_data.sales_data_clean1;
---------------------------------------------------------------
                           -- 1. Revenue & Order Overview
                           -- 1.1 Total revenue

select round(sum(sales),2)as Toal_sales 
from sales_data_clean1 where STATUS in ('shipped','resolved');

							
						 -- 1.2. Total Unique Orders 
                         
SELECT COUNT(DISTINCT ORDER_NUMBER) AS Total_Orders 
FROM sales_data_clean1;


                            -- 1.3 Total units sold
                            
select sum(QUANTITY_ORDERED) as Total_units_sold 
from sales_data_clean1 WHERE status IN ('shipped', 'resolved');


                            -- 2. Sales Trend & Time Analysis
                            
                            -- 2.1	How have sales changed over time?
                            
SELECT YEAR(order_date) AS Year,ROUND(SUM(sales), 2) AS 'Total sales' 
FROM sales_data_clean1
WHERE status IN ('Shipped', 'Resolved')
GROUP BY YEAR;

select year(order_date) as Year,round(sum(sales),2) as Total_sales
from sales_data_clean1
where status in('shipped','resolved')
group by year
order by Total_sales desc
limit 1;


-- Note: Comparing Jan–May for 2003–2005 to maintain a fair trend analysis since 2005 data is only available through May.

select year(order_date) as Year,round(sum(sales),2)as Sales from sales_data_clean1
where month(order_date) between 1 and 5
and status in ('shipped','resolved')
group by year;

WITH YTD_Sales AS (SELECT YEAR(order_date) AS Year,SUM(sales) AS Current_Year_Sales
    FROM sales_data_clean1
    WHERE status IN ('Shipped', 'Resolved')
      AND MONTH(order_date) <= 5
    GROUP BY YEAR(order_date)
)
SELECT Year,ROUND(Current_Year_Sales, 2) AS 'Total YTD Sales',
ROUND(((Current_Year_Sales - LAG(Current_Year_Sales) OVER (ORDER BY Year)) / LAG(Current_Year_Sales) OVER (ORDER BY Year)) * 100, 2) AS 'YoY Growth %'
FROM YTD_Sales;
                                               -- 3 Product Performance Analysis
                                      -- 3.1.	Which product generated the highest revenue and units sold?
SELECT 
    product_code,
    ROUND(SUM(sales), 2) AS Total_sales,
    SUM(QUANTITY_ORDERED) AS Total_quantity
FROM
    sales_data_clean1
WHERE
    status IN ('shipped' , 'resolved')
GROUP BY product_code
ORDER BY Total_sales DESC
LIMIT 5;

                                               -- 3.2 Which product line have the highest sales ?
select PRODUCT_LINE,round(sum(sales),2)as Total_sales
 from sales_data_clean1
where status in('shipped','resolved')
group by PRODUCT_LINE
order by Total_sales desc;
                
                                              -- 3.3 9.	Which products are underperforming in terms of revenue and quantity?
SELECT 
    product_code,
    ROUND(SUM(sales), 2) AS Total_sales,
    SUM(QUANTITY_ORDERED) AS Total_quantity
FROM
    sales_data_clean1
WHERE
    status IN ('shipped' , 'resolved')
GROUP BY product_code
ORDER BY Total_sales 
LIMIT 5;

                                                -- 4 Geographic Performance Analysis
                                                
                                                -- 4.1 Which country generated the highest revenue?
select COUNTRY,round(sum(sales),2)as Total_sales from sales_data_clean1
where status in('shipped','resolved')
group by country
order by Total_sales desc
limit 5;
                                            -- 4.2 	How do sales vary across different territories?
SELECT territory,ROUND(SUM(sales), 2) AS total_revenue,COUNT(DISTINCT order_number) AS total_orders,SUM(quantity_ordered) AS total_units
FROM sales_data_clean1
WHERE status IN ('Shipped', 'Resolved')
GROUP BY territory
ORDER BY total_revenue DESC;

                                             -- 4.3	Are there countries with high sales volume but comparatively low revenue?
select COUNTRY,round(sum(sales),2) as Total_sales,sum(QUANTITY_ORDERED) as Total_Quantity, round(sum(sales) / sum(quantity_ordered), 2) as avg_revenue_per_unit
from sales_data_clean1
where status IN ('Shipped', 'Resolved')
group by country
order by Total_Quantity desc;

                                           -- 5 Discount Analysis
                                           -- 5.1 What is the distribution of order statuses
select status,count(*) as Total_orders,round(count(*)*100.0/sum(count(*)) over() ,2) as percentage
from sales_data_clean1
group by status;

                                          -- 5.2 Does order status impact revenue?
select status,round(sum(sales),2) as Total_sales
from sales_data_clean1
group by Status;               

                                          -- 6. Customer Behavior Analysis
                                          -- 6.1 Who are the top customers by revenue?
select CUSTOMER_NAME,round(sum(sales),2) as Total_sales
from sales_data_clean1
where status in('shipped','resolved')
group by CUSTOMER_NAME
order by Total_sales desc
limit 5;

                                         -- 6.2 How many customers are repeat buyers?
                                         
select count(*) as repeat_customers
from (
    select customer_name
    from sales_data_clean1
    where status in ('shipped', 'resolved')
    group by customer_name
    having count(distinct order_number) > 1
) as sub;
