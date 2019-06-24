USE [OwnMoney];
GO

CREATE SCHEMA [Application];
GO

CREATE SCHEMA [Users];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE [Application].[Accounts]
(
             [AccountId]      [UNIQUEIDENTIFIER] NOT NULL, 
             [AccountTypeId]  [INT] NOT NULL, 
             [Name]           [NVARCHAR](50) NOT NULL, 
             [Balance]        [DECIMAL](18, 2) NOT NULL, 
             [CurrencyId]     [INT] NOT NULL, 
             [ProjectId]      [UNIQUEIDENTIFIER] NULL, 
             [GroupId]        [UNIQUEIDENTIFIER] NULL, 
             [CreatorUserId]  [UNIQUEIDENTIFIER] NOT NULL, 
             [ModifierUserId] [UNIQUEIDENTIFIER] NOT NULL, 
             [Modified]       [DATETIMEOFFSET](7) NOT NULL, 
             [Created]        [DATETIMEOFFSET](7) NOT NULL, 
             [StatusCode]     [TINYINT] NOT NULL, 
             [Params]         [XML] NULL, 
             CONSTRAINT [PK_Accounts] PRIMARY KEY CLUSTERED([AccountId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

CREATE TABLE [Application].[AccountTypes]
(
             [AccountTypeId] [INT] NOT NULL, 
             [Name]          [NVARCHAR](50) NOT NULL, 
             CONSTRAINT [PK_AccountTypes] PRIMARY KEY CLUSTERED([AccountTypeId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Application].[Currencies]
(
             [CurrencyId]   [INT] NOT NULL, 
             [CurrencyName] [NVARCHAR](50) NOT NULL, 
             CONSTRAINT [PK_Currencies] PRIMARY KEY CLUSTERED([CurrencyId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Application].[OperationCategories]
(
             [OperationCategoryId]       [UNIQUEIDENTIFIER] NOT NULL, 
             [ParentOperationCategoryId] [UNIQUEIDENTIFIER] NULL, 
             [Name]                      [NVARCHAR](60) NULL, 
             [GroupId]                   [UNIQUEIDENTIFIER] NULL, 
             [ProjectId]                 [UNIQUEIDENTIFIER] NULL, 
             [StatusCode]                [TINYINT] NOT NULL, 
             [Created]                   [DATETIMEOFFSET](7) NOT NULL, 
             [Modified]                  [DATETIMEOFFSET](7) NOT NULL, 
             [Creator]                   [UNIQUEIDENTIFIER] NOT NULL, 
             [Modifier]                  [UNIQUEIDENTIFIER] NOT NULL, 
             CONSTRAINT [PK_OperationCategories] PRIMARY KEY CLUSTERED([OperationCategoryId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Application].[Operations]
(
             [OperationId]         [UNIQUEIDENTIFIER] NOT NULL, 
             [AccountId]           [UNIQUEIDENTIFIER] NOT NULL, 
             [OperationTypeId]     [INT] NOT NULL, 
             [OperationCategoryId] [UNIQUEIDENTIFIER] NULL, 
             [ProjectId]           [UNIQUEIDENTIFIER] NULL, 
             [Amount]              [DECIMAL](18, 2) NOT NULL, 
             [Comment]             [NVARCHAR](150) NULL, 
             [Params]              [XML] NULL, 
             [Created]             [DATETIMEOFFSET](7) NOT NULL, 
             [Modified]            [DATETIMEOFFSET](7) NOT NULL, 
             CONSTRAINT [PK_Operations] PRIMARY KEY CLUSTERED([OperationId] ASC, [AccountId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

CREATE TABLE [Application].[OperationTypes]
(
             [OperationTypeId] [INT] NOT NULL, 
             [Name]            [NVARCHAR](50) NOT NULL, 
             CONSTRAINT [PK_OperationTypes] PRIMARY KEY CLUSTERED([OperationTypeId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Application].[Projects]
(
             [ProjectId]  [UNIQUEIDENTIFIER] NOT NULL, 
             [Name]       [NVARCHAR](50) NOT NULL, 
             [StatusCode] [TINYINT] NOT NULL, 
             [UserId]     [UNIQUEIDENTIFIER] NOT NULL, 
             [GroupId]    [UNIQUEIDENTIFIER] NULL, 
             [Created]    [DATETIMEOFFSET](7) NOT NULL, 
             [Modified]   [DATETIMEOFFSET](7) NOT NULL, 
             CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED([ProjectId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Users].[GroupRoles]
(
             [GroupRoleId] [INT] NOT NULL, 
             [RoleName]    [NVARCHAR](50) NOT NULL, 
             CONSTRAINT [PK_GroupRoles] PRIMARY KEY CLUSTERED([GroupRoleId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO
CREATE TABLE [Users].[Groups]
(
             [GroupId]       [UNIQUEIDENTIFIER] NOT NULL, 
             [Created]       [DATETIMEOFFSET](7) NOT NULL, 
             [Modified]      [DATETIMEOFFSET](7) NOT NULL, 
             [CreatorUserId] [UNIQUEIDENTIFIER] NOT NULL, 
             [StatusCode]    [TINYINT] NOT NULL, 
             CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED([GroupId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Users].[Table]
(
             [UserId]   [UNIQUEIDENTIFIER] NOT NULL, 
             [Username] [NVARCHAR](50) NOT NULL, 
             CONSTRAINT [PK_Table] PRIMARY KEY CLUSTERED([UserId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO

CREATE TABLE [Users].[UsersInGroups]
(
             [UsersInGroupsId] [UNIQUEIDENTIFIER] NOT NULL, 
             [UserId]          [UNIQUEIDENTIFIER] NOT NULL, 
             [GroupId]         [UNIQUEIDENTIFIER] NOT NULL, 
             [GroupRoleId]     [INT] NOT NULL, 
             [Created]         [DATETIMEOFFSET](7) NOT NULL, 
             [Modified]        [DATETIMEOFFSET](7) NOT NULL, 
             [StatusCode]      [TINYINT] NOT NULL, 
             CONSTRAINT [PK_UsersInGroups_1] PRIMARY KEY CLUSTERED([UsersInGroupsId] ASC)
             WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY];
GO
ALTER TABLE [Application].[Accounts]
ADD CONSTRAINT [DF_Accounts_Modified] DEFAULT(GETUTCDATE()) FOR [Modified];
GO
ALTER TABLE [Application].[Accounts]
ADD CONSTRAINT [DF_Accounts_Created] DEFAULT(GETUTCDATE()) FOR [Created];
GO
ALTER TABLE [Application].[OperationCategories]
ADD CONSTRAINT [DF_OperationCategories_StatusCode] DEFAULT((0)) FOR [StatusCode];
GO
ALTER TABLE [Application].[OperationCategories]
ADD CONSTRAINT [DF_OperationCategories_Created] DEFAULT(GETUTCDATE()) FOR [Created];
GO
ALTER TABLE [Application].[OperationCategories]
ADD CONSTRAINT [DF_OperationCategories_Modified] DEFAULT(GETUTCDATE()) FOR [Modified];
GO
ALTER TABLE [Application].[Operations]
ADD CONSTRAINT [DF_Operations_Created] DEFAULT(GETUTCDATE()) FOR [Created];
GO
ALTER TABLE [Application].[Operations]
ADD CONSTRAINT [DF_Operations_Modified] DEFAULT(GETUTCDATE()) FOR [Modified];
GO
ALTER TABLE [Application].[Projects]
ADD CONSTRAINT [DF_Projects_StatusCode] DEFAULT((0)) FOR [StatusCode];
GO
ALTER TABLE [Application].[Projects]
ADD CONSTRAINT [DF_Projects_Created] DEFAULT(GETUTCDATE()) FOR [Created];
GO
ALTER TABLE [Application].[Projects]
ADD CONSTRAINT [DF_Projects_Modified] DEFAULT(GETUTCDATE()) FOR [Modified];
GO
ALTER TABLE [Users].[Groups]
ADD CONSTRAINT [DF_Groups_Created] DEFAULT(GETUTCDATE()) FOR [Created];
GO
ALTER TABLE [Users].[Groups]
ADD CONSTRAINT [DF_Groups_Modified] DEFAULT(GETUTCDATE()) FOR [Modified];
GO
ALTER TABLE [Users].[Groups]
ADD CONSTRAINT [DF_Groups_StatusCode] DEFAULT((0)) FOR [StatusCode];
GO
ALTER TABLE [Users].[UsersInGroups]
ADD CONSTRAINT [DF_UsersInGroups_UsersInGroupsId] DEFAULT(NEWID()) FOR [UsersInGroupsId];
GO
ALTER TABLE [Users].[UsersInGroups]
ADD CONSTRAINT [DF_UsersInGroups_Created] DEFAULT(GETUTCDATE()) FOR [Created];
GO
ALTER TABLE [Users].[UsersInGroups]
ADD CONSTRAINT [DF_UsersInGroups_Modified] DEFAULT(GETUTCDATE()) FOR [Modified];
GO
ALTER TABLE [Users].[UsersInGroups]
ADD CONSTRAINT [DF_UsersInGroups_StatusCode] DEFAULT((0)) FOR [StatusCode];
GO
ALTER TABLE [Application].[Accounts]
WITH CHECK
ADD CONSTRAINT [FK_Accounts_AccountTypes] FOREIGN KEY([AccountTypeId]) REFERENCES [Application].[AccountTypes](
                                                                                  [AccountTypeId]);
GO
ALTER TABLE [Application].[Accounts] CHECK CONSTRAINT [FK_Accounts_AccountTypes];
GO
ALTER TABLE [Application].[Accounts]
WITH CHECK
ADD CONSTRAINT [FK_Accounts_Currencies] FOREIGN KEY([CurrencyId]) REFERENCES [Application].[Currencies](
                                                                             [CurrencyId]);
GO
ALTER TABLE [Application].[Accounts] CHECK CONSTRAINT [FK_Accounts_Currencies];
GO
ALTER TABLE [Application].[Accounts]
WITH CHECK
ADD CONSTRAINT [FK_Accounts_Groups] FOREIGN KEY([GroupId]) REFERENCES [Users].[Groups](
                                                                      [GroupId]);
GO
ALTER TABLE [Application].[Accounts] CHECK CONSTRAINT [FK_Accounts_Groups];
GO
ALTER TABLE [Application].[Accounts]
WITH CHECK
ADD CONSTRAINT [FK_Accounts_Projects] FOREIGN KEY([ProjectId]) REFERENCES [Application].[Projects](
                                                                          [ProjectId]);
GO
ALTER TABLE [Application].[Accounts] CHECK CONSTRAINT [FK_Accounts_Projects];
GO
ALTER TABLE [Application].[OperationCategories]
WITH CHECK
ADD CONSTRAINT [FK_OperationCategories_Groups] FOREIGN KEY([GroupId]) REFERENCES [Users].[Groups](
                                                                                 [GroupId]);
GO
ALTER TABLE [Application].[OperationCategories] CHECK CONSTRAINT [FK_OperationCategories_Groups];
GO
ALTER TABLE [Application].[OperationCategories]
WITH CHECK
ADD CONSTRAINT [FK_OperationCategories_OperationCategories] FOREIGN KEY([ParentOperationCategoryId]) REFERENCES [Application].[OperationCategories](
                                                                                                                [OperationCategoryId]);
GO
ALTER TABLE [Application].[OperationCategories] CHECK CONSTRAINT [FK_OperationCategories_OperationCategories];
GO
ALTER TABLE [Application].[OperationCategories]
WITH CHECK
ADD CONSTRAINT [FK_OperationCategories_Projects] FOREIGN KEY([ProjectId]) REFERENCES [Application].[Projects](
                                                                                     [ProjectId]);
GO
ALTER TABLE [Application].[OperationCategories] CHECK CONSTRAINT [FK_OperationCategories_Projects];
GO
ALTER TABLE [Application].[Operations]
WITH CHECK
ADD CONSTRAINT [FK_Operations_Accounts] FOREIGN KEY([AccountId]) REFERENCES [Application].[Accounts](
                                                                            [AccountId]);
GO
ALTER TABLE [Application].[Operations] CHECK CONSTRAINT [FK_Operations_Accounts];
GO
ALTER TABLE [Application].[Operations]
WITH CHECK
ADD CONSTRAINT [FK_Operations_OperationCategories] FOREIGN KEY([OperationCategoryId]) REFERENCES [Application].[OperationCategories](
                                                                                                 [OperationCategoryId]);
GO
ALTER TABLE [Application].[Operations] CHECK CONSTRAINT [FK_Operations_OperationCategories];
GO
ALTER TABLE [Application].[Operations]
WITH CHECK
ADD CONSTRAINT [FK_Operations_Projects] FOREIGN KEY([ProjectId]) REFERENCES [Application].[Projects](
                                                                            [ProjectId]);
GO
ALTER TABLE [Application].[Operations] CHECK CONSTRAINT [FK_Operations_Projects];
GO
ALTER TABLE [Application].[Projects]
WITH CHECK
ADD CONSTRAINT [FK_Projects_Table] FOREIGN KEY([UserId]) REFERENCES [Users].[Table](
                                                                    [UserId]);
GO
ALTER TABLE [Application].[Projects] CHECK CONSTRAINT [FK_Projects_Table];
GO
ALTER TABLE [Users].[Groups]
WITH CHECK
ADD CONSTRAINT [FK_Groups_Table] FOREIGN KEY([CreatorUserId]) REFERENCES [Users].[Table](
                                                                         [UserId]);
GO
ALTER TABLE [Users].[Groups] CHECK CONSTRAINT [FK_Groups_Table];
GO
ALTER TABLE [Users].[UsersInGroups]
WITH CHECK
ADD CONSTRAINT [FK_UsersInGroups_GroupRoles] FOREIGN KEY([GroupRoleId]) REFERENCES [Users].[GroupRoles](
                                                                                   [GroupRoleId]);
GO
ALTER TABLE [Users].[UsersInGroups] CHECK CONSTRAINT [FK_UsersInGroups_GroupRoles];
GO
ALTER TABLE [Users].[UsersInGroups]
WITH CHECK
ADD CONSTRAINT [FK_UsersInGroups_Groups] FOREIGN KEY([GroupId]) REFERENCES [Users].[Groups](
                                                                           [GroupId]);
GO
ALTER TABLE [Users].[UsersInGroups] CHECK CONSTRAINT [FK_UsersInGroups_Groups];
GO
ALTER TABLE [Users].[UsersInGroups]
WITH CHECK
ADD CONSTRAINT [FK_UsersInGroups_Table] FOREIGN KEY([UserId]) REFERENCES [Users].[Table](
                                                                         [UserId]);
GO
ALTER TABLE [Users].[UsersInGroups] CHECK CONSTRAINT [FK_UsersInGroups_Table];
GO