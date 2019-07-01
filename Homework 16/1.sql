SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Исходное чудо)
SELECT ord.CustomerID, 
       det.StockItemID, 
       SUM(det.UnitPrice), 
       SUM(det.Quantity), 
       COUNT(ord.OrderID)
FROM Sales.Orders AS ord
     JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
     JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
     JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
     JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
      AND
(
    SELECT SupplierId
    FROM Warehouse.StockItems AS It
    WHERE It.StockItemID = det.StockItemID
) = 12
      AND
(
    SELECT SUM(Total.UnitPrice * Total.Quantity)
    FROM Sales.OrderLines AS Total
         JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    WHERE ordTotal.CustomerID = Inv.CustomerID
) > 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, 
         det.StockItemID
ORDER BY ord.CustomerID, 
         det.StockItemID;


-- Первое, что бросилось в глаза - очень жёсткие наименования, которые не понять совсем (по мне).
-- Переписываем названия.
SELECT o.CustomerID, 
       ol.StockItemID, 
       SUM(ol.UnitPrice), 
       SUM(ol.Quantity), 
       COUNT(o.OrderID)
FROM Sales.Orders o
     JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
     JOIN Sales.Invoices i ON i.OrderID = o.OrderID
     JOIN Sales.CustomerTransactions ct ON ct.InvoiceID = i.InvoiceID
     JOIN Warehouse.StockItemTransactions sit ON sit.StockItemID = ol.StockItemID
WHERE i.BillToCustomerID != o.CustomerID
      AND
(
    SELECT SupplierId
    FROM Warehouse.StockItems AS It
    WHERE It.StockItemID = ol.StockItemID
) = 12
      AND
(
    SELECT SUM(Total.UnitPrice * Total.Quantity)
    FROM Sales.OrderLines AS Total
         JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    WHERE ordTotal.CustomerID = i.CustomerID
) > 250000
AND DATEDIFF(dd, i.InvoiceDate, o.OrderDate) = 0
GROUP BY o.CustomerID, 
         ol.StockItemID
ORDER BY o.CustomerID, 
         ol.StockItemID;

-- Пока менял наименования на более читабельные, то обратил внимание на странное условие с DATEDIFF.
-- У нас две колонки с типом date, для чего мы вычисляем разницу в днях между ними, и если разницы нет, то всё ок..
-- Адекватнее будет написать строгое равенство.

SELECT o.CustomerID, 
       ol.StockItemID, 
       SUM(ol.UnitPrice), 
       SUM(ol.Quantity), 
       COUNT(o.OrderID)
FROM Sales.Orders o
     JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
     JOIN Sales.Invoices i ON i.OrderID = o.OrderID
     JOIN Sales.CustomerTransactions ct ON ct.InvoiceID = i.InvoiceID
     JOIN Warehouse.StockItemTransactions sit ON sit.StockItemID = ol.StockItemID
WHERE i.BillToCustomerID != o.CustomerID
      AND
(
    SELECT SupplierId
    FROM Warehouse.StockItems AS It
    WHERE It.StockItemID = ol.StockItemID
) = 12
      AND
(
    SELECT SUM(Total.UnitPrice * Total.Quantity)
    FROM Sales.OrderLines AS Total
         JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    WHERE ordTotal.CustomerID = i.CustomerID
) > 250000
AND i.InvoiceDate = o.OrderDate
GROUP BY o.CustomerID, 
         ol.StockItemID
ORDER BY o.CustomerID, 
         ol.StockItemID;

-- Далее решил проверить, а действительнонам нужны все join'ы? Не заметил использования CustomerTransactions и StockItemTransactions и убрал их.
-- так же добавил названия для полей, чтобы хоть понимать, что это.
-- Как я правильно понимаю запрос на текущий момент, то мы смотрим:
-- Какие заказчики заказывали товары определённого поставщика (12 Id)
-- Какой общий был объем и (ЗАЧЕМ-ТО) сумма по всем заказу на еденицу (?????) SUM(ol.UnitPrice) AS [TotalUnitPrice]
-- И, соответственно, сколько заказов всего по конкретному товару.
-- Фильтруем все заказы по тому, что счёт был выставлен в день заказа
-- и заказчиков, у которых сумма всех заказов больше 250.000 попугаев.

-- Ничего не понятно, но это нормально.
-- Заменяю подзапрос c поставщиком в WHERE на join + where
-- Попутно заменяю JOIN на INNER JOIN (я постоянно забываю, что JOIN это INNER JOIN).. Простите(
SELECT o.CustomerID, 
       ol.StockItemID, 
       SUM(ol.UnitPrice) AS [TotalUnitPrice], 
       SUM(ol.Quantity) AS [TotalQuantity], 
       COUNT(o.OrderID) AS [TotalOrdersCount]
FROM Sales.Orders o
     INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
     INNER JOIN Sales.Invoices i ON i.OrderID = o.OrderID
	 INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
WHERE i.BillToCustomerID != o.CustomerID
      AND si.SupplierID = 12
      AND
(
    SELECT SUM(Total.UnitPrice * Total.Quantity)
    FROM Sales.OrderLines AS Total
         JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    WHERE ordTotal.CustomerID = i.CustomerID
) > 250000
AND i.InvoiceDate = o.OrderDate
GROUP BY o.CustomerID, 
         ol.StockItemID
ORDER BY o.CustomerID, 
         ol.StockItemID;


-- Прирост, по скорости, уже в два раза, что не может не радовать) Значит движемся в нужном направлении.
-- думал о том, чтобы убрать подзапрос на having, но обратил внимание - там считается общий оборот, а у нас идёт группировка по Customerid + stockItemId :C не подойдёть

-- Быть может, переписать в CTE с уже выбранными для нас CustomerId и по ним производить выборку?
WITH BestCustomers AS (
	SELECT o.CustomerID FROM Sales.OrderLines ol
	INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
	GROUP BY o.CustomerID
	HAVING SUM(ol.UnitPrice * ol.Quantity) > 250000
)
SELECT o.CustomerID, 
       ol.StockItemID, 
       SUM(ol.UnitPrice) AS [TotalUnitPrice], 
       SUM(ol.Quantity) AS [TotalQuantity], 
       COUNT(o.OrderID) AS [TotalOrdersCount]
FROM Sales.Orders o
     INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
     INNER JOIN Sales.Invoices i ON i.OrderID = o.OrderID
	 INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
	 INNER JOIN BestCustomers bc ON o.CustomerID = bc.CustomerID
WHERE i.BillToCustomerID <> o.CustomerID
    AND si.SupplierID = 12
	AND i.InvoiceDate = o.OrderDate	
GROUP BY o.CustomerID, 
         ol.StockItemID
ORDER BY o.CustomerID, 
         ol.StockItemID;

-- Особого прироста не дало (разница в 3-10мс), но так, по мне, более читабельно, чем было ранее.
-- Смотря на план, понимаю, что Key Lookup в данном случае, не очень хорошая штука, учитывая то, что на invoices висят три предиката..
-- немного подумав и посмотрев на статистику IO подумал, а почему бы не начать выборку с самой таблицы Invoices, а к ней уже джойнить всё остальное? Надо пробовать.
WITH BestCustomers AS (
	SELECT o.CustomerID FROM Sales.OrderLines ol
	INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
	GROUP BY o.CustomerID
	HAVING SUM(ol.UnitPrice * ol.Quantity) > 250000
)
SELECT o.CustomerID, 
       ol.StockItemID, 
       SUM(ol.UnitPrice) AS [TotalUnitPrice], 
       SUM(ol.Quantity) AS [TotalQuantity], 
       COUNT(o.OrderID) AS [TotalOrdersCount]
FROM Sales.Invoices i
	 INNER JOIN Sales.Orders o ON i.OrderID = o.OrderID
     INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
	 INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
	 INNER JOIN BestCustomers bc ON o.CustomerID = bc.CustomerID
WHERE i.BillToCustomerID <> o.CustomerID
    AND si.SupplierID = 12
	AND i.InvoiceDate = o.OrderDate	
GROUP BY o.CustomerID, 
         ol.StockItemID
ORDER BY o.CustomerID, 
         ol.StockItemID;

-- Уже лучше :) примерно на 40-50мс упало время по CPU
-- Больше не особо придумал, как можно это всё улучшить :( В целом, я добился хороших результатов, но не идеал, я уверен)

-- Время тестов! Нужно сравнить то, что было и что стало сейчас. Возможно, я сделал хуже?)
-- Очень большой СОРЯН за русский Management Studio (я сам очумел, когда увидел)
-- Планы так же прилагаю :)






--Было:
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.

--(3619 rows affected)
--Таблица "StockItemTransactions". Число просмотров 1, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 29, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItemTransactions". Считано сегментов 1, пропущено 0.
--Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 2, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "CustomerTransactions". Число просмотров 5, логических чтений 261, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 1, логических чтений 44525, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 375 мс, затраченное время = 435 мс.




--Стало:
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.

--(3619 rows affected)
--Таблица "OrderLines". Число просмотров 4, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 331, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 2, пропущено 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 52, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 11767, логических чтений 61156, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Orders". Число просмотров 2, логических чтений 883, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "StockItems". Число просмотров 1, логических чтений 2, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 109 мс, затраченное время = 153 мс.

