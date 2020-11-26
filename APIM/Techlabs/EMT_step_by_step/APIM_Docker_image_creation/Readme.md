# APIM Docker image creation

## What do you need to start
- Access to a Linux server
- APIGateway installation binary (latest)
    - https://support.axway.com/fr/search/index/type/Downloads/sort/created%7Cdesc/ipp/10/product/324/version/3034/subtype/50
- APIGateway DockerScripts (latest)
    - https://support.axway.com/fr/search/index/type/Downloads/sort/created%7Cdesc/ipp/10/product/324/version/3034/subtype/47
- A valid license file
- A FED for the ANM component
- A FED for the API Manager component
- Dependencies
    - mysql-connector-java-5.1.46.jar

*********************

Information you need before you start : 
1. **ACR_URL**                        *(url of your Azure Container Registry)*
2. **ACR_NAME**                       *(name of your Azure Container Registry)*

Information you need to set :
1. **IMAGE_BASE_NAME**                *(a name for your base image name)*
2. **IMAGE_ANM_NAME**                 *(a name for your anm image name)*
3. **IMAGE_GTW_NAME**                 *(a name for your gateway image name)*
4. **APIM_VERSION**                   *(APIM version of your binary)*
5. **APIM_BUILD**                     *(APIM build of your binary)*
6. **BINARIES_PATH**                  *(eg. $HOME/binaries)*
7. **FULL_PATH_TO_YOUR_LICENSE**      *(eg. $HOME/license/my_license.lic)*
8. **MERGE_PATH_APIGATEWAY**          *(eg. $HOME/merge-directory/apigateway)*
9. **FULL_PATH_TO_YOUR_ANM_FED**      *(eg. $HOME/fed/my_anm_fed.fed)*
10. **FULL_PATH_TO_YOUR_GTW_FED**     *(eg. $HOME/fed/my_gtw_fed.fed)*

*********************

## What we are going to do
- Prepare environment to generate APIM Docker images
    - Certificate generation and password creation
    - Binaries, FEDs, dependancies and license upload
- Generate Docker images
    - apim-base
    - apim-gtw *(used for API Manager, API Manager UI and API Gateway components)*
    - apim-anm *(used for API Admin Node Manager component)*
- Push Docker images into Azure Container Repository (ACR)

*********************

### Prepare environement to generate APIM Docker images
1. Upload APIGateway installation binary, APIGateway DockerScripts, license, FED and dependencies into your Linux server
    - $HOME/binaries -> APIGateway installation binary and APIGateway DockerScripts
    - $HOME/fed -> your FED for ANM and Gateway
    - $HOME/license -> your license
    - $HOME/merge-directory/apigateway/ext/lib/ -> your dependencies (the mysql driver)

2. Extract files from the Docker scripts package that you downloaded from Axway Support
    ``` Bash
    cd $HOME/binaries
    tar -xvf APIGateway_7.x.YYYYMMDD-<bn>_DockerScripts.tar.gz
    ```
    The extracted package includes the following:
    - Python scripts (*.py)
    - Docker files
    - Quickstart demo
    
    *You will have now an apigw-emt-scripts-x.y.z-SNAPSHOT directory*

3. Generate certificates

    Used for internal flows between API components (ANM image and Gtw images)
    *gen_domain_cert.py with "--default-cert option" will generate selfsigned certificat with changeme as default passphrass*
   
    ``` Bash
    cd $HOME/binaries/apigw-emt-scripts-x.y.z-SNAPSHOT
    python2 gen_domain_cert.py --help
    python2 gen_domain_cert.py --default-cert
    
    ```
    Expected Command output 
    ``` Bash
    *Generating private key...*
    *Generating CSR...*
    *Generating self-signed domain cert...*
    *Done.*
    
    *Private key: certs/DefaultDomain/DefaultDomain-key.pem*
    *Domain cert: certs/DefaultDomain/DefaultDomain-cert.pem*
    ```
    *Once gen_domain_cert.py is executed, it has generated a directory tree into cert*


4. Create a file for storing password used as passphrase by DefaultDomain certificat

    ``` Bash
    echo changeme > certs/DefaultDomain/pass.txt
    ```

5. Create a file for storing ANM password
    Scripts to build images need to have password into files.

    ``` Bash
    echo changeme > anmpass.txt
    ```

### Generate Docker images
1. Make sure Docker deamon is started

    ``` Bash
    systemctl start docker
    ```

2. Build an API base image ([Axway documentation](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigw_containers/docker_script_baseimage/index.html))

    ``` Bash
    cd $HOME/binaries/apigw-emt-scripts-x.y.z-SNAPSHOT
    
    python2 build_base_image.py --installer=<<BINARIES_PATH>>/APIGateway_<<APIM_VERSION>>.<<APIM_BUILD>>_Install_linux-x86-64_BN3.run --os="centos7" --out-image <<ACR_URL>>/<<IMAGE_BASE_NAME>>:<<APIM_VERSION>>-<<APIM_BUILD>>
    ```
    Expected Command output 
    ``` Bash
    Step 1/14
    ...
    Step 14/14
    ```
    
    *Your Docker image is now created into Docker local repository.*
    
    You can see it with the following command :
    ``` Bash
    docker image ls
    ```
    Expected Command output
    ``` Bash
    REPOSITORY                                    TAG                             IMAGE ID            CREATED             SIZE
    <<ACR_URL>>/<<IMAGE_BASE_NAME>>      <<APIM_VERSION>>-<<APIM_BUILD>>        xxxxxxxxxxxx        x seconds ago        949MB
    centos                                     7                                xxxxxxxxxxxx        x seconds ago        204MB
    ```

3. Build an ANM image ([Axway documentation](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigw_containers/docker_script_anmimage/index.html))

    This image will be use to generate 
    - API Admin Node Manager component

    ``` Bash
    python2 build_anm_image.py --out-image=<<ACR_URL>>/<<IMAGE_ANM_NAME>>:<<APIM_VERSION>>-<<APIM_BUILD>> --parent-image <<ACR_URL>>/<<IMAGE_BASE_NAME>>:<<APIM_VERSION>>-<<APIM_BUILD>> --domain-cert certs/DefaultDomain/DefaultDomain-cert.pem --domain-key certs/DefaultDomain/DefaultDomain-key.pem --domain-key-pass-file certs/DefaultDomain/pass.txt --license <<FULL_PATH_TO_YOUR_LICENSE.lic>> --anm-username=admin --anm-pass-file=anmpass.txt --healthcheck --metrics --merge-dir <<MERGE_PATH_APIGATEWAY>> --fed $HOME/fed/<<FULL_PATH_TO_YOUR_ANM_FED>>
    ```
    Expected Command output 
    ``` Bash
    Step 1/13
    ...
    Step 13/13
    ```
    
    *Your Docker image is now created into Docker local repository.*
    
    You can see it with the following command :
    ``` Bash
    docker image ls
    ```

    Expected Command output
    ``` Bash
    REPOSITORY                                       TAG                             IMAGE ID            CREATED             SIZE
    <<ACR_URL>>/<<IMAGE_ANM_NAME>>           <<APIM_VERSION>>-<<APIM_BUILD>>        xxxxxxxxxxxx        x seconds ago        953MB
    <<ACR_URL>>/<<IMAGE_BASE_NAME>>          <<APIM_VERSION>>-<<APIM_BUILD>>        xxxxxxxxxxxx        x seconds ago        949MB
    centos                                         7                                xxxxxxxxxxxx        x seconds ago        204MB
    ```

4. Build an API Gateway image ([Axway documentation](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigw_containers/docker_script_gwimage/index.html))

    This image will be use to generate 
    - API Manager component
    - API Manager UI component
    - API Gateway component
    
    ``` Bash
    python2 build_gw_image.py --out-image=<<ACR_URL>>/<<IMAGE_GTW_NAME>>:<<APIM_VERSION>>-<<APIM_BUILD>> --parent-image <<ACR_URL>>/<<IMAGE_BASE_NAME>>:<<APIM_VERSION>>-<<APIM_BUILD>> --domain-cert certs/DefaultDomain/DefaultDomain-cert.pem --domain-key certs/DefaultDomain/DefaultDomain-key.pem --domain-key-pass-file certs/DefaultDomain/pass.txt --license <<FULL_PATH_TO_YOUR_LICENSE>> --group-id default --merge-dir <<MERGE_PATH_APIGATEWAY>> --fed <<FULL_PATH_TO_YOUR_GTW_FED>>
    ```

    Expected Command output 
    ``` Bash
    Step 1/11
    ...
    Step 11/11
    ```
    
    *Your Docker image is now created into Docker local repository.*
    
    You can see it with the following command :
    ``` Bash
    docker image ls
    ```

    Expected Command output
    ``` Bash
    REPOSITORY                                        TAG                             IMAGE ID            CREATED             SIZE
    <<ACR_URL>>/<<IMAGE_GTW_NAME>>           <<APIM_VERSION>>-<<APIM_BUILD>>        xxxxxxxxxxxx        x seconds ago        957MB
    <<ACR_URL>>/<<IMAGE_ANM_NAME>>           <<APIM_VERSION>>-<<APIM_BUILD>>        xxxxxxxxxxxx        x seconds ago        953MB
    <<ACR_URL>>/<<IMAGE_BASE_NAME>>          <<APIM_VERSION>>-<<APIM_BUILD>>        xxxxxxxxxxxx        x seconds ago        949MB
    centos                                         7                                xxxxxxxxxxxx        x seconds ago        204MB
    ```

### Push Docker images into Azure Container Repository (ACR)
1. Connexion to ACR
    Now we need to connect to Azure Container Repository by login in and configure as default repository :
    ``` Bash
    az acr login --name <<ACR_NAME>>
    ```
    Expected Command output 
    ``` Bash
    Login Succeeded
    ```

    ``` Bash
    az configure --defaults acr=<<ACR_NAME>>
    ```

2. Push images to ACR
    Last step, we push our 3 Docker images into ACR :
    ``` Bash
    docker push <<ACR_URL>>/<<IMAGE_BASE_NAME>>
    docker push <<ACR_URL>>/<<IMAGE_ANM_NAME>>
    docker push <<ACR_URL>>/<<IMAGE_GTW_NAME>>
    ```
    
    You can check container list on ACR with the following command 
    ``` Bash
    az acr repository list
    ```
    
    Output command example :
    ``` Bash
    [
      "ddi-apim-anm",
      "ddi-apim-base",
      "ddi-apim-gtw"
    ]
    ```