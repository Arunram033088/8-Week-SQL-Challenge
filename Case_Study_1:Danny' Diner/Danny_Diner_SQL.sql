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