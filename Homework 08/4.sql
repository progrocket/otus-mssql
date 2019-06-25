SELECT c.CustomerID, 
	c.CustomerName, 
	TopProducts.StockItemID, 
	TopProducts.StockItemName, 
	TopProducts.UnitPrice, 
(
	SELECT STRING_AGG(I1.InvoiceDate, ', ') WITHIN GROUP (ORDER BY I1.InvoiceDate) 
	FROM Sales.InvoiceLines AS IL1
	INNER JOIN Sales.Invoices AS I1 ON I1.InvoiceID=IL1.InvoiceLineID
	WHERE IL1.StockItemID=TopProducts.StockItemID AND I1.CustomerID=c.CustomerID
) [Date]
FROM  Sales.Customers c
CROSS APPLY 
(
	SELECT DISTINCT TOP 2 
		il.StockItemID, 
		wsi.StockItemName, 
		wsi.UnitPrice
	FROM Sales.InvoiceLines il
	INNER JOIN Sales.Invoices i
		ON i.InvoiceID=il.InvoiceLineID
	INNER JOIN Warehouse.StockItems wsi
		ON il.StockItemID=wsi.StockItemID
	WHERE i.CustomerID=c.CustomerID
	ORDER BY wsi.UnitPrice DESC
) AS TopProducts