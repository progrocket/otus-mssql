-- Выберите города (ид и название), в которые были доставлены товары, 
-- входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов

SELECT c2.CityID, c2.CityName, p.FullName
FROM Sales.OrderLines ol
     INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
     INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
     INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
     INNER JOIN Application.Cities c2 ON c.DeliveryCityID = c2.CityID
     INNER JOIN Application.People p ON i.PackedByPersonID = p.PersonID
WHERE ol.StockItemID IN
(
    SELECT TOP 3 si.StockItemID
    FROM Warehouse.StockItems si
    ORDER BY si.UnitPrice DESC
);


WITH TopProducts AS (
	SELECT TOP 3 si.StockItemID
    FROM Warehouse.StockItems si
    ORDER BY si.UnitPrice DESC
)
SELECT c2.CityID, c2.CityName, p.FullName
FROM Sales.OrderLines ol
     INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
     INNER JOIN Sales.Invoices i ON o.OrderID = i.OrderID
     INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
     INNER JOIN Application.Cities c2 ON c.DeliveryCityID = c2.CityID
     INNER JOIN Application.People p ON i.PackedByPersonID = p.PersonID
WHERE ol.StockItemID IN (SELECT tp.StockItemID FROM TopProducts tp)