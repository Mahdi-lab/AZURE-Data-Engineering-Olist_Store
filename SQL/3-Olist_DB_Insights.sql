select count(*) as customer_count from customers;
select count(*) as geolocation_count from Geolocation;
select count(*) as order_items_count from OrderItems;
select count(*) as order_count from Orders
select count(*) as payments_count from Payments;
select count(*) as product_count from Products;
select count(*) as product_transaction_count from ProductTranslations;
select count(*) as reviews_count from Reviews;
select count(*) as sellers_count from sellers;

select * from Products; 

select * from OrderItems;

select * from reviews;


SELECT customer_city, customer_state, COUNT(*) AS num_customers
FROM Customers
GROUP BY customer_city, customer_state
ORDER BY num_customers DESC;

-----------Order Status------
SELECT order_status, COUNT(*) AS num_orders
FROM Orders
GROUP BY order_status
ORDER BY num_orders DESC;

------------Mean of Delivery(Average) of Orders-----
SELECT C.customer_state, AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS avg_delivery_time
FROM Orders O
JOIN Customers C ON O.customer_id = C.customer_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY C.customer_state
ORDER BY avg_delivery_time;

----------Distributions of Payment Methods---------
SELECT payment_type, COUNT(*) AS num_payments
FROM Payments
GROUP BY payment_type
ORDER BY num_payments DESC;

----What is the Average Payment of your single sale----
SELECT payment_type, AVG(payment_value) AS avg_payment_value
FROM Payments
GROUP BY payment_type
ORDER BY avg_payment_value DESC;

--------What is the Trends Product Categories------
SELECT PT.product_category_name_english, COUNT(*) AS num_sales
FROM OrderItems OI
JOIN Products P ON OI.product_id = P.product_id
JOIN ProductTranslations PT ON P.product_category_name = PT.product_category_name
GROUP BY PT.product_category_name_english
ORDER BY num_sales DESC;

------What is the average price per single sale-----
SELECT PT.product_category_name_english, AVG(OI.price) AS avg_price
FROM OrderItems OI
JOIN Products P ON OI.product_id = P.product_id
JOIN ProductTranslations PT ON P.product_category_name = PT.product_category_name
GROUP BY PT.product_category_name_english
ORDER BY avg_price DESC;

------What is the average reviews of your products per category----
SELECT PT.product_category_name_english, AVG(R.review_score) AS avg_review_score
FROM Reviews R
JOIN Orders O ON R.order_id = O.order_id
JOIN OrderItems OI ON O.order_id = OI.order_id
JOIN Products P ON OI.product_id = P.product_id
JOIN ProductTranslations PT ON P.product_category_name = PT.product_category_name
GROUP BY PT.product_category_name_english
ORDER BY avg_review_score DESC;

------How many reviews per review score----
SELECT review_score, COUNT(*) AS num_reviews
FROM Reviews
GROUP BY review_score
ORDER BY review_score;