--  Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
SELECT DISTINCT C.CustomerID AS [ClientId], C.CustomerName AS [ClientName], C.PhoneNumber
FROM Warehouse.StockItems AS I
INNER JOIN Sales.OrderLines AS OL ON OL.StockItemID = I.StockItemID
INNER JOIN Sales.Orders AS O ON O.OrderID = OL.OrderID
INNER JOIN Sales.Customers AS C ON C.CustomerID = O.CustomerID
WHERE I.StockItemName='Chocolate frogs 250g'