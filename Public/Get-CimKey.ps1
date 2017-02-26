<#
.SYNOPSIS
Execute a CIM method to enumerate a list of keys from the registry.

.DESCRIPTION
Uses CIM to enumerate keys under a key.

.PARAMETER ComputerName
A computer name. A New-CimSessionDown will be created for it.

.PARAMETER CimSession
A CimSession from New-CimSessionDown.

.PARAMETER Hive
A hive type. The default is LocalMachine.

.PARAMETER Value
The name of the value to read.

.PARAMETER Simple
Whether to return the full output or only the data.

.PARAMETER OperationTimeoutSec
Defaults to 30. If this wasn't specified operations may never timeout.

.NOTES

#>

function Get-CimKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName", Position=1)]
        [string] $ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession", Position=1)]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName", Position=3)]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession", Position=3)]
        [Microsoft.Win32.RegistryHive] $Hive = "LocalMachine",
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName", Position=2)]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession", Position=2)]
        [string] $Key,

        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [int] $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )
	
    begin {
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "ComputerName") {
            $cimKeys = Get-CimEnumKey -ComputerName $ComputerName -Hive $Hive -Key $Key -OperationTimeoutSec $OperationTimeoutSec
        } else {
            $cimKeys = Get-CimEnumKey -CimSession $CimSession -Hive $Hive -Key $Key -OperationTimeoutSec $OperationTimeoutSec        
        }

        foreach ($cimName in $cimKeys.sNames) {
            [PSCustomObject] @{
                ComputerName = $cimKeys.PSComputerName
                Hive = $Hive
                Key = "$Key\$cimName"
            }
        }
    }

    end {
    }
}
