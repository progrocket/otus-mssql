-- 3. В таблице StockItems в колонке CustomFields есть данные в json.
-- Написать select для вывода:
-- - StockItemID
-- - StockItemName
-- - CountryOfManufacture (из CustomFields)
-- - Range (из CustomFields)

SELECT StockItemID, 
       StockItemName, 
       JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS [CountryOfManufacture], 
       JSON_VALUE(CustomFields, '$.Range') AS [Range]
FROM [Warehouse].[StockItems];