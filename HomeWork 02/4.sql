-- Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, 
-- добавьте название поставщика, имя контактного лица принимавшего заказ

SELECT S.SupplierName AS [Supplier], P.FullName AS [Employee]
FROM Purchasing.PurchaseOrders AS PO
INNER JOIN Application.DeliveryMethods AS DM ON PO.DeliveryMethodID = DM.DeliveryMethodID
INNER JOIN Purchasing.Suppliers AS S ON S.SupplierID = PO.SupplierID
INNER JOIN Application.People AS P ON P.PersonID = PO.ContactPersonID
INNER JOIN Purchasing.SupplierTransactions AS ST ON ST.PurchaseOrderID = PO.PurchaseOrderID
WHERE (DM.DeliveryMethodName = 'Road Freight' OR DM.DeliveryMethodName = 'Post')
	AND DATEPART(YEAR, ST.FinalizationDate) = 2014