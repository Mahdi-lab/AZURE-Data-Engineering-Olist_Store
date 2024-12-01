USE olist_synapse_warehousedb
GO

CREATE OR ALTER PROCEDURE olist_synapse_warehousedb_View 
    @TableName NVARCHAR(1000) -- Correct parameter name
AS
BEGIN
    SET NOCOUNT ON; -- Prevent extra result sets from interfering

    -- Input Validation
    IF @TableName IS NULL OR LEN(@TableName) = 0
    BEGIN
        RAISERROR('TableName cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    -- Validation for TableName (not ViewName)
    IF @TableName NOT LIKE '%[^a-zA-Z0-9_%]%' AND LEN(@TableName) <= 128
    BEGIN
        DECLARE @statement NVARCHAR(MAX);
        DECLARE @fullPath NVARCHAR(1000);

        -- Set the full path with proper escaping
        SET @fullPath = 'https://olistdepi.dfs.core.windows.net/bronze/dbo/' + @TableName + '/';

        -- Construct the dynamic SQL statement
        SET @statement = 'CREATE OR ALTER VIEW ' + QUOTENAME(@TableName) + ' AS
        SELECT *
        FROM OPENROWSET(
            BULK ''' + @fullPath + ''',
            FORMAT = ''PARQUET''
        ) AS [result];';

        BEGIN TRY
            -- Execute the dynamic SQL statement
            EXEC sp_executesql @statement;

            -- Log success
            PRINT 'View ' + QUOTENAME(@TableName) + ' created or altered successfully.';
        END TRY
        BEGIN CATCH
            -- Log the error details
            DECLARE @ErrorMessage NVARCHAR(4000);
            DECLARE @ErrorSeverity INT;
            DECLARE @ErrorState INT;

            SELECT 
                @ErrorMessage = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE();

            RAISERROR('Error creating view: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
        END CATCH
    END
    ELSE
    BEGIN
        RAISERROR('Invalid TableName. It must consist of alphanumeric characters, underscores, or percent signs, and must be less than or equal to 128 characters.', 16, 1);
        RETURN;
    END
END
GO
