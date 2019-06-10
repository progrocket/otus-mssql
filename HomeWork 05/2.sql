-- 2. Отобразить все месяцы, где общая сумма продаж превысила 10 000 
SELECT MONTH(i.InvoiceDate)
FROM Sales.InvoiceLines il
     INNER JOIN Sales.Invoices i ON i.InvoiceID = il.InvoiceID
GROUP BY MONTH(i.InvoiceDate)
HAVING SUM(il.Quantity * il.UnitPrice) > 10000
ORDER BY MONTH(i.InvoiceDate);