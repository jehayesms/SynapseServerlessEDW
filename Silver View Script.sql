CREATE VIEW Silver.Calendar as 
With dates(date) as (
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, '2013-01-01')
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, '2013-01-01', '2025-12-31')) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    -- on my system this would support > 5 million days
    ORDER BY s1.[object_id]
  ) AS x
) AS y)
select
 date,
 day(date) as daynum,
 DATEPART(dw,date) dayofweeknum,
 DATENAME(dw,date) dayofweekname,
 MONTH(date) as monthnum,
 DATENAME(Month,date) as monthname,
 DATEPART(QUARTER,date) as quarternum,
 'Q' +  ltrim(DATEPART(QUARTER,date)) as quartername,
 year(date) as year
 from dates

 GO

 CREATE View Silver.OpenOrders as 
select CustomerID
,SalesPersonPersonID
,ContactPersonID
,StockItemID
,PackageTypeID
,Cast(OrderDate as Date) as OrderDate
,Quantity 
,Quantity * UnitPrice as ExtendedPrice
,DATEDIFF(DD,Cast(OrderDate as Date),Cast(getdate() as Date)) as DaysOpen
from Bronze.OrderLines ol
inner join Bronze.Orders o on ol.OrderID = o.OrderID
where ol.PickingCompletedWhen is  null and o.PickingCompletedWhen is NULL

GO

Create View [Silver].[PickedOrders] as 
select   CustomerID
,SalesPersonPersonID
,ContactPersonID
,StockItemID
,PackageTypeID
,Cast(OrderDate as Date) as OrderDate
,Cast(ol.PickingCompletedWhen as Date) as PickedDate
,PickedQuantity 
,PickedQuantity * UnitPrice as ExtendedPrice
,(PickedQuantity * UnitPrice) * (TaxRate/100) as SalesTaxAmt
,(PickedQuantity * UnitPrice) + ((PickedQuantity * UnitPrice) * (TaxRate/100)) TotalSalesAmt
,DATEDIFF(DD,Cast(OrderDate as Date),Cast(ol.PickingCompletedWhen as Date)) as DaysToPick
from Bronze.OrderLines ol
inner join Bronze.Orders o on ol.OrderID = o.OrderID
where ol.PickingCompletedWhen is not null

GO

Create View Silver.Salesperson as 
select 
PersonID
,FullName
,JSON_VALUE(CustomFields,'$.Title') AS Title
,JSON_VALUE(CustomFields,'$.PrimarySalesTerritory') AS SalesTerritory
,EmailAddress
from Bronze.People
where IsSalesperson=1

GO
Create View Silver.Customers as
SELECT  C.[CustomerID]
,C.[CustomerName]
,C.[BillToCustomerID]
,B.[CustomerName] as BillToCustomerName
--,C.[CustomerCategoryID]
,CC.[CustomerCategoryName]
--,C.[BuyingGroupID]
,BG.[BuyingGroupName]
,C.[PostalAddressLine1]
,C.[PostalAddressLine2]
,C.[PostalPostalCode]
,C.[WebsiteURL]
,C.[DeliveryAddressLine1]
,C.[DeliveryAddressLine2]
,C.[DeliveryPostalCode]
,C.[StandardDiscountPercentage]
,C.[IsStatementSent]
,C.[IsOnCreditHold]
,C.[PaymentDays]
,SUBSTRING(C.[PhoneNumber],2,3) as AreaCode
--,C.[DeliveryMethodID]
,DM.[DeliveryMethodName]
,C.[CreditLimit]
,C.[AccountOpenedDate]

-- Ship To Columns
,DC.CityName as ShipToCity
,DSP.StateProvinceCode as ShipToStateProvinceCode
,DSP.StateProvinceName as ShipToStateProvinceName
,DCO.CountryName as ShipToCountryName
,DCO.IsoAlpha3Code as ShipToCountryCode
,DSP.SalesTerritory
,DCO.Continent
,DCO.Region
,DCO.Subregion

-- Postal Columns
,PC.CityName as PostalCity
,PSP.StateProvinceCode as PostalStateProvinceCode
,PSP.StateProvinceName as PostalStateProvinceName
,PCO.CountryName as PostalCountryName 
,PCO.IsoAlpha3Code as PostalCountryCode
 FROM [Bronze].[Customers] as C
 INNER JOIN [Bronze].[Customers]  B on C.BillToCustomerID = B.CustomerID
 INNER JOIN Bronze.CustomerCategories  CC on C.CustomerCategoryID = CC.CustomerCategoryID
 INNER JOIN Bronze.BuyingGroups  BG on C.BuyingGroupID = BG.BuyingGroupID
 INNER JOIN Bronze.DeliveryMethods  DM on C.DeliveryMethodID = DM. DeliveryMethodID
 -- Ship To Joins
 INNER JOIN Bronze.Cities DC on C.[DeliveryCityID] = DC.CityID
 INNER JOIN Bronze.StateProvinces DSP on DC.[StateProvinceID] = DSP.StateProvinceID
 INNER JOIN Bronze.Countries DCO on DSP.CountryID = DCO.CountryID
 -- Postal Joins
 INNER JOIN Bronze.Cities PC on C.[PostalCityID] = PC.CityID
 INNER JOIN Bronze.StateProvinces PSP on PC.[StateProvinceID] = PSP.StateProvinceID
 INNER JOIN Bronze.Countries PCO on PSP.CountryID = PCO.CountryID
 

GO

Create View Silver.StockItemGroups as
SELECT  SISG.StockItemID,
SG.StockGroupName
From Bronze.StockItemStockGroups SISG
INNER JOIN Bronze.StockGroups SG on SG.StockGroupID = SISG.StockGroupID 

GO

Create View Silver.StockItems as
SELECT  SI_A.StockItemID,
SI_A.StockItemName,
--SG.StockGroupName,
S.SupplierID,
S.SupplierName,
SC.SupplierCategoryID,
SC.SupplierCategoryName,
C.ColorID,
SI_A.UnitPackageID as [Selling Package],
SP_A.PackageTypeName,
SI_A.OuterPackageID as [Buying Package],
SI_A.Brand,
SI_A.Size,
SI_A.LeadTimeDays,
SI_A.QuantityPerOuter,
SI_A.IsChillerStock,
SI_A.Barcode,
SI_A.TaxRate,
SI_A.UnitPrice,
SI_A.RecommendedRetailPrice,
SI_A.TypicalWeightPerUnit,
SI_A.MarketingComments,
SI_A.InternalComments,
SI_A.Photo, 
SI_A.CustomFields,
SI_A.Tags,
SI_A.SearchDetails,
SI_A.LastEditedBy,
SI_A.ValidFrom,
SI_A.ValidTo
From Bronze.StockItems as SI_A
INNER JOIN Bronze.Suppliers S ON SI_A.SupplierID = S.SupplierID
INNER JOIN Bronze.Colors C on SI_A.ColorID = C.ColorID
INNER JOIN Bronze.PackageTypes SP_A on SP_A.PackageTypeID = SI_A.UnitPackageID
INNER JOIN Bronze.SupplierCategories SC on S.SupplierCategoryID = SC.SupplierCategoryID

GO
Create View Silver.Invoices as 
SELECT CustomerID
,BillToCustomerID
,SalesPersonPersonID
,StockItemID
,CAST(InvoiceDate as Date) as InvoiceDate
,Quantity as InvoiceQuantity
,ExtendedPrice
,TaxAmount
,LineProfit
From Bronze.Invoices i
inner JOIN Bronze.InvoiceLines il 
on i.InvoiceID = il.InvoiceID



