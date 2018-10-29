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

.PARAMETER Key
The name of the key to read.

.PARAMETER Value
A filter to apply to the last value.

.PARAMETER Simple
Whether to return the full output or only the data.

.PARAMETER OperationTimeoutSec
Defaults to 30. If this wasn't specified operations may never timeout.

.NOTES

#>

function Get-CimRegKey {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ComputerName")]
        [string] $ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "CimSession")]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Microsoft.Win32.RegistryHive] $Hive = "LocalMachine",
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Key,
        [string[]] $Value,

        [int] $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )

    begin {
    }

    process {
        $cimKeys = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegEnumKey -Hive $Hive -Key $Key -OperationTimeoutSec $OperationTimeoutSec

        foreach ($cimName in $cimKeys.sNames) {
            if (!$Value -or $Value -contains $cimName) {
                [PSCustomObject] @{
                    ComputerName = $cimKeys.PSComputerName
                    Hive         = $Hive
                    Key          = "$Key\$cimName"
                }
            }
        }
    }

    end {
    }
}
