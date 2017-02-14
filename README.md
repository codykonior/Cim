# PowerShell: CimSession module

## TOPIC
    about_CimSession

## SHORT DESCRIPTION
	Opens a CIM session to a computer, with a fallback from WSMAN to DCOM for older 
	operating systems.

## LONG DESCRIPTION
	CIM is the preferred method of interacting with WMI on a computer. It can reuse a 
	single session instead of creaing a new session for each interaction. It can timeout 
	which the built-in WMI functions will not. When communicating with modern operating 
	systems it is less chatty with a fraction of the number of network roundtrips.

	A New-CimSession by default only attempts a WSMAN connection, which is the modern 
	CIM protocol. By using New-CimSessionDown instead existing connections can be re-used,
	and an additional check is done to use DCOM if WSMAN fails. This allows you to use CIM
	to communicate with all of your Windows estate without building two sets of CIM and 
	WMI calls.

	You should always specify -OperationTimeoutSec on any Get-CimInstance and related 
	calls over a CimSession.

## REQUIREMENTS
	PowerShell v3 only the computer using the function, not on the host.
	
## EXAMPLE #1
	$cimSession = New-CimSessionDown Server1
	Get-CimInstance -CimSession $cimSession -Class Win32_Service -OperationTimeoutSec 30

## LINKS
	https://github.com/codykonior/CimSession


