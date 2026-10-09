# mpa.ConfirmLinkedServers

### Description
This stored procedure returns information about Linked Servers in the given SQL Instance.

### Permissions needed
- db_owner

### Tables queried

- raw.server_linked_server_information

### Parameters

| Parameter Name | Data Type | Description                   |
|-----------------|-----------|-------------------------------|
| `@SQLInstance`      | VARCHAR(50)       | SQL Instance where of database being evaluated   |


## Usage

To execute the `mpa.ConfirmLinkedServers` stored procedure, follow these steps:

1. Open a SQL query window in your database management tool.
2. Use the following SQL command to call the procedure:

```sql
EXEC mpa.ConfirmLinkedServers @SQLInstance = 'EC2AMAZ-2I49TPN'
```


### Sample Results

| SQLInstance  |  LinkedServerName | ProviderName  | Product  |  DataSource |RemoteName |  ProviderString | Migrate | Notes |
|---|---|---|---|---|---|---|---|---|
|EC2AMAZ-2I49TPN|MALAWIOIPA|SQLNCLI||db-rds-prd-001.xxxxxxxxxxxx.eu-west-1.rds.amazonaws.com| SYBRINOIPA | | | |
