# errorlog

### Description

This table holds the errors that were captured from the PowerShell scripts during the data collection on the SQL Server Instance. This table can be used later to evaluate the errors on particular instance(s), database(s) and script(s)

### Schema

- raw

### Table Columns


| Column Name        | Data Type     | Description    | Constraints| Example Values                            |
|--------------------|---------------|----------------|------------|-------------------------------------------|
| `SQLInstance`      | VARCHAR(50)   | SQL Instance   | NULL       | EC2AMAZ-2I49TPN                           |
| `Category`         | VARCHAR(50)   | Category       | NULL       | Script                                    |
| `DatabaseName`     | VARCHAR(100)  | Database Name  | NULL       | DB001                                     |
| `ScriptName`       | VARCHAR(MAX) | Script Name    | NULL       | server_installed_services_information.sql |
| `ErrorMessage`     | NVARCHAR(MAX) | Error Message  | NULL       | User is not sysadmin                      |
| `date_collected`   | DATETIME      | Date Collected | NULL       | 2024-02-27 03:02:57                       |



### Indexes

- `ix_errorlog`: Index on the `SQLInstance`.

### Script

- N/A
