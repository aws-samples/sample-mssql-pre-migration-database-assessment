# server_mirroring_information.sql

## Description

This SQL Server script collects information about database mirroring. It retrieves details such as database name, mirroring state, mirroring role, mirroring safety level, mirroring partner name and instance, mirroring witness state, and collection date from the system view `sys.database_mirroring`.

## Permissions needed

- `VIEW ANY DATABASE`

## Scope

- Server

## Tables queried

- `sys.database_mirroring`

## Columns

- `SQLInstance`
- `DatabaseName`
- `MirroringState`
- `MirroringRole`
- `MirroringSafetyLevel`
- `MirroringPartnerName`
- `MirroringPartnerInstance`
- `MirroringWitnessState`
- `collect_date`

## Sample Results

| SQLInstance | DatabaseName | MirroringState | MirroringRole | MirroringSafetyLevel | MirroringPartnerName | MirroringPartnerInstance | MirroringWitnessState | collect_date          |
|-------------|--------------|----------------|---------------|----------------------|----------------------|--------------------------|-----------------------|-----------------------|
| ServerName  | Database1    | SYNCHRONIZED   | PARTNER       | FULL                 | PartnerServer1       | Instance1                | SYNCHRONIZED          | 2024-03-07 10:30:00  |
| ServerName  | Database2    | SYNCHRONIZED   | PARTNER       | FULL                 | PartnerServer2       | Instance2                | SYNCHRONIZED          | 2024-03-07 10:31:00  |
