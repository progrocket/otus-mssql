-- Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
SELECT PS.*
FROM Purchasing.Suppliers AS PS
LEFT JOIN Purchasing.PurchaseOrders AS PPO ON PS.SupplierID=PPO.SupplierID
WHERE PPO.PurchaseOrderID IS NULL
