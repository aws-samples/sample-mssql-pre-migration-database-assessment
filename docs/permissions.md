# Permissions

This document describes the SQL Server permissions required to run the MSSQL Pre-Migration Database Assessment tool.

## Permission Justifications

The following table explains each permission, why it is required, the risk if misused, and whether it can be scoped down for your environment:

| Permission | Required For | Risk if Abused | Can Be Scoped Down? |
|---|---|---|---|
| `VIEW ANY DEFINITION` | Reading object definitions across all databases (stored procedures, functions, views) | Object source code exposure | No - server-level only |
| `VIEW SERVER STATE` | DMV access for performance metrics, configuration, memory, and session data | Server state visibility | No - server-level only |
| `ALTER ANY SERVER AUDIT` | Reading server audit specifications and configurations | Could create/modify/drop audits | Consider `VIEW ANY SERVER AUDIT` if using SQL Server 2022+ |
| `VIEW ANY DATABASE` | Listing all databases and their properties | Database metadata visibility | No - required for comprehensive assessment |
| `xp_regenumkeys` | Enumerating installed SQL Server services via registry | Registry key enumeration | Skip if service inventory not needed |
| `xp_regread` | Reading SQL Server configuration from registry (ports, paths, timezone) | Registry value access | Skip if registry-based config not needed |
| `db_datareader` (all DBs) | Reading system catalog views in each database | Could read application data tables | Limit to system catalogs if custom role is acceptable |
| `ssis_admin` (SSISDB only) | Reading SSIS package metadata and configurations | SSIS project visibility | Only required if SSISDB exists |

## Security Recommendations

1. **Use a dedicated account**: Create a service account specifically for assessments. Disable or delete it after the assessment window closes.

2. **Review and scope down**: Before running in production, review the permission list with your security team. Remove permissions for features you don't need to assess (e.g., skip `xp_reg*` if registry information is not required).

3. **Time-limited access**: Grant permissions only for the duration of the assessment. Use SQL Agent jobs or automation to revoke permissions automatically after a defined period.

4. **Audit trail**: Enable SQL Server Audit on the assessment account to track all queries executed during the assessment.

## Grant Permissions Script

The following script creates a Windows login and grants the required permissions. Replace `CONTOSO\s2m2admin` with your assessment account.

```SQL
DECLARE @LoginName NVARCHAR(100)  = 'CONTOSO\s2m2admin'
DECLARE @SQL VARCHAR(MAX);

-- Step 1: Create login if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = @LoginName)
BEGIN
    PRINT('Step 1. Creating login for [' + @LoginName + ']')
    SET @SQL = 'CREATE LOGIN [' + @LoginName + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]';
    EXEC(@SQL);
END

-- Step 2: Grant server-level permissions
PRINT('Step 2.1. GRANTING VIEW ANY DEFINITION TO [' + @LoginName + ']')
SET @SQL = 'GRANT VIEW ANY DEFINITION TO [' + @LoginName + ']';
EXEC(@SQL);

PRINT('Step 2.2. GRANTING VIEW SERVER STATE TO [' + @LoginName + ']')
SET @SQL = 'GRANT VIEW SERVER STATE TO [' + @LoginName + ']';
EXEC(@SQL);

PRINT('Step 2.3. GRANTING ALTER ANY SERVER AUDIT TO [' + @LoginName + ']')
SET @SQL = 'GRANT ALTER ANY SERVER AUDIT TO [' + @LoginName + ']';
EXEC(@SQL);

PRINT('Step 2.4. GRANTING VIEW ANY DATABASE TO [' + @LoginName + ']')
SET @SQL = 'GRANT VIEW ANY DATABASE TO [' + @LoginName + ']';
EXEC(@SQL);

PRINT('Step 2.5. GRANTING EXECUTE ON xp_regenumkeys TO [' + @LoginName + ']')
SET @SQL = 'GRANT EXECUTE ON xp_regenumkeys TO [' + @LoginName + ']';
EXEC(@SQL);

PRINT('Step 2.6. GRANTING EXECUTE ON xp_regread TO [' + @LoginName + ']')
SET @SQL = 'GRANT EXECUTE ON xp_regread TO [' + @LoginName + ']';
EXEC(@SQL);

-- Step 3: Create users and assign db_datareader in all online databases
DECLARE @DatabaseName NVARCHAR(100)
DECLARE @Command NVARCHAR(MAX)

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Command = '
        USE [' + @DatabaseName + '];
        IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name = ''' + @LoginName + ''')
        BEGIN
            CREATE USER [' + @LoginName + '] FROM LOGIN [' + @LoginName + '];
        END
        ALTER ROLE [db_datareader] ADD MEMBER [' + @LoginName + '];'

    EXEC sp_executesql @Command

    FETCH NEXT FROM db_cursor INTO @DatabaseName
END

CLOSE db_cursor
DEALLOCATE db_cursor

-- Step 4: Grant ssis_admin in SSISDB if it exists
DECLARE @SqlStatement NVARCHAR(MAX)

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SSISDB')
BEGIN
    SET @SqlStatement = '
        USE [SSISDB];
        IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name = ''' + @LoginName + ''')
        BEGIN
            CREATE USER [' + @LoginName + '] FROM LOGIN [' + @LoginName + '];
        END
        ALTER ROLE [ssis_admin] ADD MEMBER [' + @LoginName + '];'
    EXEC sp_executesql @SqlStatement
END
```

## Revoke Permissions Script

Run this script after completing your assessment to remove all granted permissions:

```SQL
DECLARE @LoginName NVARCHAR(100) = 'CONTOSO\s2m2admin'
DECLARE @SQL NVARCHAR(MAX)
DECLARE @DatabaseName NVARCHAR(100)

-- Revoke server-level permissions
SET @SQL = 'REVOKE VIEW ANY DEFINITION FROM [' + @LoginName + ']'; EXEC(@SQL);
SET @SQL = 'REVOKE VIEW SERVER STATE FROM [' + @LoginName + ']'; EXEC(@SQL);
SET @SQL = 'REVOKE ALTER ANY SERVER AUDIT FROM [' + @LoginName + ']'; EXEC(@SQL);
SET @SQL = 'REVOKE VIEW ANY DATABASE FROM [' + @LoginName + ']'; EXEC(@SQL);
SET @SQL = 'REVOKE EXECUTE ON xp_regenumkeys FROM [' + @LoginName + ']'; EXEC(@SQL);
SET @SQL = 'REVOKE EXECUTE ON xp_regread FROM [' + @LoginName + ']'; EXEC(@SQL);

-- Drop users from all databases
DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases WHERE state_desc = 'ONLINE'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = '
        USE [' + @DatabaseName + '];
        IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = ''' + @LoginName + ''')
        BEGIN
            DROP USER [' + @LoginName + '];
        END'
    EXEC sp_executesql @SQL
    FETCH NEXT FROM db_cursor INTO @DatabaseName
END

CLOSE db_cursor
DEALLOCATE db_cursor

-- Optionally drop the login entirely
-- SET @SQL = 'DROP LOGIN [' + @LoginName + ']'; EXEC(@SQL);
```
