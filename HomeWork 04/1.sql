--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

-- Subquery
SELECT ap.PersonID, 
       ap.FullName
FROM [Application].People ap
WHERE ap.IsSalesperson = 1
      AND NOT EXISTS
(
    SELECT 1
    FROM Sales.Invoices si
    WHERE si.SalespersonPersonID = ap.PersonID
);

-- CTE
WITH SalesPersons AS (
	SELECT DISTINCT si.SalespersonPersonID 
	FROM Sales.Invoices si
)
SELECT ap.PersonID, 
       ap.FullName
FROM Application.People ap
LEFT JOIN SalesPersons sp ON ap.PersonID = sp.SalespersonPersonID
WHERE ap.IsSalesperson = 1 AND sp.SalespersonPersonID IS NULL;