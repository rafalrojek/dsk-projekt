USE dsk;

CREATE TABLE `Customers` (
   `CustomerID`   VARCHAR(5)   NOT NULL,
       -- First 5 letters of CompanyName
       -- Probably better to use an UNSIGNED INT
   `CompanyName`  VARCHAR(40)  NOT NULL,
   `ContactName`  VARCHAR(30),
   `ContactTitle` VARCHAR(30),
   `Address`      VARCHAR(60),
   `City`         VARCHAR(15),
   `Region`       VARCHAR(15),
   `PostalCode`   VARCHAR(10),
   `Country`      VARCHAR(15),
   `Phone`        VARCHAR(24),
   `Fax`          VARCHAR(24),
   PRIMARY KEY (`CustomerID`),
   INDEX (`City`),
   INDEX (`CompanyName`),
   INDEX (`PostalCode`),
   INDEX (`Region`)
       -- Build indexes on these columns for fast search
);

CREATE TABLE `Employees` (
   `EmployeeID`      MEDIUMINT UNSIGNED  NOT NULL AUTO_INCREMENT,
                     -- [0, 65535]
   `LastName`        VARCHAR(20)         NOT NULL,
   `FirstName`       VARCHAR(10)         NOT NULL,
   `Title`           VARCHAR(30),  -- e.g., 'Sales Coordinator'
   `TitleOfCourtesy` VARCHAR(25),  -- e.g., 'Mr.' 'Ms.' (ENUM??)
   `BirthDate`       DATE,         -- 'YYYY-MM-DD'
   `HireDate`        DATE,
   `Address`         VARCHAR(60),
   `City`            VARCHAR(15),
   `Region`          VARCHAR(15),
   `PostalCode`      VARCHAR(10),
   `Country`         VARCHAR(15),
   `HomePhone`       VARCHAR(24),
   `Extension`       VARCHAR(4),
   `Photo`           BLOB,                          -- 64KB
   `Notes`           TEXT                NOT NULL,  -- 64KB
   `ReportsTo`       MEDIUMINT UNSIGNED  NULL,  -- Manager's ID
                                                -- Allow NULL for boss
   `PhotoPath`       VARCHAR(255),
   `Salary`          INT,
   INDEX (`LastName`),
   INDEX (`PostalCode`),
   PRIMARY KEY (`EmployeeID`),
   FOREIGN KEY (`ReportsTo`) REFERENCES `Employees` (`EmployeeID`)
);

CREATE TABLE `Region` (
   `RegionID`           TINYINT UNSIGNED  NOT NULL AUTO_INCREMENT,
                        -- [0,255]
   `RegionDescription`  VARCHAR(50)       NOT NULL,
                        -- e.g., 'Eastern','Western','Northern','Southern'
                        -- Could use an ENUM and eliminate this table
   PRIMARY KEY (`RegionID`)
);

-- e.g., ('02116', 'Boston', 1)
CREATE TABLE `Territories` (
   `TerritoryID`           VARCHAR(20)       NOT NULL,  -- ZIP code
   `TerritoryDescription`  VARCHAR(50)       NOT NULL,  -- Name
   `RegionID`              TINYINT UNSIGNED  NOT NULL,
                           -- Could use an ENUM to eliminate `Region` table
   PRIMARY KEY (`TerritoryID`),
   FOREIGN KEY (`RegionID`) REFERENCES `Region` (`RegionID`)
);

-- Many-to-many Junction table between Employee and Territory
CREATE TABLE `EmployeeTerritories` (
   `EmployeeID`  MEDIUMINT UNSIGNED  NOT NULL,
   `TerritoryID` VARCHAR(20) NOT NULL,
   PRIMARY KEY (`EmployeeID`, `TerritoryID`),
   FOREIGN KEY (`EmployeeID`) REFERENCES `Employees` (`EmployeeID`),
   FOREIGN KEY (`TerritoryID`) REFERENCES `Territories` (`TerritoryID`)
);

CREATE TABLE `Categories` (
   `CategoryID`   TINYINT UNSIGNED  NOT NULL AUTO_INCREMENT,
                  -- [0, 255], not expected to be large
   `CategoryName` VARCHAR(30)       NOT NULL,
                  -- e.g., 'Beverages','Condiments',etc
   `Description`  TEXT,       -- up to 64KB characters
   `Picture`      BLOB,       -- up to 64KB binary
   PRIMARY KEY  (`CategoryID`),
   UNIQUE INDEX (`CategoryName`)
      -- Build index on this unique-value column for fast search
);

CREATE TABLE `Suppliers` (
   `SupplierID`   SMALLINT UNSIGNED  NOT NULL AUTO_INCREMENT,
                                     -- [0, 65535]
   `CompanyName`  VARCHAR(40)        NOT NULL,
   `ContactName`  VARCHAR(30),
   `ContactTitle` VARCHAR(30),
   `Address`      VARCHAR(60),
   `City`         VARCHAR(15),
   `Region`       VARCHAR(15),
   `PostalCode`   VARCHAR(10),
   `Country`      VARCHAR(15),
   `Phone`        VARCHAR(24),
   `Fax`          VARCHAR(24),
   `HomePage`     TEXT,          -- 64KB?? VARCHAR(255)?
    PRIMARY KEY (`SupplierID`),
    INDEX (`CompanyName`),       -- UNIQUE?
    INDEX (`PostalCode`)
);

CREATE TABLE `Products` (
   `ProductID`       SMALLINT UNSIGNED       NOT NULL AUTO_INCREMENT,
   `ProductName`     VARCHAR(40)             NOT NULL,
   `SupplierID`      SMALLINT UNSIGNED       NOT NULL,  -- one supplier only
   `CategoryID`      TINYINT UNSIGNED        NOT NULL,
   `QuantityPerUnit` VARCHAR(20),            -- e.g., '10 boxes x 20 bags'
   `UnitPrice`       DECIMAL(10,2) UNSIGNED  DEFAULT 0,
   `UnitsInStock`    SMALLINT                DEFAULT 0,  -- Negative??
   `UnitsOnOrder`    SMALLINT UNSIGNED       DEFAULT 0,
   `ReorderLevel`    SMALLINT UNSIGNED       DEFAULT 0,
   `Discontinued`    BOOLEAN                 NOT NULL DEFAULT FALSE,
   PRIMARY KEY (`ProductID`),
   INDEX (`ProductName`),
   FOREIGN KEY (`CategoryID`) REFERENCES `Categories` (`CategoryID`),
   FOREIGN KEY (`SupplierID`) REFERENCES `Suppliers` (`SupplierID`)
);

CREATE TABLE `Shippers` (
   `ShipperID`   TINYINT UNSIGNED  NOT NULL AUTO_INCREMENT,
   `CompanyName` VARCHAR(40)       NOT NULL,
   `Phone`       VARCHAR(24),
   PRIMARY KEY (`ShipperID`)
);

CREATE TABLE `Orders` (
   `OrderID`        INT UNSIGNED        NOT NULL AUTO_INCREMENT,
                    -- Use UNSIGNED INT to avoid run-over
   `CustomerID`     VARCHAR(5),
   `EmployeeID`     MEDIUMINT UNSIGNED  NOT NULL,
   `OrderDate`      DATE,
   `RequiredDate`   DATE,
   `ShippedDate`    DATE,
   `ShipVia`        TINYINT UNSIGNED,
   `Freight`        DECIMAL(10,2) UNSIGNED  DEFAULT 0,
   `ShipName`       VARCHAR(40),
   `ShipAddress`    VARCHAR(60),
   `ShipCity`       VARCHAR(15),
   `ShipRegion`     VARCHAR(15),
   `ShipPostalCode` VARCHAR(10),
   `ShipCountry`    VARCHAR(15),
   PRIMARY KEY (`OrderID`),
   INDEX (`OrderDate`),
   INDEX (`ShippedDate`),
   INDEX (`ShipPostalCode`),
   FOREIGN KEY (`CustomerID`) REFERENCES `Customers` (`CustomerID`),
   FOREIGN KEY (`EmployeeID`) REFERENCES `Employees` (`EmployeeID`),
   FOREIGN KEY (`ShipVia`)    REFERENCES `Shippers`  (`ShipperID`)
);

-- Many-to-many Junction table between Orders and Products
CREATE TABLE `Order Details` (
   `OrderID`   INT UNSIGNED           NOT NULL,
   `ProductID` SMALLINT UNSIGNED      NOT NULL,
   `UnitPrice` DECIMAL(8,2) UNSIGNED  NOT NULL DEFAULT 999999.99,
                                      -- max value as default
   `Quantity`  SMALLINT(2) UNSIGNED   NOT NULL DEFAULT 1,
   `Discount`  DOUBLE(8,0)            NOT NULL DEFAULT 0, -- e.g., 0.15
   PRIMARY KEY (`OrderID`, `ProductID`),
   FOREIGN KEY (`OrderID`)   REFERENCES `Orders`   (`OrderID`),
   FOREIGN KEY (`ProductID`) REFERENCES `Products` (`ProductID`)
);

CREATE TABLE `CustomerDemographics` (
   `CustomerTypeID`  VARCHAR(10)  NOT NULL,
   `CustomerDesc`    TEXT,        -- 64KB
   PRIMARY KEY (`CustomerTypeID`)
);

CREATE TABLE `CustomerCustomerDemo` (
   `CustomerID`     VARCHAR(5)   NOT NULL,
   `CustomerTypeID` VARCHAR(10)  NOT NULL,
   PRIMARY KEY (`CustomerID`, `CustomerTypeID`),
   FOREIGN KEY (`CustomerTypeID`) REFERENCES `CustomerDemographics` (`CustomerTypeID`),
   FOREIGN KEY (`CustomerID`) REFERENCES `Customers` (`CustomerID`)
);

-- PROCEDUURES

-- List current products (not discontinued)
CREATE VIEW `CurrentProductList`
AS
SELECT
   ProductID,
   ProductName 
FROM Products 
WHERE Discontinued = 0;

-- List all products grouped by category
CREATE VIEW `ProductsByCategory`
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

CREATE VIEW `Products Above Average Price`
AS
SELECT
   Products.ProductName, 
   Products.UnitPrice
FROM Products
WHERE Products.UnitPrice > (SELECT AVG(UnitPrice) From Products);  -- subquery

-- List all customers and suppliers (with an union)
-- order by City and CompanyName
CREATE VIEW `Customer and Suppliers by City`
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
   'Suppliers'
FROM Suppliers 
ORDER BY City, CompanyName;

-- Extend `Order Details` to include ProductName and TotalPrice
CREATE VIEW `Order Details Extended`
AS
SELECT
   `Order Details`.OrderID, 
   `Order Details`.ProductID, 
   Products.ProductName, 
   `Order Details`.UnitPrice, 
   `Order Details`.Quantity, 
   `Order Details`.Discount, 
   ROUND(`Order Details`.UnitPrice*Quantity*(1-Discount)) AS ExtendedPrice
FROM Products 
   JOIN `Order Details` ON Products.ProductID = `Order Details`.ProductID;
   
   -- All information (order, customer, shipper)
-- for each `Order Details` line.
-- An invoice is supposed to be per order?!
CREATE VIEW `Invoices`
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
   `Order Details`.ProductID,
   Products.ProductName, 
   `Order Details`.UnitPrice,
   `Order Details`.Quantity,
   `Order Details`.Discount, 
   FLOOR(`Order Details`.UnitPrice*Quantity*(1-Discount)) AS ExtendedPrice,
         -- truncate to nearest dollars
   Orders.Freight
FROM Customers
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID  
   JOIN Employees ON Employees.EmployeeID = Orders.EmployeeID    
   JOIN `Order Details` ON Orders.OrderID = `Order Details`.OrderID     
   JOIN Products ON Products.ProductID = `Order Details`.ProductID      
   JOIN Shippers ON Shippers.ShipperID = Orders.ShipVia;
   
   -- List details (order and customer) of each order
--   for customer query
CREATE VIEW `Orders Qry`
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
   
   -- List sales for each productName for 1997
CREATE VIEW `Product Sales for 1997`
AS
SELECT 
   Categories.CategoryName, 
   Products.ProductName, 
   Sum(ROUND(`Order Details`.UnitPrice*Quantity*(1-Discount))) AS ProductSales
FROM Categories
   JOIN Products On Categories.CategoryID = Products.CategoryID
   JOIN `Order Details` on Products.ProductID = `Order Details`.ProductID     
   JOIN `Orders` on Orders.OrderID = `Order Details`.OrderID 
WHERE Orders.ShippedDate BETWEEN '1997-01-01' And '1997-12-31'
GROUP BY Categories.CategoryName, Products.ProductName;

-- List Sales by ProductName
CREATE VIEW `Sales by Category`
AS
SELECT
   Categories.CategoryID, 
   Categories.CategoryName, 
   Products.ProductName, 
   Sum(`Order Details Extended`.ExtendedPrice) AS ProductSales
FROM Categories 
   JOIN Products ON Categories.CategoryID = Products.CategoryID
   JOIN `Order Details Extended` ON Products.ProductID = `Order Details Extended`.ProductID
   JOIN Orders ON Orders.OrderID = `Order Details Extended`.OrderID 
WHERE Orders.OrderDate BETWEEN '1997-01-01' And '1997-12-31'
GROUP BY
   Categories.CategoryID,
   Categories.CategoryName,
   Products.ProductName;
      
   CREATE VIEW `Category Sales for 1997`
AS
SELECT
   `Product Sales for 1997`.CategoryName,   -- Use `Product Sales for 1997` view
   Sum(`Product Sales for 1997`.ProductSales) AS CategorySales
FROM `Product Sales for 1997`
GROUP BY `Product Sales for 1997`.CategoryName;

-- List sales by customers in 1997
CREATE VIEW `Quarterly Orders`
AS
SELECT DISTINCT 
   Customers.CustomerID, 
   Customers.CompanyName, 
   Customers.City, 
   Customers.Country
FROM Customers 
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderDate BETWEEN '1997-01-01' And '1997-12-31';

-- List the total amount for each order
CREATE VIEW `Order Subtotals` 
AS
SELECT 
   `Order Details`.OrderID, 
   Sum(ROUND(`Order Details`.UnitPrice*Quantity*(1-Discount))) AS Subtotal
FROM `Order Details`
GROUP BY `Order Details`.OrderID;

CREATE VIEW `Sales Totals by Amount`
AS
SELECT 
   `Order Subtotals`.Subtotal AS SaleAmount,   -- `Order Subtotals` is a view
   Orders.OrderID, 
   Customers.CompanyName, 
   Orders.ShippedDate
FROM Customers 
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID
   JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID 
WHERE (`Order Subtotals`.Subtotal > 2500) 
   AND (Orders.ShippedDate BETWEEN '1997-01-01' And '1997-12-31');
   
   CREATE VIEW `Summary of Sales by Quarter`
AS
SELECT 
   Orders.ShippedDate, 
   Orders.OrderID, 
   `Order Subtotals`.Subtotal  -- Use `Order Subtotals` view
FROM Orders 
   INNER JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
WHERE Orders.ShippedDate IS NOT NULL;

-- List each order
CREATE VIEW `Summary of Sales by Year`
AS
SELECT
   Orders.ShippedDate, 
   Orders.OrderID, 
   `Order Subtotals`.Subtotal
FROM Orders 
   INNER JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
WHERE Orders.ShippedDate IS NOT NULL;

-- PROCEDUURES

-- Given an OrderID, print `Order Details`
DELIMITER $$
CREATE PROCEDURE `CustOrdersDetail`(IN AtOrderID INT)
BEGIN
   SELECT ProductName,
      `Order Details`.UnitPrice,
      Quantity,
      Discount * 100 AS `Discount`, 
      ROUND(Quantity * (1 - Discount) * `Order Details`.UnitPrice) AS ExtendedPrice
   FROM Products INNER JOIN `Order Details` USING (ProductID)
   WHERE `Order Details`.OrderID = AtOrderID;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `CustOrdersOrders`(IN AtCustomerID VARCHAR(5))
BEGIN
   SELECT 
      OrderID,
      OrderDate,
      RequiredDate,
      ShippedDate
   FROM Orders
   WHERE CustomerID = AtCustomerID
   ORDER BY OrderID;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `CustOrderHist`(IN AtCustomerID VARCHAR(5))
BEGIN
   SELECT
      ProductName,
      SUM(Quantity) as TOTAL
   FROM Products
      INNER JOIN `Order Details` USING(ProductID)
      INNER JOIN Orders USING (OrderID)
      INNER JOIN Customers USING (CustomerID)
   WHERE Customers.CustomerID = AtCustomerID
   GROUP BY ProductName;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS `Ten Most Expensive Products`;
DELIMITER $$
CREATE PROCEDURE `Ten Most Expensive Products`()
BEGIN
   SELECT 
      Products.ProductName AS TenMostExpensiveProducts,
      Products.UnitPrice
   FROM Products
   ORDER BY Products.UnitPrice DESC
   LIMIT 10;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `Employee Sales by Country`(IN AtBeginning_Date DATE, IN AtEnding_Date DATE)
BEGIN
   SELECT
      Employees.Country,
      Employees.LastName,
      Employees.FirstName,
      Orders.ShippedDate,
      Orders.OrderID,
      `Order Subtotals`.Subtotal AS SaleAmount
   FROM Employees
      INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
      INNER JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
   WHERE Orders.ShippedDate BETWEEN AtBeginning_Date AND AtEnding_Date;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `Sales by Year`(IN AtBeginning_Date DATE, IN AtEnding_Date DATE)
BEGIN
   SELECT
      Orders.ShippedDate,
      Orders.OrderID,
      `Order Subtotals`.Subtotal,
      ShippedDate AS Year
   FROM Orders 
      JOIN `Order Subtotals` ON Orders.OrderID = `Order Subtotals`.OrderID
   WHERE Orders.ShippedDate BETWEEN AtBeginning_Date AND AtEnding_Date;
END $$
DELIMITER ;
