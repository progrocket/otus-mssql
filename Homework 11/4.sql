-- Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
-- Во всех процедурах, в описании укажите для преподавателям

-- что именно в описании указать - не понятно...

-- Три последних собранных заказа работником.
ALTER FUNCTION Sales.GetPackedInvoicesByPersonId(@PersonId INT)
RETURNS TABLE
AS
	RETURN(	
		SELECT TOP 3 i.InvoiceID
		FROM Sales.Invoices i
		WHERE i.PackedByPersonID = @PersonId
		-- Мб я слепой, но не нашёл packed date
		ORDER BY i.InvoiceID, i.InvoiceDate DESC
	);
GO

-- Не знаю зачем, но пусть будет.
-- Последние 3 собранных заказа по сотрудникам.
SELECT p.PersonID, p.FullName, TopInvoices.InvoiceId
FROM Application.People p
CROSS APPLY (
	SELECT ti.InvoiceId
	FROM Sales.GetPackedInvoicesByPersonId(p.PersonId) ti
) AS TopInvoices
WHERE p.IsEmployee = 1