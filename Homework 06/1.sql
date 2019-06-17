-- 1.Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
-- Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

-- Сделать 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;

SET STATISTICS TIME ON;

-- First version
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 47 мс, истекшее время = 56 мс.

-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.

--(71898 rows affected)

SELECT
	i.InvoiceID AS [InvoiceId]
	, c.CustomerName AS [CustomerName]
	, i.InvoiceDate AS [InvoiceDate]
	, SUM(il.Quantity * il.UnitPrice) OVER (PARTITION BY i.InvoiceID) [OrderSum]
	, SUM(il.Quantity * il.UnitPrice) OVER (ORDER BY DATEPART(YEAR, i.InvoiceDate), DATEPART(MONTH, i.InvoiceDate)) [CumulativeTotal]
FROM Sales.Invoices i
INNER JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
INNER JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
WHERE i.InvoiceDate >= '20150101' AND i.InvoiceDate < '20160101'
ORDER BY i.InvoiceDate, i.CUstomerID;


-- Second version
-- Время работы SQL Server:
--   Время ЦП = 171 мс, затраченное время = 489 мс.

--(71898 rows affected)

-- Время работы SQL Server:
--   Время ЦП = 17219 мс, затраченное время = 17569 мс.
SELECT i.InvoiceID, 
    c.CustomerName, 
    i.InvoiceDate, 
(
    SELECT SUM(il.Quantity * il.UnitPrice)
    FROM Sales.InvoiceLines AS il
    WHERE il.InvoiceID = i.InvoiceID
) AS [OrderSum], 
(
    SELECT SUM(il2.Quantity * il2.UnitPrice)
    FROM Sales.InvoiceLines AS il2
        INNER JOIN Sales.Invoices AS i2 ON il2.InvoiceID = i2.InvoiceID
    WHERE i2.InvoiceDate <= EOMONTH(i.InvoiceDate)
        AND i2.InvoiceDate >= '20150101' AND i2.InvoiceDate < '20160101'
) [CumulativeTotal]
FROM Sales.Invoices AS i
    INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
    INNER JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
WHERE InvoiceDate >= '20150101' AND i.InvoiceDate < '20160101'
ORDER BY i.InvoiceDate, i.CUstomerID;