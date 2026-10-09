# question_table

### Description

This table is used to store questions based on the environment. This can be used by teams delivering database assessments to ask questions to application teams.

### Schema

- dbo

### Table Columns

| Column Name   | Data Type    | Description                              | Constraints                                              | Example Values     |
|---------------|--------------|------------------------------------------|----------------------------------------------------------|--------------------|
| `id`          | INT          | Unique identifier for the question       | NOT NULL                                                 | 1                  |
| `Question`    | VARCHAR(500) | The question itself                      | NULL                                                     | How to install SQL Server? |
| `Answer`      | VARCHAR(100) | The answer to the question               | NULL                                                     | You can install SQL Server using the installation wizard. |
| `Comments`    | VARCHAR(1000)| Additional comments or notes             | NULL                                                     | Make sure to review the system requirements before installation. |
| `Environment` | VARCHAR(30)  | The environment in which the question applies | NULL                                                 | Production         |
| `enabled`     | BIT          | Indicates whether the question is enabled or not | NULL                                                | 1 (Enabled), 0 (Disabled) |

### Indexes

- `ix_question_table`: Clustered index on the `id` column for faster lookup of questions.

### Script

- N/A
