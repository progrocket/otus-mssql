--2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
WITH ProductMonthSales
AS (
    SELECT si.StockItemName, 
        SUM(il.Quantity) AS [TotalQuantity], 
        MONTH(i.InvoiceDate) AS [MonthNumber]
    FROM Sales.InvoiceLines il
        INNER JOIN [Sales].[Invoices] i ON il.InvoiceID = i.InvoiceID 
        INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
	WHERE YEAR(i.InvoiceDate) = 2016
    GROUP BY si.StockItemName, MONTH(i.InvoiceDate)
),
ProductSalesNumbered
AS (
    SELECT ProductMonthSales.StockItemName, 
        ProductMonthSales.TotalQuantity, 
        ProductMonthSales.MonthNumber, 
        ROW_NUMBER() OVER(PARTITION BY ProductMonthSales.MonthNumber ORDER BY ProductMonthSales.TotalQuantity DESC) AS [Num]
    FROM ProductMonthSales
)
SELECT psm.StockItemName, psm.TotalQuantity
FROM ProductSalesNumbered psm
WHERE psm.Num <= 2
ORDER BY psm.MonthNumber, psm.TotalQuantity DESC;