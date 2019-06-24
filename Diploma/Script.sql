--Сценарий
-- Пользователи будут обрабатываться отдельной БД (микросервисом). 
-- Вся работа с Users сделана для примера и не является адекватным примером
--Условная "Регистрация":
DECLARE @Registereduserid UNIQUEIDENTIFIER; -- GUID указыать не обязательно. Если он пустой - сгенерируется на сервере.
DECLARE @Username NVARCHAR(50) = 'Test for diploma';
EXECUTE [Users].[usp_users_create] 
        @Registereduserid, 
        @Username;
GO

-- Пользователи могут создавать группы, тем самым вести общий бюджет.
-- Для создания группы используется следующий запрос:

DECLARE @Groupid UNIQUEIDENTIFIER; -- GUID указыать не обязательно. Если он пустой - сгенерируется на сервере.
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9'; -- Mistand, создаём группу от лица ранее существующего юзверя.

EXECUTE [Users].[usp_groups_create] 
        @Groupid, 
        @Userid;
GO

-- Запрос для проверки данных.
SELECT 
       [uig].*, 
       [gr].[RoleName]
FROM Users.UsersInGroups uig
     INNER JOIN Users.GroupRoles gr ON uig.GroupRoleId = gr.GroupRoleId
WHERE [GroupId] = '70044851-B3DE-4A81-B1CA-5E7EE90CD36D';
GO

-- Добавление стороннего юзверя в группу
-- Пока сам механизм под вопросом, но для примера подойдёт.
--SELECT * FROM Users.[Table] t

DECLARE @Groupid UNIQUEIDENTIFIER = 'PASTEUIDHERE';
DECLARE @Userid UNIQUEIDENTIFIER = 'PASTEUSERIDHERE';
DECLARE @Roleid INT; -- Можно не указывать, автоматически выставит User.

EXECUTE [Users].[usp_groups_add_user] 
        @Groupid, 
        @Userid, 
        @Roleid;
GO

-- Добавим уже сущестующего юзверя в группу, для тестирования следующего функционала
DECLARE @Groupid UNIQUEIDENTIFIER = 'PASTEUIDHERE';
DECLARE @Userid UNIQUEIDENTIFIER = 'DFC161D1-FA14-4F0E-9512-ED0E6656684A';
DECLARE @Roleid INT;
EXECUTE [Users].[usp_groups_add_user] 
        @Groupid, 
        @Userid, 
        @Roleid;
GO

-- Удаление пользователя из группы:
DECLARE @Userid UNIQUEIDENTIFIER = 'DFC161D1-FA14-4F0E-9512-ED0E6656684A';
EXECUTE [Users].[usp_groups_kick_user] 
        @Userid;
GO

-- Теперь представим, что пользователь с ролью Admin выходит из группы. 
-- По задумке, Admin'ом становится первый пользователь, который вступил в группу.
-- К примеру, админ создал группу - №1.
-- Вступило ещё два пользователя №2 и №3.
-- При выходе из группы администратора - админом станет №2.
-- Привыходе из группы администратора №2 - админом станет №3.
-- Если в группе нет больше пользователей - группа станет архивной и никто не сможет в неё вступить.
-- Эта хранимка будет вызываться самим приложением.
DECLARE @Groupid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Users].[usp_groups_set_first_admin] 
        @Groupid;
GO

-- Самая главная часть самого приложения/сервиса - учет расходов.
-- Какой же это учёт расходов, если у нас нет ещё ни одного счёта. Самое время создать его!
DECLARE @Accountid UNIQUEIDENTIFIER; -- Создастся автоматически.
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
DECLARE @Accounttypeid INT = 2; -- Это тип счёта "Наличные"
DECLARE @Name NVARCHAR(50) = 'Налик';
DECLARE @Groupid UNIQUEIDENTIFIER; -- Если это общий счёт для группы - здесь указывается GroupId;
DECLARE @Projectid UNIQUEIDENTIFIER; -- Если счёт создан для проекта - указываем ProjectId;
DECLARE @Currencyid INT = 643; -- Идентификатор валюты. Пока что только рубли :)
DECLARE @Params XML; -- Здесь будет дополнительная информация о счёте. Пока нет точной информации, что конкретно будет содержаться здесь
-- Для вкладов планируется добавить информацию о: процентах, сроках, дате открытия и тд.
-- Для кредитов - даты платежей, срок кредита и прочее.

EXECUTE [Application].[usp_accounts_create] 
        @Accountid, 
        @Userid, 
        @Accounttypeid, 
        @Name, 
        @Groupid, 
        @Projectid, 
        @Currencyid, 
        @Params;
GO

-- Теперь у нас есть счёт. Прекрасно, но нужно же добавить транзакции, иначе, нечего учитывать
-- Но для начала, может, стоит добавить категорию расходов? Чтобы мы сразу понимали, на какие категории у нас уходит больше всего трат.
DECLARE @Categoryid UNIQUEIDENTIFIER; -- Автоматом, как обычно :)
DECLARE @Parentcategoryid UNIQUEIDENTIFIER; -- Родительская категория. Можно не указывать :)
DECLARE @Groupid UNIQUEIDENTIFIER; -- Идентификатор группы, если эта категория доступна в рамках группы
DECLARE @Projectid UNIQUEIDENTIFIER; -- Идентификатор проекта, если транзакция относится к нему
DECLARE @Name NVARCHAR(60) = 'Sample name'; -- Наименование категории
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9'; -- Юзверь, который пушит запись

EXECUTE [Application].[usp_operation_categories_create] 
        @Categoryid, 
        @Parentcategoryid, 
        @Groupid, 
        @Projectid, 
        @Name, 
        @Userid;
GO

-- Получаем список всех категорий, в которые может добавить юзверь запись. Сюда входят категории собственные (Own), группы (Group) и проекты (Projects)
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_operation_categories_list] 
        @Userid;
GO

-- Получаем список счетов, которые мы можем использовать для добавления транзакций
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_account_select] 
        @Userid;
GO

-- Создаём саму запись (операцию) :)
DECLARE @Operationid UNIQUEIDENTIFIER; -- Auto generate
DECLARE @Accountid UNIQUEIDENTIFIER = '1DF5044F-E074-4E28-BDC7-C4412AFA6C8B'; -- Идентификатор аккаунта
DECLARE @Operationtypeid INT = 1; -- Тип операции. Пускай будет код "ЗП"
DECLARE @Operationcategoryid UNIQUEIDENTIFIER; -- Идентификатор категории. Создадим без
DECLARE @Amount DECIMAL(18, 2)  = 10000; -- Спасибо государству за такую ЗП.
DECLARE @Comment NVARCHAR(150) = 'Test :O';
DECLARE @Params XML;
EXECUTE [Application].[usp_operations_create] 
        @Operationid, 
        @Accountid, 
        @Operationtypeid, 
        @Operationcategoryid, 
        @Amount, 
        @Comment, 
        @Params;
GO

-- Теперь, можем получить список операций за день
DECLARE @Accountid UNIQUEIDENTIFIER = '1DF5044F-E074-4E28-BDC7-C4412AFA6C8B';
DECLARE @Clientdate DATE = '20190624';
EXECUTE [Application].[usp_operations_get_for_day_by_account_id] 
        @Accountid, 
        @Clientdate;
GO

-- А вот и сам счёт (Balance)
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_account_select] 
        @Userid;
GO

-- Странное название для операции.. Надо бы его изменить, но по задумке - операции нельзя изменять, только удалять.
-- Для этого используется следующий код:

DECLARE @Operationid UNIQUEIDENTIFIER = '992AF19D-6F80-42A5-967B-1339EC5D1748';
DECLARE @Accountid UNIQUEIDENTIFIER = '1DF5044F-E074-4E28-BDC7-C4412AFA6C8B';
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_operations_delete_by_id] 
        @Operationid, 
        @Accountid, 
        @Userid;
GO

-- Проверим счёт ещё раз (обновился баланс)
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_account_select] 
        @Userid;
GO

-- Создаём под новым именем транзакцию
DECLARE @Operationid UNIQUEIDENTIFIER; -- Auto generate
DECLARE @Accountid UNIQUEIDENTIFIER = '1DF5044F-E074-4E28-BDC7-C4412AFA6C8B'; -- Идентификатор аккаунта
DECLARE @Operationtypeid INT = 1; -- Тип операции. Пускай будет код "ЗП"
DECLARE @Operationcategoryid UNIQUEIDENTIFIER; -- Идентификатор категории. Создадим без
DECLARE @Amount DECIMAL(18, 2)  = 10000; -- Спасибо государству за такую ЗП.
DECLARE @Comment NVARCHAR(150) = 'Зарплата за июнь';
DECLARE @Params XML;
EXECUTE [Application].[usp_operations_create] 
        @Operationid, 
        @Accountid, 
        @Operationtypeid, 
        @Operationcategoryid, 
        @Amount, 
        @Comment, 
        @Params;
GO
-- Проверим счёт ещё раз (обновился баланс)
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_account_select] 
        @Userid;
GO

-- Посмотрим транзакции за день
DECLARE @Accountid UNIQUEIDENTIFIER = '1DF5044F-E074-4E28-BDC7-C4412AFA6C8B';
DECLARE @Clientdate DATE = '20190624';
EXECUTE [Application].[usp_operations_get_for_day_by_account_id] 
        @Accountid, 
        @Clientdate;
GO

-- Проекты: 
-- Для создания проекта используется следующая хранимка:
DECLARE @Userid UNIQUEIDENTIFIER = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
DECLARE @Projectid UNIQUEIDENTIFIER; -- Auto generate
DECLARE @Groupid UNIQUEIDENTIFIER; -- ID группы, если это проект семьи/группы
DECLARE @Name NVARCHAR(50) = 'Ремонт'; -- наименование

EXECUTE [Application].[usp_projects_create] 
        @Userid, 
        @Projectid, 
        @Groupid, 
        @Name;
GO

-- Получение списка проектов
DECLARE @Userid uniqueidentifier = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';

EXECUTE [Application].[usp_projects_get] 
   @Userid
GO


-- удаление проекта (ранее созданного)
DECLARE @Projectid uniqueidentifier = '4FC80F49-D332-497A-81B0-D91023EF9C19';
DECLARE @Userid uniqueidentifier = 'CF5B267A-D2C8-4FE4-834D-451F7475ADF9';
EXECUTE [Application].[usp_projects_delete] 
   @Projectid
  ,@Userid
GO

-- И, пожалуй, всё :) 
-- Маленькая работа, но для себя я получил большой опыт, за что большое спасибо преподавателям курса :)