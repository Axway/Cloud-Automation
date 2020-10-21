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
| global.dockerRegistry.token | - |
| anm.buildTag | Docker image tag of Admin Node Manager component | - |
| anm.imageName | Docker image name of Admin Node Manager component | |
| anm.ingressName | Ingress URL to access to the  | |
| apimgr.buildTag | Docker image tag of API Manager component | |
| apimgr.imageName | Docker image name of API Manager component | |
| apimgr.ingressName | | - |
| apitraffic.buildTag | Docker image tag of API Gateway component | - |
| apitraffic.imageName | Docker image name of API Gateway component | - |
| apitraffic.ingressName |  | - |
| cassandra.adminPasswd | Password of cassandra User | changeme |
| mysqlAnalytics.adminPasswd | Password of Mysql user | changeme |
|  |  | - |

## Product Configuration
The following tables lists the parameters and their default values to configure AMPLIFY API Management in Helm chart.

| Parameter     | Description                           | Default      |
|:------------- |:------------------------------------- |:------------ |
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
Helm install *<release-name>* amplify-apim-*<version>* --set global.dockerRegistry.url=*<container registry url>*,global.dockerRegistry.token=*<your token>*,anm.buildTag=*<anm tag>*,anm.imageName=*<anm image name>*,anm.ingressName=*<anm ingress url>*,apimgr.buildTag=*<API Manager tag>*,apimgr.imageName=*<API Manager image name>*,apimgr.ingressName=*<API Manager ingress url>*,apitraffic.buildTag=*<API Gateway tag>*,apitraffic.imageName=*<API Gateway image name>*,apitraffic.ingressName=*<API Gateway ingress url>*,cassandra.adminPasswd=*<your password>*,mysqlAnalytics.adminPasswd=*<your password>*
```

### Upgrade deployment with a new license
Before deploy this command, please edit the file license-configmap.yaml and past your license in the data section. 
```
helm upgrade *<release-name>* amplify-apim-*<version>* --reuse-values --set dynamicLicense=true
```