use tst
DECLARE @sql NVARCHAR(MAX);
SET @sql = N' ';

SELECT @sql = @sql + N'
  ALTER TABLE ' + QUOTENAME(s.name) + N'.'
  + QUOTENAME(t.name) + N' DROP CONSTRAINT '
  + QUOTENAME(c.name) + ';'
FROM sys.objects AS c
INNER JOIN sys.tables AS t
ON c.parent_object_id = t.[object_id]
INNER JOIN sys.schemas AS s 
ON t.[schema_id] = s.[schema_id]
WHERE c.[type] IN ('F')
ORDER BY c.[type];

PRINT @sql;

ALTER TABLE [dbo].[Employees] DROP CONSTRAINT [FK__Employees__Repor__3A81B327];
ALTER TABLE [dbo].[Territories] DROP CONSTRAINT [FK__Territori__Regio__412EB0B6];
ALTER TABLE [dbo].[EmployeeTerritories] DROP CONSTRAINT [FK__EmployeeT__Emplo__44FF419A];
ALTER TABLE [dbo].[EmployeeTerritories] DROP CONSTRAINT [FK__EmployeeT__Terri__45F365D3];
ALTER TABLE [dbo].[Products] DROP CONSTRAINT [FK__Products__Catego__59FA5E80];
ALTER TABLE [dbo].[Products] DROP CONSTRAINT [FK__Products__Suppli__5AEE82B9];
ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [FK__Orders__Customer__656C112C];
ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [FK__Orders__Employee__66603565];
ALTER TABLE [dbo].[Orders] DROP CONSTRAINT [FK__Orders__ShipVia__6754599E];
ALTER TABLE [dbo].[OrderDetails] DROP CONSTRAINT [FK__OrderDeta__Order__70DDC3D8];
ALTER TABLE [dbo].[OrderDetails] DROP CONSTRAINT [FK__OrderDeta__Produ__71D1E811];
ALTER TABLE [dbo].[CustomerCustomerDemo] DROP CONSTRAINT [FK__CustomerC__Custo__76969D2E];
ALTER TABLE [dbo].[CustomerCustomerDemo] DROP CONSTRAINT [FK__CustomerC__Custo__778AC167]; 

select * from orders;