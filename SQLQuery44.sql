WITH emp AS (
    SELECT e.id,
           e.emp_date
    FROM dbo.EmployeesToProcess AS e
),
/* One row per employee: Table1 wins over history */
resolved AS (
    SELECT
        e.id AS searched_id,
        COALESCE(t.id, h.id) AS employee_id,
        CAST(GETDATE() AS DATE) AS pay_period,
        CASE
            WHEN t.id IS NOT NULL THEN CAST(2000.00 AS DECIMAL(18, 2))
            ELSE CAST(20000.00 AS DECIMAL(18, 2))
        END AS amount,
        CASE
            WHEN t.id IS NOT NULL THEN N'Table1'
            ELSE N'Table1_history'
        END AS source_table,
        CASE
            WHEN t.id IS NOT NULL THEN 1
            WHEN h.id IS NOT NULL THEN 1
            ELSE 0
        END AS found
    FROM emp AS e
    LEFT JOIN dbo.Table1 AS t
        ON t.id = e.id
    LEFT JOIN dbo.Table1_history AS h
        ON h.id = e.id
       AND t.id IS NULL   -- only when no row in Table1
    -- Optional history filters (uncomment and adjust as needed):
    -- AND h.archived_on >= e.emp_date
    -- AND h.emp_date <= e.emp_date
)
INSERT INTO dbo.Employ_pay (employee_id, pay_period, amount, source_table)
SELECT r.employee_id, r.pay_period, r.amount, r.source_table
FROM resolved AS r
WHERE r.found = 1;

WITH emp AS (
    SELECT e.id,
           e.emp_date
    FROM dbo.EmployeesToProcess AS e
),
resolved AS (
    SELECT
        e.id AS searched_id,
        COALESCE(t.id, h.id) AS employee_id,
        CAST(GETDATE() AS DATE) AS pay_period,
        CASE
            WHEN t.id IS NOT NULL THEN CAST(2000.00 AS DECIMAL(18, 2))
            ELSE CAST(20000.00 AS DECIMAL(18, 2))
        END AS amount,
        CASE
            WHEN t.id IS NOT NULL THEN N'Table1'
            ELSE N'Table1_history'
        END AS source_table,
        CASE
            WHEN t.id IS NOT NULL THEN 1
            WHEN h.id IS NOT NULL THEN 1
            ELSE 0
        END AS found
    FROM emp AS e
    LEFT JOIN dbo.Table1 AS t
        ON t.id = e.id
    LEFT JOIN dbo.Table1_history AS h
        ON h.id = e.id
       AND t.id IS NULL
)
INSERT INTO dbo.tableLog_error (searched_id, message)
SELECT r.searched_id, N'id not found in Table1 or eligible Table1_history.'
FROM resolved AS r
WHERE r.found = 0;