# InvokeExecution.ps1

## Description

The `InvokeExecution.ps1` script orchestrates the database assessment process by executing assessment scripts against each SQL Server instance listed in `ServerList.txt`. It provides progress tracking, error handling, and generates a comprehensive summary report at completion.

## Prerequisites

- `DB_ASSESSMENT_HOME` environment variable must be set
- `ServerList.txt` must exist in the assessment folder with at least one server
- Windows domain account with assessment permissions on target instances (see [permissions.md](../permissions.md))

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_ASSESSMENT_HOME` | Yes | Root folder for the assessment toolkit |

## Audit Logging

The script automatically creates a transcript log file capturing all console output:

- **Location**: `$Env:DB_ASSESSMENT_HOME\assessment-log-yyyyMMdd-HHmmss.txt`
- **Format**: Timestamped text file with full session output
- **Purpose**: Compliance audit trail, troubleshooting, verification of assessed servers

The log file records:
- All servers attempted
- Success/failure status for each server
- Error messages for failed connections
- Timing information

## Populating ServerList.txt

The script reads target servers from `ServerList.txt` located in the `DB_ASSESSMENT_HOME` folder.

1. Navigate to the folder specified in `$Env:DB_ASSESSMENT_HOME`
2. Create or edit `ServerList.txt`
3. Add one SQL Server instance per line:

```text
SERVER001
SERVER002\Instance01
SERVER003.corp.contoso.com
SERVER004.corp.contoso.com\Instance01
SERVER005,50001
```

**Notes:**
- Default instances: Use server name only (e.g., `SRVDB001`)
- Named instances: Use `ServerName\InstanceName` format
- Custom ports: Use `ServerName,Port` format
- For Availability Groups: Specify the primary replica only
- Empty lines are ignored

## Usage

### From PowerShell Console (Recommended)

```powershell
# Set the environment variable (if not already set)
$Env:DB_ASSESSMENT_HOME = 'C:\DatabaseAssessment'

# Navigate to the assessment folder
cd $Env:DB_ASSESSMENT_HOME\DatabaseAssessment

# Run the assessment
.\InvokeExecution.ps1
```

### From PowerShell ISE

1. Open PowerShell ISE
2. Set the environment variable: `$Env:DB_ASSESSMENT_HOME = '<path>'`
3. Open `InvokeExecution.ps1`
4. Press F5 or click Run

## Output

### Console Output

The script displays:
- Progress bar during execution
- Warning messages for failed servers
- Summary report showing success/failure counts

### Assessment Summary Example

```
============================================
           ASSESSMENT SUMMARY
============================================
Total servers in list: 5
Successfully assessed: 4
Failed to assess:      1

Successful servers:
  [OK] SERVER001
  [OK] SERVER002\Instance01
  [OK] SERVER003.corp.contoso.com
  [OK] SERVER004.corp.contoso.com\Instance01

Failed servers:
  [FAILED] SERVER005,50001
           Error: A network-related or instance-specific error occurred...

Assessment log saved to: C:\DatabaseAssessment\assessment-log-20260629-143022.txt
```

### Output Folders

For each assessed instance, a folder is created under `$Env:DB_ASSESSMENT_HOME\mssql-pre-database-assessment\`:

- Default instances: `output-SERVERNAME` (e.g., `output-SRVDB001`)
- Named instances: `output-SERVERNAME-INSTANCENAME` (e.g., `output-SRVDB002-SQL2016`)

Each folder contains CSV files with the assessment data.

## Error Handling

- If `DB_ASSESSMENT_HOME` is not set, the script throws an error and exits
- If `ServerList.txt` is empty, the script displays an error and exits
- If a server assessment fails, the error is logged and the script continues with the next server
- All errors are captured in the transcript log file

## Next Steps

After running `InvokeExecution.ps1`:

1. Run [`ConsolidateFiles.ps1`](ConsolidateFiles.md) to merge assessment data
2. Run [`LoadDatabase.ps1`](LoadDatabase.md) to load data into the assessment database
3. Run [`GenerateAppQuestionnaire.ps1`](GenerateAppQuestionnaire.md) or [`GenerateRDSSupport.ps1`](GenerateRDSSupport.md) to generate reports

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "DB_ASSESSMENT_HOME doesn't exist" | Set the environment variable before running |
| "ServerList.txt is empty" | Add at least one server to the file |
| Server connection failures | Verify network access and permissions |
| No output folders created | Check the transcript log for errors |
