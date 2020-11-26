# Deploy APIM EMT with HELM
*********************

Information you need before you start : 
1. SERVICE_PRINCIPAL_PASSWORD   *(Password of your Service Principal)* 
2. SERVICE_PRINCIPAL_NAME       *(Name of your Service Principal)*
3. ACR_NAME                     *(name of your Azure Container Registry)*
4. ACR_URL                      *(url of your Azure Container Registry)*
5. K8S_NAMESPACE_NAME           *(Name of your K8S namespace)*
6. STORAGE_SHARED_NAME          *(Name of your shared storage)*
7. YOUR_DNS_ALIAS               
8. APIM_VERSION                 *(APIM version of your binary)*
9. APIM_BUILD                   *(APIM build of your binary)*
10. IMAGE_ANM_NAME              *(name of your anm image name)*
11. IMAGE_GTW_NAME              *(name of your gtw image name)*
12. YOUR_DOMAIN_NAME            *(name of your domain)*
13. HELM_PACKAGE_NAME           *(name of Helm package to deploy)*
14. HELM_PACKAGE_VERSION        *(version of Helm package to deploy)*

Information you need to set :
1. YOUR_HELM_RELEASE_NAME        *(a name for your Helm release)*


*********************

## What we are going to do
The goal of this step is to get Helm package from Azure Container Registry and deploy APIM EMT into Azure Kubernetes Service by using this Helm package.

*********************

### Fetch APIM EMT Helm package

1. Adding ACR repository into HELM client
    ``` Bash
    az acr helm repo add --name <<ACR_NAME>>
    ```
    Expected Output command
     ``` Bash
    This command is implicitly deprecated because command group 'acr helm' is deprecated and will be removed in a future release. Use 'helm v3' instead.
    "<<ACR_NAME>>" has been added to your repositories
     ```
    
2. Updating HELM local repository

     ``` Bash
    helm repo update
    ```

    Expected Output command
     ``` Bash
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "<<ACR_NAME>>" chart repository
    Update Complete. ⎈Happy Helming!⎈
     ```


3. Pulling HELM charts package from ACR
    In our case, Helm package we want to use is located in ACR so we are going to search for our package into ACR first :
    ``` Bash
    helm search repo apim
    ```
    Expected Command output 
    ``` Bash
    NAME                                            CHART VERSION   APP VERSION                 DESCRIPTION
    <<ACR_NAME>>/<<HELM_PACKAGE_NAME>>                  x.y.z       <<HELM_PACKAGE_VERSION>>          Package for ...
    ```
    
    Then go on a specific folder and pull our Helm charts package
    ``` Bash
    cd $HOME/helm-package

    helm pull <<ACR_NAME>>/<<HELM_PACKAGE_NAME>>
    ```

    When it is done, untar Helm package
    ``` Bash
    tar -xvf <<HELM_PACKAGE_NAME>>-<<HELM_PACKAGE_VERSION>>.tgz
    ```
    
### Perform Helm package installation
- Execute HELM install [documentation](https://helm.sh/docs/helm/helm_install/)
    The following command will install your HELM package.
    **It can takes several minutes before your Kubernetes cluster is up and running.**

    ``` Bash
   helm install <<YOUR_HELM_RELEASE_NAME>> <<YOUR_HELM_PACKAGE_NAME>> --namespace=<<K8S_NAMESPACE_NAME>> --set global.domainName=<<YOUR_DNS_ALIAS>>.<<YOUR_DOMAIN_NAME>>,global.apimVersion=<<APIM_VERSION>>.<<APIM_BUILD>>,global.namespace=<<K8S_NAMESPACE_NAME>>,global.createSecrets=false,global.dockerRegistry.url=<<ACR_URL>>,anm.buildTag=<<APIM_VERSION>>.<<APIM_BUILD>,anm.imageName=<<IMAGE_ANM_NAME>>,apimgr.buildTag=<<APIM_VERSION>>.<<APIM_BUILD>>,apimgr.imageName=<<IMAGE_GTW_NAME>>,apitraffic.buildTag=<<APIM_VERSION>>.<<APIM_BUILD>>,apitraffic.imageName=<<IMAGE_GTW_NAME>>,apitraffic.share.name=<<STORAGE_SHARED_NAME>> --atomic --wait --timeout 15m0s
    ```

    Expected output command example
    ``` Bash
    NAME: <<YOUR_HELM_RELEASE_NAME>>
    LAST DEPLOYED: Day MM DD hh:mm:ss YYYY
    NAMESPACE: <<K8S_NAMESPACE_NAME>>
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

- Verify your Kubernetes cluster state
    While your APIM EMT Cluster is starting, you can check pod logs with the following commands :
    
        - Check your 3 ingress have been created :
        ``` Bash
        kubectl get ingress -n <<K8S_NAMESPACE_NAME>>
        ```
    
        Expected output command example
        ``` Bash
        NAME                        HOSTS                                                 ADDRESS           PORTS     AGE
        apimanager                  api-mgr.<<YOUR_DNS_ALIAS >>.<<YOUR_DOMAIN_NAME>>   xxx.xxx.xxx.xxx   80, 443   6m48s
        cm-acme-http-solver-4sdcm   anm.<<YOUR_DNS_ALIAS >>.<<YOUR_DOMAIN_NAME>>                        80        6m44s
        cm-acme-http-solver-7cvzj   api-mgr.<<YOUR_DNS_ALIAS >>.<<YOUR_DOMAIN_NAME>>                     80        6m45s
        cm-acme-http-solver-nk2f6   api.<<YOUR_DNS_ALIAS >>.<<YOUR_DOMAIN_NAME>>                         80        6m45s
        gatewaymanager              anm.<<YOUR_DNS_ALIAS >>.<<YOUR_DOMAIN_NAME>>       xxx.xxx.xxx.xxx   80, 443   6m48s
        traffic                     api.<<YOUR_DNS_ALIAS >>.<<YOUR_DOMAIN_NAME>>       xxx.xxx.xxx.xxx   80, 443   6m48s
        ```
        
        - Get a list of your pods
         ``` Bash
        kubectl get po -n <<K8S_NAMESPACE_NAME>>
        ```
        Expected output command example **when all pods are deployed in success**
        ``` Bash
        NAME                                                              READY   STATUS      RESTARTS   AGE
        anm-6968d9fc4f-tv9s6                                              1/1     Running     0          4m41s
        apimgr-5db9b4b8d9-2bvmw                                           1/1     Running     0          4m41s
        cassandra-0                                                       1/1     Running     0          4m41s
        cm-acme-http-solver-h8vzq                                         1/1     Running     0          4m37s
        cm-acme-http-solver-jctsp                                         1/1     Running     0          4m37s
        cm-acme-http-solver-r6jwk                                         1/1     Running     0          4m37s
        db-create-mysql-apigw-6293cfb3-34b8-4af9-96a6-14a495d692dbwl2jj   0/1     Completed   0          4m40s
        mysql-aga-757495f88f-rg9nv                                        1/1     Running     0          4m41s
        traffic-75ffc776b6-g2shk                                          1/1     Running     0          4m41s
        traffic-75ffc776b6-shkzl                                          1/1     Running     0          4m41s
        traffic-75ffc776b6-sq8lw                                          1/1     Running     0          4m41s
        ```

        - Access a log for a specific pod
        ``` Bash
        kubectl logs <<POD_NAME>> --follow -n <<K8S_NAMESPACE_NAME>> 
        ```
    
- Delete your cluster
    If you need to delete your cluster, you can run the following command
    ``` Bash
    helm delete <<YOUR_HELM_RELEASE_NAME>> --namespace=<<K8S_NAMESPACE_NAME>>
    ```