# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- None.

## [1.6.2] - 2019-06-18

### Fixed

- Added aliases for constrained endpoint compatibility.

## [1.6.1] - 2019-04-17

### Fixed

- Typo.

## [1.6.0] - 2019-04-17

### Changed

- When creating a session to the current computer name, localhost is used
  instead of resolving the FQDN. In some environments using a FQDN for localhost
  "works" as the session is created but then any CIM queries will fail unless
  run as Administrator.
  By using localhost (and possibly adding yourself to the Remote Management
  Users local AD group) the session gets created but then also works in more
  cases without having started the session as Administrator.
  On the downside, the PSComputerName returned with each query is then localhost
  instead of the name or FQDN.
  So this behaviour can be overridden with -ForceResolve.
- Improve module load time.

### Fixed

- Changelog syntax passes VS Code markdown linter.

## [1.5.1] - 2018-10-30

### Changed

- Internal structure and documentation. Version bump for PowerShellGallery.

## [1.5.0] - 2018-10-29

### Changed

- `Get-CimRegEnumValues` renamed to `Get-CimRegEnumValue`.

## [1.4.6] - 2018-05-23

### Fixed

- Try to resolve computer names to FQDN before connecting. This improves the
  chances of getting a WSMAN connection as a NETBIOS name will only give you
  DCOM fallback.

## [1.4.4] - 2017-11-08

### Fixed

- Improve reliability by skipping WSMAN connections to PowerShell 2 and instead
  falling back to DCOM. This is because you can get a CIM session to PowerShell
  2 but it does not function properly for most CIM queries.

## [1.2.1] - 2017-02-26

### Fixed

- Fixes for not connecting over DCOM.

## [1.2.0] - 2017-02-26

### Added

- Added Registry over CIM functions.

## [1.1.2] - 2017-02-19

### Fixed

- Stopped polluting $Error variable.

## [1.0.2] - 2017-02-16

### Fixed

- Issue with it not connecting over WSMAN.

## [1.0.1] - 2017-02-05

### Changed

- OperationTimeoutSec defaults to 30s instead of no timeout by default. This is
  because it's too easy to forget to add a timeout and have scripts hang.

## [1.0.0] - 2015-08-30

### Changed

- Forked from Mike F Robbins.

### Added

- Reuse of CIM sessions.
