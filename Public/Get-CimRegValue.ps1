<#
.SYNOPSIS
Execute a CIM method to enumerate a list of values from the registry.

.DESCRIPTION
Uses CIM to enumerate values under a key.

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

function Get-CimRegValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [string] $ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Microsoft.Win32.RegistryHive] $Hive = "LocalMachine",
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Key,
        [string[]] $Value,

        [int] $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )
	
    begin {
    }

    process {
        $cimValues = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegEnumValues -Hive $Hive -Key $Key -OperationTimeoutSec $OperationTimeoutSec

        for ($i = 0; $cimValues.sNames -and $i -lt $cimValues.sNames.Count; $i++) {
            $cimValue = $cimValues.sNames[$i]
            if (!$Value -or $Value -contains $cimValue) {
                switch ($cimType = [Microsoft.Win32.RegistryValueKind] $cimValues.Types[$i]) {
                    "String" {
                        $cimData = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegStringValue -Hive $Hive -Key $Key -Value $cimValue -Simple -OperationTimeoutSec $OperationTimeoutSec
                        break
                    }
                    "ExpandString" {
                        $cimData = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegExpandedStringValue -Hive $Hive -Key $Key -Value $cimValue -Simple -OperationTimeoutSec $OperationTimeoutSec
                        break
                    }
                    "Binary" {
                        $cimData = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegBinaryValue -Hive $Hive -Key $Key -Value $cimValue -Simple -OperationTimeoutSec $OperationTimeoutSec
                        break
                    }
                    "DWord" {
                        $cimData = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegDWordValue -Hive $Hive -Key $Key -Value $cimValue -Simple -OperationTimeoutSec $OperationTimeoutSec
                        break
                    }
                    "MultiString" {
                        $cimData = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegMultiStringValue -Hive $Hive -Key $Key -Value $cimValue -Simple -OperationTimeoutSec $OperationTimeoutSec
                        break
                    }
                    "QWord" {
                        $cimData = @(if ($PSCmdlet.ParameterSetName -eq "ComputerName") { $ComputerName } else { $CimSession }) | Get-CimRegQWordValue -Hive $Hive -Key $Key -Value $cimValue -Simple -OperationTimeoutSec $OperationTimeoutSec
                        break
                    }
                    default {
                        # Unknown
                        # None
                        $cimData = $null
                        break
                    }
                }

                [PSCustomObject] @{
                    ComputerName = $cimValues.PSComputerName
                    Hive = $Hive
                    Key = $Key
                    Value = $cimValue
                    Data = $cimData
                    Type = $cimType
                 }
            }
        }
    }

    end {
    }
}
