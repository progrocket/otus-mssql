-- 3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц. 
SELECT MONTH(i.InvoiceDate) AS [MonthNumber], 
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
GROUP BY ROLLUP(MONTH(i.InvoiceDate), il.StockItemID)
HAVING(SUM(il.Quantity) < 50)
      OR (GROUPING(MONTH(i.InvoiceDate)) = 1
          OR GROUPING(il.StockItemID) = 1)
ORDER BY [MonthNumber], il.StockItemID;