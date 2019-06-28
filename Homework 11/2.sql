--Написать хранимую процедуру с входящим параметром
--СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

CREATE PROCEDURE Sales.GetCustomerTotalPurchaseAmount 
                @CustomerID INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT @CustomerId AS [CustomerId], 
        (
            SELECT SUM(il.Quantity * il.UnitPrice)
            FROM Sales.InvoiceLines il
                INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
            WHERE i.CustomerID = @CustomerID
        ) AS [TotalAmount];
    END;
GO