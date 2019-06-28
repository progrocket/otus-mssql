-- 3) Cоздать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему


-- К примеру, создадим такую же функцию, как и в 2 задании.
CREATE FUNCTION Sales.GetCustomerTotalPurchaseAmountFunction
					(@CustomerId INT)
RETURNS MONEY
AS
    BEGIN
        RETURN
        (
            SELECT SUM(il.Quantity * il.UnitPrice)
            FROM Sales.InvoiceLines il
                INNER JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
            WHERE i.CustomerID = @CustomerID
        );
    END;
GO

-- По сути, вызов хранимки и функции у меня не отличается, занимает примерное одинакое количество времени