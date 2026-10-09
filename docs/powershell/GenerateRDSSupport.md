# GenerateRDSSupport.ps1

## Description

The `GenerateRDSSupport.ps1` script generates an Excel report showing RDS for SQL Server compatibility for all SQL Server instances in the assessment database. The report highlights features that are supported or not supported on Amazon RDS for SQL Server, helping prioritize migration targets.

## Prerequisites

- `DB_ASSESSMENT_HOME` environment variable must be set (or use `-OutputFolder` parameter)
- `AwsDatabaseAssessment` database must exist and be populated (run `LoadDatabase.ps1` first)
- `ImportExcel` PowerShell module (auto-installed if missing)

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `-SqlInstance` | string | No | `$Env:COMPUTERNAME` | SQL Server instance where the assessment database resides |
| `-DatabaseName` | string | No | `AwsDatabaseAssessment` | Name of the assessment database |
| `-OutputFolder` | string | No | `$Env:DB_ASSESSMENT_HOME` | Folder where the Excel file will be created |

## Usage

### Basic Usage

```powershell
.\GenerateRDSSupport.ps1
```

### Specify SQL Server Instance

```powershell
.\GenerateRDSSupport.ps1 -SqlInstance "SQLSERVER01"
```

### Specify All Parameters

```powershell
.\GenerateRDSSupport.ps1 `
    -SqlInstance "SQLSERVER01" `
    -DatabaseName "AwsDatabaseAssessment" `
    -OutputFolder "C:\Reports"
```

### Full Workflow Example

```powershell
# Set environment variable
$Env:DB_ASSESSMENT_HOME = 'C:\DatabaseAssessment'

# Navigate to the assessment folder
cd $Env:DB_ASSESSMENT_HOME\DatabaseAssessment

# Generate RDS support report
.\GenerateRDSSupport.ps1 -SqlInstance "SQLSERVER01"
```

## Output

### Output File

The Excel file is created in the specified output folder:

```
<OutputFolder>/RDSSupport_V1_<date>.xlsx
```

Example: `C:\DatabaseAssessment\RDSSupport_V1_20260629.xlsx`

### Excel Worksheet: RDS Support

The report contains a single worksheet with one row per SQL Server instance assessed:

| Column | Description | Values |
|--------|-------------|--------|
| SQLInstance | SQL Server instance name | Instance identifier |
| ResourceGovernor | Resource Governor usage | True/False |
| MaintenancePlans | Maintenance Plans usage | True/False |
| PolicyBasedManagement | Policy-Based Management | True/False |
| DatabaseSnapshots | Database Snapshots usage | True/False |
| ServerTriggers | Server-level Triggers | True/False |
| XPCmdShell | xp_cmdshell usage | True/False |
| BufferPoolExtension | Buffer Pool Extension | True/False |
| StretchDatabase | Stretch Database | True/False |
| ServiceBrokerEnpoints | Service Broker Endpoints | True/False |
| LogShipping | Log Shipping configuration | True/False |
| Replication | Transactional/Merge Replication | True/False |
| TCPEndpoints | Custom TCP Endpoints | True/False |
| Polybase | PolyBase configuration | True/False |
| MachineLearningServices | ML Services | True/False |
| DataQualityServices | Data Quality Services | True/False |
| PerformanceDataCollector | Performance Data Collector | True/False |
| CLRSupport | CLR Assemblies | True/False |
| StorageSize | Storage exceeds RDS limits | True/False |
| VersionSupport | SQL Server version supported | True/False |

### Conditional Formatting

- **Green (LightGreen)**: Feature is **not used** (`False`) - no migration blocker
- **Yellow**: Feature **is used** (`True`) - requires attention during migration planning

### Sample Output

| SQLInstance | ResourceGovernor | MaintenancePlans | XPCmdShell | CLRSupport | StorageSize | VersionSupport |
|-------------|------------------|------------------|------------|------------|-------------|----------------|
| SQLPROD01 | False | False | False | True | False | False |
| SQLPROD02 | False | True | False | False | False | False |
| SQLDEV01 | False | False | True | False | False | False |

## Tables Queried

- [`raw.server_general_information`](../tables/server_general_information.md) - List of assessed instances

## Stored Procedures Executed

| Procedure | Purpose |
|-----------|---------|
| [`mpa.ConfirmRDSSupport`](../stored_procedures/mpa.ConfirmRDSSupport.md) | Evaluates RDS compatibility for each instance |

## RDS Feature Support Reference

| Feature | RDS Support | Notes |
|---------|-------------|-------|
| Resource Governor | No | Use RDS instance sizing instead |
| Maintenance Plans | Limited | Use RDS automated backups |
| Database Snapshots | No | Use RDS snapshots |
| xp_cmdshell | No | Security restriction |
| Buffer Pool Extension | No | Use memory-optimized instances |
| Stretch Database | No | Deprecated in SQL Server 2022 |
| Log Shipping | Yes | Supported for migration |
| Replication | Yes | Publisher/Subscriber supported |
| CLR | Limited | SAFE assemblies only |
| PolyBase | No | Use AWS Glue or Athena |
| ML Services | No | Use Amazon SageMaker |

## Error Handling

| Scenario | Behavior |
|----------|----------|
| `OutputFolder` not set and `DB_ASSESSMENT_HOME` missing | Throws error and exits |
| No instances in `server_general_information` | Generates empty report |
| ImportExcel module missing | Auto-installs from PowerShell Gallery |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "OutputFolder parameter not provided" | Set `$Env:DB_ASSESSMENT_HOME` or use `-OutputFolder` parameter |
| Empty report | Verify data exists in `raw.server_general_information` |
| ImportExcel installation fails | Run PowerShell as Administrator or use `-Scope CurrentUser` |
| Connection failure | Verify SQL Server connectivity and permissions |

## Security Notes

- Uses TLS encryption (`-Encrypt Mandatory`) when supported by the SqlServer module
- Uses parameterized queries via `-Variable` to prevent SQL injection
- Windows Integrated Authentication is used (no passwords in scripts)

## Comparison with GenerateAppQuestionnaire.ps1

| Feature | GenerateRDSSupport.ps1 | GenerateAppQuestionnaire.ps1 |
|---------|------------------------|------------------------------|
| Scope | All instances | Single application/environment |
| Output | Single worksheet | Multiple worksheets |
| Parameters | 3 optional | 2 required, 3 optional |
| Use Case | Quick compatibility overview | Detailed migration planning |

Use `GenerateRDSSupport.ps1` for a quick overview of which instances are RDS-compatible. Use `GenerateAppQuestionnaire.ps1` for detailed migration planning for a specific application.

## Next Steps

After generating the RDS support report:

1. Review instances with `True` values (yellow highlighting) - these have features not supported on RDS
2. For instances with many unsupported features, consider EC2 as the migration target
3. Use [`GenerateAppQuestionnaire.ps1`](GenerateAppQuestionnaire.md) for detailed analysis of specific applications
4. Consult the [RDS for SQL Server documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html) for current feature support
