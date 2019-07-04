-- Temp table
CREATE TABLE #Hierarchy(EmployeeId INT PRIMARY KEY, [Name] NVARCHAR(MAX), TItle NVARCHAR(MAX), EmployeeLevel TINYINT);

WITH EmployeeHierarchy(EmployeeId, [Name], ManagerId, Title, EmployeeLevel) AS (
	SELECT me.EmployeeID, 
		CAST(me.FirstName + ' ' + me.LastName AS NVARCHAR(MAX)), 
		me.ManagerID, 
		me.Title, 
		1 
	FROM dbo.MyEmployees me
	WHERE me.ManagerID IS NULL
	UNION ALL
	SELECT me.EmployeeID, 
		CAST(REPLICATE('| ', eh.EmployeeLevel + 1) AS NVARCHAR(MAX)) + me.FirstName + ' ' + me.LastName, 
		me.ManagerID, 
		me.Title, 
		eh.EmployeeLevel + 1
	FROM EmployeeHierarchy eh
	INNER JOIN dbo.MyEmployees me ON eh.EmployeeId = me.ManagerId
)
INSERT INTO #Hierarchy
SELECT eh.EmployeeId, eh.[Name], eh.Title, eh.EmployeeLevel
FROM EmployeeHierarchy eh

SELECT * FROM #Hierarchy h;
DROP TABLE #Hierarchy;

-- Table variable
DECLARE @Hierarchy TABLE (EmployeeId INT PRIMARY KEY, [Name] NVARCHAR(MAX), TItle NVARCHAR(MAX), EmployeeLevel TINYINT);

WITH EmployeeHierarchy(EmployeeId, [Name], ManagerId, Title, EmployeeLevel) AS (
	SELECT me.EmployeeID, 
		CAST(me.FirstName + ' ' + me.LastName AS NVARCHAR(MAX)), 
		me.ManagerID, 
		me.Title, 
		1 
	FROM dbo.MyEmployees me
	WHERE me.ManagerID IS NULL
	UNION ALL
	SELECT me.EmployeeID, 
		CAST(REPLICATE('| ', eh.EmployeeLevel + 1) AS NVARCHAR(MAX)) + me.FirstName + ' ' + me.LastName, 
		me.ManagerID, 
		me.Title, 
		eh.EmployeeLevel + 1
	FROM EmployeeHierarchy eh
	INNER JOIN dbo.MyEmployees me ON eh.EmployeeId = me.ManagerId
)
INSERT INTO @Hierarchy
SELECT eh.EmployeeId, eh.[Name], eh.Title, eh.EmployeeLevel
FROM EmployeeHierarchy eh

SELECT * FROM @Hierarchy;
