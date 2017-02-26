<#
.SYNOPSIS
Opens a CIM session to a computer, with a fallback from WSMAN to DCOM for older operating systems.

.DESCRIPTION
CIM is the preferred method of interacting with WMI on a computer. It can reuse a single session instead of creaing a new session for each interaction. It can timeout which the built-in WMI functions will not. When communicating with modern operating systems it is less chatty with a fraction of the number of network roundtrips.

A New-CimSession by default only attempts a WSMAN connection, which is the modern CIM protocol. By using New-CimSessionDown instead existing connections can be re-used, and an additional check is done to use DCOM if WSMAN fails. This allows you to use CIM to communicate with all of your Windows estate without building two sets of CIM and WMI calls.

You should always specify -OperationTimeoutSec on any Get-CimInstance and related calls over a CimSession.

.PARAMETER ComputerName
The name of the remote computer(s). This parameter accepts pipeline input. The local computer is the default.

.PARAMETER Credential
Specifies a user account that has permission to perform this action. The default is the current user.

It's not possible to tell connections apart by credential, so, multiple connections to one server with different users is not recommended, as the wrong session may be returned.

.EXAMPLE
New-CimSessionDown -ComputerName Server1
New-CimSessionDown -ComputerName Server1, Server2

Creates a session to a server, then re-retrieves that existing session, along with a new one.

.INPUTS
String

.OUTPUTS
Microsoft.Management.Infrastructure.CimSession

.NOTES
The "Down" in New-CimSessionDown stands for "down-level", because it talks to down-level versions of Windows. 

Verbose is always explicitly disabled on the New-CimSession call because it returns a useless message of ''.

This function is based largely on work done by Mike F Robbins @ http://mikefrobbins.com

#>

function New-CimSessionDown {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("Name")]
        [ValidateNotNullorEmpty()]
        [string[]] $ComputerName = $env:COMPUTERNAME,
        [PSCredential] $Credential,
        $OperationTimeoutSec = 30 # "Robust connection timeout minimum is 180" but that's too long
    )
	
	begin {
        $dcomSessionOption = New-CimSessionOption -Protocol Dcom

        $verboseSplat = @{ 
		    Verbose = $false
	    }
		
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
            if ($cimSession = Get-CimSession | Where-Object { $_.ComputerName -eq $computer } | Select-Object -First 1) {
                Write-Verbose "Used existing connection to $computer using the $($cimSession.Protocol) protocol."
                $cimSession
            } else {
                try {
                    if ((Test-WSMan -ComputerName $computer @verboseSplat).productversion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+') {
                        $cimSession = New-CimSession -ComputerName $computer @sessionSplat
                        Write-Verbose "Connected to $computer using the WSMAN protocol."
                        $cimSession
                    }
                } catch {
                    Write-Verbose "Faied to connect to $computer with WSMAN protocol: $_"

                    try {
                        New-CimSession -ComputerName $computer @sessionSplat -SessionOption $dcomSessionOption
                        Write-Verbose "Connected to $computer using the DCOM protocol."
                        $cimSession
                    } catch {
                        Write-Error "Failed to connect to $computer with DCOM protocol: $_"
                    }
                }
            }
        }
    }

    end {
    }
}
