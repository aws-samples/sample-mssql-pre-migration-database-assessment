# SQL Server Pre-Migration Database Assessment

PowerShell toolkit for executing pre-migration assessments on SQL Server environments, collecting comprehensive data to support migration planning to AWS.

## Overview

This toolkit collects detailed information from SQL Server instances and databases, consolidates the data, and generates reports to help identify:

- Database configurations and dependencies
- Features requiring migration consideration
- RDS for SQL Server compatibility
- Hardware and performance baselines

## Prerequisites

1. **Windows Server** 2016+ with network access to target SQL Server instances
2. **PowerShell** 5.1 or later
3. **Windows Domain Account** with [required permissions](./permissions.md) on target databases
4. **SqlServer Module**: Automatically installed if missing (requires Administrator)
5. **SQL Server Target**: SQL Server 2016 or later (for TLS encryption support)

**Note**: For the `server_installed_services_information.sql` script, the executing user must be a member of the **sysadmin** server role. This script can be skipped if the permission is not granted.

## Quick Start

```powershell
# 1. Set environment variable
$Env:DB_ASSESSMENT_HOME = 'C:\DatabaseAssessment'

# 2. Navigate to the assessment folder
cd $Env:DB_ASSESSMENT_HOME\DatabaseAssessment

# 3. Edit ServerList.txt with your SQL Server instances

# 4. Run assessment
.\InvokeExecution.ps1

# 5. Consolidate data
.\ConsolidateFiles.ps1

# 6. Load into database
.\LoadDatabase.ps1 -SqlInstance "YOURSERVER"

# 7. Generate reports
.\GenerateAppQuestionnaire.ps1 -SqlInstance "YOURSERVER" -OutputPath "C:\Reports"
```

See the [detailed setup guide](./setup/howto.md) for complete instructions.

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Assessment Workflow                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │ SQL Server  │    │ SQL Server  │    │ SQL Server  │    │ SQL Server  │    │
│  │ Instance 1  │    │ Instance 2  │    │ Instance 3  │    │ Instance N  │    │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    │
│         │                  │                  │                  │           │
│         └──────────────────┴──────────────────┴──────────────────┘           │
│                                    │                                         │
│                                    ▼                                         │
│                    ┌───────────────────────────────┐                         │
│                    │     InvokeExecution.ps1       │                         │
│                    │   (Data Collection + Logging) │                         │
│                    └───────────────┬───────────────┘                         │
│                                    │                                         │
│                                    ▼                                         │
│                    ┌───────────────────────────────┐                         │
│                    │     ConsolidateFiles.ps1      │                         │
│                    │      (Data Merging)           │                         │
│                    └───────────────┬───────────────┘                         │
│                                    │                                         │
│                                    ▼                                         │
│                    ┌───────────────────────────────┐                         │
│                    │      LoadDatabase.ps1         │                         │
│                    │   (Database Import + TLS)     │                         │
│                    └───────────────┬───────────────┘                         │
│                                    │                                         │
│                                    ▼                                         │
│                    ┌───────────────────────────────┐                         │
│                    │   AwsDatabaseAssessment DB    │                         │
│                    └───────────────┬───────────────┘                         │
│                                    │                                         │
│                    ┌───────────────┴───────────────┐                         │
│                    ▼                               ▼                         │
│    ┌───────────────────────────┐   ┌───────────────────────────┐             │
│    │ GenerateAppQuestionnaire  │   │   GenerateRDSSupport      │             │
│    │     (Excel Report)        │   │    (Excel Report)         │             │
│    └───────────────────────────┘   └───────────────────────────┘             │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Workflow Steps

| Step | Script | Description |
|------|--------|-------------|
| 1 | [InvokeExecution.ps1](./powershell/InvokeExecution.md) | Collects data from all SQL Server instances |
| 2 | [ConsolidateFiles.ps1](./powershell/ConsolidateFiles.md) | Merges CSV files from all instances |
| 3 | [LoadDatabase.ps1](./powershell/LoadDatabase.md) | Imports data into assessment database |
| 4 | [GenerateAppQuestionnaire.ps1](./powershell/GenerateAppQuestionnaire.md) | Creates application questionnaire report |
| 5 | [GenerateRDSSupport.ps1](./powershell/GenerateRDSSupport.md) | Creates RDS compatibility report |

## Limitations

- Requires SQL Server 2005+ for DMV-based data collection
- TLS encryption requires SQL Server 2016+ with valid certificates
- Some scripts require elevated SQL Server permissions (sysadmin)

## What Data the Script Collects

### Database Level

- **General Database Information**: Name, collation, compatibility level, recovery model, isolation level, last read/write timestamps
- **CLR**: Common Language Runtime assemblies and configurations
- **Cross-Database References**: Direct references to other databases
- **Filestream**: Filestream-enabled tables and configurations
- **In-Memory OLTP**: Memory-optimized tables and procedures
- **I/O Utilization**: Read/write statistics per database
- **CPU Utilization**: Database-level CPU consumption
- **SSIS Packages**: Packages in SSISDB and MSDB, environment settings, unsupported components
- **SSRS Reports**: Reporting Services report inventory
- **User Permissions**: Database-level securables and permissions
- **Table Information**: Table list, tables without primary keys
- **Replication**: Published tables and replication configuration
- **Database Audit**: Audit specification settings
- **Extended Stored Procedures**: Usage of xp_cmdshell and other extended procedures

### Server Level

- **Backup Statistics**: Backup execution history and statistics
- **Server Configuration**: sp_configure settings
- **CPU Utilization**: SQL process CPU consumption
- **Connected Hosts**: Client hosts connected to the instance
- **Custom Error Messages**: User-defined error messages
- **Database Mail**: Mail configuration and accounts
- **Deprecated Features**: Features flagged for deprecation
- **Instance Information**: Collation, version, edition, build number, installation and reboot times
- **Timezone**: Current server timezone configuration
- **Hardware Information**: CPU count, memory, OS architecture, virtualization platform
- **Linked Servers**: Linked server configurations
- **Logins and Permissions**: Server-level securables and permissions
- **Database Mirroring**: Mirroring configurations
- **SQL Agent**: Proxy accounts, alerts, jobs, operators
- **Service Broker**: Service Broker configurations
- **Trace Flags**: Active trace flags
- **Disk Information**: Volume latency and sizing

## Security

- All database connections enforce TLS encryption
- Windows Integrated Authentication only (no stored passwords)
- Audit transcript logs created for each assessment run
- No data transmitted outside the environment

## Documentation

- [Setup Guide](./setup/howto.md) - Complete installation and configuration instructions
- [Permissions](./permissions.md) - Required SQL Server permissions
- [PowerShell Scripts](./powershell/) - Detailed script documentation

## License

This project is licensed under the MIT-0 License. See the LICENSE file for details.
