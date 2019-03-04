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
