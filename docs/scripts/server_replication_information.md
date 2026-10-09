# server_replication_information.sql

## Description

This SQL Server script collects replication information including publisher details, publication names, replication types, vendor names, and replication descriptions. It retrieves this information from the `dbo.MSpublications` table in the distributor database.

## Permissions needed

- Public permission on the distributor database

## Scope

- Server

## Tables queried

- `dbo.MSpublications`

## Columns

- `SQLInstance`
- `publisher_id`
- `publisher_db`
- `PublicationName`
- `ReplicationType`
- `VendorName`
- `ReplicationDescription`
- `collect_date`

## Sample Results

| SQLInstance | publisher_id | publisher_db | PublicationName | ReplicationType           | VendorName  | ReplicationDescription | collect_date        |
|-------------|--------------|--------------|-----------------|---------------------------|-------------|------------------------|---------------------|
| ServerName  | 1            | Database1    | Publication1    | Transactional Replication | Vendor1     | Description1           | 2024-03-07 10:30:00 |
| ServerName  | 2            | Database2    | Publication2    | Snapshot Replication      | Vendor2     | Description2           | 2024-03-07 10:31:00 |
