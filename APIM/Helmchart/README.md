# Helmchart for Amplify API-Management

## Introduction

This Helmchart can be used to deploy the Axway API management solution on a Kubernetes environment. It is not tied to any dedicated version, i.e. you can deploy any version >=7.7 (e.g. 7.7.20210830) by configuring the corresponding ImageTag. 
Axway does not provide pre-built images as of today, so you have to build them yourself in advance, store them in your container registry and reference them accordingly in your local-values.

## Prerequisite

This Helmchart requires the following capabilities on the Kubernetes cluster:

- A minimal Kubernetes version 1.11
- `kubectl` installed and configured to your Kubernetes cluster
- Helm is installed and configured
- A configured Ingress-Controller depending on your platform
- If persistence is enabled 
  - A storage class with in RWM.
  - A storage class with in RWO.
- A total resources of minimal 6vcpu and 8Go memory spread on 2 nodes.
- A container registry with API-Gateway and API-Portal images
  - To learn more how to build API-Gateway Docker-Image [click here](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigw_containers/docker_script_baseimage/index.html)
  - To learn more how to build/use the API-Portal Docker image [click here](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apiportal_docker/index.html)

Even though this documentation tries to explain the deployment as best as possible, a solid understanding of your Kubernetes-Distribution, your underlying platform, Internet-Naming-Service and of course Helm is absolutely necessary for the installation.  

## Examples

The Helm chart provided is highly configuable and independent of the Kubernetes distribution with a few exceptions. With that, you can use it to deploy the solution on a plain Kubernetes, AWS Elastic Kubernetes service, Google GKE, etc., by providing a properly configured local-values.yaml file to the Helm process.     

As a kick-starter, we have already provided sample values files including documentation for some environments. 

| Distribution                             | Helm-Chart version  | Comment                                        | 
| :---                                     | :---                | :---                                           |
| [AWS-EKS](examples/aws-eks)              | >= v2.0.0           |                                                |
| [Google GKE](examples/google-gke)        | >= v2.1.0           |                                                |
| [OpenShift](examples/openshift)          | >= v2.x.x           | To be validated with refactored Helm-Chart     |

The list is not to say that the Helm chart cannot be used for other Kubernetes distributions, but just a list of the current provided example values and documentation.

## Create Admin-Users

If the API management platform is run in a container platform, then you need to configure the admin users either via an externally provided file: apigateway/conf/adminUsers.json 
or via an [LDAP connection](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_administration/apigtw_admin/general_rbac_ad_ldap/index.html) which is the preferred way.  

User management in API Gateway Manager is disabled because changes to the file: `adminUsers.json` are not persisted.  

If you do not want to set up an LDAP connection, then you can either include the file directly in the admin node manager image via merge directory or provide it via a 
mounted secret. The latter option is certainly more flexible, since you do not have to rebuild the image for each user.  

The following steps are necessary to set up a secret mount based on the helmet chart.  

1. Create the secret based on the `adminUsers.json`
```
wget -o adminUsers.json https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/general/adminUsers.json
kubectl create secret generic axway-apigateway-admin-users -n apim --save-config --dry-run=client --from-file=adminUsers.json=adminUsers.json -o yaml | kubectl apply -f -
```
