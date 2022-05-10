# AZURE-AKS Deployment examples

To deploy the solution on an AZURE-AKS cluster you can use the following samples `local-values.yaml` as a starting point, which of course needs to be customized according to your environment.

Two deployment patterns are proposed here :
- Simplest deployment with external services. This solution will consume 4 publics IP.
- Deployment with the Azure managed ingress named Application Gateway Ingress Controller (AGIC).

THe Amplify API Management demo containers used are preconfigured for the container mode. Those images contains : 
- Configuration to externalize all certs.
- External Env Module to externalize SMTP configuration and TLS listener certificates.
- All environment variables for container mode.

Azure Application Gateway requires that listener certificates are not self-signed and it can't ignore a bad SSL certificate. For this reason, the certificate configuration step is really important.

## Deploy APIM on AKS without ingress controller
### Additional AZURE-AKS Prerequisites

- A Kubernetes cluster configured in AKS
  - At least 2 nodes (e.g. ds2v2)
  - If you plan to deploy the Elastic-Solution please configure at least 3 Nodes (e.g. ds2v2)
  - A namespace (e.g. apim) 
- `kubectl` configured and points to configured Kubernetes cluster
- Helm is installed and configured

### Preparations
#### Domain- and DNS-Setup
DNS records must be configured manually in this scenario.
Kubernetes services are Load balancer lvl-4 and it not possible to set appropriate cert-manager annotation.

If you want to use one or more new domains, then you should register them accordingly in advance. 
You have different possibilities up to the local `/etc/hosts` or you use the Azure DNZ Zone service to register your domain.

#### Ingress-Controller
No ingress controller must be configured in this scenario.

#### Certificates
The default certificates embedded in the docker images are enough in this scenario. 


But API-Portal requires some server certificate to start correctly. The following step import a demo certificate.
```
wget -o azure-portal-secrets.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/azure-aks/azure-portal-secrets.yaml
kubectl apply -f ./azure-portal-secrets.yaml -n apim
```
Note : The helm value apiportal.config.ssl.generateCertificates doesn't create them. Need to fix this feature.


#### Add Demo docker registry
This docker registry contains basic APIM docker images with some defaults parameters.
Those images have a short license term (Max 2 months). 

Add a registry for the demo
```
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$demo-github' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTQ0NTM5OTMsImlhdCI6MTY0NjY3Nzk5MywiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6NjMsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9LHsiUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9oZWxtLWNoYXJ0IiwiQWN0aW9uIjoicmVhZCIsIkVmZmVjdCI6IiJ9XX0.CWhcKlWG3Mflkq7M2FAZ0oFgvktpUFduL2fKLARPTapY5Sm9f6nQmL8ql7QZWGq0Zu6kFLnE9bhRZB7lLGYxFYA1Rs4TA7Q3hB6qxfpZcCSOuw2l_VQNY9aoHS_yC1v-uYJorrJA2ba1sOgy7WyOm9BXnrvcZl5aUGbiAh1S7qZlFEiUOJEjYkdU3hP1-uU-FvEW60yEd1StWj9mJM_Ykonuv8xl-pffmnCzGMWhyhH2NDLuROXHpxMO0b_yTlkUDjAsxkuarpsDbSf8SJSDn82KW5lSjEXuXk2IixQClS6MIhvkciKX1zZ1pbQpV09-l1xxpoAOkcZSodZv6T6S8kKwZ7b0f3Jd3WHBJsfPIpHVKoqH0O9JFlZk3-vh1_yGmIOovIYX1yKN0tfwsWNIA_Ul72zq0ewcTEioJX3PDvsAl1bDsry5xAADkd5xXDsJC3CEN4n1xvsdNr0Lk7-z0vvWFNy1ZecOkJpTb-OrPl6bC6hnhmqRHnxnvImlCIkj9tUX0CHQTxEwjmnvwwPLb0LgtTAAwBvaAG9-ZHIcLtBap45AIw1RESPT1F6ghJkDRM7HYxkisH73WgUjKTwE6QwnZNSTgHMxjY9ZDtjOjF6A66y3fK-49V1EMZvUCFtMEkXsVNhu4hJmDCINXq_0XcSFzLYj2rPVdwwLzWWN07M" \
    --docker-email=demo@axway.com -n apim-demo
```

#### Create External services
Create  simple load balancer access. Azure will provide one public IP per services.

```
wget -o azure-externalservices.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/azure-aks/azure-externalservices.yaml
kubectl apply -f ./azure-externalservices.yaml -n apim
```

### Installation
For the installation of our Helmchart you have to create and maintain for future upgrades your own `local-values.yaml` file. As a starter, you may use our AZURE-AKS with no ingress [example](azure-aks-example-noingress-values.yaml) as a base. Use the following command to get a local copy:  

```
wget -o local-values-aks-noingress.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/azure-aks/azure-aks-example-noingress-values.yaml
```

By default, no modification in value file is required.
You can overwrite all parameters of the base [`values.yaml`](../../values.yaml), therefore our recommendation is to check it for appropriate configuration parameters inlcuding their documentation.

To finally start the deployment into your Kubernetes Cluster using Helm, use now the following command:
```
helm install axway-apim -n apim -f .\local-values-aks-noingress.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.9.0/helm-chart-axway-apim-2.11.0-pre.tgz
```

Now wait that all containers are up and in running state with the following command : 
```
kubectl get pods -n apim -w
```

### Access to APIM
Use the fololowing command to known what ip has been created for 
```
kubectl get svc -n apim | grep public
```

Open your web browser and use the the public IP (third column) and the port to access to the UI.
Admin node manager https://<public-ip>:8090
API Manager https://<public-ip2>:8075
API Portal https://<public-ip3>
API Traffic https://<public-ip4>:8065/healthcheck


## Deploy APIM on AKS with AGIC
### Additional AZURE-AKS Prerequisites

- A Kubernetes cluster configured in AKS
  - At least 2 nodes (e.g. ds2v2)
  - If you plan to deploy the Elastic-Solution please configure at least 3 Nodes (e.g. ds2v2)
  - A namespace for apim (e.g. apim)
  - A namespace for externaldns (e.g. externaldns). This is optional.
- An Application Gateway deployed with the module Ingress Controller on the AKS cluster. 
- `kubectl` configured and points to configured Kubernetes cluster
- Helm is installed and configure

### Preparations
#### Domain- and DNS-Setup

To ultimately make the solution available, a number of ingress resources are created for the specified domain(s) (e.g., anm.axway-apim-customer.com) and Azure Load-Balancers are created based on them.  

If you want to use one or more new domains, then you should register them accordingly in advance. 
You have different possibilities up to the local `/etc/hosts` or you use the Azure DNS zone service to register your domain.

With Azure, you have the option to dynamically create necessary DNS records based on created ingress resources for the domain. To do this, they need to install and set up the external DNS component. [external DNS](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/integrations/external_dns/) in your Kubernetes cluster. 

PLease follow this specific [page](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md) to configure this module on AKS. 

```
kubectl -n externaldns get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns"
NAME                            READY   STATUS    RESTARTS   AGE
external-dns-76cf95cbff-q2mzm   1/1     Running   0          33s
```

#### Ingress-Controller

This scenario requires the AGIC add-on. please check that it's up and running before continuing the deployment.
The AGIC component is deployed on the kube-system namespace by default.

```
kubectl get pods -l app=ingress-appgw  -A
NAMESPACE     NAME                                        READY   STATUS    RESTARTS   AGE
kube-system   ingress-appgw-deployment-5bbd94f7d9-266sd   1/1     Running   113        2d16h
```

You must proceed to the deployment if pod doesn't exist. please follow this [documentation](https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing#enable-the-agic-add-on-in-existing-aks-cluster-through-portal).

#### Certificates

For services, such as the API-Manager, API-Traffic, etc. depending on the configuration one or more HTTPS Load-Balancers are created, that obviously require a certificate. 
Azure doesn't have a service to generate certificates. But external solution exist.

##### Automatic import 
The easier solution based on the Let's encrypt issuer.
This solution allows to create dynamically the certificate for any new deployed ingress objects.
It requires the solution cert-manager that is a X.509 ceritficate management for Kubernetes.

Please follow the deployment steps [here](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-letsencrypt-certificate-application-gateway)

```
kubectl get pods -l app=cert-manager  -A
NAMESPACE      NAME                            READY   STATUS    RESTARTS   AGE
cert-manager   cert-manager-6d87886d5c-rwwg6   1/1     Running   0          52s
```

An issuer is needed to generate a certificates. It's recommended to be deployed inside the same cert-manager namespace. Here is an example to use Let's Encrypt. Please process to any changes.
```
wget -o letsencrypt-clusterissuer-agic.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/azure-aks/letsencrypt-clusterissuer-agic.yaml
kubectl apply -f ./letsencrypt-clusterissuer-agic.yaml -n cert-manager
```

Note: Cert Manager can also generate automatically some certificates signed by a private authority. 

##### Manual import

If you want to import custom certificates, You must create TLS certificates manually.
The following command supposed that cert file contains must the fullchain.

```
kubectl create secret tls anm-tls-secret --key="path/to/tls.key" --cert="path/to/tls.crt" -n apim
kubectl create secret tls manager-tls-secret --key="path/to/tls.key" --cert="path/to/tls.crt" -n apim
kubectl create secret tls traffic-tls-secret --key="path/to/tls.key" --cert="path/to/tls.crt" -n apim
kubectl create secret tls apiportal-tls-secret --key="path/to/tls.key" --cert="path/to/tls.crt" -n apim
```

By default, Application Gateway stores all public certificate authority.
The root certificate must also be loaded in Azure applicationn gateway only if private.
```
az network application-gateway root-cert create --gateway-name <application gateway names --name apim-root-cert --resource-group <AKS managed Resource group or resource group of the application gateway>
```

#### Add Demo docker registry
This docker registry contains basic APIM docker images with some defaults parameters.
Those images have a short license term (Max 2 months). 

Add a registry for the demo
```
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$demo-github' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTQ0NTM5OTMsImlhdCI6MTY0NjY3Nzk5MywiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6NjMsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9LHsiUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9oZWxtLWNoYXJ0IiwiQWN0aW9uIjoicmVhZCIsIkVmZmVjdCI6IiJ9XX0.CWhcKlWG3Mflkq7M2FAZ0oFgvktpUFduL2fKLARPTapY5Sm9f6nQmL8ql7QZWGq0Zu6kFLnE9bhRZB7lLGYxFYA1Rs4TA7Q3hB6qxfpZcCSOuw2l_VQNY9aoHS_yC1v-uYJorrJA2ba1sOgy7WyOm9BXnrvcZl5aUGbiAh1S7qZlFEiUOJEjYkdU3hP1-uU-FvEW60yEd1StWj9mJM_Ykonuv8xl-pffmnCzGMWhyhH2NDLuROXHpxMO0b_yTlkUDjAsxkuarpsDbSf8SJSDn82KW5lSjEXuXk2IixQClS6MIhvkciKX1zZ1pbQpV09-l1xxpoAOkcZSodZv6T6S8kKwZ7b0f3Jd3WHBJsfPIpHVKoqH0O9JFlZk3-vh1_yGmIOovIYX1yKN0tfwsWNIA_Ul72zq0ewcTEioJX3PDvsAl1bDsry5xAADkd5xXDsJC3CEN4n1xvsdNr0Lk7-z0vvWFNy1ZecOkJpTb-OrPl6bC6hnhmqRHnxnvImlCIkj9tUX0CHQTxEwjmnvwwPLb0LgtTAAwBvaAG9-ZHIcLtBap45AIw1RESPT1F6ghJkDRM7HYxkisH73WgUjKTwE6QwnZNSTgHMxjY9ZDtjOjF6A66y3fK-49V1EMZvUCFtMEkXsVNhu4hJmDCINXq_0XcSFzLYj2rPVdwwLzWWN07M" \
    --docker-email=demo@axway.com -n apim
```

### Installation
For the installation of our Helmchart you have to create and maintain for future upgrades your own `local-values.yaml` file. As a starter, you may use our AZURE-AKS with no ingress [example](azure-aks-example-agic-values.yaml) as a base. Use the following command to get a local copy:  

```
wget -o local-values-aks-agic.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/azure-aks/azure-aks-example-agic-values.yaml
```

Some modifications must be done :
- Uncomment cert-manager ingress annotation if using it.
- Uncomment the appgw-trusted-root-certificate if using private certs.
- global.domainName must be changed
- xxx.tls.hosts must be changed


You can overwrite all parameters of the base [`values.yaml`](../../values.yaml), therefore our recommendation is to check it for appropriate configuration parameters inlcuding their documentation.

To finally start the deployment into your Kubernetes Cluster using Helm, use now the following command:
```
helm install axway-apim -n apim -f .\local-values-aks-agic.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-2.9.0/helm-chart-axway-apim-2.11.0-pre.tgz
```

Now wait that all containers are up and in running state with the following command : 
```
kubectl get pods -n apim -w
```

You can check also the configuration in the Azure Application Gateway.
Configuration has been updated automatically so never change anything directly from the portal. All changes must be provided by annotation or configuration inside Kubernetes.


Listeners
![Application gateway listener](imgs/agic-listener.png)

HTTP listeners exists because the value file example contains an annotation to redirect requests in https 

Probes:
![Application gateway probes](imgs/agic-probes.png)


### Access to APIM
Use the fololowing command to known the URL. 
```
kubectl get ingress -n apim
```

Open your web browser and use the ingress hosts to access to the UI.
Admin node manager https://anm.<domainname>
API Manager https://manager.<domainname>
API Portal https://portal.<domainname>
API Traffic https://traffic.<domainname>/healthcheck


## Uninstall the product
Uninstall APIM
```
helm uninstall apim-demo -n apim
kubectl delete ns apim
```