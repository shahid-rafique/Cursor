DECLARE @id INT, @emp_date DATE;
DECLARE @employee_id INT, @pay_period DATE, @amount DECIMAL(18,2), @source_table NVARCHAR(50);

-- Outer cursor: employees to process
DECLARE c_emp CURSOR LOCAL FAST_FORWARD FOR
SELECT e.id, e.emp_date
FROM dbo.EmployeesToProcess e;

OPEN c_emp;
FETCH NEXT FROM c_emp INTO @id, @emp_date;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @employee_id = NULL;
    SET @pay_period = NULL;
    SET @amount = NULL;
    SET @source_table = NULL;

    -- Inner cursor using UNION ALL (no CTE)
    DECLARE c_src CURSOR LOCAL FAST_FORWARD FOR
    SELECT employee_id, pay_period, amount, source_table
    FROM
    (
        SELECT
            t.id AS employee_id,
            CAST(GETDATE() AS DATE) AS pay_period,
            CAST(2000.00 AS DECIMAL(18,2)) AS amount,
            N'Table1' AS source_table,
            1 AS priority
        FROM dbo.Table1 t
        WHERE t.id = @id

        UNION ALL

        SELECT
            h.id AS employee_id,
            CAST(GETDATE() AS DATE) AS pay_period,
            CAST(20000.00 AS DECIMAL(18,2)) AS amount,
            N'Table1_history' AS source_table,
            2 AS priority
        FROM dbo.Table1_history h
        WHERE h.id = @id
          AND h.archived_on >= @emp_date
    ) x
    ORDER BY x.priority; -- Table1 first, then history

    OPEN c_src;
    FETCH NEXT FROM c_src INTO @employee_id, @pay_period, @amount, @source_table; -- first match only

    IF @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.Employ_pay (employee_id, pay_period, amount, source_table)
        VALUES (@employee_id, @pay_period, @amount, @source_table);
    END
    ELSE
    BEGIN
        INSERT INTO dbo.tableLog_error (searched_id, message)
        VALUES (@id, N'id not found in Table1 or eligible Table1_history.');
    END

    CLOSE c_src;
    DEALLOCATE c_src;

    FETCH NEXT FROM c_emp INTO @id, @emp_date;
END

CLOSE c_emp;
DEALLOCATE c_emp;