# Cim PowerShell Module by Cody Konior

![Cim logo][1]

[![Build status](https://ci.appveyor.com/api/projects/status/1e2t9v0rfhuy5awk?svg=true)](https://ci.appveyor.com/project/codykonior/cim)

Read the [CHANGELOG][3]

## Description

CIM is the replacement for WMI in Windows Server 2008 and above and aside from being very easy to use, it's also important to use
because it's faster, less resource intensive, more reliable, and supports timeouts out of the box. Unfortunately the components
built into PowerShell only work to Windows Server 2012 and above.

Cim, the module, changes that by giving you an easy way to create the CIM connection to computers as old as Windows Server 2003. It
also manages connections so you don't create the same one over and over (a problem the built-in function has).

But another big part of WMI and CIM that is often overlooked is remote registry operations. Most remote registry commands have to
be run over a PSSession and cause a shell to be provisioned and torn down each time. There's no reason for this except laziness,
but now the Cim module lets you do this all remotely over the CimSession. It also supports easy chaining to get the data you
want.

## Installation
- `Install-Module Cim`

## Major functions
- `New-CimSessionDown` anywhere you would previously use `New-CimSession`
- `Get-CimRegKey`
- `Get-CimRegValue`

## Tips
- Every CIM operation should include an -OperationTimeoutSec. It defaults to 30.
- `Get-CimRegKey` and `Get-CimRegValue` can be chained together to an arbitrary
  length without specifying additional CimSession parameters.

## Demo

![Demo of differences between existing CIM and the new CIM commands][2]

[1]: Images/cim.ai.svg
[2]: Images/cim.gif
[3]: CHANGELOG.md
