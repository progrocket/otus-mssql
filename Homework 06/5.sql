-- 5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
-- В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
SELECT c.CustomerID, 
       c.CustomerName, 
       subq.StockItemID, 
       subq.StockItemName, 
       subq.UnitPrice, 
       subq.InvoiceDate
FROM
(
    SELECT i.CustomerID, 
           il.StockItemID, 
           si.StockItemName, 
           si.UnitPrice, 
           i.InvoiceDate, 
           ROW_NUMBER() OVER(PARTITION BY i.CustomerID ORDER BY si.UnitPrice DESC) AS [Num]
    FROM Sales.InvoiceLines il
         INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
         INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
) AS subq
INNER JOIN Sales.Customers c ON subq.CustomerID = c.CustomerID
WHERE subq.Num <= 2;