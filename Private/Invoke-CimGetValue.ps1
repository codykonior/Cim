<#
.SYNOPSIS
Private function to execute a remote CIM method to get a value type.

.DESCRIPTION
All of the GetXXXValue methods are the same so this is a shortcut to save code. It does a string substitution on the caller name to 

.PARAMETER CimSession
A CimSession from New-CimSessionDown.

.PARAMETER SubKeyName
The name of the key to read.

.PARAMETER ValueName
The name of the value to read.

.PARAMETER Hive
Which hive, HLKM (the default) or HKCU.

.PARAMETER Raw
Whether to return the raw output or just the value(s).

.PARAMETER OperationTimeoutSec
Defaults to 30. If this wasn't specified operations may never timeout.

.NOTES
Not meant to be called externally.

#>

function Invoke-CimGetValue {
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
            $CimSession = New-CimSessionDown $ComputerName        
        }

        if ($cimSession.Protocol -eq "WSMAN") {
            $namespace = "root\cimv2"
        } else {
            $namespace = "root\default"
        }

        $methodName = (Get-PSCallStack)[1].Command.Replace("-Cim", "")

        $cimSplat = @{
            OperationTimeoutSec = $OperationTimeoutSec
            CimSession = $CimSession
            Namespace = $namespace
            ClassName = "StdRegProv"
            MethodName = $methodName
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
