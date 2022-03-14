# Multiple API Gateway groups deployment example

The target of this section is to deploy multiple API Gateway groups in Kubernetes.
The following sampls are platform agnostic and you will have to adapt them in your context.

![Multiple API Gateway groups diagram](imgs/multiple-api-gateway-groups-deployment.png)

Note : It's possible to use the same Cassandra instance and to disable Redis component to decrease resources usage.

## Additional Kubernetes Prerequisites

To deploy this solution, you need to have configured:
- A Kubernetes cluster with 
    - 3 nodes minimaly (size DS2v2 min)
    - 2 namespaces (apim-external and apim-internal in our example)
    - 2 ingress controllers. Please consult the Managed ingress limitation to know if multiple ingress can be deployed.
- Clients kubectl and helm v3 installed

## Installation
### Preparations

 Please follow the appropriate instructions in other README examples according your environment:
 - Storage class for PVC events
 - Ingress annotations

#### Domain- and DNS-Setup

You need 2 subdomains minimally. 
Both of them must listen on a diferent IP.
Those ips can be public or private.

#### Ingress-Controller
It's recommended to use 2 ingress controllers deployed Although it's possible to use external services.
Please follow the appropriate instructions in other README examples according your environment.

#### Add Demo docker registry
This docker registry contains basic APIM docker images with some defaults parameters.
Those images have a short license term (Max 2 months).

Add a registry for the demo
```
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$demo-github' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTQ0NTM5OTMsImlhdCI6MTY0NjY3Nzk5MywiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6NjMsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9LHsiUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9oZWxtLWNoYXJ0IiwiQWN0aW9uIjoicmVhZCIsIkVmZmVjdCI6IiJ9XX0.CWhcKlWG3Mflkq7M2FAZ0oFgvktpUFduL2fKLARPTapY5Sm9f6nQmL8ql7QZWGq0Zu6kFLnE9bhRZB7lLGYxFYA1Rs4TA7Q3hB6qxfpZcCSOuw2l_VQNY9aoHS_yC1v-uYJorrJA2ba1sOgy7WyOm9BXnrvcZl5aUGbiAh1S7qZlFEiUOJEjYkdU3hP1-uU-FvEW60yEd1StWj9mJM_Ykonuv8xl-pffmnCzGMWhyhH2NDLuROXHpxMO0b_yTlkUDjAsxkuarpsDbSf8SJSDn82KW5lSjEXuXk2IixQClS6MIhvkciKX1zZ1pbQpV09-l1xxpoAOkcZSodZv6T6S8kKwZ7b0f3Jd3WHBJsfPIpHVKoqH0O9JFlZk3-vh1_yGmIOovIYX1yKN0tfwsWNIA_Ul72zq0ewcTEioJX3PDvsAl1bDsry5xAADkd5xXDsJC3CEN4n1xvsdNr0Lk7-z0vvWFNy1ZecOkJpTb-OrPl6bC6hnhmqRHnxnvImlCIkj9tUX0CHQTxEwjmnvwwPLb0LgtTAAwBvaAG9-ZHIcLtBap45AIw1RESPT1F6ghJkDRM7HYxkisH73WgUjKTwE6QwnZNSTgHMxjY9ZDtjOjF6A66y3fK-49V1EMZvUCFtMEkXsVNhu4hJmDCINXq_0XcSFzLYj2rPVdwwLzWWN07M" \
    --docker-email=demo@axway.com -n apim-internal
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$demo-github' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTQ0NTM5OTMsImlhdCI6MTY0NjY3Nzk5MywiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6NjMsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9LHsiUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9oZWxtLWNoYXJ0IiwiQWN0aW9uIjoicmVhZCIsIkVmZmVjdCI6IiJ9XX0.CWhcKlWG3Mflkq7M2FAZ0oFgvktpUFduL2fKLARPTapY5Sm9f6nQmL8ql7QZWGq0Zu6kFLnE9bhRZB7lLGYxFYA1Rs4TA7Q3hB6qxfpZcCSOuw2l_VQNY9aoHS_yC1v-uYJorrJA2ba1sOgy7WyOm9BXnrvcZl5aUGbiAh1S7qZlFEiUOJEjYkdU3hP1-uU-FvEW60yEd1StWj9mJM_Ykonuv8xl-pffmnCzGMWhyhH2NDLuROXHpxMO0b_yTlkUDjAsxkuarpsDbSf8SJSDn82KW5lSjEXuXk2IixQClS6MIhvkciKX1zZ1pbQpV09-l1xxpoAOkcZSodZv6T6S8kKwZ7b0f3Jd3WHBJsfPIpHVKoqH0O9JFlZk3-vh1_yGmIOovIYX1yKN0tfwsWNIA_Ul72zq0ewcTEioJX3PDvsAl1bDsry5xAADkd5xXDsJC3CEN4n1xvsdNr0Lk7-z0vvWFNy1ZecOkJpTb-OrPl6bC6hnhmqRHnxnvImlCIkj9tUX0CHQTxEwjmnvwwPLb0LgtTAAwBvaAG9-ZHIcLtBap45AIw1RESPT1F6ghJkDRM7HYxkisH73WgUjKTwE6QwnZNSTgHMxjY9ZDtjOjF6A66y3fK-49V1EMZvUCFtMEkXsVNhu4hJmDCINXq_0XcSFzLYj2rPVdwwLzWWN07M" \
    --docker-email=demo@axway.com -n apim-external
```

### Installation
#### Internal namespace deployment
For the installation of our Helmchart you have to create and maintain for future upgrades your own `local-values.yaml` file. As a starter, you may use our apim internal value file [example](apim-internal-value.yaml) our apim external value file [example2](apim-external-value.yaml) as a base. Use the following command to get a local copy:  

```
wget -o local-apim-internal-value.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/multiple-gateways-groups/apim-internal-value.yaml
wget -o local-apim-external-value.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/multiple-gateways-groups/apim-external-value.yaml
```

By default, those files can't be deployed without modification. You need to customize ingress/services and storage class minimally.
You can overwrite all parameters of the base [`values.yaml`](../../values.yaml), therefore our recommendation is to check it for appropriate configuration parameters including their documentation.

To finally start the deployment into your Kubernetes Cluster using Helm, use now the following commands:
```
helm install axway-apim-int -n apim-internal -f .\local-apim-internal-value.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.3.0/helm-chart-axway-apim-2.3.0.tgz
helm install axway-apim-ext -n apim-external -f .\local-apim-external-value.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.3.0/helm-chart-axway-apim-2.3.0.tgz
```

Now wait that all containers are up and in running state with the following command : 
```
kubectl get pods -A
```

### Access to APIM
Use the fololowing command to known the URL. 
```
kubectl get ingress -A
```

Open your web browser and use the ingress hosts to access to the UI.
Admin node manager https://anm.<domainname1>
API Manager int https://manager.<domainname1>
API Traffic int https://traffic.<domainname1>/healthcheck
API Manager ext https://manager.<domainname2>
API Traffic ext https://traffic.<domainname2>/healthcheck
API Portal https://portal.<domainname2>


Login to the Admin Node Manager UI and check that the topology view contains both API groups.

Note : The second API-Manager must be added in the API-Portal configuration.