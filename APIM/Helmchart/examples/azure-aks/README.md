


## Prerequisites
### Add Demo docker registry
This docker registry contains basic APIM docker images with some defaults parameters.
Those images have a short license term (Max 2 months). 


Create an APIM namespace
```
Kubectl create ns apim-demo
```


Add a registry for the demo
```
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=docker-registry.demo.axway.com/demo-public \
    --docker-username='robot$apim-demo' \
    --docker-password="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTQ0NDkxNDIsImlhdCI6MTY0NjY3MzE0MiwiaXNzIjoiaGFyYm9yLXRva2VuLWRlZmF1bHRJc3N1ZXIiLCJpZCI6NjAsInBpZCI6MTYsImFjY2VzcyI6W3siUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9yZXBvc2l0b3J5IiwiQWN0aW9uIjoicHVsbCIsIkVmZmVjdCI6IiJ9LHsiUmVzb3VyY2UiOiIvcHJvamVjdC8xNi9oZWxtLWNoYXJ0IiwiQWN0aW9uIjoicmVhZCIsIkVmZmVjdCI6IiJ9XX0.JhN1cW-WaKSq3onrQI_TccTxCudNRaP9_QbndwO7EruVPrQr1Msdap4V_sXGyN4fr7XnEIVEa878p_Xbe44fqLTkDgfj1ob5gOg7SsYoUv5_TjgO8hcZPtbaHKdIb0Xro2-Xgu-fbfWbyoIzL52iKtD_mc8RGcQSiYNQwjY_4crI6S2uBJ-Q0Gz4l2lg7LW--Si7U11WNV3geeNZJdbra1pQEVduPQjX-GvLj-SPEO5jYTztAuO9vg35rZ0HOq1X1OmCzwF7tVNTxGicABnQTySFGar4emmD_WJ99PZVnozvYzmPafl1nFUX7EECRA2G9dhXmN7Y8oRzCJDr6caReATkGSfqk6nm6LsDJlfu4ie92fVMU-2-Kd80J8Zrl0rln0WVdwDkBI8DCPURv2iNcna_gqclu7xhwY6bDJ607Uz84n3YXktLnNt_2_sLDkyLx73Sm94Wuq68IV4n1HAuGyzJhDzIl27Jk1Au7iFvMIuia5K7u2KsFxzah1Ph70IFwNsPiWDSt90TxcrVWWJnD5Bfa9caOU8VShQ6ON7OxxJiXHTHfTWezMCmvtIJkvo9PpN9Hr-DdVT_FHko-V9g3Jo-_aObEuXx7jzLsdpiPq99PZdscrvD01XNAVRDFIoYMP1OJdQLquznOk1S7RGqI9lAZFGIONaKr8y0XCWA0Kw" \
    --docker-email=demo@axway.com -n apim-demo
```

### Create External services
Create  simple load balancer access
```
kubectl apply -f APIM/Helmchart/examples/azure-aks/azure-externalservices.yaml -n apim-demo
```


## Deploy APIM
```
helm install apim-demo ./ -n apim-demo -f APIM/Helmchart/examples/azure-aks/azure-aks-example-noingress-value.yaml
```

# Cluster AKS cluster
Uninstall APIM
```
helm uninstall apim-demo -n apim-demo
```
