# Changelog Axway API-Management Helm-Chart

All notable changes to this project will be documented in this file.

## [Unreleased] 
### Added
- Added the option to add extra annotations to service objects

### Fixed
- No emptyDir volume for audit log created, if pvcs.audit.enabled set to false
- Don't create Agents-Secrets if agents are disabled
- Checking the available Ingress version improved

## [2.0.0] 2021-11-22
### Added
- Refactored version of the Axway API-Management Helm-Chart