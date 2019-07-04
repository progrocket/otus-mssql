CREATE MESSAGE TYPE [//WWI/Broker/TestMessage] AUTHORIZATION [dbo] VALIDATION = NONE;
GO

CREATE CONTRACT [//WWI/Broker/MessageContract] AUTHORIZATION [dbo]([//WWI/Broker/TestMessage] SENT BY INITIATOR);
GO

CREATE QUEUE [dbo].[TestMessageQueue];
GO

CREATE SERVICE [//WWI/Broker/MessageService] AUTHORIZATION [dbo] ON QUEUE [dbo].[TestMessageQueue]([//WWI/Broker/MessageContract]);
GO

-- Test sending message
DECLARE @text NVARCHAR(MAX)= 'test message';
DECLARE @handle UNIQUEIDENTIFIER;
BEGIN TRANSACTION;

BEGIN DIALOG @handle FROM SERVICE [//WWI/Broker/MessageService] TO SERVICE '//WWI/Broker/MessageService' ON CONTRACT [//WWI/Broker/MessageContract] WITH ENCRYPTION = OFF;
SEND ON CONVERSATION @handle MESSAGE TYPE [//WWI/Broker/TestMessage](@text);

COMMIT TRANSACTION;
GO

-- Get message
DECLARE @conversation_handle UNIQUEIDENTIFIER, @message_body VARBINARY(MAX), @message_type_name VARCHAR(256);
BEGIN TRANSACTION;

RECEIVE TOP (1) @conversation_handle = [conversation_handle], 
                @message_body = [message_body], 
                @message_type_name = [message_type_name] FROM [dbo].[TestMessageQueue];
DECLARE @text NVARCHAR(MAX);
SET @text = CONVERT(NVARCHAR(MAX), @message_body);
PRINT @text;

COMMIT TRANSACTION;
  GO