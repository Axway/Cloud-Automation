## Zero downtime deployment

Another great feature of container deployment is the zero downtime deployment.

The solution was deployed using [Helm](https://helm.sh/). Let use a new version of the chart

!!! Get the version

We can update the deployment with following command
```
helm upgrade --reuse-values apim-amplify-apim-7.6.2 1 
```
apim-amplify-apim-7.6.2

![](./imgs/)

helm rollback apim-amplify-apim-7.6.2 1