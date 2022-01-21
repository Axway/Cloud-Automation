# Changelog Axway API-Management Helm-Chart

All notable changes to this project will be documented in this file.

## [2.3.0] 2022-01-21

### Fixed
- API-Portal certificate no longer generated if API-Portal is disabled
- variable `apitraffic.name` was not defined correctly in all cases

### Changed
- ConfigMap jvmxml now created using the Helm-`.Release.Name`, which allows to deploy the Helm-Chart x-time into the same namespace
- Updated dependencies
  - bitnami/common 1.10.1 --> 1.10.4
  - mysql/mysql 8.8.12 --> 8.8.23
  - redis/redis 15.5.5 --> 15.7.6
- API-Traffic default livenessProbe changed 
  - period changed from 10 to 30 seconds
  - timeoutSeconds changed from 5 to 15 seconds (to avoid unwanted POD-Restarts)
- API-Manager default livenessProbe changed
  - period changed from 10 to 30 seconds
  - timeoutSeconds changed from 5 to 15 seconds (to avoid unwanted POD-Restarts)

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
