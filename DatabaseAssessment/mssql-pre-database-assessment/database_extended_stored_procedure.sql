    DECLARE @SearchString NVARCHAR(100)
    SET @SearchString = 'xp_' -- Search string for extended stored procedures starting with 'xp_'

    DECLARE @ProcedureName NVARCHAR(200)

    -- Create a temporary table to store the results
    CREATE TABLE #Results (
        ProcedureName NVARCHAR(200),
        Code NVARCHAR(MAX)
    )

    -- Loop through all stored procedures in the database
    DECLARE proc_cursor CURSOR FOR
    SELECT [name]
    FROM sys.procedures

    OPEN proc_cursor
    FETCH NEXT FROM proc_cursor INTO @ProcedureName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get the definition using parameterized approach (safe from SQL injection)
        DECLARE @ProcedureDefinition NVARCHAR(MAX)
        SELECT @ProcedureDefinition = definition
        FROM sys.sql_modules
        WHERE object_id = OBJECT_ID(@ProcedureName)

        -- Search through the code of the stored procedure for the usage of extended stored procedures
        DECLARE @StartPosition INT
        DECLARE @EndPosition INT
        DECLARE @FoundCode NVARCHAR(MAX)

        SET @StartPosition = CHARINDEX(@SearchString, @ProcedureDefinition, 1)

        WHILE @StartPosition > 0
        BEGIN
            SET @EndPosition = CHARINDEX(CHAR(13), @ProcedureDefinition, @StartPosition)
            IF @EndPosition = 0
                SET @EndPosition = LEN(@ProcedureDefinition)

            SET @FoundCode = SUBSTRING(@ProcedureDefinition, @StartPosition, @EndPosition - @StartPosition)
            INSERT INTO #Results (ProcedureName,Code)
            VALUES (@ProcedureName,  @FoundCode)

            SET @StartPosition = CHARINDEX(@SearchString, @ProcedureDefinition, @EndPosition)
        END

        FETCH NEXT FROM proc_cursor INTO @ProcedureName
    END

    CLOSE proc_cursor
    DEALLOCATE proc_cursor

    -- Select the results
    SELECT @@SERVERNAME as SQLInstance,DB_NAME(DB_ID()) as DatabaseName,ProcedureName, Code, GETDATE() as date_collected
    FROM #Results

    -- Drop the temporary table
    DROP TABLE #Results
