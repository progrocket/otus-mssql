
SELECT 
    CountryID, 
    CountryName, 
    CodeType, 
    Code
FROM
    (
     SELECT 
         c.CountryID, 
		 c.CountryName, 
         CAST(c.IsoAlpha3Code AS NVARCHAR) IsoAlpha3Code, 
         CAST(c.IsoNumericCode AS NVARCHAR) IsoNumericCode
     FROM Application.Countries c
     ) AS S UNPIVOT(Code FOR CodeType IN(
    [IsoAlpha3Code], 
    [IsoNumericCode])) AS U;