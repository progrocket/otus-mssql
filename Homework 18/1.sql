ALTER DATABASE [OwnMoney] ADD FILEGROUP [YearData]
GO

ALTER DATABASE [OwnMoney] ADD FILE 
( NAME = N'Years', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER01\MSSQL\DATA\Yeardata.ndf' , 
SIZE = 2097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO


-- Создание функции для секционирования
-- Не хотелось писать вручную :(
DECLARE @DatePartitionFunction NVARCHAR(MAX) = N'CREATE PARTITION FUNCTION PF_Operations_Created (DATETIMEOFFSET) 
    AS RANGE RIGHT FOR VALUES (';

DECLARE @I DATETIMEOFFSET = '20190101';

WHILE @I < '20300101'
    BEGIN
        SET @DatePartitionFunction+='''' + CAST(@I AS NVARCHAR(10)) + ' 00:00:00.000 -07:00''' + N', ';
        SET @I = DATEADD(YEAR, 1, @I);
    END;

SET @DatePartitionFunction+='''' + CAST(@I AS NVARCHAR(10)) + ' 00:00:00.000 -07:00''' + N');';

EXEC sp_executesql 
     @DatePartitionFunction;  
GO



CREATE PARTITION SCHEME PS_Operations_Created AS PARTITION PF_Operations_Created 
ALL TO ([YearData])
GO

ALTER TABLE [Application].[Operations] DROP CONSTRAINT [PK_Operations] WITH ( ONLINE = OFF )
GO

ALTER TABLE [Application].[Operations] ADD CONSTRAINT PK_Operations
PRIMARY KEY CLUSTERED  ([OperationId], [AccountId], [Created])
 ON PS_Operations_Created([Created]);