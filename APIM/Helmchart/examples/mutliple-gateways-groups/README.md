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
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzA4MzAyMzYsImlhdCI6MTY2MzA1NDIzNiwiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6MTE2LCJwaWQiOjE2LCJhY2Nlc3MiOlt7IlJlc291cmNlIjoiL3Byb2plY3QvMTYvcmVwb3NpdG9yeSIsIkFjdGlvbiI6InB1bGwiLCJFZmZlY3QiOiIifSx7IlJlc291cmNlIjoiL3Byb2plY3QvMTYvaGVsbS1jaGFydCIsIkFjdGlvbiI6InJlYWQiLCJFZmZlY3QiOiIifV19.bMhjEatxETCDzgu1YMFacsj_gwH-KHwC1H1OaQ_2b77KzxPzoDM4iFzmReEMylQeaszcEZ4gdGYqHgME66DQC-qsSFlgprHGBPGTM6dSFeVQHXA_sfdNJYWgXFQFcq3lGiqqX4o56YxmtQgQznfBtkm8ijGLU0S7sMgFKU6GilTfyNNAVs0SvsTadKloPMXvZaBiM3hOlt22wV7LnBMPWnZY2r12WNa6uYRQEXHRsTvlOBC96Gf0SH3ofr9iVqd8FHs_yGtvkkZl9dYjf3oZ-7AtgKS33lJU-W1iQ-0xiaLNwj01MlVHlsmDJhdlZDN-7pVl4SX6VlHG915m6Nn6or6kb3A2HCzmENFerM7C3GCIdnE8rIknqbrvAvoO6a-hbRN6uUaWHmh0h0o_b1ZcwgKBJlmlnVlMufnGoeZOUwrV4_JDxg0U-W9NaUCKor9QXjqu-sJpAYXgCcBD1HFwpK3gRbXcrlIOMWMgQqq8yad9qvpeJtw5S2K6GROikd-kBdVEHn0vY-Noyq4fz0CwrxRE1fKEfgyfpqmQT_uUXGwBgbGFbfdMYYB8JPjgfvEx1DMVG_RsKEYfQ-fa7O1-t0eHvFCOgBixuzYNACOdi5-uf5KYn3kFyL4jxPLJDvWnBypu3BBOFTQLDv9KJ3pirhjQqrtYtwyKdHnel1USzl0" \
    --docker-email=demo@axway.com -n apim-internal
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$demo-github' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzA4MzAyMzYsImlhdCI6MTY2MzA1NDIzNiwiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6MTE2LCJwaWQiOjE2LCJhY2Nlc3MiOlt7IlJlc291cmNlIjoiL3Byb2plY3QvMTYvcmVwb3NpdG9yeSIsIkFjdGlvbiI6InB1bGwiLCJFZmZlY3QiOiIifSx7IlJlc291cmNlIjoiL3Byb2plY3QvMTYvaGVsbS1jaGFydCIsIkFjdGlvbiI6InJlYWQiLCJFZmZlY3QiOiIifV19.bMhjEatxETCDzgu1YMFacsj_gwH-KHwC1H1OaQ_2b77KzxPzoDM4iFzmReEMylQeaszcEZ4gdGYqHgME66DQC-qsSFlgprHGBPGTM6dSFeVQHXA_sfdNJYWgXFQFcq3lGiqqX4o56YxmtQgQznfBtkm8ijGLU0S7sMgFKU6GilTfyNNAVs0SvsTadKloPMXvZaBiM3hOlt22wV7LnBMPWnZY2r12WNa6uYRQEXHRsTvlOBC96Gf0SH3ofr9iVqd8FHs_yGtvkkZl9dYjf3oZ-7AtgKS33lJU-W1iQ-0xiaLNwj01MlVHlsmDJhdlZDN-7pVl4SX6VlHG915m6Nn6or6kb3A2HCzmENFerM7C3GCIdnE8rIknqbrvAvoO6a-hbRN6uUaWHmh0h0o_b1ZcwgKBJlmlnVlMufnGoeZOUwrV4_JDxg0U-W9NaUCKor9QXjqu-sJpAYXgCcBD1HFwpK3gRbXcrlIOMWMgQqq8yad9qvpeJtw5S2K6GROikd-kBdVEHn0vY-Noyq4fz0CwrxRE1fKEfgyfpqmQT_uUXGwBgbGFbfdMYYB8JPjgfvEx1DMVG_RsKEYfQ-fa7O1-t0eHvFCOgBixuzYNACOdi5-uf5KYn3kFyL4jxPLJDvWnBypu3BBOFTQLDv9KJ3pirhjQqrtYtwyKdHnel1USzl0" \
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