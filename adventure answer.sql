use Adventure_work;
select*from [AdventureWorks Sales Data];
select*from customer;
select*from product;

--1.Retrieve the top 5 customers who generated the highest profit.
SELECT 
    c.CustomerKey,
    c.FirstName,
    c.LastName,
    SUM((p.ProductPrice - p.ProductCost) * a.OrderQuantity) AS TotalProfit
FROM [AdventureWorks Sales Data] a
INNER JOIN Product p ON a.ProductKey = p.ProductKey
INNER JOIN Customer c ON a.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName
ORDER BY TotalProfit DESC;

--2.Identify the top 10 most profitable product categories.
SELECT TOP 10 
    P.Category,
    SUM((p.ProductPrice - p.ProductCost) * a.OrderQuantity) AS TotalProfit
FROM [AdventureWorks Sales Data] a
JOIN Product P ON a.ProductKey = P.ProductKey
GROUP BY P.Category
ORDER BY TotalProfit DESC;

--3.Calculate the average sales per customer for each region.
SELECT 
    a.Region,
    AVG(a.OrderQuantity * p.ProductPrice) AS AverageSales
FROM [AdventureWorks Sales Data] a
JOIN Product P ON a.ProductKey = P.ProductKey
JOIN Customer C ON C.CustomerKey = C.CustomerKey
GROUP BY a.Region;

--4.List the top 5 cities with the highest average profit per order
SELECT TOP 5 
    a.Continent,
    AVG((p.ProductPrice - p.ProductCost) * a.OrderQuantity)/ SUM(a.OrderQuantity) AS AverageProfitPerOrder
FROM [AdventureWorks Sales Data] a
JOIN Customer C ON a.CustomerKey = C.CustomerKey
JOIN Product P ON a.ProductKey = P.ProductKey
GROUP BY a.Continent
ORDER BY AverageProfitPerOrder DESC;

--5.Total sales and profit for each product subcategory and region, excluding sales < $1000
SELECT 
    P.Sub_category,
    a.Region,
    SUM(a.OrderQuantity * P.ProductPrice) AS TotalSales,
    SUM((p.ProductPrice - p.ProductCost) * a.OrderQuantity) AS TotalProfit
FROM [AdventureWorks Sales Data] a
JOIN Product P ON a.ProductKey = P.ProductKey
JOIN Customer C ON a.CustomerKey = C.CustomerKey
WHERE (a.OrderQuantity * P.ProductPrice) >= 1000
GROUP BY P.Sub_category, a.Region;

--6.Average profit per order and % of returns per category, excluding sales < $100

SELECT 
    P.Category AS ProductCategory,
    AVG((p.ProductPrice - p.ProductCost) * a.OrderQuantity)/ SUM(a.OrderQuantity) AS AverageProfitPerOrder,
    (SUM(CASE WHEN (a.OrderQuantity * P.ProductPrice) < 0 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS ReturnPercentage
FROM [AdventureWorks Sales Data] a
JOIN Product P ON a.ProductKey = P.ProductKey
WHERE (a.OrderQuantity * P.ProductPrice)>= 100
GROUP BY P.Category
ORDER BY AverageProfitPerOrder DESC;

--7.Total sales and profit for each subcategory and brand (East region, no returns)

SELECT 
    P.Sub_category,
    P.ProductName,
    SUM(a.OrderQuantity * P.ProductPrice) AS TotalSales,
    SUM((p.ProductPrice - p.ProductCost) * a.OrderQuantity) AS TotalProfit
FROM [AdventureWorks Sales Data] a
JOIN Product P ON a.ProductKey = P.ProductKey
JOIN Customer C ON a.CustomerKey = C.CustomerKey
WHERE a.Region = 'Northwest'  
AND (a.OrderQuantity * P.ProductPrice) >= 0
GROUP BY P.Sub_category, P.ProductName
ORDER BY TotalProfit DESC;

--8.Total sales and profit for each brand in each product subcategory
SELECT 
    P.ProductName,
    P.Sub_category,
    SUM(a.OrderQuantity * P.ProductPrice) AS TotalSales,
    SUM((p.ProductPrice - p.ProductCost) * a.OrderQuantity) AS TotalProfit
FROM [AdventureWorks Sales Data] a
JOIN Product P ON a.ProductKey = P.ProductKey
GROUP BY P.ProductName, P.Sub_category;

--9.Top 10 states by total sales, excluding returns
SELECT TOP 10 
    a.Continent,
    SUM(a.OrderQuantity * P.ProductPrice) AS TotalSales
FROM [AdventureWorks Sales Data] a
JOIN Customer C ON a.CustomerKey = C.CustomerKey
JOIN Product P ON a.ProductKey = P.ProductKey
WHERE (a.OrderQuantity * P.ProductPrice) >= 0
GROUP BY a.Continent
ORDER BY TotalSales DESC;

--10.Top 10 customers with the most returns and total value of their returns
SELECT TOP 10 
    c.FirstName,
    c.LastName,
    COUNT(a.OrderNumber) AS TotalReturns,
    SUM(a.OrderQuantity * P.ProductPrice)AS TotalReturnValue
FROM [AdventureWorks Sales Data] a
JOIN Customer C ON a.CustomerKey = C.CustomerKey
JOIN Product P ON a.ProductKey = P.ProductKey
WHERE (a.OrderQuantity * P.ProductPrice)>=0
GROUP BY c.FirstName,c.LastName
ORDER BY TotalReturns DESC, TotalReturnValue DESC;