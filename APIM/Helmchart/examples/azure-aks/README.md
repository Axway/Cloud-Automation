








## Prerequisites

# You haven't a DNS zone




# Add Demo docker registry
This docker registry contains basic APIM docker images with some defaults parameters.
Those images have a short license term (Max 2 months). 


Create an APIM namespace
'''
Kubectl create ns apim-demo
'''


Add a registry for the demo
'''
kubectl create secret docker-registry axway-demo-registry \
    --docker-server=axwayproductsdemo.azurecr.io \ --docker-username=apim-demo \ --docker-password=3mL3FoB8Pb/lqIWZwmaf3oYV2zKr0W68 \ --docker-email=demo@axway.com -n apim-demo
'''


Install Helm
'''
helm install apim-demo APIM/Helmchart -n apim -f APIM/Helmchart/examples/azure-aks/azure-aks-example.yaml
'''





# Cluster AKS cluster
Uninstall APIM
'''
helm uninstall apim-demo -n apim
'''

Clean PVC
The following action will destroy all persistant data. Please make sure pour un

