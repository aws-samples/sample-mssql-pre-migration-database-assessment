# server_trace_flag_information.sql

## Description

This SQL Server script retrieves the trace flags currently in place on the server. It creates a temporary table to store the trace flag information, then inserts the trace flag status using the `DBCC TRACESTATUS` command. Finally, it selects the trace flag details from the temporary table and displays them along with the server instance name and collection date.

## Permissions needed

- `VIEW SERVER STATE`

## Scope

- Server

## Tables queried

- None

## Columns

- `SQLInstance`
- `TraceFlag`
- `Status`
- `Global`
- `Session`
- `collect_date`

## Sample Results

| SQLInstance | TraceFlag | Status | Global | Session | collect_date          |
|-------------|-----------|--------|--------|---------|-----------------------|
| ServerName  | 123       | 1      | 1      | 0       | 2024-03-07 10:30:00  |
| ServerName  | 456       | 0      | 0      | 1       | 2024-03-07 10:31:00  |
