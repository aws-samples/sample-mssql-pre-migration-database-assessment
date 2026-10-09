# server_pbm_information

### Description

This table contains information about Policy-Based Management (PBM) policies on SQL Server instances.

### Schema

- raw

### Table Columns

| Column Name     | Data Type    | Description                                | Constraints         | Example Values           |
|-----------------|--------------|--------------------------------------------|----------------------|--------------------------|
| `SQLInstance`   | VARCHAR(50)  | SQL Server instance name                   | NULL                 | ServerA                  |
| `Policy`        | VARCHAR(256) | Name of the PBM policy                    | NULL                 | MaxDOP                   |
| `Condition`     | VARCHAR(256) | Condition associated with the policy       | NULL                 | Max Degree of Parallelism|
| `facet`         | VARCHAR(256) | Facet of the policy                        | NULL                 | Engine                   |
| `date_created`  | DATETIME     | Date and time when the policy was created | NULL                 | 2024-03-06 10:00:00      |
| `date_modified` | DATETIME     | Date and time when the policy was modified| NULL                 | 2024-03-06 10:30:00      |
| `execution_mode`| VARCHAR(50)  | Execution mode of the policy               | NULL                 | Enforce                  |
| `collect_date`  | DATETIME     | Date and time of data collection           | NULL                 | 2024-03-06 20:00:00      |

### Indexes

- `ix_server_pbm_information_sql_instance`: Clustered index on the `SQLInstance` column for faster lookup of SQL Instances.


### Script

- [server_pbm_information](../scripts/server_pbm_information.md)
