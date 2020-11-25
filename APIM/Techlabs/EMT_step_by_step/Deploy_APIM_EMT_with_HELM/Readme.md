# Deploy APIM EMT with HELM
*********************

Information you need before you start : 

1. SERVICE_PRINCIPAL_PASSWORD
2. SERVICE_PRINCIPAL_NAME
3. K8S_NAMESPACE_NAME
4. ACR_NAME
5. ACR_URL
1. STORAGE_ACCOUNT
1. STORAGE_SHARED_NAME
1. YOUR_HELM_RELEASE_NAME
1. YOUR_HELM_PACKAGE_NAME
1. YOUR_DNS_ALIAS
1. APIM_VERSION
1. APIM_BUILD
1. IMAGE_ANM_NAME
1. IMAGE_GTW_NAME
1. STORAGE_SHARED_NAME

*********************

helm list -A
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
cert-manager    cert-manager    1               2020-11-09 22:07:15.85852 +0100 CET     deployed        cert-manager-v0.14.1    v0.14.1
nginx-ingress   nco-ns          1               2020-11-09 22:23:20.4600221 +0100 CET   deployed        nginx-ingress-0.7.0     1.9.0


- Execute HELM install [documentation](https://helm.sh/docs/helm/helm_install/)

helm install <<YOUR_HELM_RELEASE_NAME>> <<ACR_NAME>>/<<YOUR_HELM_PACKAGE_NAME>> 
--namespace=<<K8S_NAMESPACE_NAME>> 
--set global.domainName=<<YOUR_DNS_ALIAS>>.azure.demoaxway.com,
global.apimVersion=<<APIM_VERSION>>,
global.namespace=<<K8S_NAMESPACE_NAME>>,
global.dockerRegistry.url=<<ACR_URL>>,
global.dockerRegistry.username=<<SERVICE_PRINCIPAL_NAME>>,
global.dockerRegistry.token=<<SERVICE_PRINCIPAL_PASSWORD>>,
global.createSecrets=false,
anm.buildTag=<<APIM_VERSION>>-<<APIM_BUILD>>,
anm.imageName=<<IMAGE_ANM_NAME>>,
apimgr.buildTag=<<APIM_VERSION>>-<<APIM_BUILD>>,
apimgr.imageName=<<IMAGE_GTW_NAME>>,
apitraffic.buildTag=<<APIM_VERSION>>-<<APIM_BUILD>>,
apitraffic.imageName=<<IMAGE_GTW_NAME>>,
apitraffic.share.secret=azure-file,
apitraffic.share.name=<<STORAGE_SHARED_NAME>> 
--atomic --wait --timeout 10m0s


While your APIM EMT Cluster is starting, you can check pod logs with the following command :
kubectl logs <<POD_NAME>> --follow -n <<K8S_NAMESPACE_NAME>> 

Check your 3 ingress have been created :
kubectl get ingress -n <<K8S_NAMESPACE_NAME>> 

helm delete <<YOUR_HELM_RELEASE_NAME>> --namespace=<<K8S_NAMESPACE_NAME>>
