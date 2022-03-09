# Deploy APIM on AKS without ingress controller
## Prerequisites
### Create namespace
It's recommended to create a dedicated namespace to deploy the demo.
```
Kubectl create ns apim-demo
```

### Add Demo docker registry
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

### Create External services
Create  simple load balancer access
```
kubectl apply -f APIM/Helmchart/examples/azure-aks/azure-externalservices.yaml -n apim-demo
```

### Add APIPortal certificates.
API-Portal requires some server certificate to start correctly. THe following step import a demo certificate.
```
kubectl apply -f APIM/Helmchart/examples/azure-aks/azure-portal-secrets.yaml -n apim-demo
```

## APIM deployment
```
helm install apim-demo APIM/Helmchart -n apim-demo -f APIM/Helmchart/examples/azure-aks/azure-aks-example-noingress-value.yaml
```
Please wait that all containers are up and in running state with the following command : 
```
kubectl get pods -n apim-demo -w
```

## Access to APIM
Use the fololowing command to known what ip has been created for 
```
kubectl get svc -n apim-demo | grep public
```

Open your web browser and use the the public IP (third column) and the port to access to the UI.
Admin node manager https://<public-ip>:8090
API Manager https://<public-ip2>:8075
API Portal https://<public-ip3>
API Traffic https://<public-ip4>:8065/healthcheck

# Uninstall the product
Uninstall APIM
```
helm uninstall apim-demo -n apim-demo
kubectl delete ns apim-demo
```
