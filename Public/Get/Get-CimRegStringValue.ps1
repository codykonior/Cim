<#
.SYNOPSIS
Execute a CIM method to get a string value from the registry.

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

function Get-CimRegStringValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ComputerName")]
        [string] $ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="CimSession")]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Microsoft.Win32.RegistryHive] $Hive = "LocalMachine",
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Key,
        [string] $Value,

        [switch] $Simple,
        [int] $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )
	
    begin {
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "ComputerName") {
            $CimSession = New-CimSessionDown $ComputerName        
        }
        if ($CimSession.Protocol -eq "WSMAN") {
            $namespace = "root\cimv2"
        } else {
            $namespace = "root\default"
        }

        $cimSplat = @{
            OperationTimeoutSec = $OperationTimeoutSec
            CimSession = $CimSession
            Namespace = $namespace
            ClassName = "StdRegProv"
            MethodName = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("-CimReg", "")
            Arguments = @{
                hDefKey = [uint32] ("0x{0:x}" -f $Hive)
                sSubKeyName = $Key
                sValueName = $Value
            }

        }

        $cimResult = Invoke-CimMethod @cimSplat
        if (!$Simple) {
            $cimResult
        } else {
            if ($cimResult.psobject.Properties["sValue"]) {
                $cimResult.sValue
            } else {
                $cimResult.uValue
            }
        }
    }

    end {
    }
}
