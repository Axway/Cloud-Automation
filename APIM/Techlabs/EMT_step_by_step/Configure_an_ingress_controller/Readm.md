# Configure an Ingress Controller

## What we are going to do
- Install and configure an Ingress Controler with NGINX
It will allow us to access our APIM cluster in Kubernetes from outside
- Install and configure a certificat manager with Lets Encrypt
It will allow automatic generation of certificat using Lets Encrypt

TODO -> SCHEMA Here

*********************

## Information you need before you start
1. RG_NAME_NETWORK
2. RG_NAME_DNS
3. PUBLIC_IP_ADDRESS_NAME (eg. apim-emt-ip-<<your-trigram>>)
4. YOUR_DNS_ALIAS (eg. <<your-trigram>>)

*********************

## Information you will get from this step
1. PUBLIC_IP_ADDRESS

*********************

- Create a public IP into AKS Ressource Group
    First, we need to create a public address to join AKS

    Execute the following command to create a public IP [documentation](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_create)
    ``` Bash
    az network public-ip create --resource-group <<RG_NAME_NETWORK>> --sku Standard --name <<PUBLIC_IP_ADDRESS_NAME>> --allocation-method static --query publicIp.ipAddress -o tsv --allocation-method static
    ```

    Output command
    ``` Bash
    <<PUBLIC_IP_ADDRESS>>
    ```

- Create DNS zone
Then we need DNS records in order to be able to connect to AKS and to APIM UIs (manager, manageent)
    - Record creation of A type [information](https://pressable.com/2019/10/11/what-are-dns-records-types-explained-2/)
        ``` Bash
        az aks show --resource-group <<AKS_RESSOURCE_GROUP>> --name <<AKS_NAME>> --query nodeResourceGroup -o tsv

        az network dns record-set a add-record -g <<RG_NAME_DNS>> -z azure.demoaxway.com -n <<YOUR_DNS_ALIAS>> -a <<PUBLIC_IP_ADDRESS>>
        ```
        Output command
        ``` Bash
        {
          "arecords": [
            {
              "ipv4Address": "<<PUBLIC_IP_ADDRESS>>"
            }
          ],
          "etag": "7101c679-aca0-494c-975b-5cfb87bfb886",
          "fqdn": "....azure.demoaxway.com.",
          "id": "/subscriptions/f0202431-2a18-4bea-8ae0-f3b4c723bbdb/resourceGroups/.../providers/Microsoft.Network/dnszones/azure.demoaxway.com/A/...",
          "metadata": null,
          "name": "...",
          "provisioningState": "Succeeded",
          "resourceGroup": "...",
          "targetResource": {
            "id": null
          },
          "ttl": 3600,
          "type": "Microsoft.Network/dnszones/A"
        }
        ```

    - Record creation of CNAME type [information](https://pressable.com/2019/10/11/what-are-dns-records-types-explained-2/)

        - DNS record to join ANM web UI
        ``` Bash
        az network dns record-set cname set-record -g <<RG_NAME_DNS>> -z azure.demoaxway.com -n anm.<<YOUR_DNS_ALIAS>> -c <<YOUR_DNS_ALIAS>>.azure.demoaxway.com
        ```
        
        Output command
        ``` Bash
        {
          "cnameRecord": {
            "cname": "...azure.demoaxway.com"
          },
          "etag": "7d7b3e19-20ae-4dd8-bacd-ad85683f516b",
          "fqdn": "...azure.demoaxway.com.",
          "id": "/subscriptions/f0202431-2a18-4bea-8ae0-f3b4c723bbdb/resourceGroups/.../providers/Microsoft.Network/dnszones/azure.demoaxway.com/CNAME/...",
          "metadata": null,
          "name": "...",
          "provisioningState": "Succeeded",
          "resourceGroup": "...",
          "targetResource": {
            "id": null
          },
          "ttl": 3600,
          "type": "Microsoft.Network/dnszones/CNAME"
        }
        ```

        - DNS record to join API web UI
        ``` Bash
        az network dns record-set cname set-record -g <<RG_NAME_DNS>> -z azure.demoaxway.com -n api.<<YOUR_DNS_ALIAS>> -c <<YOUR_DNS_ALIAS>>.azure.demoaxway.com
        ```

        Output command
        ``` Bash
        {
          "cnameRecord": {
            "cname": "...azure.demoaxway.com"
          },
          "etag": "e5f956da-0a1d-4bf9-88b4-be223be92b02",
          "fqdn": "...azure.demoaxway.com.",
          "id": "/subscriptions/f0202431-2a18-4bea-8ae0-f3b4c723bbdb/resourceGroups/.../providers/Microsoft.Network/dnszones/azure.demoaxway.com/CNAME/...",
          "metadata": null,
          "name": "...",
          "provisioningState": "Succeeded",
          "resourceGroup": "...",
          "targetResource": {
            "id": null
          },
          "ttl": 3600,
          "type": "Microsoft.Network/dnszones/CNAME"
        }
        ```

        - DNS record to join API Manager web UI
        ``` Bash
        az network dns record-set cname set-record -g <<RG_NAME_DNS>> -z azure.demoaxway.com -n api-manager.<<YOUR_DNS_ALIAS>> -c <<YOUR_DNS_ALIAS>>.azure.demoaxway.com
        ```

        Output command
        ``` Bash
        {
          "cnameRecord": {
            "cname": "...azure.demoaxway.com"
          },
          "etag": "651c0b4c-2da0-458b-b4bd-b08628efd4be",
          "fqdn": "...azure.demoaxway.com.",
          "id": "/subscriptions/f0202431-2a18-4bea-8ae0-f3b4c723bbdb/resourceGroups/.../providers/Microsoft.Network/dnszones/azure.demoaxway.com/CNAME/...",
          "metadata": null,
          "name": "...",
          "provisioningState": "Succeeded",
          "resourceGroup": "...",
          "targetResource": {
            "id": null
          },
          "ttl": 3600,
          "type": "Microsoft.Network/dnszones/CNAME"
        }
        ```

- Install NGINX
Now we need to install an ingress controller. 
To do so, we are using NGINX offcial HELM who will deploy NGINX as Ingress Controller into our AKS

    - Adding NGINX repository into HELM
        First we need to add NGINX repository into HELM repo :
        ``` Bash
        helm repo add nginx-stable https://helm.nginx.com/stable
        ```
        Expected Output command
        ``` Bash
        "nginx-stable" has been added to your repositories
        ```

    - Updating HELM repository
        ``` Bash
        helm repo update
        ```
        Expected Output command
        ``` Bash  
        Hang tight while we grab the latest from your chart repositories...
        ...Successfully got an update from the "nginx-stable" chart repository
        Update Complete. ⎈Happy Helming!⎈
        ```
TODO: check this command with NCO
    - Deploying NGINX
        
        ``` Bash
        kubectl create namespace ingress-controller
        ```

        Then we can deploy by launching an HELM install :
        ``` Bash
        helm install nginx-ingress nginx-stable/nginx-ingress --namespace "ingress-controller" --set controller.replicaCount=2,controller.nodeSelector."beta\.kubernetes\.io/os"=linux,defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux,controller.service.externalTrafficPolicy=Local,controller.service.loadBalancerIP="<<PUBLIC_IP_ADDRESS>>",rbac.create=true --set-string controller.config.use-http2=false,controller.ssl_procotols=TLSv1.2        
        ```

    Output command
    ``` Bash
    NAME: nginx-ingress
    LAST DEPLOYED: ...
    NAMESPACE: <<K8S_NAMESPACE_NAME>>
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    The NGINX Ingress Controller has been installed.
    ```

- Install a certificat manager
    First, we are going to create a dedicated namespace : 
    ``` Bash
    kubectl create namespace cert-manager
    ```

    Than give a mandatory label name to cert-manager namespace (TODO:documentation)
    ``` Bash
    kubectl label namespace cert-manager cert-manager.io/disable-validation=true
    ```
    
    Add jetstack to HELM repository
    ``` Bash
    helm repo add jetstack https://charts.jetstack.io
    ```
    
    Update HELM repository
    ``` Bash
    helm repo update
    ```
    
    Install the certificat manager
    ``` Bash
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.14.1 --set webhook.enabled=false
    ```
    
    Create a file called "gen-cert.yml" and insert the following yaml instruction :
    ``` Bash
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-dev
      namespace: "ingress-controller"
    spec:
      acme:
        server: https://acme-staging-v02.api.letsencrypt.org/directory
        email: youremail@yourdomain.com
        privateKeySecretRef:
          name: letsencrypt-dev
        solvers:
        - http01:
            ingress:
              class: nginx
    ```
    
    Deploy your file
    ``` Bash
    kubectl apply -F yourfile.yml
    ```