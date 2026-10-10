create database olist_db;

use olist_db;

-- Q1.  Month-over-Month(MoM) Renevnue Growth Rate
with monthly_sales as(
select
 date_format(order_purchase_timestamp, '%Y-%m') as sales_month ,
 sum(price) as monthly_revenue
 from orders
 join order_items on orders.order_id = order_items.order_id
 where orders.order_status = 'delivered'
 group by sales_month
 )
 select sales_month, 
 round(monthly_revenue,2) as current_revenue,
 round(lag(monthly_revenue,1) over (order by sales_month),2) as prevoius_revenue,
 round(
 (monthly_revenue - lag(monthly_revenue ,1)over (order by sales_month) )
 / lag(monthly_revenue ,1) over (order by sales_month) * 100 ,2) as growth
 from monthly_sales
 order by sales_month;
 
 -- Q2. Top 3 best-selling products within each category?
 WITH RankedProducts AS (
    SELECT products.product_category_name,order_items.product_id,
        COUNT(order_items.order_id) AS total_orders,
        DENSE_RANK() OVER (PARTITION BY products.product_category_name 
        ORDER BY COUNT(order_items.order_id) DESC) AS product_rank
    FROM order_items 
    JOIN products ON order_items.product_id = product.product_id
    WHERE products.product_category_name IS NOT NULL AND products.product_category_name != 'unknown'
    GROUP BY products.product_category_name, order_items.product_id
)
SELECT 
    product_category_name,product_id,total_orders,product_rank
FROM RankedProducts
WHERE product_rank <= 3
ORDER BY product_category_name ASC, product_rank ASC;
    
    -- Q3. Delivery performace
SELECT c.customer_state,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.late_delivery > 0 THEN 1 ELSE 0 END) AS total_late_orders,
    ROUND(
        (SUM(CASE WHEN o.late_delivery > 0 THEN 1 ELSE 0 END) / COUNT(o.order_id)) * 100, 
        2) AS late_delivery_rate_percentage
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND o.late_delivery IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_delivery_rate_percentage DESC;
    
  -- Q4. Impact of Late Deliveries on customer review rating
SELECT 
    CASE 
        WHEN o.late_delivery > 0 THEN 'Late Delivery'ELSE 'On-Time / Early Delivery'
    END AS delivery_status,
    COUNT(o.order_id) AS total_orders,ROUND(AVG(r.review_score), 2) AS average_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND o.late_delivery IS NOT NULL
GROUP BY 
    CASE 
        WHEN o.late_delivery > 0 THEN 'Late Delivery'ELSE 'On-Time / Early Delivery'END;

-- Q5. Payment method impact on order value & volume    
SELECT payment_type,COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue,ROUND(AVG(payment_value), 2) AS average_order_value
FROM order_payments
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY total_revenue DESC;
 
-- Q6. Credit Card Installment vs average Spending
SELECT 
CASE 
	WHEN payment_installments = 1 THEN 'Single Payment'
	WHEN payment_installments BETWEEN 2 AND 5 THEN 'Short-Term (2-5 Months)'
	WHEN payment_installments BETWEEN 6 AND 10 THEN 'Mid-Term (6-10 Months)'
	ELSE 'Long-Term (11+ Months)'END AS installment_tier,
COUNT(DISTINCT order_id) AS total_orders,ROUND(AVG(payment_value), 2) AS average_order_value
FROM order_payments
WHERE payment_type = 'credit_card'
GROUP BY 
CASE 
	WHEN payment_installments = 1 THEN 'Single Payment'
	WHEN payment_installments BETWEEN 2 AND 5 THEN 'Short-Term (2-5 Months)'
	WHEN payment_installments BETWEEN 6 AND 10 THEN 'Mid-Term (6-10 Months)'
	ELSE 'Long-Term (11+ Months)'END
ORDER BY average_order_value ASC;
    
-- Q7. Identifying underperformance high-volume sellers
SELECT oi.seller_id,COUNT(DISTINCT oi.order_id) AS total_orders,
ROUND(SUM(oi.price), 2) AS total_revenue,
ROUND(AVG(o.late_delivery), 1) AS avg_delivery_lag_days,
ROUND(AVG(r.review_score), 2) AS average_seller_rating
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING total_orders >= 50 -- Focus only on high-volume sellers
ORDER BY average_seller_rating ASC
LIMIT 10;
