-- 2. Отобразить все месяцы, где общая сумма продаж превысила 10 000 
SELECT CAST(YEAR(i.InvoiceDate) AS VARCHAR(4)) + '-' + CAST(MONTH(i.InvoiceDate) AS VARCHAR(2)) AS [MonthNumber]
FROM Sales.InvoiceLines il
     INNER JOIN Sales.Invoices i ON i.InvoiceID = il.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.Quantity * il.UnitPrice) > 10000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);