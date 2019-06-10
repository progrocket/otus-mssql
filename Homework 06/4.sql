-- 4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
-- В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
SELECT p.PersonID, 
       p.FullName, 
       c.CustomerID, 
       c.CustomerName, 
       r.TransactionDate, 
       r.TransactionAmount
FROM
(
    SELECT ct.CustomerID, 
           i.SalespersonPersonID, 
           ct.TransactionDate, 
           ct.TransactionAmount, 
           ROW_NUMBER() OVER(PARTITION BY SalespersonPersonID ORDER BY TransactionDate DESC) AS [Num]
    FROM Sales.CustomerTransactions ct
         INNER JOIN Sales.Invoices i ON ct.InvoiceID = i.InvoiceID
) AS r
INNER JOIN Application.People p ON r.SalespersonPersonID = p.PersonID
INNER JOIN Sales.Customers c ON r.CustomerID = c.CustomerID
WHERE r.[num] = 1;