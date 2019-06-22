--Оптимизация запроса.
SELECT Invoices.InvoiceID, 
       Invoices.InvoiceDate, 
(
    SELECT People.FullName
    FROM Application.People
    WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName, 
       SalesTotals.TotalSumm AS TotalSummByInvoice, 
(
    SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
    FROM Sales.OrderLines
    WHERE OrderLines.OrderId =
    (
        SELECT Orders.OrderId
        FROM Sales.Orders
        WHERE Orders.PickingCompletedWhen IS NOT NULL
              AND Orders.OrderId = Invoices.OrderId
    )
) AS TotalSummForPickedItems
FROM Sales.Invoices
     JOIN
(
    SELECT InvoiceId, 
           SUM(Quantity * UnitPrice) AS TotalSumm
    FROM Sales.InvoiceLines
    GROUP BY InvoiceId
    HAVING SUM(Quantity * UnitPrice) > 27000
) AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

--В моём понимании запрос выбирает счета, стоимость которых выше 27к и 
--получает данные из таблицы Orders (если заказ получен). Так же получает менеджера продажи (SalesPersonName?)
--По всей видимости, стоимость в счёте и стоимость при получении может быть разной, но эт не точно..

-- Просто улучшать запрос не очень бы хотелось, для меня проще переписать.

-- Заготовка.
SELECT * FROM Sales.Invoices i
INNER JOIN Application.People p ON i.SalespersonPersonID = p.PersonID;

-- SalesTotals можно вынести как CTE, что увеличит читабельность.
-- Непонятная мистика в TotalSummForPickedItems так же заменяется на CTE.
-- Остаётся поправить выборку (только необходимые поля) и добавить FullName продавана.
WITH LineTotal
     AS (SELECT il.InvoiceID, 
                SUM(il.Quantity * il.UnitPrice) AS [TotalSumm]
         FROM Sales.InvoiceLines il
         GROUP BY il.InvoiceID
         HAVING SUM(il.Quantity * il.UnitPrice) > 27000),
     OrderTotal
     AS (SELECT o.OrderID, 
                SUM(ol.PickedQuantity * ol.UnitPrice) AS [TotalSummForPickedItems]
         FROM Sales.Orders o
              INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
         WHERE o.PickingCompletedWhen IS NOT NULL
         GROUP BY o.OrderID)
     SELECT i.InvoiceID, 
            i.InvoiceDate, 
            p.FullName AS [SalesPersonName], 
            lt.TotalSumm AS [TotalSummByInvoice], 
            ot.TotalSummForPickedItems
     FROM Sales.Invoices i
          INNER JOIN LineTotal lt ON i.InvoiceID = lt.InvoiceID
          LEFT JOIN OrderTotal ot ON ot.OrderID = i.OrderID
          INNER JOIN Application.People p ON i.SalespersonPersonID = p.PersonID
     ORDER BY lt.TotalSumm DESC;