-- 5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
EXEC sp_configure 'show advanced options', 1;  
GO

EXEC sp_configure 'xp_cmdshell', 1;  
GO 

RECONFIGURE;  
GO  


EXEC master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out "C:\TestBCP\SalesCustomers.data" -T -w -t, -S WIN-O8BSRD2VVMP'
GO

BEGIN TRAN

-- Copy table schema
SELECT *  INTO [WideWorldImporters].Sales.Customers2 FROM [WideWorldImporters].Sales.Customers WHERE 1 = 2

BULK INSERT [WideWorldImporters].Sales.Customers2
	FROM "C:\TestBCP\SalesCustomers.data"
	WITH 
	(
		BATCHSIZE = 1000, 
		DATAFILETYPE = 'widechar',
		FIELDTERMINATOR = '#',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK,
		CODEPAGE=65001
	);

ROLLBACK TRAN