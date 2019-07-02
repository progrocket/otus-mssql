-- 2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
DECLARE @dataQuery nvarchar(max) = '
SELECT [@Name] = [StockItemName], 
    [Package] = (CAST(
(
    SELECT [UnitPackageID], 
        [OuterPackageID], 
        [QuantityPerOuter], 
        [TypicalWeightPerUnit]
    FROM [Warehouse].[StockItems] sip
    WHERE si.[StockItemID] = sip.[StockItemID] FOR XML PATH('''')
) AS XML)), 
    [LeadTimeDays], 
    [IsChillerStock], 
    [TaxRate], 
    [UnitPrice]
FROM [Warehouse].[StockItems] si FOR XML PATH(''''Item''''), ROOT(''''StockItems'''');';

DECLARE @bcpQuery nvarchar(max) = 'EXEC xp_cmdshell ''bcp "'+ @dataQuery +'" QUERYOUT "C:\OTUS\StockItems2.xml" -T -c -t''';
EXEC sp_executesql @bcpQuery;