--2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
SELECT *
FROM
(
    SELECT subq.StockItemName, 
           subq.TotalQuantity, 
           subq.MonthNumber, 
           ROW_NUMBER() OVER(PARTITION BY subq.MonthNumber ORDER BY subq.TotalQuantity DESC) AS [Num]
    FROM
    (
        SELECT si.StockItemName, 
               SUM(il.Quantity) AS [TotalQuantity], 
               DATEPART(MONTH, i.InvoiceDate) AS [MonthNumber]
        FROM Sales.InvoiceLines il
             INNER JOIN [Sales].[Invoices] i ON il.InvoiceID = i.InvoiceID 
             INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
		WHERE DATEPART(YEAR, i.InvoiceDate) = 2016
        GROUP BY si.StockItemName, DATEPART(MONTH, i.InvoiceDate)
    ) AS subq
) AS subq2
WHERE subq2.Num <= 2
ORDER BY subq2.MonthNumber,  subq2.TotalQuantity DESC;