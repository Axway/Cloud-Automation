# Helmchart for AMPLIFY API MANAGEMENT

## Introduction

Helmcharts are compatible with AMPLIFY API Management 7.6.2 and 7.7. The first one won't evolve with some limitation and we consider that EMT mode must be deployed with the latest version (7.7).

This helmchart uses Helm V3 and is compliant a minimal Kubernetes version of 1.15.


## Prerequisite

This helmchart requires the following capabilities on the Kubernetes cluster:
- A minimal kubernetes version 1.15
- An nginx ingress-controller like nginx or Azure Application Gateway.
- A storage class with in RWM.
- A storage class with in RWO.
- An automatic certificates creator for ingress like cert-manager and Let's Encrypt.
- A total resources of 6vcpu and 8Go memory spread on 2 nodes.
- A container registry with APIM images

The following tables lists the mandatory parameters of the AMPLIFY API Management Helm chart.
| Parameter     | Description                           | Default       |
|:------------- |:------------------------------------- |:------------- |
| global.dockerRegistry.url | The apim's container registry url | - |
| global.enableDynamicLicense | Set if the license.lic file will be baked into the image (not dynamic), or if it will be populated from files/license.lic and mounted dynamically using a config map. | false |
| global.userID | Set the user ID used by initial process to change the ownership of the mounted volumes and to run the Admin Nodemanager process. The default is the emtuser (1000). | 1000 |
| global.probe.page | Set the page URL used by the liveness and readiness probes. | /healthchecklb |
| anm.buildTag | Docker image tag of Admin Node Manager component | - |
| anm.imageName | Docker image name of Admin Node Manager component | |
| anm.ingressName | Ingress URL to access to the admin nodemanager  | anm |
| apimgr.buildTag | Docker image tag of API Manager component | |
| apimgr.imageName | Docker image name of API Manager component | |
| apimgr.ingressName | Ingress URL to access to the API Manager UI | api-mgr |
| apimgr.sso.enable | Set if the API Manager UI will have SSO as a form to login. If yes, the file contents need to be set on the files/service-provider.xml and files/idp.xml. | false |
| apitraffic.buildTag | Docker image tag of API Gateway component | - |
| apitraffic.imageName | Docker image name of API Gateway component | - |
| apitraffic.ingressName | Ingress URL to access to the APIs | api |
| apitraffic.probe.port | Set the port used by the liveliness and readiness probes to check for healthy state | 8065 |
| apitraffic.probe.scheme | Set the scheme used by the liveliness and readiness probes to check for healthy state. It can be HTTP, HTTPS and TCP | HTTPS |
| apiportal.buildTag | Docker image tag of API Portal component | - |
| apiportal.imageName | Docker image name of API Portal component | - |
| apiportal.ingressName | Ingress URL to access to the API Portal | apiportal |
| apiportal.runAsUser | User used to run the API Portal, it can be 1000 for older images or 1048 (apache) for newer images. | 1000 |
| apiportal.sso.enable | Set if the API Portal will have SSO as a form to login. If yes, the file contents need to be set on the files/service-provider-apiportal.xml and files/idp-apiportal.xml. | false |
| cassandra.adminPasswd | Password of cassandra User | changeme |
| mysqlAnalytics.adminPasswd | Password of Mysql user | changeme |
| mysqlAnalytics.rootPasswd | Password of Mysql root user | changeme |

## Product Configuration
The following tables lists the parameters and their default values to configure AMPLIFY API Management in Helm chart.

| Parameter     | Description                           | Default      |
|:------------- |:------------------------------------- |:------------ |
| global.dockerRegistry.token | Optional. Set the token needed to access the docker registry repository. | - |
| anm.logTraceToFile | Enable traces to file | true |
| anm.logTraceJSONtoSTDOUT | Enable JSON format for logs and STDOUT | false |
| anm.emt_heap_size_mb | Specifies the initial and maximum Java heap size | 1024 |
| anm.emt_topology_ttl | The time, in seconds that | 10 |
| anm.emt_trace_level | Specifies the trace level. Possible values are INFO, DEBUG, DATA | INFO |
| apimgr.logTraceToFile | Enable traces to file | true |
| apimgr.logTraceJSONtoSTDOUT | Enable JSON format for logs and STDOUT | false |
| apimgr.emt_heap_size_mb | Specifies the initial and maximum Java heap size | 1024 |
| apimgr.emt_topology_ttl | The time, in seconds that | 10 |
| apimgr.emt_trace_level | Specifies the trace level. Possible values are INFO, DEBUG, DATA | INFO |
| apimgr.logOpenTrafficOutput |  | stdout |
| apitraffic.logTraceToFile | Enable traces to file | true |
| apitraffic.logTraceJSONtoSTDOUT | Enable JSON format for logs and STDOUT | false |
| apitraffic.logOpenTrafficOutput |  | stdout |
| apitraffic.emt_trace_level | Specifies the trace level. Possible values are INFO, DEBUG, DATA | INFO |
| apitraffic.emt_heap_size_mb | Specifies the initial and maximum Java heap size | 1512 |
| oauth.enable | Enable oauth feature | false |
| oauth.ingressName | Url to access to the oauth API | - |


## Volumes and Config Maps variables.
The following tables lists the parameters used to set up storage, volumes, and config maps.

| Parameter     | Description                           | Default      |
|:------------- |:------------------------------------- |:------------ |
| global.customStorageClass.scrwo | Set the storage class for read and write only | - |
| global.customStorageClass.scrwm | Set the storage class for read and write many | - |
| global.volumes.accessModes | Set the access modes | ReadWriteOnce |
| global.volumes.gateway.paths.logs | Set the path for the gateway's logs folder | /opt/Axway/apigateway/groups/emt-group/emt-service/logs |
| global.volumes.gateway.paths.trace | Set the path for the gateway's trace folder | /opt/Axway/apigateway/groups/emt-group/emt-service/trace |
| global.volumes.nodemanager.paths.events | Set the path for the nodemanager's events folder | /opt/Axway/apigateway/events |
| global.volumes.nodemanager.paths.logs | Set the path for the nodemanager's logs folder | /opt/Axway/apigateway/logs |
| global.volumes.nodemanager.paths.trace | Set the path for the nodemanager's trace folder | /opt/Axway/apigateway/trace |
| global.jvm.gateway.enable | Set if the gateway will have a jvm.xml. If yes, the file contents needs to be updated on files/gateway-jvm.xml | false |
| global.jvm.nodemanager.enable | Set if the nodemanager will have a jvm.xml. If yes, the file contents needs to be updated on files/nodemanager-jvm.xml | false |
| anm.volumes.quota | Set the volume quota for the ANM PVC. | 1Gi |
| anm.volumes.name | Set the volume name for the ANM PVC. | anm-pvc |
| apimgr.volumes.quota | Set the volume quota for the API Manager UI PVC. | 1Gi |
| apimgr.volumes.name | Set the volume name for the API Manager UI PVC. | apimgr-pvc |
| apitraffic.volumes.quota | Set the volume quota for the API's PVC. | 1Gi |
| apitraffic.volumes.name | Set the volume name for the API's PVC. | apitraffic-pvc |



## Optional Configuration
The following tables lists the optional parameters of the AMPLIFY API Management Helm chart and their default values.

| Parameter     | Description                           | Default      |
|:------------- |:------------------------------------- |:------------ |
| global.namespace | Set the targeted namespace | default |
| global.apimVersion | Release of the product for label | 7.7 |
| global.dockerRegistry.secret | The Kubernetes secret name | registry-secret |
| global.platform | Set standard storage class for of the platform. Value can be ESX or AZURE | ESX |
| global.nodeAffinity.enable | Enable component deployment on specific node pool | false |
| global.nodeAffinity.apimName | Set the node pool name for apim | apimpool |
| global.nodeAffinity.dbName | Set the node pool name for databases | apimpool |
| global.enableDynamicLicense | Enable capability to load your license key with a configMap | false |


## Helm command examples

### Minimal installation
The followinf command deploys components Admin Node Manager, API Manager and API Gateway in the default namespace on Kubernetes.

```
Helm install *<release-name>* amplify-apim-*<version>* --set global.dockerRegistry.url=*<container registry url>*,global.dockerRegistry.token=*<your token>*,anm.buildTag=*<anm tag>*,anm.imageName=*<anm image name>*,anm.ingressName=*<anm ingress url>*,apimgr.buildTag=*<API Manager tag>*,apimgr.imageName=*<API Manager image name>*,apimgr.ingressName=*<API Manager ingress url>*,apitraffic.buildTag=*<API Gateway tag>*,apitraffic.imageName=*<API Gateway image name>*,apitraffic.ingressName=*<API Gateway ingress url>*,cassandra.adminPasswd=*<your password>*,mysqlAnalytics.adminPasswd=*<your password>*,mysqlAnalytics.rootPasswd=*<your password>*
```

### Upgrade deployment with a new license
Before deploy this command, please edit the file license-configmap.yaml and paste your license in the data section.
```
helm upgrade *<release-name>* amplify-apim-*<version>* --reuse-values --set dynamicLicense=true
```

### Run a local installation
To run a local installation on your own environment, you will need to edit the values.local.yaml, but first you will need to install the local-path storage class on your environment:
```
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

Then you can install the APIM helm chart:
```
helm install *<release-name>* amplify-apim-*<version>* --namespace *<namespace>* . --create-namespace -f ./values.local.yaml
```


### Database disclaimer
This chart is to help you having a kick start on your APIM environment. In order to accelerate this, we added to the templates MySQL and Cassandra charts, as well, so you can have it locally for a demo/lab/dev environment. But the DB charts ARE not production ready, as Axway does not support databases in containers and you should always use your own database infrastructure.
