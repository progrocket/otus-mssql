-- 1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
SELECT MONTH(i.InvoiceDate) AS [MonthNumber]
	, AVG(il.UnitPrice) AS [AVGPrice]
	, SUM(il.UnitPrice * il.Quantity) AS [Total]
FROM Sales.InvoiceLines il
INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
GROUP BY MONTH(i.InvoiceDate)
ORDER BY MONTH(i.InvoiceDate);