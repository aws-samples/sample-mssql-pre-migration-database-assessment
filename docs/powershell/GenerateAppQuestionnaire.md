# GenerateAppQuestionnaire.ps1

## Description

The `GenerateAppQuestionnaire.ps1` script generates an Excel-based assessment questionnaire for a specific application and environment. The output includes multiple worksheets covering general information, SSIS packages, SSRS reports, SQL Agent jobs, linked servers, database mail, configuration settings, users, CLR objects, credentials, RDS support, and database dependencies.

## Prerequisites

- `DB_ASSESSMENT_HOME` environment variable must be set
- `AwsDatabaseAssessment` database must exist and be populated (run `LoadDatabase.ps1` first)
- `ImportExcel` PowerShell module (auto-installed if missing)
- Application and environment must be registered in `mpa.master_applications` and `mpa.master_databases` tables

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `-SqlInstance` | string | No | `$Env:COMPUTERNAME` | SQL Server instance where the assessment database resides |
| `-DatabaseName` | string | No | `AwsDatabaseAssessment` | Name of the assessment database |
| `-AppName` | string | **Yes** | — | Application name to generate the questionnaire for |
| `-Environment` | string | **Yes** | — | Environment name (Development, Quality Assurance, Production, Training) |
| `-OutputFolder` | string | No | `$Env:DB_ASSESSMENT_HOME` | Folder where the Excel file will be created |

## Usage

### Basic Usage

```powershell
.\GenerateAppQuestionnaire.ps1 -AppName "MyApplication" -Environment "Production"
```

### Specify SQL Server Instance

```powershell
.\GenerateAppQuestionnaire.ps1 -SqlInstance "SQLSERVER01" -AppName "CRM System" -Environment "Development"
```

### Specify All Parameters

```powershell
.\GenerateAppQuestionnaire.ps1 `
    -SqlInstance "SQLSERVER01" `
    -DatabaseName "AwsDatabaseAssessment" `
    -AppName "ERP System" `
    -Environment "Quality Assurance" `
    -OutputFolder "C:\Reports"
```

### Full Workflow Example

```powershell
# Set environment variable
$Env:DB_ASSESSMENT_HOME = 'C:\DatabaseAssessment'

# Navigate to the assessment folder
cd $Env:DB_ASSESSMENT_HOME\DatabaseAssessment

# Generate questionnaire for Production environment
.\GenerateAppQuestionnaire.ps1 -SqlInstance "SQLSERVER01" -AppName "OrderProcessing" -Environment "Production"
```

## Environment Values

The `-Environment` parameter accepts these values:

| Value | File Name Abbreviation |
|-------|------------------------|
| `Development` | DEV |
| `Quality Assurance` | QA |
| `Production` | PRD |
| `Training` | TR |

## Output

### Output File Location

The Excel file is created in a subfolder under `OutputFolder`:

```
<OutputFolder>/<ENV> - <ApplicationId> - <AppName>/MSSQL_Assessment_Checklist_V1_<AppName>_<ENV>_<date>.xlsx
```

Example:
```
C:\DatabaseAssessment\PRD - 42 - OrderProcessing\MSSQL_Assessment_Checklist_V1_OrderProcessing_PRD_20260629.xlsx
```

### Excel Worksheets Generated

| Worksheet | Description |
|-----------|-------------|
| ADM Questionnaire | Migration questionnaire with standardized questions |
| General Information | Database overview with migration target recommendations |
| Confirm SSIS Packages | SSIS packages requiring migration |
| Confirm SSRS Reports | SSRS reports requiring migration |
| Confirm SQL Server Agent Jobs | SQL Agent jobs associated with the application |
| Confirm Linked Servers | Linked server configurations (Oracle connections highlighted) |
| Confirm Database Mail | Database mail profiles and accounts |
| Non-Default sp_configure | Server configuration settings that differ from defaults |
| Confirm Database Users | Database users and their role memberships |
| Confirm CLR Usage | CLR assemblies deployed in databases |
| Confirm Server Credentials | SQL Server credentials in use |
| RDS Support | RDS for SQL Server compatibility assessment |
| Database Dependencies | Cross-database dependencies |
| Database Downgrade | Enterprise to Standard edition compatibility |

### Data Validation Lists

The General Information worksheet includes dropdown lists for:
- Column R-S: Yes/No selections
- Column U: RDS/EC2 target platform
- Column V: Migration method (Backup/Restore, DMS/Replication, MGN)
- Column W-X: Yes/No selections

### Conditional Formatting

- **Linked Servers**: Oracle OLEDB and MSOLAP providers highlighted in yellow
- **sp_configure**: xp_cmdshell, Ole Automation, Polybase, Filestream, Hadoop highlighted
- **Database Users**: sysadmin role members highlighted in yellow
- **RDS Support**: Unsupported features (True) highlighted in yellow, supported (False) in green

## Tables Queried

- `sys.databases`
- `mpa.master_applications`
- `mpa.master_databases`
- `dbo.question_table`
- `dbo.vw_database_general_information`

## Stored Procedures Executed

| Procedure | Purpose |
|-----------|---------|
| `mpa.GeneralInformation` | Database general information |
| `mpa.ConfirmSSISPackages` | SSIS package inventory |
| `mpa.ConfirmSSRSReports` | SSRS report inventory |
| `mpa.ConfirmAgentJobs` | SQL Agent job inventory |
| `mpa.ConfirmLinkedServers` | Linked server configurations |
| `mpa.ConfirmDatabaseMail` | Database mail settings |
| `mpa.ConfirmSPConfigure` | Non-default server settings |
| `mpa.ConfirmDatabaseUsers` | Database users and permissions |
| `mpa.ConfirmCLRUsage` | CLR assembly inventory |
| `mpa.ConfirmCredentials` | Server credential inventory |
| `mpa.ConfirmRDSSupport` | RDS compatibility check |
| `mpa.ConfirmDatabaseInterdependency` | Cross-database dependencies |
| `mpa.ConfirmDowngradeToStandard` | Edition downgrade compatibility |

## Error Handling

| Scenario | Behavior |
|----------|----------|
| `OutputFolder` not set and `DB_ASSESSMENT_HOME` missing | Throws error and exits |
| `AwsDatabaseAssessment` database doesn't exist | Throws error and exits |
| Application not found for environment | Displays message and exits |
| ImportExcel module missing | Auto-installs from PowerShell Gallery |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Application [X] not found for Environment [Y]" | Register the application in `mpa.master_applications` and databases in `mpa.master_databases` |
| "AwsDatabaseAssessment doesn't exist" | Run `LoadDatabase.ps1` first |
| "OutputFolder parameter not provided" | Set `$Env:DB_ASSESSMENT_HOME` or use `-OutputFolder` parameter |
| ImportExcel installation fails | Run PowerShell as Administrator or use `-Scope CurrentUser` |
| Excel file not created | Check for errors in stored procedure execution |

## Security Notes

- Uses TLS encryption (`-Encrypt Mandatory`) when supported by the SqlServer module
- Uses parameterized queries via `-Variable` to prevent SQL injection
- Windows Integrated Authentication is used (no passwords in scripts)
- Temporary CSV files are automatically cleaned up after Excel generation

## Next Steps

After generating the questionnaire:

1. Open the Excel file and review each worksheet
2. Complete the ADM Questionnaire with application-specific answers
3. Fill in the General Information migration targets (RDS/EC2)
4. Review highlighted items that may require special attention during migration
5. Use [`GenerateRDSSupport.ps1`](GenerateRDSSupport.md) for a focused RDS compatibility report
