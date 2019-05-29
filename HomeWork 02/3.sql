-- Продажи с названием месяца, в котором была продажа, номером квартала, 
--к которому относится продажа, включите также к какой трети года относится дата - каждая треть по 4 месяца, 
-- дата забора заказа должна быть задана, с ценой товара более 100$ либо количество единиц товара более 20.  
SELECT FORMAT(O.OrderDate, 'MMMM', 'RU-ru') AS [Месяц]
	, DATEPART(QUARTER, O.OrderDate) AS [Квартал]
	, CEILING(CONVERT(INT, DATEPART(M, O.OrderDate)) / 4) AS [Треть]
	, COALESCE(OL.UnitPrice, SI.UnitPrice) AS [Цена]
	, OL.Quantity AS [Количество]
FROM Sales.Orders AS O
INNER JOIN Sales.OrderLines AS OL ON OL.OrderID=O.OrderID
INNER JOIN Warehouse.StockItems AS SI ON SI.StockItemID=OL.StockItemID
WHERE O.PickingCompletedWhen IS NOT NULL AND (COALESCE(OL.UnitPrice, SI.UnitPrice) > 100 OR OL.Quantity > 20)

-- Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей. 
-- Соритровка должна быть по номеру квартала, трети года, дате продажи.
SELECT FORMAT(O.OrderDate, 'MMMM', 'en-US') AS [Month]
	, DATEPART(QUARTER, O.OrderDate) AS [Quarter]
	, CEILING(CONVERT(INT, DATEPART(M, O.OrderDate)) / 4) AS [1/3 Year]
	, COALESCE(OL.UnitPrice, SI.UnitPrice) AS [Price]
	, OL.Quantity AS [Count]
FROM Sales.Orders AS O
INNER JOIN Sales.OrderLines AS OL ON OL.OrderID = O.OrderID
INNER JOIN Warehouse.StockItems AS SI ON SI.StockItemID = OL.StockItemID
WHERE O.PickingCompletedWhen IS NOT NULL
	AND (COALESCE(OL.UnitPrice, SI.UnitPrice) > 100 OR OL.Quantity > 20)
ORDER BY [Quarter], [1/3 Year], O.OrderDate 
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY