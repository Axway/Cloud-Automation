# Automation and use cases

This topic provides some guidance to : 
- Build APIM docker images best practices and recommendations
- Externalize assets 
- Update configuration without recreate a new docker image
    - Ephemeral approach
    - Local approach
    - Gitops approach

## APIM image creation

This repository provides a docker image made for demonstration and enablement.
They are based on UBI7 delivered with the EMT scripts 2.6.0.
UBI7 is more light and secure.

This image contains the external module 


## Deploy your configuration

It exists multiple ways to push a configuration on the docker image.

1. Create a new docker image
It's the historical way to push a .fed or a .env and .pol.
It's possible by using parameters on 



## Helm configurations
### Change the default docker repository

This helm is compatible to pull docker images from another (private) repository. 

| value | Description | Default value |
| ------------------ | -------------------- | ------------- |
| global.imagePullSecrets | Set a docker registry secret. the secret must be created in prerequisite. | No |
| global.dockerRepository | Set the docker registry url. Default images hosted on github. | ghcr.io/axway |
| global.imageTag | Apply a similar tag on all docker images.  | "20220830-1.0.0" |
| anm.image | docker image name. | anm-demo-7.7 |
| anm.imageTag | Docker image tag. Not required if global.imageTag is not null. |  |
| apimgr.image | docker image name. | gtw-demo-7.7 |
| apimgr.imageTag | Docker image tag. Not required if global.imageTag is not null. | 20220830-1.0.0 |
| apitraffic.image | docker image name. | gtw-demo-7.7 |
| apitraffic.imageTag | Docker image tag. Not required if global.imageTag is not null | 20220830-1.0.0 |
| apiportal.image | docker image name. | portal-demo-7.7 |
| apiportal.imageTag | Docker image tag. Not required if global.imageTag is not null | 20220830-1.0.0 |
| cassandra.image.registry | Cassandra image registry name. | docker.io |
| cassandra.image.repository | Cassandra image name. | bitnami/cassandra |
| cassandra.image.tag | Cassandra image tag.| 3.11.11-debian-10-r0 |
| cassandra.image.pullSecrets | Specify docker-registry secret names. | "" |
| mysqlapiportal.image.registry | Mysql image registry name. | docker.io |
| mysqlapiportal.image.repository | Mysql image name. | bitnami/mysql |
| mysqlapiportal.image.tag | Mysql image tag. | 8.0.29-debian-10-r2 |
| mysqlapiportal.image.pullSecrets | Specify docker-registry secret names. | "" |
| mysqlmetrics.image.registry | Mysql image registry name. | docker.io |
| mysqlmetrics.image.repository | Mysql image name. | bitnami/mysql |
| mysqlmetrics.image.tag | Mysql image tag. | 8.0.29-debian-10-r2 |
| mysqlmetrics.image.pullSecrets | Specify docker-registry secret names. | "" |
| apiportalredis.image.registry | Redis image registry name. | bitnami/redis |
| apiportalredis.image.repository | Redis image registry name. | docker.io |
| apiportalredis.image.tag | Redis image tag. | 6.2.6-debian-10-r97 |
| apiportalredis.image.pullSecrets | Specify docker-registry secret names. | "" |


### Ingress name

The helm is compatible to use a different ingress class per ingress and it's also possible to set a custom name.

| value | Description | Default value |
| ------------------ | -------------------- | ------------- |
| global.ingressClassName | | "" |

### FED Injection

Any policy modifications requires to be packaged in a new fed.
Tis method 
3 solutions exists to update it : 
1. Build a new docker image with the new fed file.
The EMT scripts provided by Axway inject the FED file and additional assets in merge folder during the container creation. 
This method is compatible with all EMT scripts version from the APIM 7.6.2.

2. Inject the fed when the container start

As of API management version 7.7.0.20220228, you can provide the necessary configuration (e.g. policies, settings) externally instead of having to bake it into the image. This init container downloads a provided FED file and places it under /merge/fed before the ANM and the GTW starts.

You can choose any method how the configuration is loaded. For example via git clone which is recommended for a YAML entity store as you can store the whole merge dir structure directly in git.

Please note that the image must be built with the EMT script: apigw-emt-scripts-2.4.0-20220222.150412-10.tar.gz or newer.


| value | Description | Default value |
| ------------------ | -------------------- | ------------- |
| anm.extraInitContainers | Script that pull the assets in the merge folder | "" |
| apimgr.extraInitContainers | Script that pull the assets in the merge folder | "" |
| apitraffic.extraInitContainers | Script that pull the assets in the merge folder | "" |

This init container example downloads a provided FED file and places it under /merge/fed before the API Gateway instance starts.
```
...
anm:
    ...
    extraInitContainers:
        - name: init-fed
        image: busybox:1.33
        volumeMounts:
            - name: merge-dir
            mountPath: /merge
        # command: [ "sh", "-c", "tail -f /dev/null" ]
        command: 
            - sh
            - -c 
            - |
            #!/bin/sh
            echo "Download API-Gateway config from: https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Automation/gateway-config/anm/fed/anm-demo-7.7-20220830.fed"
            wget -O /merge/fed https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Automation/gateway-config/anm/fed/anm-demo-7.7-20220830.fed
...
apimgr:
    ...
    extraInitContainers:
        - name: init-fed
        image: busybox:1.33
        volumeMounts:
            - name: merge-dir
            mountPath: /merge
        # command: [ "sh", "-c", "tail -f /dev/null" ]
        command: 
            - sh
            - -c 
            - |
            #!/bin/sh
            echo "Download API-Gateway config from: https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Automation/gateway-config/gtw/fed/gtw-demo-7.7-20220830.fed"
            wget -O /merge/fed https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Automation/gateway-config/gtw/fed/gtw-demo-7.7-20220830.fed
...
apitraffic:
    ...
    extraInitContainers:
        - name: init-fed
        image: busybox:1.33
        volumeMounts:
            - name: merge-dir
            mountPath: /merge
        # command: [ "sh", "-c", "tail -f /dev/null" ]
        command: 
            - sh
            - -c 
            - |
            #!/bin/sh
            echo "Download API-Gateway config from: https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Automation/gateway-config/gtw/fed/gtw-demo-7.7-20220830.fed"
            wget -O /merge/fed https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Automation/gateway-config/gtw/fed/gtw-demo-7.7-20220830.fed
```


### APIM configuration

1. Inject an APIM license
Those demo images contains a temporary license file that can be expired.
Axway allow a way to generate a temporary license file from his support website.

Set custom license to start the APIM in a Kubernetes secret.
If you want to use your own secret, it's possible to specify the name of the secret which contains the license Base64 encoded with key license.

For example:
```
kubectl -n apim create secret generic axway-license --from-file=C:\temp\license.lic 
```

| value | Description | Default value |
| ------------------ | -------------------- | ------------- |
| global.license | Content of the license file that will be injected in a secret. ||
| global.existingLicenseSecret | Use an existing Kubernetes secret. | |
