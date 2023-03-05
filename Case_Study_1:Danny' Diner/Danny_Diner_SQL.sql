--Danny's Diner SQL case study
--3 Tables
--Table 1: sales

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

--Table 2 : menu1

CREATE TABLE menu1 (
	"product_id" INTEGER
	"product_name" VARCHAR(10),
	"price" INTEGER
);
Inserting values
INSERT INTO menu1
	("product_id", "product_name", "price")
VALUES
	('1', 'sushi', '10'),
	('2', 'curry', '15'),
	('3', 'ramen', '12');
	
--Table 3 : members
members
CREATE TABLE members(
	"customer_id" INTEGER,
	"join_date" date
);
Inserting values
INSERT INTO members
	("customer_id", "join_date")
VALUES
	('A', '2021-01-07'),
	('B', '2021-01-09');
	
--1) What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, 
       SUM(m.price) as total_spent
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 DESC;

--2) How many days has each customer visited the restaurant?

SELECT customer_id, 
       COUNT(DISTINCT(order_date)) AS days_visited
FROM sales 
GROUP BY 1;



--3) What was the first item from the menu purchased by each customer?
--There are 2 ways in deriving answer for this query and one is using subqueries and the next is using CTE

--a) using subqueries:

SELECT s.customer_id,
	   m.product_name
FROM sales s
JOIN menu1 m
ON s.product_id = m.product_id
WHERE (SELECT m.product_id FROM menu1 m JOIN sales s
		ON m.product_id = s.product_id
	    ORDER BY s.order_date DESC
		LIMIT 1)
GROUP BY 1;

--b) using CTE:

WITH first_item AS (
	SELECT customer_id,
		   product_name,
		   dense_rank () OVER (PARTITION BY customer_id ORDER BY order_date) AS ranks
	FROM sales
	JOIN menu1
	USING (product_id))
SELECT customer_id,
	   product_name
FROM first_item
WHERE ranks = 1
GROUP BY 1,2;

--Here the result value differs between the subqueries and CTE since person A ordered 2 items on his/her first order and whereas only order is getting
--reflected in the subqueries and CTE gets both the items.

--4) What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name AS most_purchased,
	   count(s.product_id) AS quantity
FROM sales s
JOIN menu1 m
ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--The most purchased item is ramen and it was purchased 8 times.

--5) Which item was the most popular for each customer?

WITH most_popular_dish AS (
	SELECT s.customer_id,
		   m.product_name,
		   count(s.product_id) AS most_popular,
		   dense_rank() OVER (PARTITION BY s.customer_id ORDER BY count(s.product_id) DESC) AS ranks
	FROM sales s
	JOIN menu1 m
	ON s.product_id = m.product_id
	GROUP BY 1,2)
SELECT customer_id,
	   product_name,
	   most_popular
FROM most_popular_dish
WHERE ranks = 1; 

--* Customer A's most popular item is ramen and they purchased it 3 times
--* Customer B purchased all items on the menu twice
--* Customer C's most popular item was ramen and they purchased it 3 times
-- Here I assumed that any order placed on the same date as join_date was placed after the customer had become a member

--6) Which item was purchased first by the customer after they became a member?

WITH membership_info AS (
	SELECT s.customer_id,
		   s.order_date,
		   m.product_name,
		   me.join_date,
		   dense_rank() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS ranks
	FROM sales s
	JOIN members me
	ON s.customer_id = me.customer_id
	JOIN menu1 m
	ON s.product_id = m.product_id
	WHERE s.order_date >= me.join_date)
SELECT customer_id, product_name, order_date, join_date
FROM membership_info
WHERE ranks = 1;

--After becoming a member,
--Customer A first purchased curry
--Customer B purchased sushi.

--7) Which item was purchased just before the customer became a member?

WITH purchase_before_membership AS (
	SELECT s.customer_id,
		   m.product_name,
		   s.order_date,
		   me.join_date,
		   dense_rank() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS ranks
    FROM sales s
	JOIN members me
	ON s.customer_id = me.customer_id
	JOIN menu1 m
	ON s.product_id = m.product_id
	WHERE s.order_date < me.join_date)
SELECT customer_id,
	   product_name,
	   order_date,
	   join_date
FROM purchase_before_membership
WHERE ranks = 1;

--Just before becoming a member,
--Customer A purchased sushi and curry on 2021-01-01
--Customer B ordered sushi on 2021-01-04
