-- 1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
SELECT CAST(YEAR(i.InvoiceDate) AS VARCHAR(4)) + '-' + CAST(MONTH(i.InvoiceDate) AS VARCHAR(2)) AS [MonthNumber]
	, AVG(il.UnitPrice) AS [AVGPrice]
	, SUM(il.UnitPrice * il.Quantity) AS [Total]
FROM Sales.InvoiceLines il
INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);