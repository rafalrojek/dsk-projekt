CREATE TABLE Customers (
   CustomerID   VARCHAR2(5)   NOT NULL,
       -- First 5 letters of CompanyName
       -- Probably better to use an UNSIGNED INT
   CompanyName  VARCHAR2(40)  NOT NULL,
   ContactName  VARCHAR2(30),
   ContactTitle VARCHAR2(30),
   Address      VARCHAR2(60),
   City         VARCHAR2(15),
   Region       VARCHAR2(15),
   PostalCode   VARCHAR2(10),
   Country      VARCHAR2(15),
   Phone        VARCHAR2(24),
   Fax          VARCHAR2(24),
   PRIMARY KEY (CustomerID)
       -- Build indexes on these columns for fast search
);

CREATE INDEX Customers_PostalCode ON Customers(PostalCode)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE INDEX Customers_Region ON Customers(Region)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE INDEX Customers_City ON Customers(City)
      TABLESPACE users
      STORAGE (INITIAL 20K
      NEXT 20k
      PCTINCREASE 75);

CREATE INDEX Customers_CompanyName ON Customers(CompanyName)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);


CREATE TABLE Employees (
   EmployeeID      NUMBER(7) CHECK (EmployeeID > 0)  NOT NULL,
                     -- [0, 65535]
   LastName        VARCHAR2(20)         NOT NULL,
   FirstName       VARCHAR2(10)         NOT NULL,
   Title           VARCHAR2(30),  -- e.g., 'Sales Coordinator'
   TitleOfCourtesy VARCHAR2(25),  -- e.g., 'Mr.' 'Ms.' (ENUM??)
   BirthDate       DATE,         -- 'YYYY-MM-DD'
   HireDate        DATE,
   Address         VARCHAR2(60),
   City            VARCHAR2(15),
   Region          VARCHAR2(15),
   PostalCode      VARCHAR2(10),
   Country         VARCHAR2(15),
   HomePhone       VARCHAR2(24),
   Extension       VARCHAR2(4),
   Photo           BLOB,                          -- 64KB
   Notes           CLOB                NOT NULL,  -- 64KB
   ReportsTo       NUMBER(7) CHECK (ReportsTo > 0)  NULL,  -- Manager's ID
                                                -- Allow NULL for boss
   PhotoPath       VARCHAR2(255),
   Salary          NUMBER(10)
  ,
   PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_EMPLOYEES FOREIGN KEY (ReportsTo) REFERENCES Employees (EmployeeID)
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Employees_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Employees_seq_tr
 BEFORE INSERT ON Employees FOR EACH ROW
 WHEN (NEW.EmployeeID IS NULL)
BEGIN
 SELECT Employees_seq.NEXTVAL INTO :NEW.EmployeeID FROM DUAL;
END;
/

CREATE INDEX Employees_LastName ON Employees(LastName)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE INDEX Employees_PostalCode ON Employees(PostalCode)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE TABLE Region (
   RegionID           NUMBER(3) CHECK (RegionID > 0)  NOT NULL,
                        -- [0,255]
   RegionDescription  VARCHAR2(50)       NOT NULL,
                        -- e.g., 'Eastern','Western','Northern','Southern'
                        -- Could use an ENUM and eliminate this table
   PRIMARY KEY (RegionID)
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Region_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Region_seq_tr
 BEFORE INSERT ON Region FOR EACH ROW
 WHEN (NEW.RegionID IS NULL)
BEGIN
 SELECT Region_seq.NEXTVAL INTO :NEW.RegionID FROM DUAL;
END;
/

-- e.g., ('02116', 'Boston', 1)
CREATE TABLE Territories (
   TerritoryID           VARCHAR2(20)       NOT NULL,  -- ZIP code
   TerritoryDescription  VARCHAR2(50)       NOT NULL,  -- Name
   RegionID              NUMBER(3) CHECK (RegionID > 0)  NOT NULL,
                           -- Could use an ENUM to eliminate `Region` table
   PRIMARY KEY (TerritoryID),
   CONSTRAINT FK_TERRITORIES FOREIGN KEY (RegionID) REFERENCES Region (RegionID)
);

-- Many-to-many Junction table between Employee and Territory
CREATE TABLE EmployeeTerritories (
   EmployeeID  NUMBER(7) CHECK (EmployeeID > 0)  NOT NULL,
   TerritoryID VARCHAR2(20) NOT NULL,
   PRIMARY KEY (EmployeeID, TerritoryID),
   CONSTRAINT FK_EmployeeTerritories1 FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID),
   CONSTRAINT FK_EmployeeTerritories2 FOREIGN KEY (TerritoryID) REFERENCES Territories (TerritoryID)
);

CREATE TABLE Categories (
   CategoryID   NUMBER(3) CHECK (CategoryID > 0)  NOT NULL,
                  -- [0, 255], not expected to be large
   CategoryName VARCHAR2(30)       NOT NULL,
                  -- e.g., 'Beverages','Condiments',etc
   Description  CLOB,       -- up to 64KB characters
   Picture      BLOB,       -- up to 64KB binary
   PRIMARY KEY  (CategoryID),
   UNIQUE (CategoryName)
      -- Build index on this unique-value column for fast search
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Categories_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Categories_seq_tr
 BEFORE INSERT ON Categories FOR EACH ROW
 WHEN (NEW.CategoryID IS NULL)
BEGIN
 SELECT Categories_seq.NEXTVAL INTO :NEW.CategoryID FROM DUAL;
END;
/

CREATE TABLE Suppliers (
   SupplierID   NUMBER(5) CHECK (SupplierID > 0)  NOT NULL,
                                     -- [0, 65535]
   CompanyName  VARCHAR2(40)        NOT NULL,
   ContactName  VARCHAR2(30),
   ContactTitle VARCHAR2(30),
   Address      VARCHAR2(60),
   City         VARCHAR2(15),
   Region       VARCHAR2(15),
   PostalCode   VARCHAR2(10),
   Country      VARCHAR2(15),
   Phone        VARCHAR2(24),
   Fax          VARCHAR2(24),
   HomePage     CLOB,          -- 64KB?? VARCHAR(255)?
    PRIMARY KEY (SupplierID)
          -- UNIQUE?
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Suppliers_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Suppliers_seq_tr
 BEFORE INSERT ON Suppliers FOR EACH ROW
 WHEN (NEW.SupplierID IS NULL)
BEGIN
 SELECT Suppliers_seq.NEXTVAL INTO :NEW.SupplierID FROM DUAL;
END;
/

CREATE INDEX Suppliers_CompanyName ON Suppliers(CompanyName)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE INDEX Suppliers_PostalCode ON Suppliers(PostalCode)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE TABLE Products (
   ProductID       NUMBER(5) CHECK (ProductID > 0)       NOT NULL,
   ProductName     VARCHAR2(40)             NOT NULL,
   SupplierID      NUMBER(5) CHECK (SupplierID > 0)       NOT NULL,  -- one supplier only
   CategoryID      NUMBER(3) CHECK (CategoryID > 0)        NOT NULL,
   QuantityPerUnit VARCHAR2(20),            -- e.g., '10 boxes x 20 bags'
   UnitPrice       NUMBER(10,2) DEFAULT 0 CHECK (UnitPrice > 0) ,
   UnitsInStock    NUMBER(5)                DEFAULT 0,  -- Negative??
   UnitsOnOrder    NUMBER(5) DEFAULT 0 CHECK (UnitsOnOrder > 0)      ,
   ReorderLevel    NUMBER(5) DEFAULT 0 CHECK (ReorderLevel > 0)      ,
   Discontinued    NUMBER(1) default 0 NOT NULL,
   PRIMARY KEY (ProductID)
  ,
   CONSTRAINT FK_PRODUCTS1 FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID),
   CONSTRAINT FK_PRODUCTS2 FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID)
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Products_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Products_seq_tr
 BEFORE INSERT ON Products FOR EACH ROW
 WHEN (NEW.ProductID IS NULL)
BEGIN
 SELECT Products_seq.NEXTVAL INTO :NEW.ProductID FROM DUAL;
END;
/

CREATE INDEX Products_ProductName ON Products(ProductName)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE TABLE Shippers (
   ShipperID   NUMBER(3) CHECK (ShipperID > 0)  NOT NULL,
   CompanyName VARCHAR2(40)       NOT NULL,
   Phone       VARCHAR2(24),
   PRIMARY KEY (ShipperID)
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Shippers_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Shippers_seq_tr
 BEFORE INSERT ON Shippers FOR EACH ROW
 WHEN (NEW.ShipperID IS NULL)
BEGIN
 SELECT Shippers_seq.NEXTVAL INTO :NEW.ShipperID FROM DUAL;
END;
/

CREATE TABLE Orders(
    OrderID        NUMBER(10) CHECK (OrderID > 0)        NOT NULL,
                    -- Use UNSIGNED INT to avoid run-over
   CustomerID     VARCHAR2(5),
   EmployeeID     NUMBER(7) CHECK (EmployeeID > 0)  NOT NULL,
   OrderDate      DATE,
   RequiredDate   DATE,
   ShippedDate    DATE,
   ShipVia        NUMBER(3) CHECK (ShipVia > 0),
   Freight        NUMBER(10,2) DEFAULT 0 CHECK (Freight > 0) ,
   ShipName       VARCHAR2(40),
   ShipAddress    VARCHAR2(60),
   ShipCity       VARCHAR2(15),
   ShipRegion     VARCHAR2(15),
   ShipPostalCode VARCHAR2(10),
   ShipCountry    VARCHAR2(15),
   PRIMARY KEY (OrderID)
  ,
    CONSTRAINT FK_ORDERS1 FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
    CONSTRAINT FK_ORDERS2 FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID),
    CONSTRAINT FK_ORDERS3 FOREIGN KEY (ShipVia)    REFERENCES Shippers  (ShipperID)
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE Orders_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Orders_seq_tr
 BEFORE INSERT ON Orders FOR EACH ROW
 WHEN (NEW.OrderID IS NULL)
BEGIN
 SELECT Orders_seq.NEXTVAL INTO :NEW.OrderID FROM DUAL;
END;
/

CREATE INDEX Orders_ShipPostalCode ON Orders(ShipPostalCode)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE INDEX Orders_ShippedDate ON Orders(ShippedDate)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

CREATE INDEX Orders_OrderDate ON Orders(OrderDate)
TABLESPACE users
STORAGE (INITIAL 20K
NEXT 20k
PCTINCREASE 75);

-- Many-to-many Junction table between Orders and Products
CREATE TABLE OrderDetails (
   OrderID   NUMBER(10) CHECK (OrderID > 0)           NOT NULL,
   ProductID NUMBER(5) CHECK (ProductID > 0)      NOT NULL,
   UnitPrice NUMBER(8,2) DEFAULT 999999.99 CHECK (UnitPrice > 0)  NOT NULL,
                                      -- max value as default
   Quantity  NUMBER(5) DEFAULT 1 CHECK (Quantity > 0)   NOT NULL,
   Discount  BINARY_DOUBLE DEFAULT 0            NOT NULL, -- e.g., 0.15
   PRIMARY KEY (OrderID, ProductID),
   CONSTRAINT FK_OrderDetails1 FOREIGN KEY (OrderID)   REFERENCES Orders   (OrderID),
   CONSTRAINT FK_OrderDetails2 FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

CREATE TABLE CustomerDemographics (
   CustomerTypeID  VARCHAR2(10)  NOT NULL,
   CustomerDesc    CLOB,        -- 64KB
   PRIMARY KEY (CustomerTypeID)
);

CREATE TABLE CustomerCustomerDemo (
   CustomerID     VARCHAR2(5)   NOT NULL,
   CustomerTypeID VARCHAR2(10)  NOT NULL,
   PRIMARY KEY (CustomerID, CustomerTypeID),
   CONSTRAINT FK_CustomerCustomerDemo1 FOREIGN KEY (CustomerTypeID) REFERENCES CustomerDemographics (CustomerTypeID),
   CONSTRAINT FK_CustomerCustomerDemo2 FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

-- PROCEDUURES

-- List current products (not discontinued)
CREATE VIEW CurrentProductList
AS
SELECT
   ProductID,
   ProductName 
FROM Products 
WHERE Discontinued = 0;

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
WHERE Products.Discontinued = 0;

CREATE VIEW ProductsAboveAveragePrice
AS
SELECT
   Products.ProductName, 
   Products.UnitPrice
FROM Products
WHERE Products.UnitPrice > (SELECT AVG(UnitPrice) From Products);

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
UNION
SELECT City, 
   CompanyName, 
   ContactName, 
   'Suppliers'
FROM Suppliers 
ORDER BY City, CompanyName;

-- Extend `Order Details` to include ProductName and TotalPrice
CREATE VIEW OrderDetailsExtended
AS
SELECT
   OrderDetails.OrderID, 
   OrderDetails.ProductID, 
   Products.ProductName, 
   OrderDetails.UnitPrice, 
   OrderDetails.Quantity, 
   OrderDetails.Discount, 
   ROUND(OrderDetails.UnitPrice*Quantity*(1-Discount)) AS ExtendedPrice
FROM Products 
   JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID;
   
   -- All information (order, customer, shipper)
-- for each `Order Details` line.
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
   
   -- List sales for each productName for 1997
CREATE VIEW ProductSalesFor1997
AS
SELECT 
   Categories.CategoryName, 
   Products.ProductName, 
   Sum(ROUND(OrderDetails.UnitPrice*Quantity*(1-Discount))) AS ProductSales
FROM Categories
   JOIN Products On Categories.CategoryID = Products.CategoryID
   JOIN OrderDetails on Products.ProductID = OrderDetails.ProductID     
   JOIN Orders on Orders.OrderID = OrderDetails.OrderID
WHERE Orders.ShippedDate BETWEEN '1997-01-01' And '1997-12-31'
GROUP BY Categories.CategoryName, Products.ProductName;

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
      
   CREATE VIEW CategorySalesFor1997
AS
SELECT
   ProductSalesFor1997.CategoryName,   -- Use `Product Sales for 1997` view
   Sum(ProductSalesFor1997.ProductSales) AS CategorySales
FROM ProductSalesFor1997
GROUP BY ProductSalesFor1997.CategoryName;

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

-- List the total amount for each order
CREATE VIEW OrderSubtotals 
AS
SELECT 
   OrderDetails.OrderID, 
   Sum(ROUND(OrderDetails.UnitPrice*Quantity*(1-Discount))) AS Subtotal
FROM OrderDetails
GROUP BY OrderDetails.OrderID;

CREATE VIEW SalesTotalsByAmount
AS
SELECT 
   OrderSubtotals.Subtotal AS SaleAmount,
   Orders.OrderID, 
   Customers.CompanyName, 
   Orders.ShippedDate
FROM Customers 
   JOIN Orders ON Customers.CustomerID = Orders.CustomerID
   JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID 
WHERE (OrderSubtotals.Subtotal > 2500) 
   AND (Orders.ShippedDate BETWEEN '1997-01-01' And '1997-12-31');
   
   CREATE VIEW SummaryOfSalesByQuarter
AS
SELECT 
   Orders.ShippedDate, 
   Orders.OrderID, 
   OrderSubtotals.Subtotal  -- Use `Order Subtotals` view
FROM Orders 
   INNER JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
WHERE Orders.ShippedDate IS NOT NULL;

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

-- Given an OrderID, print `Order Details`
CREATE OR REPLACE PROCEDURE CustOrdersDetail( AtOrderID IN NUMBER, cur OUT SYS_REFCURSOR)
IS
BEGIN
   OPEN cur FOR SELECT ProductName,
      OrderDetails.UnitPrice,
      Quantity,
      Discount * 100 AS Discount, 
      ROUND(Quantity * (1 - Discount) * OrderDetails.UnitPrice) AS ExtendedPrice
   FROM Products INNER JOIN OrderDetails USING (ProductID)
   WHERE OrderDetails.OrderID = AtOrderID;
END;

/
CREATE OR REPLACE PROCEDURE CustOrdersOrders( AtCustomerID IN VARCHAR2, cur OUT SYS_REFCURSOR)
IS
BEGIN
   OPEN cur FOR SELECT 
      OrderID,
      OrderDate,
      RequiredDate,
      ShippedDate
   FROM Orders
   WHERE CustomerID = AtCustomerID
   ORDER BY OrderID;
END;
/ 

CREATE OR REPLACE PROCEDURE CustOrderHist( AtCustomerID IN VARCHAR2, cur OUT SYS_REFCURSOR)
IS
BEGIN
   OPEN cur FOR SELECT
      ProductName,
      SUM(Quantity) as TOTAL
   FROM Products b,
      OrderDetails a,
      Orders c,
      Customers d
   WHERE d.CustomerID = AtCustomerID and a.ProductID=b.ProductID and c.OrderID=a.OrderID and d.CustomerID=c.CustomerID
   GROUP BY ProductName;
END;
/ 

CREATE OR REPLACE PROCEDURE TenMostExpensiveProducts (cur OUT SYS_REFCURSOR)
IS
BEGIN
   OPEN cur FOR SELECT * FROM (SELECT 
      Products.ProductName,
      Products.UnitPrice
   FROM Products
   ORDER BY Products.UnitPrice DESC) a
  WHERE rownum <= 10;
END;
/ 

CREATE OR REPLACE PROCEDURE EmployeeSalesByCountry( AtBeginning_Date IN DATE, AtEnding_Date IN DATE, cur OUT SYS_REFCURSOR)
IS
BEGIN
   OPEN cur FOR SELECT
      Employees.Country,
      Employees.LastName,
      Employees.FirstName,
      Orders.ShippedDate,
      Orders.OrderID,
      OrderSubtotals.Subtotal AS SaleAmount
   FROM Employees
      INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
      INNER JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
   WHERE Orders.ShippedDate BETWEEN AtBeginning_Date AND AtEnding_Date;
END;
/ 

CREATE OR REPLACE PROCEDURE SalesByYear( AtBeginning_Date IN DATE, AtEnding_Date IN DATE, cur OUT SYS_REFCURSOR)
IS
BEGIN
   OPEN cur FOR SELECT
      Orders.ShippedDate,
      Orders.OrderID,
      OrderSubtotals.Subtotal,
      ShippedDate AS Year
   FROM Orders 
      JOIN OrderSubtotals ON Orders.OrderID = OrderSubtotals.OrderID
   WHERE Orders.ShippedDate BETWEEN AtBeginning_Date AND AtEnding_Date;
END;
/ 


