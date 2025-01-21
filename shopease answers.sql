use lpu;

-- Create Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    signup_date DATE NOT NULL
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shopease_customers.csv'
into table customers
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from customers;
-- Create Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shopease_orders.csv'
into table orders
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from orders;
-- Create Order Items table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shopease_order_items.csv'
into table order_items
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from order_items;
-- Create Products table
CREATE TABLE shopease_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shopease_products.csv'
into table shopease_products
fields terminated by ','
ignore 1 rows;
select * from shopease_products;
-- Create Reviews table
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES shopease_products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shopease_reviews.csv'
into table reviews
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- Show the total number of customers who signed up in each month of 2023.
SELECT  
    MONTHNAME(signup_date) AS month,  
    COUNT(*) AS total_customers  
FROM  
    customers  
WHERE  
    YEAR(signup_date) = 2023  
GROUP BY  
    MONTHNAME(signup_date), MONTH(signup_date)  
ORDER BY  
    MONTH(signup_date)  
LIMIT 0, 10000;


-- List the top 5 products by total sales amount, including the total quantity sold for each.
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.price) AS total_sales_amount,
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    shopease_products p
JOIN 
    order_items oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_sales_amount DESC
LIMIT 5;

-- Find the average order value for each customer who has placed more than 5 orders.
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    AVG(o.total_amount) AS average_order_value
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    total_orders > 5
ORDER BY 
    average_order_value DESC;
    
-- Get the total number of orders placed in each month of 2023, and calculate the average order value for each month.
SELECT 
    MONTHNAME(order_date) AS month,
    COUNT(order_id) AS total_orders,
    AVG(total_amount) AS average_order_value
FROM 
    orders
WHERE 
    YEAR(order_date) = 2023
GROUP BY 
    Monthname(order_date), MONTH(order_date)
ORDER BY 
    Month(order_date)
    Limit 0, 10000;
    
-- Identify the product categories with the highest average rating, and list the top 3 categories.
SELECT 
    p.category AS product_category,
    AVG(r.rating) AS average_rating
FROM 
    shopease_products p
JOIN 
    reviews r ON p.product_id = r.product_id
GROUP BY 
    p.category
ORDER BY 
    average_rating DESC
LIMIT 3;

-- Calculate the total revenue generated from each product category, and find the category with the highest revenue.
SELECT 
    p.category AS product_category,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM 
    shopease_products p
JOIN 
    order_items oi ON p.product_id = oi.product_id
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC
LIMIT 1;

-- List the customers who have placed more than 10 orders, along with the total amount spent by each customer.
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    total_orders > 10
ORDER BY 
    total_spent DESC;

-- Find the products that have never been reviewed, and list their details.
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM 
    shopease_products p
LEFT JOIN 
    reviews r ON p.product_id = r.product_id
WHERE 
    r.review_id IS NULL;

-- Show the details of the most expensive order placed, including the customer information.
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.signup_date
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
WHERE 
    o.total_amount = (SELECT MAX(total_amount) FROM orders)
LIMIT 1;

-- Get the total quantity of each product sold in the last 30 days, and identify the top 5 products by quantity sold.
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    shopease_products p
JOIN 
    order_items oi ON p.product_id = oi.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    o.order_date >= CURDATE() - INTERVAL 30 DAY
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_quantity_sold DESC



