--  Написать функцию возвращающую Клиента с набольшей
-- суммой покупки.

-- О да, я умею называть функции.
CREATE FUNCTION Sales.GetHighestPurchaseCustomerId()
RETURNS INT
AS
    BEGIN
        DECLARE @CustometID INT;
        WITH OrderAmount
            AS (SELECT il.InvoiceID, 
                         SUM(il.Quantity * ISNULL(il.UnitPrice, si.UnitPrice)) AS Amount
                FROM Sales.InvoiceLines il
                    INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
                GROUP BY il.InvoiceID)
            SELECT TOP 1 @CustometID = c.CustomerID
            FROM Sales.Invoices i
                INNER JOIN OrderAmount oa ON i.InvoiceID = oa.InvoiceID
                INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
            ORDER BY oa.Amount DESC;
        RETURN @CustometID;
    END;
GO