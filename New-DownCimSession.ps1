<#
.SYNOPSIS
Creates CimSessions to remote computer(s), automatically determining if the WSMAN or Dcom protocol should be used.

.DESCRIPTION
New-DownCimSession is a function that is designed to create CimSessions to one or more computers, automatically determining if the default WSMAN protocol or the backwards compatible Dcom protocol should be used. PowerShell version 3 is required on the computer that this function is being run on, but PowerShell does not need to be installed at all on the remote computer.

The "Down" stands for automatically supporting down-level versions of CIM using DCOM.

.PARAMETER ComputerName
The name of the remote computer(s). This parameter accepts pipeline input. The local computer is the default.

.PARAMETER Credential
Specifies a user account that has permission to perform this action. The default is the current user.

.EXAMPLE
New-DownCimSession -ComputerName Server01, Server02

.EXAMPLE
New-DownCimSession -ComputerName Server01, Server02 -Credential (Get-Credential)

.EXAMPLE
Get-Content -Path C:\Servers.txt | New-DownCimSession

.INPUTS
String

.OUTPUTS
Microsoft.Management.Infrastructure.CimSession

.NOTES
Originally written by Mike F Robbins @ http://mikefrobbins.com

Verbose is false on the New-CimSession call because it always returns a useless "Write-Verbose "''"
#>
function New-DownCimSession {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [string[]] $ComputerName = $env:COMPUTERNAME,
 
        [PSCredential] $Credential
    )

    Begin {
        $sessionOption = New-CimSessionOption -Protocol Dcom

        $sessionSplat = @{ Verbose = $false }
        if ($Credential) {
            $sessionSplat.Credential = $Credential
        }
    }

    Process {
        foreach ($computer in $ComputerName) {
            $cimSession = $null

            try {
            	if ((Test-WSMan -ComputerName $computer @sessionSplat).productversion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+') {
                    $cimSession = New-CimSession -ComputerName $computer @sessionSplat
                    Write-Verbose "Connected to $computer using the WSMAN protocol."
                }
            } catch {
                # Swallow theunderlying error because we'll try DCOM next
            }

            try {
                if (!$cimSession) {
                    New-CimSession -ComputerName $computer @sessionSplat -SessionOption $sessionOption
                    Write-Verbose "Connected to $computer using the DCOM protocol."
                } 
            } catch {
                # Swallow the underlying error because they're verbose and not very useful
                Write-Error "Unable to connect to $computer using the WSMAN or DCOM protocol."
            }
        }
    }

    End {
    }
}
