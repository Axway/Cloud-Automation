# Changelog Axway API-Management Helm-Chart

All notable changes to this project will be documented in this file.

## [Unreleased]
### Fixed
- API-Portal certificate no longer generated if API-Portal is disabled
- apitraffic.name was not defined correctly in all cases

### Changed
- ConfigMap jvmxml now created using the Helm-.Release.Name

## [2.2.0] 2022-01-11

### Added
- Support to use global the ImageTag & Docker-Repo variables for the API-Portal [#21](https://github.com/Axway/Cloud-Automation/issues/21)

### Fixed
- warning: cannot overwrite table with non table for license (map[]) [#18](https://github.com/Axway/Cloud-Automation/issues/18)
- Cassandra Health-Check fails, if using external Cassandra-Service [#20](https://github.com/Axway/Cloud-Automation/issues/20)

## [2.1.0] 2021-12-10
### Added
- Added the option to add extra annotations to service objects

### Fixed
- No emptyDir volume for audit log created, if pvcs.audit.enabled set to false
- Don't create Agents-Secrets if agents are disabled
- Checking the available Ingress version improved

## [2.0.0] 2021-11-22
### Added
- Refactored version of the Axway API-Management Helm-Chart
