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
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjUzMjQwNTUsImlhdCI6MTY1NzU0ODA1NSwiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6OTgsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9XX0.kZUKyR5dO0aBClw3rWCyHQy7gaV80eVN4Yhwbf4kGoti-uhRMhQBnSpeRIvZ3l89I7iLkhNIuQJlJbvYWOR_G_mj3-V1Xy5IL9hzrTRDJhkvJL3yoStIBb7kqPyy3-Cf5TSra4bEWPLC9ssDk2c_CHAh88RfnRH3FNQhAo_hOjJVYSYKmvBP1k5mXjvPjLxNezj1s5hqwDFBBDnvpZ1Sxvwt4n4CCmrwhgU53dGqRLvqTM5FBK7bjqB23hyvcKoS59jUXW5mFjCd8_6EdUmcbRaC0O1StD4MwBr_6DE_p9EHZHLhUAk5tCSg2IRF2LXm40o1MTUiRIOpAPBVyAWieVelsEyeb8TgllaTT4chCL787nIRzIjzIFBf4jA5zlkpQ0_GD0EL41CiUjV96MtE4lgrVLZmj8R9nhrR0FuZlD-01cBg-GID7AG7Q42B43um3H9dJLJ1B8YbUfwofM9tzsH1deljejhYuWeKlniDZzxN8M8JOO6m2WCQEyu1_9FEvsMSECRNix0cJPkc-8OOAQ58S4nW_VrRzcDK4Is-UheNo5cHDmS3vS_37nPQsAQKnF3ovo3eZnditXsaSaAvOZXuUVSeHGFMW9g7puL_KVrsmSVW4eGIzrBphTXgdYmvWEPzEWjvC6iaxQUGrxr4L1KXYTCWySsUvQAZgeq5iQs" \
    --docker-email=demo@axway.com -n apim-internal
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$demo-github' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjUzMjQwNTUsImlhdCI6MTY1NzU0ODA1NSwiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6OTgsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9XX0.kZUKyR5dO0aBClw3rWCyHQy7gaV80eVN4Yhwbf4kGoti-uhRMhQBnSpeRIvZ3l89I7iLkhNIuQJlJbvYWOR_G_mj3-V1Xy5IL9hzrTRDJhkvJL3yoStIBb7kqPyy3-Cf5TSra4bEWPLC9ssDk2c_CHAh88RfnRH3FNQhAo_hOjJVYSYKmvBP1k5mXjvPjLxNezj1s5hqwDFBBDnvpZ1Sxvwt4n4CCmrwhgU53dGqRLvqTM5FBK7bjqB23hyvcKoS59jUXW5mFjCd8_6EdUmcbRaC0O1StD4MwBr_6DE_p9EHZHLhUAk5tCSg2IRF2LXm40o1MTUiRIOpAPBVyAWieVelsEyeb8TgllaTT4chCL787nIRzIjzIFBf4jA5zlkpQ0_GD0EL41CiUjV96MtE4lgrVLZmj8R9nhrR0FuZlD-01cBg-GID7AG7Q42B43um3H9dJLJ1B8YbUfwofM9tzsH1deljejhYuWeKlniDZzxN8M8JOO6m2WCQEyu1_9FEvsMSECRNix0cJPkc-8OOAQ58S4nW_VrRzcDK4Is-UheNo5cHDmS3vS_37nPQsAQKnF3ovo3eZnditXsaSaAvOZXuUVSeHGFMW9g7puL_KVrsmSVW4eGIzrBphTXgdYmvWEPzEWjvC6iaxQUGrxr4L1KXYTCWySsUvQAZgeq5iQs" \
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
helm install axway-apim-int -n apim-internal -f .\local-apim-internal-value.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.9.0/helm-chart-axway-apim-2.9.0.tgz
helm install axway-apim-ext -n apim-external -f .\local-apim-external-value.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.9.0/helm-chart-axway-apim-2.9.0.tgz
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