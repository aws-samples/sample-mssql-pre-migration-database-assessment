# server_mirroring_information

### Description

This table contains information about database mirroring configurations on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name               | Data Type    | Description                                   | Constraints         | Example Values           |
|---------------------------|--------------|-----------------------------------------------|----------------------|--------------------------|
| `SQLInstance`             | VARCHAR(50)  | SQL Server instance name                      | NULL                 | ServerA                  |
| `DatabaseName`            | VARCHAR(100) | Name of the mirrored database                 | NULL                 | MyDatabase               |
| `MirroringState`          | NVARCHAR(60) | State of database mirroring                   | NULL                 | SYNCHRONIZED             |
| `MirroringRole`           | NVARCHAR(60) | Role of the server in database mirroring      | NULL                 | PRINCIPAL                |
| `MirroringSafetyLevel`    | NVARCHAR(60) | Safety level of database mirroring            | NULL                 | FULL                     |
| `MirroringPartnerName`    | NVARCHAR(128)| Name of the mirroring partner                 | NULL                 | PartnerServer            |
| `MirroringPartnerInstance`| NVARCHAR(128)| SQL Instance name of the mirroring partner    | NULL                 | PartnerInstance          |
| `MirroringWitnessState`   | NVARCHAR(60) | State of the mirroring witness                 | NULL                 | SYNCHRONIZED             |
| `collect_date`            | DATETIME     | Date and time of data collection              | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_mirroring_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_mirroring_information](../scripts/server_mirroring_information.md)
