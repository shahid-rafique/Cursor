STRING_AGG in SQL Server combines values from multiple rows into one concatenated string.

Basic syntax
STRING_AGG ( expression, separator ) [ WITHIN GROUP ( ORDER BY ... ) ]
expression: the column/value to join (e.g., names)
separator: what goes between values (e.g., ', ')
Example
If Employees has rows: Ali, Sara, John:

SELECT STRING_AGG(Name, ', ') AS AllNames
FROM Employees;
Result: Ali, Sara, John

Ordered output
Without ordering, SQL Server may return values in any order.
Use WITHIN GROUP to control it:

SELECT STRING_AGG(Name, ', ') WITHIN GROUP (ORDER BY Name) AS AllNames
FROM Employees;
Grouped aggregation
Common use: get one comma-separated list per group.

SELECT DepartmentId,
       STRING_AGG(Name, ', ') WITHIN GROUP (ORDER BY Name) AS EmployeeList
FROM Employees
GROUP BY DepartmentId;
Notes
Available in SQL Server 2017+.
NULL values are ignored (they are not added).
Return type depends on input type (often nvarchar/varchar).
It does not remove duplicates by itself; use a subquery with DISTINCT first if needed.
If you want, I can also show:

how to do distinct lists with STRING_AGG
line-break-separated values
old pre-2017 alternative using FOR XML PATH
yes please

Perfect — here are those three practical patterns.

1) DISTINCT values with STRING_AGG
STRING_AGG itself doesn’t support DISTINCT directly, so do it in a subquery/CTE first.

SELECT DepartmentId,
       STRING_AGG(Name, ', ') WITHIN GROUP (ORDER BY Name) AS DistinctEmployeeList
FROM (
    SELECT DISTINCT DepartmentId, Name
    FROM Employees
) d
GROUP BY DepartmentId;
2) Line-break separated values
Use CHAR(10) (LF) or CHAR(13) + CHAR(10) (CRLF, Windows-style).

SELECT STRING_AGG(Name, CHAR(13) + CHAR(10))
       WITHIN GROUP (ORDER BY Name) AS NamesByLine
FROM Employees;
3) Pre-SQL Server 2017 alternative (FOR XML PATH)
Older pattern using XML concatenation + STUFF:

SELECT STUFF((
    SELECT ', ' + e.Name
    FROM Employees e
    ORDER BY e.Name
    FOR XML PATH(''), TYPE
).value('.', 'nvarchar(max)'), 1, 2, '') AS AllNames;
FOR XML PATH('') concatenates rows
STUFF(..., 1, 2, '') removes the first separator ', '
Extra tip: avoid truncation
If strings can get large, cast to nvarchar(max):

SELECT STRING_AGG(CAST(Name AS nvarchar(max)), ', ')
FROM Employees;
If you want, I can give you a ready-to-run demo script (table create + sample data + all queries) you can paste directly into SSMS.