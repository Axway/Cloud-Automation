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

The following tables lists the mandatory parameters of the AMPLIFY API Management Helm chart.
| Parameter     | Description                           | Default       |
|:------------- |:------------------------------------- |:------------- |
| global.dockerRegistry.url | The apim's container registry url | - |
| global.dockerRegistry.secret | The Kubernetes secret name | registry-secret |
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
| global.platform | Set standard storage class for of the platform. Value can be ESX or AZURE | ESX |
| global.nodeAffinity.enable | Enable component deployment on specific node pool | false |
| global.nodeAffinity.apimName | Set the node pool name for apim | apimpool |
| global.nodeAffinity.dbName | Set the node pool name for databases | apimpool |
| global.enableDynamicLicense | Enable capability to load your license key with a configMap | false |

## Optional features
### Affinity nodes

A Kubernetes node pool is a group of hosts with similar capabilities. Kubernetes allows to manage different node pools. Use an affinity node It's usefull for large cluster to secure resources. Affinity node is disable by default and the node pool name by default is apimpool.

Define an affinity node require theses options:
```
   nodeAffinity.enabled=true,nodeAffinity.name=<nodePoolName>
```





### dynamic License

API-Manager and API-Traffic pods require a license file to start. It's not the case of the API Gateway Manager.

The license file is embedded during generation of the docker image and EMT scripts verify the validity of the license. But change a new license mustn't be a trigger to generate a new image.

To add a dynamic license key:
- Past a new license in license-configmap.yaml
- Add the following option in install/upgrade command: 
```
dynamicLicense=true
```


## Helm commands example

### Minimal install
Minimal install require these values
```
Helm install AMPLIFY-APIM-demo amplify-apim-<version> --set 
```

### Nginx installation 
*Add dynamic license*
```
dynamicLicense=true
```

### Upgrade with automatic rollback



### Manual rollback






## Debugging

Manual rollback if helm rollback fails