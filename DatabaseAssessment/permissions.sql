USE [master]
GO
-- It must be a Windows Account DOMAIN\[DOMAIN\UserName]
CREATE LOGIN [DOMAIN\UserName] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
CREATE USER [DOMAIN\UserName] FOR LOGIN [DOMAIN\UserName]
GO
ALTER ROLE db_datareader ADD MEMBER [DOMAIN\UserName]
GO
GRANT VIEW SERVER STATE TO [DOMAIN\UserName]
GO
GRANT VIEW ANY DATABASE TO [DOMAIN\UserName]
GO
GRANT VIEW ANY DEFINITION TO [DOMAIN\UserName]
GO
GRANT EXECUTE ON xp_regenumkeys TO [DOMAIN\UserName]
GO
GRANT EXECUTE ON xp_regread TO [DOMAIN\UserName]
GO
USE [msdb]
GO
CREATE USER [DOMAIN\UserName] FOR LOGIN [DOMAIN\UserName]
GO
ALTER ROLE db_datareader ADD MEMBER [DOMAIN\UserName]
GO
USE [model]
GO
CREATE USER [DOMAIN\UserName] FOR LOGIN [DOMAIN\UserName]
GO
ALTER ROLE db_datareader ADD MEMBER [DOMAIN\UserName]
GO
USE [SSISDB]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DOMAIN\UserName]
GO
ALTER ROLE ssis_admin ADD MEMBER [DOMAIN\UserName]
GO

-- Repeat the below script for as many databases as you want to run the assessment on.
USE [DatabaseName]
GO
CREATE USER [DOMAIN\UserName] FROM LOGIN [DOMAIN\UserName]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DOMAIN\UserName]
GO

-- The below script is a simplified version that will traverse all the databases, create the user and add the required permissions
DECLARE @command varchar(1000)
SELECT @command = 'USE [?] CREATE USER [DOMAIN\UserName] FROM LOGIN [DOMAIN\UserName]; ALTER ROLE [db_datareader] ADD MEMBER [DOMAIN\UserName]'
EXEC sp_MSforeachdb @command
