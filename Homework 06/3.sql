--3. Функции одним запросом
--Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
--пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
--посчитайте общее количество товаров и выведете полем в этом же запросе
--посчитайте общее количество товаров в зависимости от первой буквы названия товара
--отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
--предыдущий ид товара с тем же порядком отображения (по имени)
--названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
--сформируйте 30 групп товаров по полю вес товара на 1 шт
--Для этой задачи НЕ нужно писать аналог без аналитических функций

SELECT si.StockItemID, 
    si.StockItemName, 
    si.Brand, 
    ROW_NUMBER() OVER(PARTITION BY LEFT(si.StockItemName, 1) ORDER BY si.StockItemName) [NumbererFirstChar], 
    COUNT(*) OVER() [TotalCount], 
    COUNT(*) OVER(PARTITION BY LEFT(si.StockItemName, 1)) [TotalCountFirstChar], 
    LEAD(StockItemID) OVER(ORDER BY si.StockItemName) [NextId], 
    LAG(StockItemID) OVER(ORDER BY si.StockItemName) [PrevId], 
    LAG(si.StockItemName, 2, 'No items') OVER(ORDER BY si.StockItemName) [Prevx2Name],
    NTILE(30) OVER(ORDER BY si.TypicalWeightPerUnit) [GroupWeight]
FROM Warehouse.StockItems si
ORDER BY si.StockItemName;