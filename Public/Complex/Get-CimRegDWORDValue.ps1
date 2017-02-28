<#
.SYNOPSIS
Execute a CIM method to get a DWORD value from the registry.

.DESCRIPTION
Uses CIM to get a registry value for a subkey and name.

.PARAMETER ComputerName
A computer name. A New-CimSessionDown will be created for it.

.PARAMETER CimSession
A CimSession from New-CimSessionDown.

.PARAMETER Hive
A hive type. The default is LocalMachine.

.PARAMETER Key
The name of the key to read.

.PARAMETER Value
The name of the value to read.

.PARAMETER Simple
Whether to return the full output or only the data.

.PARAMETER OperationTimeoutSec
Defaults to 30. If this wasn't specified operations may never timeout.

.NOTES

#>

function Get-CimRegDWORDValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [string] $ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [Microsoft.Win32.RegistryHive] $Hive = "LocalMachine",
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [string] $Key,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [string] $Value,

        [Parameter(ParameterSetName="ComputerName")]
        [Parameter(ParameterSetName="CimSession")]
        [switch] $Simple,
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [int] $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )
	
    begin {
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "ComputerName") {
            Invoke-CimRegGetValue -ComputerName $ComputerName -Hive $Hive -Key $Key -Value $Value -OperationTimeoutSec $OperationTimeoutSec -Simple:$Simple
        } else {
            Invoke-CimRegGetValue -CimSession $CimSession -Hive $Hive -Key $Key -Value $Value -OperationTimeoutSec $OperationTimeoutSec -Simple:$Simple   
        }
    }

    end {
    }
}
