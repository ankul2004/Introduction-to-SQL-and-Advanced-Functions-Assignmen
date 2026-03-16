#1 Create a database named ECommerceDB and perform the following
#tasks:

create database ECommerceDB;
use ECommerceDB;

create table Categories(
 CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50) NOT NULL UNIQUE);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL UNIQUE,
    CategoryID INT,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    JoinDate DATE
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Categories VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Home Goods'),
(4, 'Apparel');


INSERT INTO Products VALUES
(101, 'Laptop Pro', 1, 1200.00, 50),
(102, 'SQL Handbook', 2, 45.50, 200),
(103, 'Smart Speaker', 1, 99.99, 150),
(104, 'Coffee Maker', 3, 75.00, 80),
(105, 'Novel: The Great SQL', 2, 25.00, 120),
(106, 'Wireless Earbuds', 1, 150.00, 100),
(107, 'Blender X', 3, 120.00, 60),
(108, 'T-Shirt Casual', 4, 20.00, 300);

INSERT INTO Customers VALUES
(1, 'Alice Wonderland', 'alice@example.com', '2023-01-10'),
(2, 'Bob the Builder', 'bob@example.com', '2022-11-25'),
(3, 'Charlie Chaplin', 'charlie@example.com', '2023-03-01'),
(4, 'Diana Prince', 'diana@example.com', '2021-04-26');

INSERT INTO Orders VALUES
(1001, 1, '2023-04-26', 1245.50),
(1002, 2, '2023-10-12', 99.99),
(1003, 1, '2023-07-01', 145.00),
(1004, 3, '2023-01-14', 150.00),
(1005, 2, '2023-09-24', 120.00),
(1006, 1, '2023-06-19', 20.00);


#Question 7 : Generate a report showing CustomerName, Email, and the
#TotalNumberofOrders for each customer. Include customers who have not placed
#any orders, in which case their TotalNumberofOrders should be 0. Order the results
#by CustomerName.

SELECT 
    Customers.CustomerName,
    Customers.Email,
    COUNT(Orders.OrderID) AS TotalNumberOfOrders
FROM Customers
LEFT JOIN Orders
ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerName, Customers.Email
ORDER BY Customers.CustomerName;


-- Question 8 : Retrieve Product Information with Category: Write a SQL query to
-- display the ProductName, Price, StockQuantity, and CategoryName for all
-- products. Order the results by CategoryName and then ProductName alphabetically.

SELECT 
    Products.ProductName,
    Products.Price,
    Products.StockQuantity,
    Categories.CategoryName
FROM Products
JOIN Categories
ON Products.CategoryID = Categories.CategoryID
ORDER BY Categories.CategoryName, Products.ProductName;


-- Question 9 : Write a SQL query that uses a Common Table Expression (CTE) and a
-- Window Function (specifically ROW_NUMBER() or RANK()) to display the
-- CategoryName, ProductName, and Price for the top 2 most expensive products in
-- each CategoryName.

WITH RankedProducts AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        p.Price,
        ROW_NUMBER() OVER (
            PARTITION BY c.CategoryName 
            ORDER BY p.Price DESC
        ) AS RankNumber
    FROM Products p
    JOIN Categories c
    ON p.CategoryID = c.CategoryID
)

SELECT 
    CategoryName,
    ProductName,
    Price
FROM RankedProducts
WHERE RankNumber <= 2;


-- Question 10: Sakila Database Analysis Queries
use sakila;
-- 1. Top 5 Customers by Total Amount Spent
SELECT 
    c.first_name,
    c.last_name,
    c.email,
    SUM(p.amount) AS TotalSpent
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY TotalSpent DESC
LIMIT 5;
-- 2. Top 3 Movie Categories by Rental Count
SELECT 
    c.name AS CategoryName,
    COUNT(r.rental_id) AS RentalCount
FROM category c
JOIN film_category fc 
ON c.category_id = fc.category_id
JOIN film f 
ON fc.film_id = f.film_id
JOIN inventory i 
ON f.film_id = i.film_id
JOIN rental r 
ON i.inventory_id = r.inventory_id
GROUP BY c.name
ORDER BY RentalCount DESC
LIMIT 3;
-- 3. Films Available at Each Store and Never Rented
SELECT 
    store_id,
    COUNT(inventory_id) AS TotalFilms,
    SUM(CASE WHEN inventory_id NOT IN 
        (SELECT inventory_id FROM rental)
        THEN 1 ELSE 0 END) AS NeverRented
FROM inventory
GROUP BY store_id;
-- 4. Total Revenue Per Month in 2023
SELECT 
    MONTH(payment_date) AS Month,
    SUM(amount) AS TotalRevenue
FROM payment
WHERE YEAR(payment_date) = 2023
GROUP BY MONTH(payment_date)
ORDER BY Month;
-- 5. Customers Who Rented More Than 10 Times in Last 6 Months
SELECT 
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS TotalRentals
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
WHERE r.rental_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) > 10;