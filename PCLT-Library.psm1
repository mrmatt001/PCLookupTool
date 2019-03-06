Function Read-FromSQL {
    PARAM($DBServer,$DBName,$Query)

    $SQLConnectionStatus = $true
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = "Server=$DBServer;Database=$DBName;Integrated Security=True"
    try
    {
        $sqlConnection.Open()
    }
    catch
    {
        $SQLConnectionStatus = $false
    }
    
    if ($SQLConnectionStatus)
    {
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = $Query

        $dataTable = New-Object System.Data.DataTable
        $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $sqlAdapter.SelectCommand = $sqlCmd
        try
        {
            $sqlAdapter.Fill($dataTable) | Out-Null
        }
        catch
        {}
        $sqlConnection.Close()
        return $dataTable
    }
}

Function Get-MainLabelsAndContentFromSQL {
    PARAM($DBServer,$DBName,$Query)
    $Null = $Table
    $Table = Read-FromSQL -query $Query -DBServer $DBServer -DBName $DBName
    if ($Table)
    {
        $Columns = @()
        foreach ($Column in $Table.Table[0].Columns.ColumnName) { $Columns += $Column }
        $HashTable = @{}
        foreach ($Column in $Columns) { $HashTable.Add($Column,$Table.$Column) }
        return $HashTable
    }
}

Function Set-ObjectsToHidden {
    PARAM($RegExMatch)
    foreach ($LabelsToHide in $syncHash.Keys | Where-Object { $_ -match $RegExMatch}) 
    { 
        $syncHash.LabelsToHide = $LabelsToHide
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.($syncHash.LabelsToHide).Visibility = "Hidden"
            }))
    }
}

Function Set-ObjectsToVisible {
    PARAM($RegExMatch)
    foreach ($LabelsToHide in $syncHash.Keys | Where-Object { $_ -match $RegExMatch}) 
    { 
        $syncHash.LabelsToHide = $LabelsToHide
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.($syncHash.LabelsToHide).Visibility = "Visible"
            }))
    }
}

Function Test-Credential {
    [OutputType([Bool])]
    
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeLine = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias(
            'PSCredential'
        )]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [String]
        $Domain = $Credential.GetNetworkCredential().Domain
    )

    Begin {
        [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") |
            Out-Null

        $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain
        )
    }

    Process {
        foreach ($item in $Credential) {
            $networkCredential = $Credential.GetNetworkCredential()
            
            Write-Output -InputObject $(
                $principalContext.ValidateCredentials(
                    $networkCredential.UserName, $networkCredential.Password
                )
            )
        }
    }

    End {
        $principalContext.Dispose()
    }
}

function Set-CustomRegValue {
    PARAM(
    [STRING]$Path,
    [STRING]$Name,
    $Value
    )
    if (!(Get-Item $PCLTRegPath -ErrorAction SilentlyContinue)) 
    { 
        New-Item $PCLTRegPath | Out-Null 
    }
    New-ItemProperty -Path $PCLTRegPath -Name $Name -Value $Value -Force | Out-Null
}
function Get-CustomRegValue {
    PARAM(
    [STRING]$Path,
    [STRING]$Value
    )
    if (Get-ItemProperty -Path $Path -Name $Value -ErrorAction SilentlyContinue) { return (Get-ItemProperty -Path $Path -Name $Value).$Value } else { return $false }
}

Function Get-WmiCustom([string]$Class,[string]$Value,[string]$ComputerName,[string]$Namespace = "root\cimv2",[int]$Timeout=10, [pscredential]$Credential) 
{ 
    $ConnectionOptions = new-object System.Management.ConnectionOptions
    $EnumerationOptions = new-object System.Management.EnumerationOptions

    if($Credential)
    {
        $ConnectionOptions.Username = $Credential.UserName;
        $ConnectionOptions.SecurePassword = $Credential.Password;
    }

    $timeoutseconds = new-timespan -seconds $timeout 
    $EnumerationOptions.set_timeout($timeoutseconds)
    $assembledpath = "\\$Computername\$Namespace"
    $Scope = new-object System.Management.ManagementScope $assembledpath, $ConnectionOptions 
    $WMIConnection = $true
    try 
    {
        $Scope.Connect()
    }
    catch 
    {
        $WMIConnection = $false    
    }

    if ($WMIConnection)
    {
        $querystring = "SELECT * FROM " + $class 
        $Query = new-object System.Management.ObjectQuery $querystring 
        $searcher = new-object System.Management.ManagementObjectSearcher 
        $searcher.set_options($EnumerationOptions) 
        $searcher.Query = $Query 
        $searcher.Scope = $Scope
        $result = $searcher.get()
        return $result
    }
    else 
    {
        return $false    
    }
}

Function Get-WmiCustomValue([string]$Class,[string]$Value,[string]$ComputerName,[string]$Namespace = "root\cimv2",[int]$Timeout=10, [pscredential]$Credential) 
{ 
    $ConnectionOptions = new-object System.Management.ConnectionOptions
    $EnumerationOptions = new-object System.Management.EnumerationOptions

    if($Credential)
    {
        $ConnectionOptions.Username = $Credential.UserName;
        $ConnectionOptions.SecurePassword = $Credential.Password;
    }

    $timeoutseconds = new-timespan -seconds $timeout 
    $EnumerationOptions.set_timeout($timeoutseconds)
    $assembledpath = "\\$Computername\$Namespace"
    $Scope = new-object System.Management.ManagementScope $assembledpath, $ConnectionOptions 
    $WMIConnection = $true
    try 
    {
        $Scope.Connect()
    }
    catch 
    {
        $WMIConnection = $false    
    }

    if ($WMIConnection)
    {
        $querystring = "SELECT $Value FROM " + $class 
        $Query = new-object System.Management.ObjectQuery $querystring 
        $searcher = new-object System.Management.ManagementObjectSearcher 
        $searcher.set_options($EnumerationOptions) 
        $searcher.Query = $Query 
        $searcher.Scope = $Scope

        $result = $searcher.get().$Value

        return $result
    }
    else 
    {
        return $false    
    }
}

Function Get-PCStatus 
{
    PARAM(
    [STRING]$ComputerName
    )
    $NSLookupStatus = $false
    try
    {
        foreach ($Line in (nslookup $ComputerName 2> NULL))
        {
            if ($Line -match 'Name:') { $NSLookupStatus = $true }
        }
    }
    catch
    {}

    if ($NSLookupStatus)
    {
        if ((Get-WmiCustomValue -Class Win32_ComputerSystem -ComputerName $ComputerName -Value Name -Timeout 5) -eq $ComputerName)
        {
            return "Valid PC"
        }
        else
        {
            return $false
        }
    }
    else
    {
        return $false
    }
}
