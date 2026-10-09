# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- **[BREAKING]** Removed Docker functionality entirely (Dockerfile, docker-files/, related CI jobs)
- Fixed SQL injection vulnerability in `GenerateRDSSupport.ps1` - now uses parameterized queries via `Invoke-Sqlcmd -Variable`
- Fixed SQL injection vulnerability in `database_extended_stored_procedure.sql` - replaced dynamic SQL with `OBJECT_ID()` function
- Removed all `Invoke-Expression` usage that allowed command injection (was in deleted docker-files/)
- Removed Amazon employee email addresses from all script headers (60+ files)

### Added

- `SECURITY.md` - Security considerations, vulnerability reporting, and production hardening guidelines
- `CHANGELOG.md` - Project change tracking
- Revoke permissions script in `docs/permissions.md` for cleanup after assessments
- Comprehensive permission justification table in `docs/permissions.md`
- **Connection validation** in `Assessment.ps1` - script now fails fast with clear error messages when SQL Server is unreachable
- **Assessment summary** in `InvokeExecution.ps1` - displays count and status of all servers after batch completes

### Changed

- **README.md** - Complete rewrite with proper documentation structure:
  - Added data security warning
  - Added prerequisites section
  - Added "What Gets Collected" reference table
  - Added cleanup instructions
  - Removed broken internal URLs
- **docs/permissions.md** - Rewrote with security justifications and risk documentation
- **docs/setup/howto.md** - Updated to remove personal namespace URLs
- **.gitignore** - Expanded to include OS artifacts, Python cache, environment files, IDE directories
- **.gitlab-ci.yml** - Removed Docker-related jobs (`build-push-docker`, `run probe`, `run-container`)
- Script headers now use alias format instead of email addresses

### Fixed

- **Assessment.ps1** - Fixed crash when running against servers without SQL Server installed
  - Added `Test-SqlServerConnection` function for early connection validation
  - Wrapped sysadmin check in try/catch to prevent null reference exceptions
  - Improved error messages to help diagnose connection issues
- **InvokeExecution.ps1** - Script no longer stops on first server failure
  - Continues processing remaining servers in list
  - Collects and displays summary of successful/failed servers
- Broken links to personal GitLab Pages site in documentation

## [1.0.0] - Initial Release

### Added

- SQL Server pre-migration assessment scripts
- PowerShell execution framework
- Data consolidation utilities
- AWS Database Assessment database schema
- GitLab CI/CD pipeline for validation
