# dbo.logins_exclusion_list

### Description

This table stores a list of excluded logins along with their reasons and the date they were added.

### Schema

- dbo

### Table Columns

| Column Name   | Data Type    | Description                              | Constraints                                              | Example Values     |
|---------------|--------------|------------------------------------------|----------------------------------------------------------|--------------------|
| `id`          | INT          | Unique identifier for the exclusion      | NOT NULL                                                 | 1                  |
| `login_name`  | VARCHAR(50)  | Name of the excluded login               | NULL                                                     | user1              |
| `reason`      | VARCHAR(100) | Reason for exclusion                     | NULL                                                     | Deprecated account |
| `date_added`  | DATETIME     | Date and time the login was added        | NULL                                                     | 2024-03-05 20:30:00|

### Indexes

- `ix_logins_exclusion_list`: Clustered index on the `login_name` column for faster lookup of logins.

### Script

- N/A
