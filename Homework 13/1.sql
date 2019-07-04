CREATE ASSEMBLY DemoAssembly
FROM 'D:\SqlExtensions\RegMatch\bin\Debug\RegMatch.dll'
WITH PERMISSION_SET = SAFE;  
GO

--DROP ASSEMBLY DemoAssembly

SELECT * FROM sys.assemblies
GO

CREATE FUNCTION dbo.Reg(@Value nvarchar(max), @Regex nvarchar(max))  
RETURNS BIT
AS EXTERNAL NAME DemoAssembly.RegExtension.IsMatch;  
GO 

SELECT assembly_id, assembly_class, assembly_method
from sys.assembly_modules

-- Test regex email
SELECT dbo.Reg('test@otus.ru', '^(?("")(""[^""]+?""@)|(([0-9a-z]((\.(?!\.))|[-!#\$%&''\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-z][-\w]*[0-9a-z]*\.)+[a-z0-9]{2,17}))$');