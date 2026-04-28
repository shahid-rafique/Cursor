DECLARE @id INT, @emp_date DATE;
DECLARE @employee_id INT, @pay_period DATE, @amount DECIMAL(18,2), @source_table NVARCHAR(50);
DECLARE @found BIT;

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
    SET @found = 0;
	set @emp_date='2025-09-01'
    /* Cursor 1: Table1 */
    DECLARE c_t1 CURSOR LOCAL FAST_FORWARD FOR
    SELECT t.id, CAST(GETDATE() AS date), 2000.00, N'Table1'
    FROM dbo.Table1 t
    WHERE t.id = @id;

    OPEN c_t1;
    FETCH NEXT FROM c_t1 INTO @employee_id, @pay_period, @amount, @source_table;
    IF @@FETCH_STATUS = 0 SET @found = 1;
    CLOSE c_t1;
    DEALLOCATE c_t1;

    /* Cursor 2: Table1_history (only if not found in Table1) */
    IF @found = 0
    BEGIN
        DECLARE c_hist CURSOR LOCAL FAST_FORWARD FOR
        SELECT h.id, CAST(GETDATE() AS date), 20000.00, N'Table1_history'
        FROM dbo.Table1_history h
        WHERE h.id = @id
          AND h.archived_on >= @emp_date -->= '2026-09-01'
          --AND h.emp_date <= @emp_date;  -- optional upper bound

        OPEN c_hist;
        FETCH NEXT FROM c_hist INTO @employee_id, @pay_period, @amount, @source_table;
        IF @@FETCH_STATUS = 0 SET @found = 1;
        CLOSE c_hist;
        DEALLOCATE c_hist;
    END

    IF @found = 1
    BEGIN
        INSERT INTO dbo.Employ_pay (employee_id, pay_period, amount, source_table)
        VALUES (@employee_id, @pay_period, @amount, @source_table);
    END
    ELSE
    BEGIN
        INSERT INTO dbo.tableLog_error (searched_id, message)
        VALUES (@id, N'id not found in Table1 or eligible Table1_history.');
    END

    FETCH NEXT FROM c_emp INTO @id, @emp_date;
END

CLOSE c_emp;
DEALLOCATE c_emp;