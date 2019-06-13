CREATE DATABASE tst
GO
USE tst
CREATE TABLE Customers (
   [CustomerID]   VARCHAR(5)   NOT NULL,
   [CompanyName]  VARCHAR(40)  NOT NULL,
   [ContactName]  VARCHAR(30),
   [ContactTitle] VARCHAR(30),
   [Address]      VARCHAR(60),
   [City]         VARCHAR(15),
   [Region]       VARCHAR(15),
   [PostalCode]   VARCHAR(10),
   [Country]      VARCHAR(15),
   [Phone]        VARCHAR(24),
   [Fax]          VARCHAR(24),
   PRIMARY KEY ([CustomerID])
);

CREATE INDEX idx_cust_city on Customers ([City]);
CREATE INDEX idx_cust_company_nm on Customers ([CompanyName]);
CREATE INDEX idx_cust_postal_cd on Customers ([PostalCode]);
CREATE INDEX idx_cust_region on Customers ([Region]);

CREATE TABLE Employees (
   [EmployeeID]      INT CHECK ([EmployeeID] > 0)  NOT NULL IDENTITY,
                     -- [0, 65535]
   [LastName]        VARCHAR(20)         NOT NULL,
   [FirstName]       VARCHAR(10)         NOT NULL,
   [Title]           VARCHAR(30),  -- e.g., 'Sales Coordinator'
   [TitleOfCourtesy] VARCHAR(25),  -- e.g., 'Mr.' 'Ms.' (ENUM??)
   [BirthDate]       DATE,         -- 'YYYY-MM-DD'
   [HireDate]        DATE,
   [Address]         VARCHAR(60),
   [City]            VARCHAR(15),
   [Region]          VARCHAR(15),
   [PostalCode]      VARCHAR(10),
   [Country]         VARCHAR(15),
   [HomePhone]       VARCHAR(24),
   [Extension]       VARCHAR(4),
   [Photo]           VARBINARY(max),                          -- 64KB
   [Notes]           VARCHAR(max)                NOT NULL,  -- 64KB
   [ReportsTo]       INT CHECK ([ReportsTo] > 0)  NULL,  -- Manager's ID
                                                -- Allow NULL for boss
   [PhotoPath]       VARCHAR(255),
   [Salary]          INT
  ,
   PRIMARY KEY ([EmployeeID]),
   FOREIGN KEY ([ReportsTo]) REFERENCES Employees ([EmployeeID])
);

CREATE INDEX idx_empl_last_nm on Employees ([LastName]);
CREATE INDEX idx_empl_postal_cd on Employees ([PostalCode]);

CREATE TABLE Region (
   [RegionID]           SMALLINT CHECK ([RegionID] > 0)  NOT NULL IDENTITY,
                        -- [0,255]
   [RegionDescription]  VARCHAR(50)       NOT NULL,
                        -- e.g., 'Eastern','Western','Northern','Southern'
                        -- Could use an ENUM and eliminate this table
   PRIMARY KEY ([RegionID])
);

-- e.g., ('02116', 'Boston', 1)
CREATE TABLE Territories (
   [TerritoryID]           VARCHAR(20)       NOT NULL,  -- ZIP code
   [TerritoryDescription]  VARCHAR(50)       NOT NULL,  -- Name
   [RegionID]              SMALLINT CHECK ([RegionID] > 0)  NOT NULL,
                           -- Could use an ENUM to eliminate Region table
   PRIMARY KEY ([TerritoryID]),
   FOREIGN KEY ([RegionID]) REFERENCES Region ([RegionID])
);

-- Many-to-many Junction table between Employee and Territory
CREATE TABLE EmployeeTerritories (
   [EmployeeID]  INT CHECK ([EmployeeID] > 0)  NOT NULL,
   [TerritoryID] VARCHAR(20) NOT NULL,
   PRIMARY KEY ([EmployeeID], [TerritoryID]),
   FOREIGN KEY ([EmployeeID]) REFERENCES Employees ([EmployeeID]),
   FOREIGN KEY ([TerritoryID]) REFERENCES Territories ([TerritoryID])
);

CREATE TABLE Categories (
   [CategoryID]   SMALLINT CHECK ([CategoryID] > 0)  NOT NULL IDENTITY,
                  -- [0, 255], not expected to be large
   [CategoryName] VARCHAR(30)       NOT NULL,
                  -- e.g., 'Beverages','Condiments',etc
   [Description]  VARCHAR(max),       -- up to 64KB characters
   [Picture]      VARBINARY(max),       -- up to 64KB binary
   PRIMARY KEY  ([CategoryID]),
   UNIQUE ([CategoryName])
      -- Build index on this unique-value column for fast search
);

CREATE TABLE Suppliers (
   [SupplierID]   SMALLINT CHECK ([SupplierID] > 0)  NOT NULL IDENTITY,
                                     -- [0, 65535]
   [CompanyName]  VARCHAR(40)        NOT NULL,
   [ContactName]  VARCHAR(30),
   [ContactTitle] VARCHAR(30),
   [Address]      VARCHAR(60),
   [City]         VARCHAR(15),
   [Region]       VARCHAR(15),
   [PostalCode]   VARCHAR(10),
   [Country]      VARCHAR(15),
   [Phone]        VARCHAR(24),
   [Fax]          VARCHAR(24),
   [HomePage]     VARCHAR(max),          -- 64KB?? VARCHAR(255)?
    PRIMARY KEY ([SupplierID])
          -- UNIQUE?
);

CREATE INDEX idx_supp_company_nm on Suppliers ([CompanyName]);
CREATE INDEX idx_supp_postal_cd on Suppliers ([PostalCode]);

CREATE TABLE Products (
   [ProductID]       SMALLINT CHECK ([ProductID] > 0)       NOT NULL IDENTITY,
   [ProductName]     VARCHAR(40)             NOT NULL,
   [SupplierID]      SMALLINT CHECK ([SupplierID] > 0)       NOT NULL,  -- one supplier only
   [CategoryID]      SMALLINT CHECK ([CategoryID] > 0)        NOT NULL,
   [QuantityPerUnit] VARCHAR(20),            -- e.g., '10 boxes x 20 bags'
   [UnitPrice]       DECIMAL(10,2) CHECK ([UnitPrice] > 0)  DEFAULT 0,
   [UnitsInStock]    SMALLINT                DEFAULT 0,  -- Negative??
   [UnitsOnOrder]    SMALLINT CHECK ([UnitsOnOrder] > 0)       DEFAULT 0,
   [ReorderLevel]    SMALLINT CHECK ([ReorderLevel] > 0)       DEFAULT 0,
   [Discontinued]    BIT                 NOT NULL DEFAULT 0,
   PRIMARY KEY ([ProductID])
  ,
   FOREIGN KEY ([CategoryID]) REFERENCES Categories ([CategoryID]),
   FOREIGN KEY ([SupplierID]) REFERENCES Suppliers ([SupplierID])
);

CREATE INDEX idx_prod_product_nm on Products ([ProductName]);

CREATE TABLE Shippers (
   [ShipperID]   SMALLINT CHECK ([ShipperID] > 0)  NOT NULL IDENTITY,
   [CompanyName] VARCHAR(40)       NOT NULL,
   [Phone]       VARCHAR(24),
   PRIMARY KEY ([ShipperID])
);

CREATE TABLE Orders (
   [OrderID]        INT CHECK ([OrderID] > 0)        NOT NULL IDENTITY,
                    -- Use UNSIGNED INT to avoid run-over
   [CustomerID]     VARCHAR(5),
   [EmployeeID]     INT CHECK ([EmployeeID] > 0)  NOT NULL,
   [OrderDate]      DATE,
   [RequiredDate]   DATE,
   [ShippedDate]    DATE,
   [ShipVia]        SMALLINT CHECK ([ShipVia] > 0),
   [Freight]        DECIMAL(10,2) CHECK ([Freight] > 0)  DEFAULT 0,
   [ShipName]       VARCHAR(40),
   [ShipAddress]    VARCHAR(60),
   [ShipCity]       VARCHAR(15),
   [ShipRegion]     VARCHAR(15),
   [ShipPostalCode] VARCHAR(10),
   [ShipCountry]    VARCHAR(15),
   PRIMARY KEY ([OrderID])
  ,
   FOREIGN KEY ([CustomerID]) REFERENCES Customers ([CustomerID]),
   FOREIGN KEY ([EmployeeID]) REFERENCES Employees ([EmployeeID]),
   FOREIGN KEY ([ShipVia])    REFERENCES Shippers  ([ShipperID])
);

CREATE INDEX idx_orde_order_dt on Orders ([OrderDate]);
CREATE INDEX idx_orde_shipp_dt on Orders ([ShippedDate]);
CREATE INDEX idx_orde_ship_postal_cd on Orders ([ShipPostalCode]);

-- Many-to-many Junction table between Orders and Products
CREATE TABLE OrderDetails (
   [OrderID]   INT CHECK ([OrderID] > 0)           NOT NULL,
   [ProductID] SMALLINT CHECK ([ProductID] > 0)      NOT NULL,
   [UnitPrice] DECIMAL(8,2) CHECK ([UnitPrice] > 0)  NOT NULL DEFAULT 999999.99,
                                      -- max value as default
   [Quantity]  SMALLINT CHECK ([Quantity] > 0)   NOT NULL DEFAULT 1,
   [Discount]  FLOAT            NOT NULL DEFAULT 0, -- e.g., 0.15
   PRIMARY KEY ([OrderID], [ProductID]),
   FOREIGN KEY ([OrderID])   REFERENCES Orders   ([OrderID]),
   FOREIGN KEY ([ProductID]) REFERENCES Products ([ProductID])
);

CREATE TABLE CustomerDemographics (
   [CustomerTypeID]  VARCHAR(10)  NOT NULL,
   [CustomerDesc]    VARCHAR(max),        -- 64KB
   PRIMARY KEY ([CustomerTypeID])
);

CREATE TABLE CustomerCustomerDemo (
   [CustomerID]     VARCHAR(5)   NOT NULL,
   [CustomerTypeID] VARCHAR(10)  NOT NULL,
   PRIMARY KEY ([CustomerID], [CustomerTypeID]),
   FOREIGN KEY ([CustomerTypeID]) REFERENCES CustomerDemographics ([CustomerTypeID]),
   FOREIGN KEY ([CustomerID]) REFERENCES Customers ([CustomerID])
);

GO

    CREATE VIEW CurrentProductList
AS
SELECT
   ProductID,
   ProductName 
FROM Products 
WHERE Discontinued = 0;

GO

-- List all products grouped by category
CREATE VIEW ProductsByCategory
AS
SELECT 
   Categories.CategoryName, 
   Products.ProductName, 
   Products.QuantityPerUnit, 
   Products.UnitsInStock, 
   Products.Discontinued
FROM Categories 
   INNER JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued = 0;  -- FALSE

GO

CREATE VIEW ProductsAboveAveragePrice
AS
SELECT
   Products.ProductName, 
   Products.UnitPrice
FROM Products
WHERE Products.UnitPrice > (SELECT AVG(UnitPrice) From Products);  -- subquery

GO

-- List all customers and suppliers (with an union)
-- order by City and CompanyName
CREATE VIEW CustomerAndSuppliersByCity
AS
SELECT 
   City, 
   CompanyName, 
   ContactName, 
   'Customers' AS Relationship 
FROM Customers
UNION  -- Union two result sets (of same column numbers), remove duplicates
SELECT City, 
   CompanyName, 
   ContactName, 
   'Suppliers' AS Relationship 
FROM Suppliers;

GO

-- Extend Order Details to include ProductName and TotalPrice
CREATE VIEW OrderDetailsExtended
AS
SELECT
   OrderDetails.OrderID, 
   OrderDetails.ProductID, 
   Products.ProductName, 
   OrderDetails.UnitPrice, 
   OrderDetails.Quantity, 
   OrderDetails.Discount, 
   ROUND(OrderDetails.UnitPrice*Quantity*(1-Discount),2) AS ExtendedPrice
FROM Products 
   JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID;

   GO
   
   -- All information (order, customer, shipper)
-- for each Order Details line.
-- An invoice is supposed to be per order?!
CREATE VIEW Invoices
AS
SELECT 
   Orders.ShipName,
   Orders.ShipAddress,
   Orders.ShipCity,
   Orders.ShipRegion, 
   Orders.ShipPostalCode,
   Orders.ShipCountry,
   Orders.CustomerID,
   Customers.CompanyName AS CustomerName,
   Customers.Address,
   Customers.City,
   Customers.Region,
   Customers.PostalCode,
   Customers.Country,
   (Employees.FirstName + ' ' + Employees.LastName) AS Salesperson, 
   Orders.OrderID,
   Orders.OrderDate,
   Orders.RequiredDate,
   Orders.ShippedDate, 
   Shippers.CompanyName As ShipperName,
   OrderDetails.ProductID,
   Products.ProductName, 
   OrderDetails.UnitPrice,
   OrderDetails.Quantity,
   OrderDetails.Discount, 
   FLOOR(OrderDetails.UnitPrice*Quantity*(1-Discount)) AS ExtendedPrice,
         -- truncate to nearest dollars
   Orders.Freight
FROM Customers
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID  
   JOIN Employees ON Employees.EmployeeID = Orders.EmployeeID    
   JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
   JOIN Products ON Products.ProductID = OrderDetails.ProductID      
   JOIN Shippers ON Shippers.ShipperID = Orders.ShipVia;
   
   -- List details (order and customer) of each order
--   for customer query

GO

CREATE VIEW OrdersQry
AS
SELECT 
   Orders.OrderID,
   Orders.CustomerID,
   Orders.EmployeeID, 
   Orders.OrderDate, 
   Orders.RequiredDate,
   Orders.ShippedDate, 
   Orders.ShipVia, 
   Orders.Freight,
   Orders.ShipName, 
   Orders.ShipAddress, 
   Orders.ShipCity,
   Orders.ShipRegion,
   Orders.ShipPostalCode,
   Orders.ShipCountry,
   Customers.CompanyName,
   Customers.Address,
   Customers.City,
   Customers.Region,
   Customers.PostalCode, 
   Customers.Country
FROM Customers 
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

   GO
   
   -- List sales for each productName for 1997
CREATE VIEW ProductSalesFor1997
AS
SELECT 
   Categories.CategoryName, 
   Products.ProductName, 
   Sum(ROUND(OrderDetails.UnitPrice*Quantity*(1-Discount),2)) AS ProductSales
FROM Categories
   JOIN Products On Categories.CategoryID = Products.CategoryID
   JOIN OrderDetails on Products.ProductID = OrderDetails.ProductID
   JOIN Orders on Orders.OrderID = OrderDetails.OrderID 
WHERE Orders.ShippedDate BETWEEN '1997-01-01' And '1997-12-31'
GROUP BY Categories.CategoryName, Products.ProductName;
GO
-- List Sales by ProductName
CREATE VIEW SalesByCategory
AS
SELECT
   Categories.CategoryID, 
   Categories.CategoryName, 
   Products.ProductName, 
   Sum(OrderDetailsExtended.ExtendedPrice) AS ProductSales
FROM Categories 
   JOIN Products ON Categories.CategoryID = Products.CategoryID
   JOIN OrderDetailsExtended ON Products.ProductID = OrderDetailsExtended.ProductID
   JOIN Orders ON Orders.OrderID = OrderDetailsExtended.OrderID 
WHERE Orders.OrderDate BETWEEN '1997-01-01' And '1997-12-31'
GROUP BY
   Categories.CategoryID,
   Categories.CategoryName,
   Products.ProductName;
 GO     
   CREATE VIEW CategorySalesFor1997
AS
SELECT
   ProductSalesFor1997.CategoryName,   -- Use Product Sales for 1997 view
   Sum(ProductSalesFor1997.ProductSales) AS CategorySales
FROM ProductSalesFor1997
GROUP BY ProductSalesFor1997.CategoryName;
GO
-- List sales by customers in 1997
CREATE VIEW QuarterlyOrders
AS
SELECT DISTINCT 
   Customers.CustomerID, 
   Customers.CompanyName, 
   Customers.City, 
   Customers.Country
FROM Customers 
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderDate BETWEEN '1997-01-01' And '1997-12-31';
GO
-- List the total amount for each order
CREATE VIEW OrderSubtotals 
AS
SELECT 
   OrderDetails.OrderID, 
   Sum(ROUND(OrderDetails.UnitPrice*Quantity*(1-Discount),2)) AS Subtotal
FROM OrderDetails
GROUP BY OrderDetails.OrderID;
GO
CREATE VIEW SalesTotalsByAmount
AS
SELECT 
   OrderSubtotals.Subtotal AS SaleAmount,   -- Order Subtotals is a view
   Orders.OrderID, 
   Customers.CompanyName, 
   Orders.ShippedDate
FROM Customers 
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID
   JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID 
WHERE (OrderSubtotals.Subtotal > 2500) 
   AND (Orders.ShippedDate BETWEEN '1997-01-01' And '1997-12-31');
   GO
   CREATE VIEW SummaryOfSalesByQuarter
AS
SELECT 
   Orders.ShippedDate, 
   Orders.OrderID, 
   OrderSubtotals.Subtotal  -- Use Order Subtotals view
FROM Orders 
   INNER JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
WHERE Orders.ShippedDate IS NOT NULL;
GO
-- List each order
CREATE VIEW SummaryOfSalesByYear
AS
SELECT
   Orders.ShippedDate, 
   Orders.OrderID, 
   OrderSubtotals.Subtotal
FROM Orders 
   INNER JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
WHERE Orders.ShippedDate IS NOT NULL;

-- PROCEDUURES

-- Given an OrderID, print Order Details
GO
CREATE PROCEDURE CustOrdersDetail( @AtOrderID INT)
AS
BEGIN
SET NOCOUNT ON;
   SELECT ProductName,
      b.UnitPrice,
      Quantity,
      Discount * 100 AS Discount, 
      ROUND(Quantity * (1 - Discount) * b.UnitPrice,2) AS ExtendedPrice
   FROM Products a INNER JOIN OrderDetails b on a.ProductID=b.ProductID
   WHERE b.OrderID = @AtOrderID;
END;
GO
CREATE PROCEDURE CustOrdersOrders( @AtCustomerID VARCHAR(5))
AS
BEGIN
SET NOCOUNT ON;
   SELECT 
      OrderID,
      OrderDate,
      RequiredDate,
      ShippedDate
   FROM Orders
   WHERE CustomerID = @AtCustomerID
   ORDER BY OrderID;
END;
GO
CREATE PROCEDURE CustOrderHist( @AtCustomerID VARCHAR(5))
AS
BEGIN
SET NOCOUNT ON;
   SELECT
      ProductName,
      SUM(Quantity) as TOTAL
   FROM Products a
      INNER JOIN OrderDetails b on a.ProductID=b.ProductID
      INNER JOIN Orders c on c.OrderID=b.OrderID
      INNER JOIN Customers d on d.CustomerID=c.CustomerID
   WHERE d.CustomerID = @AtCustomerID
   GROUP BY ProductName;
END;

GO
CREATE PROCEDURE TenMostExpensiveProducts
AS
BEGIN
SET NOCOUNT ON;
   SELECT top(10)
      Products.ProductName AS TenMostExpensiveProducts,
      Products.UnitPrice
   FROM Products
   ORDER BY Products.UnitPrice DESC
   ;
END;

GO
CREATE PROCEDURE EmployeeSalesByCountry( @AtBeginning_Date DATE, @AtEnding_Date DATE)
AS
BEGIN
SET NOCOUNT ON;
   SELECT
      Employees.Country,
      Employees.LastName,
      Employees.FirstName,
      Orders.ShippedDate,
      Orders.OrderID,
      OrderSubtotals.Subtotal AS SaleAmount
   FROM Employees
      INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
      INNER JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
   WHERE Orders.ShippedDate BETWEEN @AtBeginning_Date AND @AtEnding_Date;
END;

GO
CREATE PROCEDURE SalesByYear( @AtBeginning_Date DATE, @AtEnding_Date DATE)
AS
BEGIN
SET NOCOUNT ON;
   SELECT
      Orders.ShippedDate,
      Orders.OrderID,
      OrderSubtotals.Subtotal,
      ShippedDate AS Year
   FROM Orders 
      JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
   WHERE Orders.ShippedDate BETWEEN @AtBeginning_Date AND @AtEnding_Date;
END;