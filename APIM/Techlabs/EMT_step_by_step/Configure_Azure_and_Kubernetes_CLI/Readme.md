# Configure Azure and Kubernetes CLI

*********************

Information you need before you start : 
1. TENANT_ID
2. SERVICE_PRINCIPAL_ID
3. SERVICE_PRINCIPAL_PASSWORD
5. SERVICE_PRINCIPAL_NAME
6. K8S_NAMESPACE_NAME
7. AKS_NAME
8. AKS_RESSOURCE_GROUP
9. ACR_URL
10. STORAGE_ACCOUNT
11. STORAGE_SHARED_NAME
12. CASSANDRA_ROOT_PASSWORD
13. MYSQL_ROOT_PASSWORD
14. ANALYTIC_USER_PASSWORD

*********************

The goal of this scenario is to create and configure step by step Azure CLI and Kubernetes CLI in order to access an AKS instance.

- Login with your account in Azure CLI called az ([documentation](https://docs.microsoft.com/fr-fr/cli/azure/create-an-azure-service-principal-azure-cli))
    ``` Bash
    az login --service-principal -u "<<SERVICE_PRINCIPAL_ID>>" --password "<<SERVICE_PRINCIPAL_PASSWORD>>" --tenant "<<TENANT_ID>>"
    ```
    
    Expected output command
    ``` Bash
    [
      {
        "cloudName": "AzureCloud",
        "homeTenantId": "...",
        "id": "...",
        "isDefault": true,
        "managedByTenants": [],
        "name": "...",
        "state": "Enabled",
        "tenantId": "...",
        "user": {
          "name": "...",
          "type": "servicePrincipal"
        }
      }
    ]
    ```
- Connect your Kubernetes CLI to AKS ([documentation](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_get_credentials))

    Execute the following commands to connect with AKS

    ``` Bash
    az aks get-credentials --resource-group <<AKS_RESSOURCE_GROUP>> --name <<AKS_NAME>>
    ```
    Expected output command
    ``` Bash
    Merged "<<AKS_NAME>>" as current context in /home/centos/.kube/config
    ```

- Get cluster information ([documentation](https://kubernetes.io/docs/reference/kubectl/cheatsheet/))
    ``` Bash
    kubectl cluster-info
    ```
    Expected output command
    ``` Bash
    Kubernetes master is running at https://...
    healthmodel-replicaset-service is running at https:...
    CoreDNS is running at https://...
    Metrics-server is running at https://...
    
    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    ```

- Create a dedicated namespace ([documentation](https://kubernetes.io/fr/docs/concepts/overview/working-with-objects/namespaces/))

    You are going to work on your own Kubernetes namespace so you need to create one first
    ``` Bash
    kubectl create namespace <<K8S_NAMESPACE_NAME>>
    ```
    Expected output command
    ``` Bash
    namespace/<<K8S_NAMESPACE_NAME>> created
    ```

- List cluster namespace 

    Execute a comand to list every namepsaces in AKS and verify yours is created :
    ``` Bash
    kubectl get namespace
    ```
    Expected output command
    ``` Bash
    NAME               STATUS   AGE
    cert-manager       Active   9d
    default            Active   10d
    K8S_NAMESPACE_NAME Active   20s
    kube-node-lease    Active   10d
    kube-public        Active   10d
    kube-system        Active   10d
    ```

- Secret creation ([documentation](https://kubernetes.io/fr/docs/concepts/configuration/secret/))

    - Secret for Azure Container Registry access
        We are going to store ACR credentials using Service Principal name and secret into Kubernetes secret 
        ``` Bash
        kubectl create secret docker-registry registry-secret --namespace <<K8S_NAMESPACE_NAME>> --docker-server <<ACR_URL>> --docker-username "<<SERVICE_PRINCIPAL_NAME>>" --docker-password "<<SERVICE_PRINCIPAL_PASSWORD>>"
        ```
        Expected output command
        ``` Bash
        secret/azure-container-registry created
        ```

    - Secret for Azure File Prenium access
        - First, we are going to create storage account in Azure
            ``` Bash
            aksConnectionString=`az storage account show-connection-string -n <<STORAGE_ACCOUNT_NAME>> -g <<AKS_RESSOURCE_GROUP>> -o tsv`
    
            az storage share create -n <<STORAGE_SHARED_NAME>> --connection-string $aksConnectionString --quota 100
            ```
            Expected output command
            ``` Bash
            {
              "created": true
            }
            ```

        - Then we are going to get and store in a local variable a shared key :
            ``` Bash
            _aksStorageFileSharedKey=$(az storage account keys list --resource-group <<AKS_RESSOURCE_GROUP>> --account-name <<STORAGE_ACCOUNT_NAME>> --query "[0].value" -o tsv)
            ```
        
        - Finally we are creating secret
            ``` Bash
            kubectl create secret generic azure-file --namespace <<K8S_NAMESPACE_NAME>> --from-literal=azurestorageaccountname=<<STORAGE_ACCOUNT_NAME>> --from-literal=azurestorageaccountkey=$_aksStorageFileSharedKey
            ```
            Expected output command
            ``` Bash
            secret/azure-file created
            ```

    - Secrets for mySQL password
        We are going to store mySQL password into Kubernetes secret 
        ``` Bash
        kubectl create secret generic apim-password --namespace <<K8S_NAMESPACE_NAME>> --from-literal=dbmysqlanalytics=<<ANALYTIC_USER_PASSWORD>> --from-literal=dbmysqlroot=<<MYSQL_ROOT_PASSWORD>> --from-literal=dbcass=<<CASSANDRA_ROOT_PASSWORD>>
        ```
    
        Expected output command
        ``` Bash
        secret/apim-password created
        ```

- Secret verification
    Execute the following command to list all secrets stored in Kubernetes :
    ``` Bash
    kubectl get secrets -n <<K8S_NAMESPACE_NAME>>
    ```

    Expected output command
    ``` Bash
    NAME                       TYPE                                  DATA
    apim-password              Opaque                                2   
    azure-container-registry   kubernetes.io/dockerconfigjson        1   
    azure-file                 Opaque                                2   
    default-token-vjkbh        kubernetes.io/service-account-token   3  
    ```