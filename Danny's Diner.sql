-- Q1: What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_spent
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- Q2: How many days has each customer visited the restaurant?
SELECT customer_id, COUNT( DISTINCT order_date) AS Num_of_days_visited FROM sales
GROUP BY customer_id
ORDER BY customer_id;

--Q3What was the first item from the menu purchased by each customer?
WITH ranked_orders AS (
 SELECT customer_id, product_name, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rank
  FROm sales
  JOIN menu ON sales.product_id = menu.product_id)
  SELECT * FROM ranked_orders
  WHERE rank = 1;
  
--Q4What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT product_name,Count(*) AS no_of_times_purchased FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY no_of_times_purchased DESC
LIMIT 1;

--Q5Which item was the most popular for each customer?
WITH counts AS (SELECT customer_id, product_name, COUNT(*) AS times_bought
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id, product_name),
ranked AS (
  SELECT customer_id, product_name, times_bought,
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY times_bought DESC) AS rank FROM counts)
SELECT customer_id, product_name, times_bought FROM ranked
WHERE rank = 1;

--Q6Which item was purchased first by the customer after they became a member?
WITH member_sales AS (
SELECT 
sales.customer_id,
menu.product_name,
sales.order_date,
 DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS ranking
  FROM sales
  JOIN menu ON sales.product_id = menu.product_id
  JOIN members ON sales.customer_id = members.customer_id
  WHERE sales.order_date >= members.join_date
)
SELECT customer_id, product_name FROM member_sales
WHERE ranking = 1;
  
--Q7Which item was purchased just before the customer became a member?  
WITH member_sales AS (
SELECT 
sales.customer_id,
menu.product_name,
sales.order_date,
 DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS ranking
  FROM sales
  JOIN menu ON sales.product_id = menu.product_id
  JOIN members ON sales.customer_id = members.customer_id
  WHERE sales.order_date < members.join_date
)
SELECT customer_id, product_name FROM member_sales
WHERE ranking = 1;
  
--Q8If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
customer_id,
SUM(
  CASE 
  WHEN product_name = 'sushi' THEN price*20
  ELSE price*10
  END)
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

--Q9If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
customer_id,
SUM(
  CASE 
  WHEN product_name = 'sushi' THEN price*20
  ELSE price*10
  END)
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

--Q10In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT 
sales.customer_id,
SUM (
CASE
WHEN sales.order_date BETWEEN members.join_date AND DATE(members.join_date, '+6 days') THEN menu.price * 20
WHEN menu.product_name = 'sushi' THEN menu.price *20
ELSE menu.price * 10
END)
FROM sales
JOIN menu On sales.product_id = menu.product_id
JOIN members ON sales.customer_id = members.customer_id
WHERE sales.order_date <= '2021-01-31'
GROUP BY sales.customer_id;

--BONUS QUESTION
--Join All The Things
--The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
SELECT 
sales.customer_id, 
sales.order_date,
menu.product_name,
menu.price,
CASE 
WHEN sales.order_date >= members.join_date THEN 'Y'
ELSE 'N'
END AS member
FROM sales
JOIN menu ON sales.product_id = menu.product_id
LEFT JOIN members ON sales.customer_id = members.customer_id;

--Rank All The Things
--Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
WITH joined_table AS(
  SELECT 
sales.customer_id, 
sales.order_date,
menu.product_name,
menu.price,
CASE 
WHEN sales.order_date >= members.join_date THEN 'Y'
ELSE 'N'
END AS member
FROM sales
JOIN menu ON sales.product_id = menu.product_id
LEFT JOIN members ON sales.customer_id = members.customer_id)
SELECT *,
CASE 
WHEN member = 'N' THEN NULL
ELSE DENSE_RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date)
END AS ranking
FROM joined_table;

