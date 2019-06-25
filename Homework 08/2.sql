
SELECT 
    SpecName, 
    AddrSrc, 
    Addr
FROM
    (
     SELECT 
         SName.SpecName, 
         DeliveryAddressLine1, 
         DeliveryAddressLine2, 
         PostalAddressLine1, 
         PostalAddressLine2
     FROM Sales.Customers AS C
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
     WHERE C.CustomerID BETWEEN 2 AND 6
     ) AS S UNPIVOT(Addr FOR AddrSrc IN(
    DeliveryAddressLine1, 
    DeliveryAddressLine2, 
    PostalAddressLine1, 
    PostalAddressLine2)) AS U;