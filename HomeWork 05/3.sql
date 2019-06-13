-- 3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц. 
SELECT CAST(YEAR(i.InvoiceDate) AS VARCHAR(4)) + '-' + CAST(MONTH(i.InvoiceDate) AS VARCHAR(2)) AS [MonthNumber], 
       il.StockItemID AS [StockItemId], 
       SUM(il.Quantity * il.UnitPrice) AS [Total], 
       MIN(i.InvoiceDate) AS [FistSale], 
       SUM(il.Quantity) AS [Quantity],
       CASE
           WHEN GROUPING(MONTH(i.InvoiceDate)) = 1 THEN 'Overall'
           WHEN GROUPING(il.StockItemID) = 1 THEN 'In month'
           ELSE 'Item in month'
       END AS [Note]
FROM Sales.InvoiceLines il
     INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
GROUP BY ROLLUP(YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), il.StockItemID)
HAVING SUM(il.Quantity) < 50
ORDER BY [MonthNumber], il.StockItemID;