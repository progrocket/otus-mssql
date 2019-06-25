SELECT 
    InvoiceMonth, 
    [Sylvanite, MT], 
    [Peeples Valley, AZ], 
    [Medicine Lodge, KS], 
    [Gasport, NY], 
    [Jessie, ND]
FROM
    (
     SELECT 
         Dates.InvoiceMonth, 
         SName.SpecName, 
         I.InvoiceID
     FROM Sales.Customers AS C
     INNER JOIN Sales.Invoices AS I
          ON I.CustomerID = C.CustomerID
     CROSS APPLY
         (
          SELECT 
              FirstBracketPos = CHARINDEX('(', C.CustomerName)
          ) AS FBP
     CROSS APPLY
         (
          SELECT 
              LastBracketPos = CHARINDEX(')', C.CustomerName, FirstBracketPos + 1)
          ) AS LBP
     CROSS APPLY
         (
          SELECT 
              SpecName = SUBSTRING(C.CustomerName, FirstBracketPos + 1, LastBracketPos - FirstBracketPos - 1)
          ) AS SName
     CROSS APPLY
         (
          SELECT 
              InvoiceMonth = FORMAT(DATEADD(MM, DATEDIFF(MM, 0, I.InvoiceDate), 0), 'dd.MM.yyyy')
          ) AS Dates
     WHERE C.CustomerID BETWEEN 2 AND 6
     ) AS D PIVOT(COUNT(I.[InvoiceID]) FOR D.SpecName IN(
    [Sylvanite, MT], 
    [Peeples Valley, AZ], 
    [Medicine Lodge, KS], 
    [Gasport, NY], 
    [Jessie, ND])) AS P
ORDER BY 
    CAST(InvoiceMonth AS DATE);