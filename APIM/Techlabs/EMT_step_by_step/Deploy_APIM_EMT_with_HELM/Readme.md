# Deploy APIM EMT with HELM
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

*********************

helm list -A
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
cert-manager    cert-manager    1               2020-11-09 22:07:15.85852 +0100 CET     deployed        cert-manager-v0.14.1    v0.14.1
nginx-ingress   nco-ns          1               2020-11-09 22:23:20.4600221 +0100 CET   deployed        nginx-ingress-0.7.0     1.9.0


helm install demo7-amplify-apim-7.7-test (nom de l’installation) demo7testacr/amplify-apim-7.7 --namespace=demo7-test --set platform=ESX,managedIngress=true,global.apimVersion=7.7,global.namespace=demo7-test,global.dockerRegistries.apimName=demo7testacr.azurecr.io,global.dockerRegistries.apimSecret=azure-container-registry,anm.buildTag=7.7.1586357966,anm.ingressName=anm.demo7.test.azure.demoaxway.com,apimgr.buildTag=7.7.1586357966,apimgr.ingressName=api-manager.demo7.test.azure.demoaxway.com,apitraffic.buildTag=7.7.1586357966,apitraffic.ingressName=api.demo7.test.azure.demoaxway.com,apitraffic.share.secret=azure-file,apitraffic.share.name=gw-events,mysqlAnalytics.enabled=true,mysqlAnalytics.external=false,mysqlAnalytics.host=,cassandra.external=false,cassandra.keyspace=demo7_test_1,apiportal.enabled=false,apiportal.buildTag=7.7.1586357966,apiportal.ingressName=none,apiportal.share.secret=azure-file,apiportal.share.name="",oauth.enabled=false