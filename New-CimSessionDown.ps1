<#
.SYNOPSIS
Opens a CIM session to a computer, with a fallback from WSMAN to DCOM for older operating systems.

.DESCRIPTION
CIM is the preferred method of interacting with WMI on a computer. It can reuse a single session 
instead of creaing a new session for each interaction. It can timeout which the built-in WMI 
functions will not. When communicating with modern operating systems it is less chatty with a
fraction of the number of network roundtrips.

A New-CimSession by default only attempts a WSMAN connection, which is the modern CIM protocol.
However New-CimSessionDown also adds in an additional check for DCOM if WSMAN fails. This allows
you to use CIM to communicate with all of your Windows estate without building two sets of CIM
and WMI calls.

.PARAMETER ComputerName
The name of the remote computer(s). This parameter accepts pipeline input. The local computer 
is the default.

.PARAMETER Credential
Specifies a user account that has permission to perform this action. The default is the current user.

.EXAMPLE
New-CimSessionDown -ComputerName Server01, Server02

.EXAMPLE
New-CimSessionDown -ComputerName Server01, Server02 -Credential (Get-Credential)

.EXAMPLE
Get-Content -Path C:\Servers.txt | New-CimSessionDown 

.INPUTS
String

.OUTPUTS
Microsoft.Management.Infrastructure.CimSession

.NOTES
This function requires PowerShell v3 but PowerShell does not need to be installed on the remote computer. The "down" in New-CimSessionDown stands for "down-level", because it talks to down-level versions of Windows. Verbose is always explicitly disabled on the New-CimSession call because it returns a useless message of ''.

This function is based largely on work done by Mike F Robbins @ http://mikefrobbins.com

#>

function New-CimSessionDown {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [Alias("Name")]
        [ValidateNotNullorEmpty()]
        [string[]] $ComputerName = $env:COMPUTERNAME,
        [PSCredential] $Credential,
        $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )

    begin {
        $sessionOption = New-CimSessionOption -Protocol Dcom

        $sessionSplat = @{ 
		    Verbose = $false 
		    OperationTimeoutSec = $OperationTimeoutSec
	    }
        
        if ($Credential) {
            $sessionSplat.Credential = $Credential
        }
    }

    Process {
        foreach ($computer in $ComputerName) {
            # Heaven help me, sometimes I found multiple connections already
            if ($cimSession = Get-CimSession -ComputerName $computer -ErrorAction:SilentlyContinue | Select -First 1) {
                Write-Verbose "Used existing connection to $computer using the $($cimSession.Protocol) protocol."
            }
            
            try {
                if (!$cimSession) {
                    if ((Test-WSMan -ComputerName $computer @sessionSplat).productversion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+') {
                        $cimSession = New-CimSession -ComputerName $computer @sessionSplat
                        Write-Verbose "Connected to $computer using the WSMAN protocol."
                    }
                }
            } catch {
                Write-Verbose "Faied to connect to $computer with WSMAN protocol: $_"
            }

            try {
                if (!$cimSession) {
                    New-CimSession -ComputerName $computer @sessionSplat -SessionOption $sessionOption
                    Write-Verbose "Connected to $computer using the DCOM protocol."
                } 
            } catch {
                Write-Error "Faied to connect to $computer with DCOM protocol: $_"
            }

            if ($cimSession) {
                $cimSession
            }
        }
    }

    end {
    }
}
