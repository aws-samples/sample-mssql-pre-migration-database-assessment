# rds_instance_sizes

### Description

This table stores information about different Amazon RDS instance sizes including their type, number of virtual CPUs (vCPU), amount of memory, and network performance.

### Schema

- dbo

### Table Columns

| Column Name          | Data Type  | Description                               | Constraints         | Example Values      |
|----------------------|------------|-------------------------------------------|----------------------|---------------------|
| `id`                 | INT        | Unique identifier for the instance size   | NOT NULL             | 1                   |
| `instance_type`      | VARCHAR(20)| Type of the RDS instance                  | NULL                 | db.t3.micro         |
| `vcpu`               | INT        | Number of virtual CPUs                    | NULL                 | 2                   |
| `memory`             | INT        | Amount of memory in MB                    | NULL                 | 2048                |
| `network_performance`| VARCHAR(20)| Network performance of the instance       | NULL                 | Low                 |

### Indexes

- `rds_instance_sizes`: Clustered index on the `id` column for faster lookup of instance sizes.

### Script

- N/A
