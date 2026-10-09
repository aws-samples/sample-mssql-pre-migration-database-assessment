# How to Setup and Run the Solution

## Download Scripts & Initial Setup

### Download mssql-pre-database-assessment Project

1. Clone or download the project from the repository.
2. If downloading as a zip, extract the contents.
3. Inside the folder, you will find a subfolder called **DatabaseAssessment**, which will be used throughout this guide.

## Deploying & Running on Customer Infrastructure

### Move DatabaseAssessment Folder to Server

1. Find a server in the customer's infrastructure that has access to the database servers you wish to assess.
2. RDP into the server.
3. Choose a location on the server where you want to place the **DatabaseAssessment** folder (e.g., `C:\DatabaseAssessment`).
4. Copy the **DatabaseAssessment** folder to it.

### Prerequisites

Before running the assessment, ensure:

- PowerShell 5.1 or later is installed
- The `SqlServer` PowerShell module is available (the scripts will attempt to install it if missing)
- The Windows account has access to the SQL Server instances you want to assess
- Network connectivity exists between the execution server and target SQL Server instances

### Updating ServerList.txt

1. Open the `ServerList.txt` file inside the DatabaseAssessment folder.
2. Populate the file with the SQL Server instances you want to assess (one per line):
   - For named instances: `SRVDB001\SQL2016`
   - For default instances: `SRVDB002`
   - If the instance is in another domain: `SRVDB003.corp.sql.com\SQL2017`
3. For Availability Groups, use the primary replica.
4. Save the file.

### Running the Assessment

1. Open a PowerShell console (as Administrator recommended) using the Windows Account created for running the assessments.

2. Navigate to the **DatabaseAssessment** folder.

3. Create the required environment variable:

   ```powershell
   $Env:DB_ASSESSMENT_HOME = 'C:\DatabaseAssessment'
   ```

4. Run the assessment:

   ```powershell
   .\InvokeExecution.ps1
   ```

5. Once completed, output folders are created under `$Env:DB_ASSESSMENT_HOME\mssql-pre-database-assessment`:
   - For default SQL instances: `output-SERVERNAME` (e.g., `output-SRVDB001`)
   - For named SQL instances: `output-SERVERNAME-INSTANCENAME` (e.g., `output-SRVDB002-SQL2016`)

**Note**: The script creates a transcript log at `$Env:DB_ASSESSMENT_HOME\assessment_transcript_<timestamp>.log` for audit purposes.

## Data Consolidation & Data Import

### Run Data Consolidation

1. In the same PowerShell console, run:

   ```powershell
   .\ConsolidateFiles.ps1
   ```

2. Once completed, consolidated files appear in `$Env:DB_ASSESSMENT_HOME\ConsolidatedFiles`:
   - Each assessment script produces a consolidated CSV file containing data from all assessed instances.

### Create AwsDatabaseAssessment Database

You have two options:

#### Option A: Automatic Database Creation (Recommended)

The `LoadDatabase.ps1` script can automatically create the database if it doesn't exist:

```powershell
.\LoadDatabase.ps1 -SqlInstance "YOURSERVER" -DatabaseName "AwsDatabaseAssessment"
```

#### Option B: Manual Database Creation

1. Connect to the SQL Server instance where you want to create the database.
2. Execute the `AwsDatabaseAssessment.sql` script located in `$Env:DB_ASSESSMENT_HOME`.
3. Grant the assessment Windows account `db_owner` permissions:

```sql
USE [master]
GO
-- Replace DOMAIN\UserName with your Windows account
CREATE LOGIN [DOMAIN\UserName] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE [AwsDatabaseAssessment]
GO
CREATE USER [DOMAIN\UserName] FOR LOGIN [DOMAIN\UserName]
GO
ALTER ROLE [db_owner] ADD MEMBER [DOMAIN\UserName]
GO
```

### Run Data Import

Run the data import using command-line parameters:

```powershell
.\LoadDatabase.ps1 -SqlInstance "YOURSERVER" -DatabaseName "AwsDatabaseAssessment"
```

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-SqlInstance` | Yes | SQL Server instance name (e.g., `SRVDB001` or `SRVDB001\SQL2016`) |
| `-DatabaseName` | No | Database name (default: `AwsDatabaseAssessment`) |

**Notes:**
- The script uses Windows Integrated Authentication
- TLS encryption is enforced for all database connections (`-Encrypt Mandatory`)
- The load time varies based on the number of SQL instances and databases assessed
- Progress is displayed in the console as each table is loaded

## Generating Reports

After loading data, generate Excel reports using:

### Application Questionnaire Report

```powershell
.\GenerateAppQuestionnaire.ps1 -SqlInstance "YOURSERVER" -DatabaseName "AwsDatabaseAssessment" -OutputPath "C:\Reports"
```

### RDS Compatibility Report

```powershell
.\GenerateRDSSupport.ps1 -SqlInstance "YOURSERVER" -DatabaseName "AwsDatabaseAssessment" -OutputPath "C:\Reports"
```

Both scripts automatically install the `ImportExcel` module if not present.

## Complete Workflow Summary

```powershell
# 1. Set environment variable
$Env:DB_ASSESSMENT_HOME = 'C:\DatabaseAssessment'

# 2. Navigate to the folder
cd $Env:DB_ASSESSMENT_HOME\DatabaseAssessment

# 3. Run assessment against all servers in ServerList.txt
.\InvokeExecution.ps1

# 4. Consolidate all output files
.\ConsolidateFiles.ps1

# 5. Load data into database (creates DB if needed)
.\LoadDatabase.ps1 -SqlInstance "YOURSERVER"

# 6. Generate reports
.\GenerateAppQuestionnaire.ps1 -SqlInstance "YOURSERVER" -OutputPath "C:\Reports"
.\GenerateRDSSupport.ps1 -SqlInstance "YOURSERVER" -OutputPath "C:\Reports"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "DB_ASSESSMENT_HOME doesn't exist" | Set the environment variable: `$Env:DB_ASSESSMENT_HOME = 'C:\path'` |
| "Access denied" connecting to SQL | Ensure Windows account has access to target SQL instances |
| SqlServer module not found | Run PowerShell as Administrator for automatic installation |
| TLS/SSL errors | Ensure SQL Server has a valid certificate or use SQL Server 2016+ |
| ImportExcel module errors | Run PowerShell as Administrator for automatic installation |

## Security Considerations

- All SQL connections use TLS encryption (`-Encrypt Mandatory`)
- Windows Integrated Authentication is used (no stored credentials)
- Assessment transcript logs are created for audit purposes
- No sensitive data is transmitted outside the environment
