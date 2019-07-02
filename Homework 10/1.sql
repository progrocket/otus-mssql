-- 1. Загрузить данные из файла StockItems.xml в таблицу StockItems.
-- Существующие записи в таблице обновить, отсутствующие добавить (искать по StockItemName).
-- Файл StockItems.xml в личном кабинете.

DECLARE @Sql NVARCHAR(MAX);
DECLARE @FilePath NVARCHAR(256) = 'D:\StockItems.xml';
SET @Sql = '
	MERGE [Warehouse].[StockItems] AS target
	USING
	(
		SELECT 
			[Name] = MY_XML.Item.value(''@Name'', ''nvarchar(100)''),
			[SupplierID] = MY_XML.Item.value(''SupplierID[1]'', ''int''),
			[UnitPackageID] = MY_XML.Item.value(''Package[1]/UnitPackageID[1]'', ''int''),
			[OuterPackageID] = MY_XML.Item.value(''Package[1]/OuterPackageID[1]'', ''int''),
			[QuantityPerOuter] = MY_XML.Item.value(''Package[1]/QuantityPerOuter[1]'', ''int''),
			[TypicalWeightPerUnit] = MY_XML.Item.value(''Package[1]/TypicalWeightPerUnit[1]'', ''decimal(18,3)''),
			[LeadTimeDays] = MY_XML.Item.value(''LeadTimeDays[1]'', ''int''),
			[IsChillerStock] = MY_XML.Item.value(''IsChillerStock[1]'', ''bit''),
			[TaxRate] = MY_XML.Item.value(''TaxRate[1]'', ''decimal(18,3)''),
			[UnitPrice] = MY_XML.Item.value(''UnitPrice[1]'', ''decimal(18,2)'')
					FROM
					(
						SELECT cast(MY_XML AS xml)
						FROM OPENROWSET( BULK N'''+ @FilePath +''', SINGLE_BLOB ) AS T(MY_XML)
					) AS T(MY_XML)
					CROSS APPLY MY_XML.nodes(''StockItems/Item'') AS MY_XML (Item)
				) AS source ([Name], [SupplierID], [UnitPackageID], [OuterPackageID], [QuantityPerOuter], [TypicalWeightPerUnit], [LeadTimeDays], [IsChillerStock], [TaxRate], [UnitPrice])
				ON (target.[StockItemName] = source.[Name])
				WHEN MATCHED
				THEN 
					UPDATE SET
						target.[SupplierID] = source.[SupplierID],
						target.[UnitPackageID] = source.[UnitPackageID],
						target.[OuterPackageID] = source.[OuterPackageID],
						target.[QuantityPerOuter] = source.[QuantityPerOuter],
						target.[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit],
						target.[LeadTimeDays] = source.[LeadTimeDays],
						target.[IsChillerStock] = source.[IsChillerStock],
						target.[TaxRate] = source.[TaxRate],
						target.[UnitPrice] = source.[UnitPrice]
				WHEN NOT MATCHED
				THEN 
					INSERT ([StockItemName],
							[SupplierID],
							[UnitPackageID],
							[OuterPackageID],
							[QuantityPerOuter],
							[TypicalWeightPerUnit],
							[LeadTimeDays],
							[IsChillerStock],
							[TaxRate],
							[UnitPrice],
							[LastEditedBy]
						)
					VALUES (source.[Name],
							source.[SupplierID],
							source.[UnitPackageID],
							source.[OuterPackageID],
							source.[QuantityPerOuter],
							source.[TypicalWeightPerUnit],
							source.[LeadTimeDays],
							source.[IsChillerStock],
							source.[TaxRate],
							source.[UnitPrice],
							2
						);
			';
			PRINT @Sql;
			--EXEC sp_executesql @Sql;