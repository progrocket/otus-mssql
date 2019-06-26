
USE [OwnMoney];
GO

/****** Object:  StoredProcedure [Application].[usp_account_delete]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description: Обновление счёта
-- =============================================

CREATE PROCEDURE [Application].[usp_account_delete] 
                 @Accountid UNIQUEIDENTIFIER, 
                 @Userid    UNIQUEIDENTIFIER
AS
    BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS
            (
             SELECT 
                 1
             FROM Application.Operations o
             WHERE o.AccountId = @Accountid
                      )
            BEGIN
                DELETE FROM Application.Accounts
                WHERE 
                    Application.Accounts.AccountId = @Accountid;
        END;
        ELSE
            BEGIN
                UPDATE Application.Accounts
                  SET 
                      Application.Accounts.ModifierUserId = @Userid, 
                      Application.Accounts.Modified = GETUTCDATE(), 
                      Application.Accounts.StatusCode = 1 -- Archive
                WHERE 
                    Application.Accounts.AccountId = @Accountid;
        END;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_account_select]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Список счетов
-- =============================================

CREATE PROCEDURE [Application].[usp_account_select] 
                 @Userid UNIQUEIDENTIFIER
AS
    BEGIN
        DECLARE 
            @SQL NVARCHAR(MAX) = 'SELECT ''Own'' AS [From],
		a.AccountId, 
		a.AccountTypeId, 
		a.[Name], 
		a.Balance, 
		a.CurrencyId, 
		a.ProjectId, 
		a.GroupId 
		FROM Application.Accounts a
		WHERE StatusCode = 0 AND a.GroupId IS NULL AND a.ProjectId IS NULL AND a.CreatorUserId = ' + QUOTENAME(@Userid, CHAR(39));
        DECLARE 
            @UserGroupId UNIQUEIDENTIFIER =
            (
             SELECT TOP 1 
                 uig.GroupId
             FROM Users.UsersInGroups uig
             WHERE uig.UserId = @UserId
                   AND uig.StatusCode = 0
                );
        IF @UserGroupId IS NOT NULL
            SET @SQL+='
		UNION
		SELECT ''Group'' AS [From],
		a.AccountId, 
		a.AccountTypeId, 
		a.[Name], 
		a.Balance, 
		a.CurrencyId, 
		a.ProjectId, 
		a.GroupId
		FROM Application.Accounts a
		WHERE StatusCode = 0 AND a.ProjectId IS NULL AND a.GroupId = ' + QUOTENAME(@UserGroupId, CHAR(39));
        SET @SQL+='
		UNION
		SELECT ''Project'' AS [From],
		a.AccountId, 
		a.AccountTypeId, 
		a.[Name], 
		a.Balance, 
		a.CurrencyId, 
		a.ProjectId, 
		a.GroupId
		FROM Application.Accounts a
		WHERE a.ProjectId IS NOT NULL AND (a.GroupId = ' + QUOTENAME(@UserGroupId, CHAR(39)) + ' OR a.CreatorUserId = ' + QUOTENAME(@UserId, CHAR(39)) + ') AND a.StatusCode = 0';
        EXECUTE sp_executesql 
                @SQL;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_accounts_create]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description: Создание нового счёта
-- =============================================

CREATE PROCEDURE [Application].[usp_accounts_create] 
                 @Accountid     UNIQUEIDENTIFIER = NULL, 
                 @Userid        UNIQUEIDENTIFIER, 
                 @Accounttypeid INT, 
                 @Name          NVARCHAR(50), 
                 @Groupid       UNIQUEIDENTIFIER = NULL, 
                 @Projectid     UNIQUEIDENTIFIER = NULL, 
                 @Currencyid    INT, 
                 @Params        XML              = NULL
AS
    BEGIN
        SET NOCOUNT ON;
        IF @Accountid IS NULL
            BEGIN
                SET @Accountid = NEWID();
        END;
        INSERT INTO Application.Accounts
        (
            AccountId, 
            AccountTypeId, 
            [Name], 
            Balance, 
            CurrencyId, 
            ProjectId, 
            GroupId, 
            CreatorUserId, 
            ModifierUserId, 
            StatusCode, 
            Params
        )
        OUTPUT 
            inserted.AccountId
        VALUES
        (
            @Accountid, 
            @Accounttypeid, 
            @Name, 
            0, -- Balance
            @Currencyid, 
            @Projectid, 
            @Groupid, 
            @Userid, -- CreatorUserId
            @Userid, -- ModifierUserId
            0, -- StatusCode - tinyint
            @Params
        );
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operation_categories_create]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Добавление новой категории
-- =============================================

CREATE PROCEDURE [Application].[usp_operation_categories_create] 
                 @Categoryid       UNIQUEIDENTIFIER, 
                 @Parentcategoryid UNIQUEIDENTIFIER, 
                 @Groupid          UNIQUEIDENTIFIER, 
                 @Projectid        UNIQUEIDENTIFIER, 
                 @Name             NVARCHAR(60), 
                 @Userid           UNIQUEIDENTIFIER
AS
    BEGIN
        IF(@Categoryid IS NULL)
            BEGIN
                SET @Categoryid = NEWID();
        END;
        INSERT INTO Application.OperationCategories
        (
            [OperationCategoryId], 
            [ParentOperationCategoryId], 
            [Name], 
            [GroupId], 
            [ProjectId], 
            [StatusCode], 
            [Creator], 
            [Modifier]
        )
        OUTPUT 
            [inserted].[OperationCategoryId]
        VALUES
        (
            @Categoryid, 
            @Parentcategoryid, 
            @Name, 
            @Groupid, 
            @Projectid, 
            0, -- StatusCode
            @Userid, 
            @Userid
        );
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operation_categories_delete]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Удаление категории 
-- =============================================

CREATE PROCEDURE [Application].[usp_operation_categories_delete] 
                 @Operationcategoryid UNIQUEIDENTIFIER
AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS
            (
             SELECT 
                 1
             FROM Application.OperationCategories oc
             WHERE [oc].[ParentOperationCategoryId] = @Operationcategoryid
                  )
            BEGIN
                RETURN;
        END;
        IF EXISTS
            (
             SELECT 
                 1
             FROM Application.Operations o
             WHERE [o].[OperationCategoryId] = @Operationcategoryid
                  )
            BEGIN
                UPDATE Application.OperationCategories
                  SET 
                      [Application].[OperationCategories].[StatusCode] = 1, -- Archive
                      [Application].[OperationCategories].[Modified] = GETUTCDATE()
                WHERE 
                    [Application].[OperationCategories].[OperationCategoryId] = @Operationcategoryid;
        END;
        ELSE
            BEGIN
                DELETE FROM Application.OperationCategories
                WHERE 
                    [Application].[OperationCategories].[OperationCategoryId] = @Operationcategoryid;
        END;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operation_categories_list]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-24
-- Description:	Список категорий для добавления операции
-- =============================================

CREATE PROCEDURE [Application].[usp_operation_categories_list] 
                 @UserId UNIQUEIDENTIFIER
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE 
            @UserGroupId UNIQUEIDENTIFIER =
            (
             SELECT TOP 1 
                 uig.GroupId
             FROM Users.UsersInGroups uig
             WHERE uig.UserId = @UserId
                   AND uig.StatusCode = 0
                );
        DECLARE 
            @SQL NVARCHAR(MAX) = 'SELECT ''Own'' AS [From], oc.* 
	FROM Application.OperationCategories oc
	WHERE oc.StatusCode = 0 AND oc.Creator = ' + QUOTENAME(@UserId, CHAR(39)) + ' AND oc.GroupId IS NULL AND oc.ProjectId IS NULL';
        IF @UserGroupId IS NOT NULL
            SET @SQL+='
		UNION 
		SELECT ''Group'' AS [From], oc.* 
		FROM Application.OperationCategories oc
		WHERE oc.StatusCode = 0 AND oc.GroupId = ' + QUOTENAME(@UserGroupId, CHAR(39));
        SET @SQL+='
	UNION
		SELECT ''Project'' AS [From], oc.* FROM Application.OperationCategories oc
		WHERE oc.ProjectId IS NOT NULL AND (oc.GroupId = ' + QUOTENAME(@UserGroupId, CHAR(39)) + ' OR oc.Creator = ' + QUOTENAME(@UserId, CHAR(39)) + ') AND oc.StatusCode = 0
	';
        EXECUTE sp_executesql 
                @SQL;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operation_update_params]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Обновление поля Params в операции
-- =============================================

CREATE PROCEDURE [Application].[usp_operation_update_params] 
                 @Operationid    UNIQUEIDENTIFIER, 
                 @Accountid      UNIQUEIDENTIFIER, 
                 @Params         XML, 
                 @Updatemodified BIT              = 0
AS
    BEGIN
        UPDATE Application.Operations
          SET 
              [Application].[Operations].[Params] = @Params, -- xml
              [Application].[Operations].[Modified] = CASE
                                                          WHEN @Updatemodified = 1
                                                              THEN GETUTCDATE() ELSE [Application].[Operations].[Modified]
                                                      END
        WHERE 
            [Application].[Operations].[OperationId] = @Operationid
            AND [Application].[Operations].[AccountId] = @Accountid;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operations_create]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Добавлении операции
-- =============================================

CREATE PROCEDURE [Application].[usp_operations_create] 
                 @Operationid         UNIQUEIDENTIFIER = NULL, 
                 @Accountid           UNIQUEIDENTIFIER, 
                 @Operationtypeid     INT, 
                 @Operationcategoryid UNIQUEIDENTIFIER, 
                 @Amount              DECIMAL(18, 2), 
                 @Comment             NVARCHAR(150), 
                 @Params              XML
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE 
            @Accountprojectid UNIQUEIDENTIFIER =
            (
             SELECT 
                 [a].[ProjectId]
             FROM Application.Accounts a
             WHERE [a].[AccountId] = @Accountid
                );
        IF @Operationid IS NULL
            SET @Operationid = NEWID();
        BEGIN TRANSACTION;
        INSERT INTO Application.Operations
        (
            [OperationId], 
            [AccountId], 
            [OperationTypeId], 
            [OperationCategoryId], 
            [ProjectId], 
            [Amount], 
            [Comment], 
            [Params]
        )
        VALUES
        (
            @Operationid, 
            @Accountid, 
            @Operationtypeid, 
            @Operationcategoryid, 
            @Accountprojectid, -- ProjectId - uniqueidentifier
            @Amount, -- Amount - decimal
            @Comment, -- Comment - nvarchar
            @Params -- Params - xml
        );
        UPDATE Application.Accounts
          SET 
              [Application].[Accounts].[Balance] = [Application].[Accounts].[Balance] + @Amount
        WHERE 
            [Application].[Accounts].[AccountId] = @Accountid;
        COMMIT TRANSACTION;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operations_delete_by_id]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Удаление операции
-- =============================================

CREATE PROCEDURE [Application].[usp_operations_delete_by_id] 
                 @Operationid UNIQUEIDENTIFIER, 
                 @Accountid   UNIQUEIDENTIFIER, 
                 @Userid      UNIQUEIDENTIFIER
AS
    BEGIN
        DECLARE 
            @Accountidtable TABLE
        (
                                  [AccountId] UNIQUEIDENTIFIER, 
                                  [Amount]    DECIMAL(18, 2)
        );
        BEGIN TRANSACTION;
        DELETE FROM Application.Operations
        OUTPUT 
            [deleted].[AccountId], 
            [deleted].[Amount]
               INTO @Accountidtable
        WHERE 
            [Application].[Operations].[OperationId] = @Operationid
            AND [Application].[Operations].[AccountId] = @Accountid;
        IF EXISTS
            (
             SELECT 
                 1
             FROM @Accountidtable
                  )
            BEGIN
                UPDATE Application.Accounts
                  SET 
                      [Application].[Accounts].[Balance] = [Application].[Accounts].[Balance] -
                    (
                     SELECT 
                         [ait].[Amount]
                     FROM @Accountidtable [ait]
                      ), 
                      [Application].[Accounts].[ModifierUserId] = @Userid
                WHERE 
                    [Application].[Accounts].[AccountId] =
                    (
                     SELECT 
                         [ait].[AccountId]
                     FROM @Accountidtable [ait]
                      );
        END;
        COMMIT TRANSACTION;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operations_get_for_day]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Получение операций за день
-- =============================================

CREATE PROCEDURE [Application].[usp_operations_get_for_day] 
                 @Accountid  UNIQUEIDENTIFIER, 
                 @Clientdate DATE
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE 
            @Datefinish DATETIMEOFFSET = DATEADD(DAY, 1, @Clientdate);
        SELECT 
            [o].[OperationId], 
            [o].[OperationTypeId], 
            [o].[OperationCategoryId], 
            [o].[ProjectId], 
            [o].[Amount], 
            [o].[Comment], 
            [o].[Params], 
            [o].[Created], 
            [o].[Modified]
        FROM Application.Operations o
        WHERE [o].[Created] >= @Clientdate
              AND [o].[Created] <= @Datefinish
              AND [o].[AccountId] = @Accountid;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_operations_get_for_day_by_account_id]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Получение операций за день
-- =============================================

CREATE PROCEDURE [Application].[usp_operations_get_for_day_by_account_id] 
                 @Accountid  UNIQUEIDENTIFIER, 
                 @Clientdate DATE
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE 
            @Datefinish DATETIMEOFFSET = DATEADD(DAY, 1, @Clientdate);
        SELECT 
            [o].[OperationId], 
            [o].[OperationTypeId], 
            [o].[OperationCategoryId], 
            [o].[ProjectId], 
            [o].[Amount], 
            [o].[Comment], 
            [o].[Params], 
            [o].[Created], 
            [o].[Modified]
        FROM Application.Operations o
        WHERE [o].[Created] >= @Clientdate
              AND [o].[Created] <= @Datefinish
              AND [o].[AccountId] = @Accountid;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_projects_create]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Создание проекта
-- =============================================

CREATE PROCEDURE [Application].[usp_projects_create] 
                 @UserId    UNIQUEIDENTIFIER, 
                 @ProjectId UNIQUEIDENTIFIER, 
                 @GroupId   UNIQUEIDENTIFIER, 
                 @Name      NVARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;
        IF(@ProjectId IS NULL)
            SET @ProjectId = NEWID();
        INSERT INTO Application.Projects
        (
            ProjectId, 
            Name, 
            StatusCode, 
            UserId, 
            GroupId
        )
        OUTPUT 
            inserted.ProjectId
        VALUES
        (
            @ProjectId, 
            @Name, -- Name - nvarchar
            0, 
            @UserId, 
            @GroupId
        );
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_projects_delete]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Удаление проекта
-- =============================================

CREATE PROCEDURE [Application].[usp_projects_delete] 
                 @Projectid UNIQUEIDENTIFIER, 
                 @Userid    UNIQUEIDENTIFIER
AS
    BEGIN
        IF EXISTS
            (
             SELECT 
                 1
             FROM Application.OperationCategories oc
             WHERE [oc].[ProjectId] = @Projectid
                  )
           OR EXISTS
            (
             SELECT 
                 1
             FROM Application.Accounts a
             WHERE [a].[ProjectId] = @Projectid
                     )
            BEGIN
                UPDATE Application.Projects
                  SET 
                      [Application].[Projects].[StatusCode] = 1, -- archive
                      [Application].[Projects].[Modified] = GETUTCDATE()
                WHERE 
                    [Application].[Projects].[ProjectId] = @Projectid;
        END;
        ELSE
            BEGIN
                DELETE FROM Application.Projects
                WHERE 
                    [Application].[Projects].[ProjectId] = @Projectid;
        END;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_projects_get]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-24
-- Description:	Получение списка проектов
-- =============================================

CREATE PROCEDURE [Application].[usp_projects_get] 
                 @Userid UNIQUEIDENTIFIER
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE 
            @Sql NVARCHAR(MAX) = 'SELECT 
               ''Own'' AS [From], 
               [p].[ProjectId], 
               [p].[Name], 
               [p].[StatusCode], 
               [p].[UserId], 
               [p].[GroupId], 
               [p].[Created], 
               [p].[Modified]
        FROM Application.Projects p
        WHERE [p].[GroupId] IS NULL
              AND [p].[UserId] = ' + QUOTENAME(@Userid, CHAR(39));
        DECLARE 
            @Usergroupid UNIQUEIDENTIFIER =
            (
             SELECT TOP 1 
                 [uig].[GroupId]
             FROM Users.UsersInGroups uig
             WHERE [uig].[UserId] = @Userid
                   AND [uig].[StatusCode] = 0
                );
        IF @Usergroupid IS NOT NULL
            BEGIN
                SET @Sql+='UNION 
			SELECT 
               ''Group'' AS [From], 
               [p].[ProjectId], 
               [p].[Name], 
               [p].[StatusCode], 
               [p].[UserId], 
               [p].[GroupId], 
               [p].[Created], 
               [p].[Modified]
        FROM Application.Projects p
        WHERE [p].[GroupId] IS NULL
              AND [p].[GroupId] = ' + QUOTENAME(@Usergroupid, CHAR(39)) + ';';
        END;
        EXECUTE sp_executesql 
                @Sql;
    END;
GO

/****** Object:  StoredProcedure [Application].[usp_projects_update_name]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Обновление имени проекта
-- =============================================

CREATE PROCEDURE [Application].[usp_projects_update_name] 
                 @Projectid UNIQUEIDENTIFIER, 
                 @Name      NVARCHAR(60)
AS
    BEGIN
        UPDATE Application.Projects
          SET 
              [Application].[Projects].[Name] = @Name, 
              [Application].[Projects].[Modified] = GETUTCDATE()
        WHERE 
            [Application].[Projects].[ProjectId] = @Projectid;
    END;
GO

/****** Object:  StoredProcedure [Users].[usp_groups_add_user]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description: Добавление пользователя в группу
-- =============================================

CREATE PROCEDURE [Users].[usp_groups_add_user] 
                 @Groupid UNIQUEIDENTIFIER, 
                 @Userid  UNIQUEIDENTIFIER, 
                 @Roleid  INT
AS
    BEGIN
        SET NOCOUNT ON;
        IF @Roleid IS NULL
            BEGIN
                SELECT 
                    @Roleid = [gr].[GroupRoleId]
                FROM Users.GroupRoles gr
                WHERE [gr].[RoleName] = 'User';
        END;
        INSERT INTO Users.UsersInGroups
        (
            [UserId], 
            [GroupId], 
            [GroupRoleId], 
            [StatusCode]
        )
        VALUES
        (
            @Userid, 
            @Groupid, 
            @Roleid, 
            0 -- StatusCode
        );
    END;
GO

/****** Object:  StoredProcedure [Users].[usp_groups_create]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Author:		Popov
-- Create date: 2019-05-11
-- Description: Создание новой группы (семьи)
-- =============================================

CREATE PROCEDURE [Users].[usp_groups_create] 
                 @Groupid UNIQUEIDENTIFIER = NULL, 
                 @Userid  UNIQUEIDENTIFIER
AS
    BEGIN
        DECLARE 
            @NewGroupId TABLE
        (
                              GroupId UNIQUEIDENTIFIER
        );
        SET NOCOUNT ON;
        IF @Groupid IS NULL
            BEGIN
                SET @Groupid = NEWID();
        END;
        INSERT INTO [Users].[Groups]
        (
            [GroupId], 
            [CreatorUserId]
        )
        OUTPUT 
            INSERTED.GroupId
               INTO @NewGroupId
        VALUES
        (
            @Groupid, 
            @Userid
        );
        DECLARE 
            @RoleIdAdmin INT =
            (
             SELECT TOP 1 
                 [GroupRoleId]
             FROM [Users].[GroupRoles]
             WHERE [Users].[GroupRoles].RoleName = 'Admin'
                );
        EXECUTE Users.usp_groups_add_user 
                @GroupId, 
                @UserId, 
                @RoleIdAdmin;
        SELECT 
            GroupId
        FROM @NewGroupId;
    END;
GO

/****** Object:  StoredProcedure [Users].[usp_groups_kick_user]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-05-11
-- Description: Создание новой группы (семьи)
-- =============================================

CREATE PROCEDURE [Users].[usp_groups_kick_user] 
                 @Userid UNIQUEIDENTIFIER
AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE Users.UsersInGroups
          SET 
              [Users].[UsersInGroups].[StatusCode] = 1
        WHERE 
            [Users].[UsersInGroups].[UserId] = @Userid;
    END;
GO

/****** Object:  StoredProcedure [Users].[usp_groups_set_first_admin]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-06-23
-- Description:	Назначить первого юзверя админом группы
-- =============================================

CREATE PROCEDURE [Users].[usp_groups_set_first_admin] 
                 @Groupid UNIQUEIDENTIFIER
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE 
            @Userid UNIQUEIDENTIFIER =
            (
             SELECT TOP 1 
                 [uig].[UserId]
             FROM Users.UsersInGroups uig
             WHERE [uig].[GroupId] = @Groupid
                   AND [uig].[StatusCode] = 0
                );
        IF @Userid IS NOT NULL
            BEGIN
                UPDATE Users.UsersInGroups
                  SET 
                      [Users].[UsersInGroups].[GroupRoleId] =
                    (
                     SELECT 
                         [gr].[GroupRoleId]
                     FROM [Users].[GroupRoles] [gr]
                     WHERE [gr].[RoleName] = 'Admin'
                      ), 
                      [Users].[UsersInGroups].[Modified] = GETUTCDATE()
                WHERE 
                    [Users].[UsersInGroups].[UserId] = @Userid
                    AND [Users].[UsersInGroups].[GroupId] = @Groupid
                    AND [Users].[UsersInGroups].[StatusCode] = 0;
        END;
        ELSE
            BEGIN
                UPDATE Users.Groups
                  SET 
                      Users.Groups.StatusCode = 1 -- Archive
                WHERE 
                    Users.Groups.GroupId = @Groupid;
        END;
    END;
GO

/****** Object:  StoredProcedure [Users].[usp_users_create]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-05-11
-- Description:	Регистрация нового юзверя
-- =============================================

CREATE PROCEDURE [Users].[usp_users_create] 
                 @Guid     UNIQUEIDENTIFIER = NULL, 
                 @Username NVARCHAR(50)
AS
    BEGIN
        IF @Guid IS NULL
            BEGIN
                SET @Guid = NEWID();
        END;
        INSERT INTO [Users].[Table]
        (
            [UserId], 
            [Username]
        )
        OUTPUT 
            INSERTED.UserId
        VALUES
        (
            @Guid, 
            @Username
        );
    END;
GO

/****** Object:  StoredProcedure [Users].[usp_users_get_by_id]    Script Date: 26.06.2019 11:53:11 ******/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Popov
-- Create date: 2019-05-11
-- Description:	Получение данных о юзвере по ID
-- =============================================

CREATE PROCEDURE [Users].[usp_users_get_by_id] 
                 @Guid UNIQUEIDENTIFIER
AS
    BEGIN
        SELECT 
            [UserId], 
            [Username]
        FROM [Users].[Table]
        WHERE [UserId] = @Guid;
    END;
GO