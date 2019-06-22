-- Выберите информацию по клиентам, которые перевели компании 
-- 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)

SELECT c.*
FROM Sales.Customers c
     INNER JOIN Sales.CustomerTransactions ct ON c.CustomerID = ct.CustomerID
WHERE ct.TransactionAmount IN
(
    SELECT DISTINCT TOP 5 ct2.TransactionAmount
    FROM Sales.CustomerTransactions ct2
    ORDER BY ct2.TransactionAmount DESC
);


SELECT  *
FROM    (
	SELECT c.CustomerID, ct.TransactionAmount, ROW_NUMBER() OVER (ORDER BY ct.TransactionAmount DESC) AS [RowNumber]
	FROM Sales.Customers c
	INNER JOIN Sales.CustomerTransactions ct ON c.CustomerID = ct.CustomerID
) subquery
WHERE subquery.RowNumber <= 5;


WITH NumberedTransactions AS (
	SELECT c.CustomerID, ct.TransactionAmount, ROW_NUMBER() OVER (ORDER BY ct.TransactionAmount DESC) AS [RowNumber]
	FROM Sales.Customers c
	INNER JOIN Sales.CustomerTransactions ct ON c.CustomerID = ct.CustomerID
)
SELECT * FROM NumberedTransactions nt WHERE nt.RowNumber <= 5;