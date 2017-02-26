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

.PARAMETER Simple
Whether to return the full output or only the data.

.PARAMETER OperationTimeoutSec
Defaults to 30. If this wasn't specified operations may never timeout.

.NOTES

#>

function Get-CimValue {
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
            $cimValues = Get-CimEnumValues -ComputerName $ComputerName -Hive $Hive -Key $Key -OperationTimeoutSec $OperationTimeoutSec
        } else {
            $cimValues = Get-CimEnumValues -CimSession $CimSession -Hive $Hive -Key $Key -OperationTimeoutSec $OperationTimeoutSec        
        }

        for ($i = 0; $cimValues.sNames -and $i -lt $cimValues.sNames.Count; $i++) {
            $dataValue = $cimValues.sNames[$i]
            $dataType = [Microsoft.Win32.RegistryValueKind] $cimValues.Types[$i]
            if ($PSCmdlet.ParameterSetName -eq "ComputerName") {
                $dataData = &Get-Cim$($dataType)Value -ComputerName $ComputerName -Hive $Hive -Key $Key -Value $dataValue -OperationTimeoutSec $OperationTimeoutSec -Simple
            } else {
                $dataData = &Get-Cim$($dataType)Value -CimSession $CimSession -Hive $Hive -Key $Key -Value $dataValue -OperationTimeoutSec $OperationTimeoutSec -Simple
            }

            [PSCustomObject] @{
                ComputerName = $cimValues.PSComputerName
                Hive = $Hive
                Key = $Key
                Value = $dataValue
                Data = $dataData
                Type = $dataType
             }
        }
    }

    end {
    }
}
