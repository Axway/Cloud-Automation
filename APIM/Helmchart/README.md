# Helmchart for Amplify API-Management

## Introduction

Helmcharts are compatible with Axway Amplify API Management 7.7. 

This helmchart uses Helm V3 and is compliant a minimal Kubernetes version of 1.11.

## Prerequisite

This helmchart requires the following capabilities on the Kubernetes cluster:
- A minimal kubernetes version 1.11
- An nginx ingress-controller like nginx or Azure Application Gateway.
- A storage class with in RWM.
- A storage class with in RWO.
- A total resources of 6vcpu and 8Go memory spread on 2 nodes.
- A container registry with API-Gateway and API-Portal images

## Installation

The Helm-Chart provided is as much as possible independent to the target platform, like AWS-EKS, Google GKE, 
OpenShift, etc. You control the specific deployment to match your environment using your local-values.yml file.

Modify the sample file according to your environment and version control your `local-values.yaml` in your version management system to make the process repeatable.  

Our recommendation is to deploy one service at a time. In other words, disable everything except the Admin-Node-Nanager and install the chart. Check that the Admin-Node-Nanager is running and then proceed, enable other services.

```
helm install -n apim -f myvalues.yaml axway-apim https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.0.0/helm-chart-axway-apim-2.0.0.tgz
```

After the Admin-Node-Manager runs, you can upgrade the Helm-Chart for more services respectively:

```
helm upgrade -n apim -f myvalues.yaml axway-apim https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.0.0/helm-chart-axway-apim-2.0.0.tgz
```

### AWS-EKS Deployment example

To deploy the solution on an AWS-EKS cluster you can use the following sample `local-values.yaml` as a starting point, which of course needs to be customized according to your environment.  

Please load the example local-values.yaml:
```
wget -O local-values.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/aws/aws-eks-example-values.yaml
```

