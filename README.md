# PowerShell: CimSession module

Opens a CIM session to a computer, with a fallback from WSMAN to DCOM for older operating systems.

CIM is the preferred method of interacting with WMI on a computer. It can reuse a single session 
instead of creaing a new session for each interaction. It can timeout which the built-in WMI 
functions will not. When communicating with modern operating systems it is less chatty with a
fraction of the number of network roundtrips.

A New-CimSession by default only attempts a WSMAN connection, which is the modern CIM protocol.
However New-CimSessionDown also adds in an additional check for DCOM if WSMAN fails. This allows
you to use CIM to communicate with all of your Windows estate without building two sets of CIM
and WMI calls.

