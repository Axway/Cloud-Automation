# Google Kubernetes Engine deployment

Here you can find information on how to deploy Axway API-Management solution on Google Kubernetes engine using our Helmchart. 

## Prerequisites

Even though this documentation tries to explain the deployment as best as possible, a solid understanding of Kubernetes, the Google Cloud Platform, name resolution and of course Helm is absolutely necessary for the installation.  

- A Kubernetes cluster configured in Google Cloud
  - At least 2 nodes (e.g. e2-medium)
  - If you plan to deploy the Elastic-Solution please configure at least 3 Nodes (e.g. e2-standard-4)
  - Create a namespace (e.g. apim) 
- `kubectl` points to configured Kubernetes cluster
- Helm is installed and configured

## Installation

The installation on Google Kubernetes engine (GKE) is divided into some preparations and the actual installation of the solution using the HELM chart.

### Preparations

#### Domain- and DNS-Setup

To ultimately make the solution available, some ingress resources are created for the specified domains (e.g., anm.axway-apim-customer.com) and Google Load-Balancers are created based on them.  

If you want to use one or more new domains, then you should register them accordingly in advance. 
You have different possibilities up to the local `/etc/hosts` or you use the Google Cloud Platform --> Networks services --> [Cloud Domains](https://cloud.google.com/domains/docs/register-domain). 

Here is an example of a registered domain using Cloud domains and Google-Domains as the name service:  
![Google Cloud-Domains](imgs/google-cloud-domains.png)  

Google does not support updating DNS records via ingress resources, so you must maintain the DNS records yourself.
Here is an example using [Google-Domains](https://domains.google.com), each pointing to the belonging created Google load balancer:  
![Google-Domains](imgs/google-domains-dns-entries.png)  

#### Certificates

The services, such as the API manager, API traffic, etc. are offered by the load balancers via HTTPS. You can provide the necessary certificates yourself in the GCP, store them as your own secret and reference them, or use Google-Managed certificates. 
In the example, [Google-Managed certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs) are used for each service. You can create these using the sample YAML file.

```
kubectl apply -f https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/google-gke/google-managed-certificates.yaml
```

#### Ingress controller

According to the Ingress controller used, such as [NGINX](https://cloud.google.com/kubernetes-engine/docs/how-to/custom-ingress-controller), the appropriate annotations must be set.  
Our Helm chart is prepared for this, but which annotations to use for which Ingress controller is not part of this documentation.  
You may skip this topic, if you are using a different Ingress-Controller, other than the default Google Ingress Controller (`kubernetes.io/ingress.class: "gce"`) that does not support extensive configuration via Ingress annotations. 

As we refer here to the standard [Google GKE ingress controller](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) (`kubernetes.io/ingress.class: "gce"`), which makes it unfortunately necessary to create [BackendConfig CRDs](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#direct_hc) that configure the required health checks. You may use our example to create the required [Google BackendConfigs](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#direct_hc) custom resource definitions:

```
kubectl apply -f https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/google-gke/google-backend-configs.yaml
```

### Installation

For the installation of our Helmchart you have to create and maintain for future upgrades your own `local-values.yaml` file. As a starter, you may use our Google Cloud GKE example as a base:
```
wget -o local-values-gke.yaml https://raw.githubusercontent.com/Axway/Cloud-Automation/master/APIM/Helmchart/examples/google-gke/google-gke-example-values.yaml
```

Now adjust the downloaded `local-values-gke.yaml` file according to your needs and version control it to make later upgrades safe and easy or to integrate it properly into your CI/CD-Pipeline.  
You can overwrite all parameters of the base [`values.yaml`](../../values.yaml), therefore our recommendation is to check it for appropriate configuration parameters inlcuding their documentation.

To finally start the deployment into your Kubernetes Cluster using Helm, use now the following command:
```
helm install axway-apim -n apim -f .\local-values-gke.yaml https://github.com/Axway/Cloud-Automation/releases/download/apim-helm-v2.0.0/helm-chart-axway-apim-2.0.0.tgz
```

Now check if the resources, such as pods, ingresses, services, etc. are created and correct any problems that occur.
```
kubectl -n apim pods get -w
```

Since it can be helpful to know the target state, here's a set of screenshots of the Google cloud management interface illustration all different resources that were created during the deployment:  

#### Services & Pods

![Services and PODS](imgs/gke-services.png)  

#### Ingresses

![Ingresses](imgs/gke-ingresses.png)  

#### Load-Balancers

![Load-Balancers](imgs/gke-load-balancers.png)  

#### Storage

In the sample values file provided, persistent volumes for API Gateway Events, OpenTraffic, Audit and Traces are disabled and an emptyDir volume is used. If you are using the Elastic solution this is fine as the log information is then streamed to Elasticsearch via Filebeat. 
Otherwise, you need to disable the PVCs and configure them according to the environment.

![Storage](imgs/gke-pvcs-storage.png)  

#### Frontends

![Frontends](imgs/gke-frontends.png)  

#### Backends

![Backends](imgs/gke-backends.png)  

#### Health checks

![Health checks](imgs/gke-healthchecks.png)  
