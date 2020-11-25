# EMT step by step

The goal of this technical lab is to create and configure step by step an APIM EMT environment on Azure Kubernetes Server (AKS).

## Prerequisites
**Thoses prerequisites are not covered in this lab and must be created and accessible**
- Create and configure an Azure Kubernetes Server (AKS)
- Create and configure an Azure Container Registry (ACR)
- Create a Service Principal (SP)
    - With Contributor as role into AKS Ressource Group
- Create a Azure Storate Account (file prenium)
- Use a Linux VM with
    - Azure CLI installed
    - Kubernetes CLI (kubctl) installed
    - Docker installed
    - HELM installed
    - Latest APIM binaries for install

## Tech lab overview
- [1. Configure Azure CLI and Kubernetes CLI](./Configure_Azure_and_Kubernetes_CLI) (kubctl)
    - Login with Azure CLI and connect to AKS
    - Create a dedicated namespace into K8S
    - Create secrets into K8S
- [2. Configure an Ingress controller](./Configure_an_ingress_controller)
    - Create a public IP address for Ressource Group cluster
    - Create DNS records
    - Create and configure NGINX ingress
    - Create and configure a certmanager
- [3. APIM Docker image creation](./APIM_Docker_image_creation)
    - Create docker images
        - APIM Base
        - APIM ANM
        - APIM Gateway
    - Push images into Azure Container Repository (ACR)
- [4. Deploy APIM EMT with HELM](./Deploy_APIM_EMT_with_HELM)
    - Configure HELM CLI to use an ACR
    - Get HELM charts from ACR
    - Deploy EMT APIM solution using Helm