--4. Найти в StockItems строки, где есть тэг "Vintage"
--Запрос написать через функции работы с JSON.
--Тэги искать в поле CustomFields, а не в Tags.

SELECT si.*
FROM [Warehouse].[StockItems] si
CROSS APPLY OPENJSON(CustomFields, '$.Tags')
WHERE Value = 'Vintage';