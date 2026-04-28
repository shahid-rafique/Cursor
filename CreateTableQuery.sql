CREATE TABLE dbo.Table1 (
  id   INT NOT NULL PRIMARY KEY,
  name NVARCHAR(100) NULL
);

CREATE TABLE dbo.Table1_history (
  id         INT NOT NULL,
  name       NVARCHAR(100) NULL,
  archived_on DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.tableLog_error (
  log_id      INT IDENTITY(1,1) PRIMARY KEY,
  searched_id INT NOT NULL,
  message     NVARCHAR(400) NOT NULL,
  logged_at   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

EmployeesToProcess

CREATE TABLE dbo.EmployeesToProcess (
  id         INT NOT NULL,
   emp_date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME())

   --INSERT INTO dbo.Employ_pay (employee_id, pay_period, amount, source_table)

   CREATE TABLE dbo.Employ_pay (
  employee_id         INT NOT NULL,
  pay_period DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  amount decimal,
  source_table varchar(50) NOT NULL,
  emp_date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME())