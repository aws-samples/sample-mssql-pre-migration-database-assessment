#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0


<#
    .SYNOPSIS
    Assessment.ps1

    .DESCRIPTION
    This execute the SQL scrpits.

    .PARAMETER ServerName
        The SQL Server Instance name. If the target is a named Instance , it must have host\instance name e.g. SERVER1\PROD

    .PARAMETER ScriptFolder
        The folder location tothe .SQL files to be executed

    .EXAMPLE
    .\Assessment.ps1 -ServerName 'Server1' -ScriptFolder 'C:\Temp'

    .NOTES
        Author: Marcos Freccia (mfreccia)
        Date:
        Description: Script creation


        Updated by: Marcelo Fernandes (marcesl)
        Date:       01/10/2021
        Description: Added new scripts to collect CLR, AG,Event Notification, SQL Services, Maintenance Plan, Reseource Governor and Serve Triggers informations

        Updated by: Marcelo Fernandes (marcesl)
        Date:       10/04/2021
        Description: Added new scripts to collect Inmemory, DB Snapshot, Logshipping, TDE and PBM informations

        Updated by: Marcos Freccia (mfreccia)
        Date:       28/10/2021
        Description: Added new scripts to collect TCP Port, Non supported RDS Features
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$ScriptFolder,
    [Parameter(Mandatory = $true)]
    [string]$ServerName
)

#############
# Functions
#############
function Test-CommandParameter {
    param (
        [string]$CommandName,
        [string]$ParameterName
    )

    try {
        $command = Get-Command $CommandName -ErrorAction SilentlyContinue
        if (-not $command) { 
            return $false 
        }
        if (-not $command.Parameters) { 
            return $false 
        }
        # Use -contains operator instead of .ContainsKey() method to avoid null reference issues
        # when the Parameters dictionary is in an unexpected state
        return ($command.Parameters.Keys -contains $ParameterName)
    }
    catch {
        # If anything goes wrong, assume the parameter doesn't exist
        Write-Verbose "Could not check parameter [$ParameterName] for command [$CommandName]: $($_.Exception.Message)"
        return $false
    }
}

function Test-SqlServerConnection {
    <#
    .SYNOPSIS
    Tests if a SQL Server instance is reachable and accepting connections.
    
    .DESCRIPTION
    Attempts a simple query to verify SQL Server connectivity before running the full assessment.
    Fails fast with a clear error message if the connection cannot be established.
    
    .PARAMETER ServerInstance
    The SQL Server instance name to test.
    
    .RETURNS
    $true if connection succeeds, throws an exception if connection fails.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServerInstance
    )
    
    Write-Verbose "Testing SQL Server connection to [$ServerInstance]..."
    
    # First check if Invoke-Sqlcmd is available
    $sqlcmdCommand = Get-Command "Invoke-Sqlcmd" -ErrorAction SilentlyContinue
    if (-not $sqlcmdCommand) {
        throw "Invoke-Sqlcmd is not available. Please install the SqlServer PowerShell module:`n  Install-Module -Name SqlServer -Scope CurrentUser`n`nOr import the SQLPS module if using SQL Server Management Studio."
    }
    
    $params = @{
        ServerInstance    = $ServerInstance
        Database          = "master"
        Query             = "SELECT 1 AS ConnectionTest"
        ConnectionTimeout = 15
        ErrorAction       = "Stop"
    }
    
    # Safely check if TrustServerCertificate parameter exists
    $hasTrustCertParam = Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate"
    if ($hasTrustCertParam) {
        $params.TrustServerCertificate = $true
    }
    
    # Enforce TLS encryption if supported (SqlServer module v22+)
    if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
        $params.Encrypt = "Mandatory"
    }
    
    try {
        $result = Invoke-Sqlcmd @params
        if ($result) {
            Write-Verbose "Successfully connected to SQL Server instance [$ServerInstance]"
        }
        return $true
    }
    catch {
        $errorMessage = $_.Exception.Message
        
        # Provide user-friendly error messages for common scenarios
        if ($errorMessage -match "network-related|connection was forcibly closed|server was not found|could not be found") {
            throw "Cannot connect to SQL Server instance [$ServerInstance]. Verify that:`n  - The server name is correct`n  - SQL Server is installed and running on the target machine`n  - The SQL Server Browser service is running (for named instances)`n  - Firewall allows connections on TCP port 1433 (or the configured port)`n`nOriginal error: $errorMessage"
        }
        elseif ($errorMessage -match "Login failed") {
            throw "Authentication failed for SQL Server instance [$ServerInstance]. Verify that:`n  - Your Windows account has access to the SQL Server`n  - The SQL Server is configured for Windows Authentication`n`nOriginal error: $errorMessage"
        }
        elseif ($errorMessage -match "certificate") {
            throw "SSL/TLS certificate error connecting to [$ServerInstance]. The server certificate may not be trusted.`n`nOriginal error: $errorMessage"
        }
        else {
            throw "Failed to connect to SQL Server instance [$ServerInstance].`n`nOriginal error: $errorMessage"
        }
    }
}

function Add-SqlSecurityParams {
    <#
    .SYNOPSIS
    Adds TLS and certificate security parameters to an Invoke-Sqlcmd params hashtable.
    
    .DESCRIPTION
    Checks if TrustServerCertificate and Encrypt parameters are supported by the 
    installed SqlServer module and adds them to the params hashtable if available.
    This ensures TLS encryption is enforced when possible.
    
    .PARAMETER Params
    The hashtable of parameters to modify (passed by reference).
    #>
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Params
    )
    
    # Check if the TrustServerCertificate parameter exists
    if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "TrustServerCertificate") {
        $Params.TrustServerCertificate = $true
    }
    
    # Enforce TLS encryption if supported (SqlServer module v22+)
    if (Test-CommandParameter -CommandName "Invoke-Sqlcmd" -ParameterName "Encrypt") {
        $Params.Encrypt = "Mandatory"
    }
}

try {
    Write-Output "Starting assessment for [$ServerName]"
    #############
    # Variables
    #############

    $OutputFolder = Join-Path -Path $ScriptFolder -ChildPath ("output-" + $ServerName.Replace("\", "-"))

    Write-Output "Output folder is: [$OutputFolder]"

    $PrimaryKeyInformation = Join-Path $ScriptFolder -ChildPath database_primary_key_information.sql
    $BackupInformation = Join-Path $ScriptFolder -ChildPath server_backup_information.sql
    $DatabaseMailInformation = Join-Path $ScriptFolder -ChildPath server_database_mail_information.sql
    $ReportingServicesInformation = Join-Path $ScriptFolder -ChildPath database_ssrs_reports_information.sql
    $ReportingServicesSubscriptionInformation = Join-Path $ScriptFolder -ChildPath database_ssrs_subscription_information.sql #3
    $MirroringInformation = Join-Path $ScriptFolder -ChildPath server_mirroring_information.sql
    $ReplicationInformation = Join-Path $ScriptFolder -ChildPath server_replication_information.sql
    $PublisherInformation = Join-Path $ScriptFolder -ChildPath database_replication_publisher_information.sql
    $GeneralDatabaseInformation = Join-Path $ScriptFolder -ChildPath database_general_information.sql
    $TraceFlagInformation = Join-Path $ScriptFolder -ChildPath server_trace_flag_information.sql
    $VolumeInformation = Join-Path $ScriptFolder -ChildPath server_volume_information.sql
    $VolumeLatencyInformation = Join-Path $ScriptFolder -ChildPath server_volume_latency.sql
    $CPUUtilizationPerDB = Join-Path $ScriptFolder -ChildPath database_cpu_utilization.sql
    $IOUtilizationPerDB = Join-Path $ScriptFolder -ChildPath database_io_utilization.sql
    $ConnectionsPerIPAddress = Join-Path $ScriptFolder -ChildPath server_connections_by_ip_address.sql
    $ConfigurationsInUse = Join-Path $ScriptFolder -ChildPath server_configuration_in_use.sql
    $CustomMessages = Join-Path $ScriptFolder -ChildPath server_custom_errors_created.sql
    $AgentOperators = Join-Path $ScriptFolder -ChildPath server_agent_operators.sql
    $ProxyAgentUsage = Join-Path $ScriptFolder -ChildPath server_proxy_agent_information.sql
    $LinkedServerInformation = Join-Path $ScriptFolder -ChildPath server_linked_server_information.sql
    $SSISPackagesInMSDB = Join-Path $ScriptFolder -ChildPath database_msdb_ssis_packages.sql
    $SSISPackagesConnectionTypeInMSDB = Join-Path $ScriptFolder -ChildPath ssis_packages_connection_type_msdb.sql
    $SSISPackagesInSSISDB = Join-Path $ScriptFolder -ChildPath database_ssisdb_ssis_packages.sql
    $EnvironmentSettingsSSISDB = Join-Path $ScriptFolder -ChildPath database_environment_settings_on_ssisdb.sql
    $HardwareInformation = Join-Path $ScriptFolder -ChildPath server_hardware_information.sql
    $SQLServerAgentAlerts = Join-Path $ScriptFolder -ChildPath server_agent_alerts.sql
    $UsersAndPermissionsPerDb = Join-Path $ScriptFolder -ChildPath database_user_permissions.sql
    $LoginsAndPermissionsInstance = Join-Path $ScriptFolder -ChildPath server_logins_and_permissions.sql
    $GeneralServerInformation = Join-Path $ScriptFolder -ChildPath server_general_information.sql
    $DeprecatedFeatures = Join-Path $ScriptFolder -ChildPath server_deprecated_features.sql
    $ServiceBrokerInformation = Join-Path $ScriptFolder -ChildPath database_service_broker_information.sql
    $DatabaseSizeInformation = Join-Path $ScriptFolder -ChildPath database_size_information.sql
    $DatabaseCLRInformation = Join-Path $ScriptFolder -ChildPath database_clr_information.sql
    $ServerAGInformation = Join-Path $ScriptFolder -ChildPath server_ag_information.sql
    $ServerEventNotificationInformation = Join-Path $ScriptFolder -ChildPath server_event_notification_information.sql
    $ServerInstalledServicesInformation = Join-Path $ScriptFolder -ChildPath server_installed_services_information.sql
    $ServerMaintenancePlanInformation = Join-Path $ScriptFolder -ChildPath server_maintenance_plan_information.sql
    $ServerRGInformation = Join-Path $ScriptFolder -ChildPath server_rg_information.sql
    $ServerTriggerInformation = Join-Path $ScriptFolder -ChildPath server_trigger_information.sql
    $ServerDBSnapshotInformation = Join-Path $ScriptFolder -ChildPath server_db_snapshot_information.sql
    $ServerLogShippingInformation = Join-Path $ScriptFolder -ChildPath server_Logshipping_information.sql
    $ServerPBMInformation = Join-Path $ScriptFolder -ChildPath server_pbm_information.sql
    $ServerTDEInformation = Join-Path $ScriptFolder -ChildPath server_tde_information.sql
    $DatabaseInMemoryInformation = Join-Path $ScriptFolder -ChildPath database_inmemory_information.sql
    $DatabaseAuditInformation = Join-Path $ScriptFolder -ChildPath database_db_audit_information.sql
    $ServerAuditInformation = Join-Path $ScriptFolder -ChildPath server_audit_information.sql
    $ServerCredInformation = Join-Path $ScriptFolder -ChildPath server_credential_information.sql
    $ServerAgentJobInformation = Join-Path $ScriptFolder -ChildPath server_agent_jobs_information.sql
    $ServerTimezoneInformation = Join-Path $ScriptFolder -ChildPath server_timezone_information.sql
    $ServerClusterInformation = Join-Path $ScriptFolder -ChildPath server_cluster_information.sql
    $DatabaseFilestreamInformation = Join-Path $ScriptFolder -ChildPath database_filestream_information.sql
    $ServerBufferPoolExtensionInformation = Join-Path $ScriptFolder -ChildPath server_buffer_pool_extension_information.sql
    $TCPEndpointsInformation = Join-Path $ScriptFolder -ChildPath server_tcp_endpoints_information.sql
    $TCPPortInformation = Join-Path $ScriptFolder -ChildPath server_tcp_port_information.sql
    $DirectReferenceInformation = Join-Path $ScriptFolder -ChildPath database_direct_reference_information.sql
    $SSISPackagesConnectionTypeInSSISDB = Join-Path $ScriptFolder -ChildPath ssis_packages_connection_type_ssisdb.ps1
    $DatabaseTableInformation = Join-Path $ScriptFolder -ChildPath database_table_information.sql
    $DatabaseUserSecurables = Join-Path $ScriptFolder -ChildPath database_user_securables.sql
    $ServerSecurables = Join-Path $ScriptFolder -ChildPath server_securables.sql
    $ServerCPUUtilization = Join-Path $ScriptFolder -ChildPath server_cpu_utilization.sql
    $DatabaseDowngradeStandard = Join-Path $ScriptFolder -ChildPath database_downgrade_to_standard.sql
    $DatabaseToServerMapping = Join-Path $ScriptFolder -ChildPath database_to_server_mapping.sql
    $DatabaseExtendedStoredProcedure = Join-Path $ScriptFolder -ChildPath database_extended_stored_procedure.sql
    $DatabaseFileTableInformation = Join-Path $ScriptFolder -ChildPath database_filetable_information.sql

    $ErrorlogHeader = 'SQLInstance','Category','DatabaseName', 'ScriptName', 'ErrorMessage', 'date_collected'


    if (-not(Test-Path -Path $OutputFolder)) {

        Write-Verbose "Creating new folder: [$OutputFolder]"

        New-Item -Path $OutputFolder -ItemType Directory | Out-Null

    }
    else {
        Write-Verbose "Folder: [$OutputFolder] exists. Cleaning-up!"

        Get-ChildItem -Path $OutputFolder -Recurse | Remove-Item

    }

    #############
    # Connection Validation - Fail fast if SQL Server is not reachable
    #############
    Test-SqlServerConnection -ServerInstance $ServerName

    #############
    # Instance Level Execution
    #############

    try {
        Write-Verbose "Working on [$GeneralDatabaseInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $GeneralDatabaseInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_general_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $GeneralDatabaseInformation."
        Write-Output "$ServerName;Database;N/A;$GeneralDatabaseInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$TraceFlagInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $TraceFlagInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_trace_flag_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
       $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $TraceFlagInformation."
        Write-Output "$ServerName;Server;N/A;$TraceFlagInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$VolumeInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $VolumeInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_volume_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
       $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $VolumeInformation."
        Write-Output "$ServerName;Server;N/A;$VolumeInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$VolumeLatencyInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $VolumeLatencyInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_volume_latency.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
       $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $VolumeLatencyInformation."
        Write-Output "$ServerName;Server;N/A;$VolumeLatencyInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$CPUUtilizationPerDB]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $CPUUtilizationPerDB
                        ConnectionTimeout = 15
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_cpu_utilization.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $CPUUtilizationPerDB."
        Write-Output "$ServerName;Database;N/A;$CPUUtilizationPerDB;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$IOUtilizationPerDB]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $IOUtilizationPerDB
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_io_utilization.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $IOUtilizationPerDB."
        Write-Output "$ServerName;Database;N/A;$IOUtilizationPerDB;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ConnectionsPerIPAddress]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ConnectionsPerIPAddress
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_connections_by_ip_address.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ConnectionsPerIPAddress."
        Write-Output "$ServerName;Server;N/A;$ConnectionsPerIPAddress;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ConfigurationsInUse]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ConfigurationsInUse
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_configuration_in_use.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ConfigurationsInUse."
        Write-Output "$ServerName;Server;N/A;$ConfigurationsInUse;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$CustomMessages]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $CustomMessages
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_custom_errors_created.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $CustomMessages."
        Write-Output "$ServerName;Server;N/A;$CustomMessages;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$AgentOperators]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $AgentOperators
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_agent_operators.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $AgentOperators."
        Write-Output "$ServerName;Server;N/A;$AgentOperators;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ProxyAgentUsage]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ProxyAgentUsage
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_proxy_agent_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ProxyAgentUsage."
        Write-Output "$ServerName;Server;N/A;$ProxyAgentUsage;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$LinkedServerInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $LinkedServerInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_linked_server_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $LinkedServerInformation."
        Write-Output "$ServerName;Server;N/A;$LinkedServerInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$SSISPackagesInMSDB]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $SSISPackagesInMSDB
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_msdb_ssis_packages.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $SSISPackagesInMSDB."
        Write-Output "$ServerName;Database;msdb;$SSISPackagesInMSDB;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$SSISPackagesConnectionTypeInMSDB]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $SSISPackagesConnectionTypeInMSDB
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath ssis_packages_connection_type_msdb.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $SSISPackagesConnectionTypeInMSDB."
        Write-Output "$ServerName;Database;msdb;$SSISPackagesConnectionTypeInMSDB;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$HardwareInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $HardwareInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_hardware_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $HardwareInformation."
        Write-Output "$ServerName;Server;N/A;$HardwareInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$SQLServerAgentAlerts]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $SQLServerAgentAlerts
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_agent_alerts.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $SQLServerAgentAlerts."
        Write-Output "$ServerName;Server;N/A;$SQLServerAgentAlerts;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$LoginsAndPermissionsInstance]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $LoginsAndPermissionsInstance
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_logins_and_permissions.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $LoginsAndPermissionsInstance."
        Write-Output "$ServerName;Server;N/A;$LoginsAndPermissionsInstance;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$GeneralServerInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $GeneralServerInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_general_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $GeneralServerInformation."
        Write-Output "$ServerName;Server;N/A;$GeneralServerInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$DeprecatedFeatures]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $DeprecatedFeatures
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_deprecated_features.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $DeprecatedFeatures."
        Write-Output "$ServerName;Server;N/A;$DeprecatedFeatures;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$MirroringInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $MirroringInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_mirroring_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $MirroringInformation."
        Write-Output "$ServerName;Server;N/A;$MirroringInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$DatabaseMailInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $DatabaseMailInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_database_mail_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $DatabaseMailInformation."
        Write-Output "$ServerName;Server;N/A;$DatabaseMailInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$BackupInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $BackupInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_backup_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $BackupInformation."
        Write-Output "$ServerName;Server;N/A;$BackupInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerAGInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerAGInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_ag_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerAGInformation."
        Write-Output "$ServerName;Server;N/A;$ServerAGInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerEventNotificationInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerEventNotificationInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_event_notification_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerEventNotificationInformation."
        Write-Output "$ServerName;Server;N/A;$ServerEventNotificationInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerMaintenancePlanInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerMaintenancePlanInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_maintenance_plan_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerMaintenancePlanInformation."
        Write-Output "$ServerName;Server;N/A;$ServerMaintenancePlanInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerRGInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerRGInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_rg_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerRGInformation."
        Write-Output "$ServerName;Server;N/A;$ServerRGInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerTriggerInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerTriggerInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_trigger_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerTriggerInformation."
        Write-Output "$ServerName;Server;N/A;$ServerTriggerInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerDBSnapshotInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerDBSnapshotInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_db_snapshot_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerDBSnapshotInformation."
        Write-Output "$ServerName;Server;N/A;$ServerDBSnapshotInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerLogShippingInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerLogShippingInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_logshipping_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerLogShippingInformation."
        Write-Output "$ServerName;Server;N/A;$ServerLogShippingInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerPBMInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerPBMInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_pbm_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerPBMInformation."
        Write-Output "$ServerName;Server;N/A;$ServerPBMInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerTDEInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerTDEInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_tde_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerTDEInformation."
        Write-Output "$ServerName;Server;N/A;$ServerTDEInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerAuditInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerAuditInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_audit_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerAuditInformation."
        Write-Output "$ServerName;Server;N/A;$ServerAuditInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerCredInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerCredInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_credential_information.csv) -NoTypeInformation -Delimiter ";"
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerCredInformation."
        Write-Output "$ServerName;Server;N/A;$ServerCredInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerAgentJobInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerAgentJobInformation
                        MaxCharLength = 1000000
                        QueryTimeout = 0
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_agent_jobs_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerAgentJobInformation."
        Write-Output "$ServerName;Server;N/A;$ServerAgentJobInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerTimezoneInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerTimezoneInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_timezone_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerTimezoneInformation."
        Write-Output "$ServerName;Server;N/A;$ServerTimezoneInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerClusterInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerClusterInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_cluster_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerClusterInformation."
        Write-Output "$ServerName;Server;N/A;$ServerClusterInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$DatabaseFilestreamInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $DatabaseFilestreamInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_filestream_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $DatabaseFilestreamInformation."
        Write-Output "$ServerName;Database;N/A;$DatabaseFilestreamInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerBufferPoolExtensionInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerBufferPoolExtensionInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_buffer_pool_extension_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerBufferPoolExtensionInformation."
        Write-Output "$ServerName;Server;N/A;$ServerBufferPoolExtensionInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$TCPEndpointsInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $TCPEndpointsInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_tcp_endpoints_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $TCPEndpointsInformation."
        Write-Output "$ServerName;Server;N/A;$TCPEndpointsInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$TCPPortInformation]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $TCPPortInformation
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_tcp_port_information.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $TCPPortInformation."
        Write-Output "$ServerName;Server;N/A;$TCPPortInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerSecurables]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerSecurables
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_securables.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerSecurables."
        Write-Output "$ServerName;Server;N/A;$ServerSecurables;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$ServerCPUUtilization]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $ServerCPUUtilization
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_cpu_utilization.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $ServerCPUUtilization."
        Write-Output "$ServerName;Server;N/A;$ServerCPUUtilization;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    try {
        Write-Verbose "Working on [$DatabaseToServerMapping]"
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        InputFile = $DatabaseToServerMapping
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_to_server_mapping.csv) -NoTypeInformation -Delimiter ";" -Append
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not execute script: $DatabaseToServerMapping."
        Write-Output "$ServerName;Server;N/A;$DatabaseToServerMapping;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    Write-Verbose "Performing [sysadmin] check"
    # Wrap sysadmin check in try/catch for defense in depth
    $IsSysAdmin = $false
    try {
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        Query = "select IS_SRVROLEMEMBER('sysadmin') as IsSysadmin"
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        $SysAdminCheck = Invoke-Sqlcmd @params
        if ($null -ne $SysAdminCheck -and $SysAdminCheck.IsSysadmin -eq 1) {
            $IsSysAdmin = $true
            Write-Verbose "SysAdminCheck=<$($SysAdminCheck.IsSysadmin)>"
        }
    }
    catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
        Write-Verbose "Could not perform sysadmin check: $Errors"
        Write-Output "$ServerName;Server;N/A;SysAdminCheck;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }
    
    if ($IsSysAdmin) {
        try {
            Write-Verbose "Working on [$ServerInstalledServicesInformation]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = "master"
                            InputFile = $ServerInstalledServicesInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_installed_services_information.csv) -NoTypeInformation -Delimiter ";"
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Could not execute script: $ServerInstalledServicesInformation."
            Write-Output "$ServerName;Server;N/A;$ServerInstalledServicesInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }
    }
    else {
        Write-Verbose "Could not execute script: $ServerInstalledServicesInformation. User is not sysadmin on $ServerName"
        Write-Output "$ServerName;Server;N/A;$ServerInstalledServicesInformation;User is not sysadmin;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
    }

    #############
    # DB Level Executions
    #############
    # Prepare the base parameters
    $params = @{
                    ServerInstance = $ServerName
                    Database = "master"
                    Query = "select name,is_read_only from sys.databases where name not in ('tempdb') and user_access_desc = 'MULTI_USER' and state_desc = 'ONLINE' order by name"
                    ErrorAction = "Stop"
                }
    # Add security parameters (TLS encryption + certificate trust)
    Add-SqlSecurityParams -Params $params
    # Execute the command
    $UserDBs = Invoke-Sqlcmd @params

        foreach ($db in $UserDBs) {
        if($db.is_read_only){
            Write-Output "$ServerName;Database;$($($db.name));readonly-script;$($($db.name)) is Read-Only, and the script(s) cannot be executed;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
            continue

        }
        else{
        try {
            Write-Verbose "Working on [$UsersAndPermissionsPerDb] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $UsersAndPermissionsPerDb
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_user_permissions.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $UsersAndPermissionsPerDb. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$UsersAndPermissionsPerDb;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$ServiceBrokerInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $ServiceBrokerInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_service_broker_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $ServiceBrokerInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$ServiceBrokerInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }
        try {
            Write-Verbose "Working on [$DatabaseSizeInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseSizeInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_size_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseSizeInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseSizeInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$PrimaryKeyInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $PrimaryKeyInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_primary_key_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $PrimaryKeyInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$PrimaryKeyInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$DatabaseCLRInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseCLRInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_clr_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseCLRInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseCLRInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$DatabaseInMemoryInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseInMemoryInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_inmemory_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseInMemoryInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseInMemoryInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }
        try {
            Write-Verbose "Working on [$DatabaseAuditInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseAuditInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_db_audit_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseAuditInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseAuditInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$DirectReferenceInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DirectReferenceInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_direct_reference_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DirectReferenceInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DirectReferenceInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }
        try {
            Write-Verbose "Working on [$DatabaseTableInformation] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseTableInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_table_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseTableInformation. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseTableInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }
        try {
            Write-Verbose "Working on [$DatabaseUserSecurables] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseUserSecurables
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_user_securables.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseUserSecurables. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseUserSecurables;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }
        try {
            Write-Verbose "Working on [$DatabaseDowngradeStandard] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseDowngradeStandard
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_downgrade_to_standard.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseDowngradeStandard. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseDowngradeStandard;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$DatabaseExtendedStoredProcedure] for [$($db.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $db.name
                            InputFile = $DatabaseExtendedStoredProcedure
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_extended_stored_procedure.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseExtendedStoredProcedure. Check errorlog.txt"
            Write-Output "$ServerName;Server;$($db.name);$DatabaseExtendedStoredProcedure;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$DatabaseFileTableInformation] for [$($db.name)]"
            Invoke-Sqlcmd -ServerInstance $ServerName -Database $db.name -InputFile $DatabaseFileTableInformation -ErrorAction Stop -TrustServerCertificate | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_filetable_information.csv) -NoTypeInformation -Delimiter ";" -Append
        }
        catch {
            $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($db.name). Could not execute script: $DatabaseFileTableInformation. Check errorlog.txt"
            Write-Output "$ServerName;Database;$($db.name);$DatabaseFileTableInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

    }
  }

    #############
    # SQL Features Validations
    #############
    # Prepare the base parameters
    $params = @{
                    ServerInstance = $ServerName
                    Database = "master"
                    Query = "SELECT database_id, name FROM sys.databases WHERE is_distributor = 1"
                    ErrorAction = "Stop"
                }
    # Add security parameters (TLS encryption + certificate trust)
    Add-SqlSecurityParams -Params $params
    # Execute the command
    $DistributorDB = Invoke-Sqlcmd @params
    if ($DistributorDB) {

        try {
            Write-Verbose "Working on [$ReplicationInformation] for [$($DistributorDB.name)]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = $DistributorDB.name
                            InputFile = $ReplicationInformation
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath server_replication_information.csv) -NoTypeInformation -Delimiter ";"
        }
        catch {
        $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $($DistributorDB.name). Could not execute script: $ReplicationInformation. Check errorlog.txt"
            Write-Output "$ServerName;Database;$($DistributorDB.name);$ReplicationInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

    }
    # Prepare the base parameters
    $params = @{
                    ServerInstance = $ServerName
                    Database = "master"
                    Query = "SELECT name FROM sys.databases WHERE is_published = 1"
                    ErrorAction = "Stop"
                }
    # Add security parameters (TLS encryption + certificate trust)
    Add-SqlSecurityParams -Params $params
    # Execute the command
    $PublisherDB = Invoke-Sqlcmd @params
    if ($PublisherDB) {
        foreach ($db in $PublisherDB) {

            try {
                Write-Verbose "Working on [$PublisherInformation] for [$($db.name)]"
                # Prepare the base parameters
                $params = @{
                                ServerInstance = $ServerName
                                Database = $db.name
                                InputFile = $PublisherInformation
                                ErrorAction = "Stop"
                            }
                # Add security parameters (TLS encryption + certificate trust)
                Add-SqlSecurityParams -Params $params
                # Execute the command
                Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_replication_publisher_information.csv) -NoTypeInformation -Delimiter ";" -Append
            }
            catch {
                $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
                Write-Verbose "Database: $($db.name). Could not execute script: $PublisherInformation. Check errorlog.txt"
                Write-Output "$ServerName;Database;$($db.name);$PublisherInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
            }

        }

    }

    # Prepare the base parameters
    $params = @{
                    ServerInstance = $ServerName
                    Database = "master"
                    Query = "SELECT name FROM sys.databases WHERE name like '%ReportServer%'"
                    ErrorAction = "Stop"
                }
    # Add security parameters (TLS encryption + certificate trust)
    Add-SqlSecurityParams -Params $params
    # Execute the command
    $SSRSDB = Invoke-Sqlcmd @params
    if ($SSRSDB) {
        foreach ($ssrs_db in $SSRSDB) {
            try {
                # Prepare the base parameters
                $params = @{
                                ServerInstance = $ServerName
                                Database = $ssrs_db.name
                                Query = "select object_id from sys.tables where name = 'Catalog'"
                                ErrorAction = "Stop"
                            }
                # Add security parameters (TLS encryption + certificate trust)
                Add-SqlSecurityParams -Params $params
                # Execute the command
                $CheckCatalogTable = Invoke-Sqlcmd @params

                if ($CheckCatalogTable) {
                    Write-Verbose "Working on [$ReportingServicesInformation] for [$($SSRSDB.name)]"
                    # Prepare the base parameters
                    $params = @{
                                    ServerInstance = $ServerName
                                    Database = $ssrs_db.name
                                    InputFile = $ReportingServicesInformation
                                    ErrorAction = "Stop"
                                }
                    # Add security parameters (TLS encryption + certificate trust)
                    Add-SqlSecurityParams -Params $params
                    # Execute the command
                    Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_ssrs_reports_information.csv) -NoTypeInformation -Delimiter ";" -Append
                }
                if ($CheckCatalogTable) {
                    Write-Verbose "Working on [$ReportingServicesSubscriptionInformation] for [$($SSRSDB.name)]"
                    # Prepare the base parameters
                    $params = @{
                                    ServerInstance = $ServerName
                                    Database = $ssrs_db.name
                                    InputFile = $ReportingServicesSubscriptionInformation
                                    ErrorAction = "Stop"
                                }
                    # Add security parameters (TLS encryption + certificate trust)
                    Add-SqlSecurityParams -Params $params
                    # Execute the command
                    Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_ssrs_subscription_information.csv) -NoTypeInformation -Delimiter ";" -Append
                }
            }
            catch {
                $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
                Write-Verbose "Database: $($ssrs_db.name). Could not execute script: $ReportingServicesInformation. Check errorlog.txt"
                Write-Output "$ServerName;Database;$($ssrs_db.name);$ReportingServicesInformation;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
            }

        }
    }

    # Prepare the base parameters
    $params = @{
                    ServerInstance = $ServerName
                    Database = "master"
                    Query = "select name from sys.databases where name = 'SSISDB'"
                    ErrorAction = "Stop"
                }
    # Add security parameters (TLS encryption + certificate trust)
    Add-SqlSecurityParams -Params $params
    # Execute the command
    $SSISDBExists = Invoke-Sqlcmd @params
    If ($SSISDBExists) {

        try {
            Write-Verbose "Working on [$SSISPackagesInSSISDB] for [SSISDB]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = "SSISDB"
                            InputFile = $SSISPackagesInSSISDB
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_ssisdb_ssis_packages.csv) -NoTypeInformation -Delimiter ";"

        }
        catch {
            $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $SSISDB. Could not execute script: $SSISPackagesInSSISDB. Check errorlog.txt"
            Write-Output "$ServerName;Database;ssisdb;$SSISPackagesInSSISDB;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }

        try {
            Write-Verbose "Working on [$EnvironmentSettingsSSISDB] for [SSISDB]"
            # Prepare the base parameters
            $params = @{
                            ServerInstance = $ServerName
                            Database = "SSISDB"
                            InputFile = $EnvironmentSettingsSSISDB
                            ErrorAction = "Stop"
                        }
            # Add security parameters (TLS encryption + certificate trust)
            Add-SqlSecurityParams -Params $params
            # Execute the command
            Invoke-Sqlcmd @params | Export-Csv -Path (Join-Path $OutputFolder -ChildPath database_environment_settings_on_ssisdb.csv) -NoTypeInformation -Delimiter ";"

        }
        catch {
            $Errors = -join($($PSItem.Exception.Message).Split([Environment]::NewLine)[0]," ",$($PSItem.Exception.Message).Split([Environment]::NewLine)[1])
            Write-Verbose "Database: $SSISDB. Could not execute script: $EnvironmentSettingsSSISDB. Check errorlog.txt"
            Write-Output "$ServerName;Database;ssisdb;$EnvironmentSettingsSSISDB;$Errors;$(Get-Date -Format 'yyyy-MM-dd HH:MM:ss')" | Out-File (Join-Path $OutputFolder -ChildPath errorlog.txt) -Encoding utf8 -Append
        }


        # When CLR is not enabled we cannot execute any procedures in the SSISDB to extract metadata from the SSIS Projects
        # Prepare the base parameters
        $params = @{
                        ServerInstance = $ServerName
                        Database = "master"
                        Query = "select value_in_use from sys.configurations where name = 'clr enabled'"
                        ErrorAction = "Stop"
                    }
        # Add security parameters (TLS encryption + certificate trust)
        Add-SqlSecurityParams -Params $params
        # Execute the command
        $IsClrEnabled = Invoke-Sqlcmd @params
        if ($IsClrEnabled.value_in_use -eq "1") {
            Write-Verbose "Working on [$SSISPackagesConnectionTypeInSSISDB] for [SSISDB]"
            $SSISFolder = Join-Path -Path $OutputFolder -ChildPath "SSISDB"

            Write-Verbose "Executing: $SSISPackagesConnectionTypeInSSISDB -serverName '$ServerName' -OutputFolder $OutputFolder"
            & $SSISPackagesConnectionTypeInSSISDB -serverName $ServerName -OutputFolder $OutputFolder -Verbose

            Write-Verbose "Removing Folder [$SSISFolder]"
            if (Test-Path $SSISFolder) {
                Remove-item -Path $SSISFolder -Recurse -Force
            }
        }
    }

    Write-Output "Script completed on $ServerName"
    if(Test-Path (Join-Path $OutputFolder -ChildPath errorlog.txt)){
        $DataX = Import-Csv (Join-Path $OutputFolder -ChildPath errorlog.txt) -Delimiter ";" -Header $ErrorlogHeader
        $DataX | Export-Csv (Join-Path $OutputFolder -ChildPath errorlog.csv) -Delimiter ";" -NoTypeInformation
        Remove-Item (Join-Path $OutputFolder -ChildPath errorlog.txt)

        Write-Output "errorlog.csv has been found for $ServerName. You may check later for any errors found."
    }
}
catch {
    Write-Error "[$($PSItem.Exception.Message)]"
}
