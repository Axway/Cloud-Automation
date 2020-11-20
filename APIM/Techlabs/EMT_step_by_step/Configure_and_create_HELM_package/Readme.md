Ajouter le repository demo7testacr :

az acr helm repo add --name <<ACR_USERNAME>>
This command is implicitly deprecated because command group 'acr helm' is deprecated and will be removed in a future release. Use 'helm v3' instead.
"axwayapimdemo7" has been added to your repositories


Effectuer une mise à jour du repository :
helm repo update

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "axwayapimdemo7" chart repository
...Successfully got an update from the "nginx-stable" chart repository
Update Complete. ⎈Happy Helming!⎈


Pour voir la liste des repository disponible :
helm repo list

NAME            URL
nginx-stable    https://helm.nginx.com/stable
axwayapimdemo7  https://axwayapimdemo7.azurecr.io/helm/v1/repo

helm package /home/centos/Cloud-Automation/APIM/Helmchart/amplify-apim-7.7 -d /home/centos/Cloud-Automation/APIM/Helmchart
Successfully packaged chart and saved it to: /home/centos/Cloud-Automation/APIM/Helmchart/amplify-apim-7.7-ddi-1.0.0.tgz

az acr helm push --name axwayapimdemo7 /home/centos/Cloud-Automation/APIM/Helmchart/amplify-apim-7.7-ddi-1.0.0.tgz
This command is implicitly deprecated because command group 'acr helm' is deprecated and will be removed in a future release. Use 'helm v3' instead.
{
  "saved": true
}

helm repo update

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "nginx-stable" chart repository
...Successfully got an update from the "axwayapimdemo7" chart repository
Update Complete. ⎈Happy Helming!⎈

