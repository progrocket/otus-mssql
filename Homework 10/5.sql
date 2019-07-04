-- 5. Пишем динамический PIVOT.
-- По заданию из 8го занятия про CROSS APPLY и PIVOT
-- Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
-- Название клиента
-- МесяцГод Количество покупок

-- Нужно написать запрос, который будет генерировать результаты для всех клиентов
-- имя клиента указывать полностью из CustomerName
-- дата должна иметь формат dd.mm.yyyy например 25.12.2019 

DECLARE @CustomerNames NVARCHAR(MAX);
SET @CustomerNames =
(
    SELECT
			'[' + c.CustomerName + ']' + ',' as 'data()'
	FROM
		(
			SELECT DISTINCT CustomerName
			FROM [Sales].[Customers] c
		) c
	FOR XML PATH ('')
);

IF @CustomerNames IS NOT NULL
BEGIN
	SET @CustomerNames = LEFT(@CustomerNames, LEN(@CustomerNames) - 1);
END

--PRINT @CustomerNames

--SET @CustomerNames = '[Tailspin Toys (Head Office)]';

DECLARE @PivotSQL NVARCHAR(MAX) = 'SELECT 
    InvoiceMonth, ' + @CustomerNames + '
FROM
    (
    SELECT 
        Dates.InvoiceMonth, 
        c.CustomerName, 
        I.InvoiceID
    FROM Sales.Customers AS C
    INNER JOIN Sales.Invoices AS I
        ON I.CustomerID = C.CustomerID
    CROSS APPLY
        (
            SELECT 
            InvoiceMonth = FORMAT(DATEADD(MM, DATEDIFF(MM, 0, I.InvoiceDate), 0), ''dd.MM.yyyy'')
        ) AS Dates
    ) AS D PIVOT(COUNT(D.[InvoiceID]) FOR D.CustomerName IN(' + @CustomerNames + ')) AS P
ORDER BY 
    CAST(P.InvoiceMonth AS DATE);'

--PRINT @PivotSQL;
EXECUTE sp_executesql @PivotSQL;