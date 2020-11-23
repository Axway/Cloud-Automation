# Configure and create HELM package

## What do you need to start 
  - HELM CLI installed [documentation](https://helm.sh/docs/intro/install/)
  - GIT installed [documentation](https://git-scm.com/book/fr/v2/D%C3%A9marrage-rapide-Installation-de-Git)

*********************

## Information you need before you start
1. **ACR_NAME**                   *(name of Azure Container Registry)*
2. **APIM_VERSION**               *(APIM version of your binary)*
3. **APIM_BUILD**                 *(APIM build of your binary)*
4. **YOUR_HELM_PACKAGE_NAME**     *(Your HELM package name)*
5. **YOUR_HELM_PACKAGE_VERSION**  *(Your HELM package version)*
*********************

## What we are going to do
- Setup HELM client
- Pull HELM project from GIT
- Configure and create an HELM package
- Publish HELM package into ACR

*********************

### Prepare environement to generate APIM Docker images

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
    ...Successfully got an update from the "nginx-stable" chart repository
    Update Complete. ⎈Happy Helming!⎈
     ```

3. Pulling HELM charts from GIT

    ``` Bash
    TODO: mettre la commande pull git sur la bonne branche
    ```

4. Modifying HELM charts

    Into "../Cloud-Automation-master/APIM/Helmchart/amplify-apim-7.7" folder, you will find a "Chart.yaml" file.
    This file describe your HELM package and will help you to find it into HELM repository.
    
    Modify this "Chart.yaml" file in order to specify your own HELM package :
        -	Change appVersion with your APIM version-build 
        -	Add your own keyword to the package (eg. your trigram)
        -	Change package name (eg. amplify-apim-7.7-your_trigram)
        -	Change package version to 1.0.0

    ``` Bash
    apiVersion: v2
    appVersion: <<APIM_VERSION>>-<<APIM_BUILD>>
    description: Package for demo instance of Axway AMPLIFY API Management.
    icon: https://images.app.goo.gl/MbQyRo2M2jzAsed79
    home: https://www.axway.com/en/products/api-management
    keywords:
    - API Management, Axway, AMPLIFY API, Demo, v7.7, Azure
    kubeVersion: '>=1.15.0'
    maintainers:
    - email: <<YOUR_EMAIL>>
      name: cloud-automation community
    name: <<YOUR_HELM_PACKAGE_NAME>>
    version: <<YOUR_HELM_PACKAG_VERSION>>
    ```

5. Generate an HELM package
    
    Once you personalized your HELM Chart, you can generate an HELM package :
    ``` Bash
    helm package <<$HOME>>/Cloud-Automation/APIM/Helmchart/amplify-apim-7.7 -d <<$HOME>>/Cloud-Automation/APIM/Helmchart
    ```

    Expected Output command
     ``` Bash
    Successfully packaged chart and saved it to: <<$HOME>>/Cloud-Automation/APIM/Helmchart/<<YOUR_HELM_PACKAGE_NAME>>-<<YOUR_HELM_PACKAG_VERSION>>.tgz
    ```

6. Push HELM packge into ACR

    Then push your HELM package to Azure Container Repository
    ``` Bash
    az acr helm push --name <<ACR_NAME>> <<$HOME>>/Cloud-Automation/APIM/Helmchart/<<YOUR_HELM_PACKAGE_NAME>>-<<YOUR_HELM_PACKAG_VERSION>>.tgz
    ```

    Expected Output command
     ``` Bash
    This command is implicitly deprecated because command group 'acr helm' is deprecated and will be removed in a future release. Use 'helm v3' instead.
    {
      "saved": true
    }
    ```

7. (Optipnal) Update your local HELM registry
    ``` Bash
    helm repo update
    ```

    Expected Output command
     ``` Bash
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "nginx-stable" chart repository
    ...Successfully got an update from the "<<ACR_NAME>>" chart repository
    Update Complete. ⎈Happy Helming!⎈
    ```