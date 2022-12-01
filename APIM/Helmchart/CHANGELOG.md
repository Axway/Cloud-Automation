# Changelog Axway API-Management Helm-Chart

All notable changes to this project will be documented in this file.

# [2.11.3] 2022-12-01
### Fixed
- Remove FED injection for AWS example.
- Add persistent volume for apiportal plugin folder.

### Changed
- Init documentation for helm configuration.
- Migrate APIM demo docker images on the Clou-Automation repository.
- Refine API-Portal PV default values.

# [2.11.2] 2022-10-03
### Fixed
- Add missing secretMount values in volumeMounts section for apimgr and apitraffic.

# [2.11.1] 2022-08-29
### Fixed
- Add beats system login/paswword environment variables on filebeat container.


## [2.11.0] 2022-08-17
### Fixed
- It's not possible to set an Ingress class name with a Kubernetes version >1.22.X. Add IngressClassName value in spec section for any ingress. A different value can be set on each ingress. Adding some verifications to force usage of IngressClassName.
- Change the Cassandra dependency repository to unblock generation of helm package.

### Changed
- Add Horizontal Pod Autoscaler capability on the APITRAFFIC deployment.
- Add filebeat sidecar for Operational Insights component (ELK).
- Add new volume for audit logs on apimgr pod.
- Externalize envSettings.prop in a configmap.


## [2.10.1] 2022-05-19
### Fixed
- global.license was mounted to conf/licenses/license which is not accepted by the API-Gateways. Now it's using helm-global-license.lic

## [2.10.0] 2022-05-09
### Changed
- Helm-Chart now released using a version tag without v (e.g. 2.10.0 )
- Now using topologySpreadConstraint instead of podAntiAffinity by default
- Updated Helm-Chart dependencies
  - bitnami/common 1.13.0 --> 1.13.1
  - bitnami/mysql 8.9.2 --> 8.9.6

### Fixed
- Using an existing license secret was not working as expected. Now it's.

## [2.9.0] 2022-04-25

### Changed
- Standard POD Anti-Affinity for apitraffic to ensure API-Gateways are running on different worker nodes
- Updated Helm-Chart dependencies
  - bitnami/mysql 8.8.34 --> 8.9.2

### Fixed
- apitraffic deployment referenced wrong PCV audit instead of apigw-audit (#34)
- Using an existing secret for CASS_PASS failed, when providing just the name of the secret as it's documented (#35)

## [2.8.0] 2022-04-07

### Added
- Support to provide the FED-Configuration and other config files externally

### Changed
- Remove Binlogs of Metrics- and API-Portal-MySQL after 7 instead of 30 days
- apitraffic probes now send the header k8sprobe: readiness.apitraffic instead of k8sprobe: readiness.apimgr
- Updated Helm-Chart dependencies
  - bitnami/mysql 8.8.26 --> 8.8.34
  - bitnami/common 1.11.3 --> 1.13.0

## [2.7.0] 2022-03-03

### Added
- Support for the 2022-Februray release
  - Added require the new required flag `global.acceptGeneralConditions` to control the flag ACCEPT_GENERAL_CONDITIONS
- By default OpenTraffic event log for the traceability agent is now disabled
- Updated Helm-Chart dependencies
  - bitnami/mysql 8.8.25 --> 8.8.26
  - bitnami/common 1.11.1 --> 1.11.3

## [2.6.0] 2022-02-23

### Added
- Support the Axway Amplify Discovery- and Traceability-Agents

### Changed
- Slightly adjusted standard Readiness and Liveness-Probes
- Updated Helm-Chart dependencies
  - bitnami/mysql 8.8.24 --> 8.8.25

## [2.5.0] 2022-02-18

### Added
- The option to configure the sessionAffinity for ANM, API-Mgr, API-Traffic and API-Portal services

### Changed
- The default sessionAffinity for API-Traffic changed from ClientIP to None
- Updated Helm-Chart dependencies
  - bitnami/mysql 8.8.23 --> 8.8.24

## [2.4.0] 2022-02-15

### Added
- The option to configure initResources for ANM, API-Mgr, API-Traffic and API-Portal

## [2.3.1] 2022-02-14

### Changed
- API-Portal database PVC now requests 2GB diskspace instead of 1GB
- Updated Helm-Chart dependencies
  - bitnami/common 1.10.1 --> 1.11.1

### Fixed
- Corrected indentation for ANM extraVolumeMounts

## [2.3.0] 2022-01-21

### Fixed
- API-Portal certificate no longer generated if API-Portal is disabled
- variable `apitraffic.name` was not defined correctly in all cases

### Changed
- ConfigMap jvmxml now created using the Helm-`.Release.Name`, which allows to deploy the Helm-Chart x-time into the same namespace
- Updated Helm-Chart dependencies
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
