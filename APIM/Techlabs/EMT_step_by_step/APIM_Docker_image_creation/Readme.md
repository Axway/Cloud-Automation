# APIM Docker image creation

## What do you need to start
- Access to a Linux server
- APIGateway installation binary (latest)
    - https://support.axway.com/fr/search/index/type/Downloads/sort/created%7Cdesc/ipp/10/product/324/version/3034/subtype/50
- APIGateway DockerScripts (latest)
    - https://support.axway.com/fr/search/index/type/Downloads/sort/created%7Cdesc/ipp/10/product/324/version/3034/subtype/47
- A valide licence file
- A FED
- Dependencies
    - mysql-connector-java-5.1.46.jar

*********************

Information you need before you start : 
1. ACR_URL
2. ACR_NAME
3. IMAGE_BASE_NAME
4. IMAGE_ANM_NAME
5. IMAGE_GTW_NAME
6. BUILD
*********************

## What we are going to do
- Prepare environement to generate APIM Docker images
- Generate Docker images
    - apim-base
    - apim-gtw
    - apim-anm
- Push Docker images into Azure Container Repository (ACR)

*********************

### Prepare environement to generate APIM Docker images
1. Upload APIGateway installation binary, APIGateway DockerScripts, licence, FED and dependencies into your Linux server
- $HOME/binaries
- $HOME/fed
- $HOME/licence
- $HOME/merge-directory

2. Extract files from the Docker scripts package that you downloaded from Axway Support
``` Bash
cd $HOME/binaries
tar -xvf APIGateway_7.7.YYYYMMDD-<bn>_DockerScripts.tar.gz
```
The extracted package includes the following:
- Python scripts (*.py)
- Docker files
- Quickstart demo

*You will have now an apigw-emt-scripts-2.1.0-SNAPSHOT directory*

3. Generate certificats

Used to communication between API components (ANM image and Gtw image)
*gen_domain_cert.py with "--default-cert option" will generate selfsigned certificat with changeme as default passphrass*
``` Bash
cd $HOME/binaries/apigw-emt-scripts-2.1.0-SNAPSHOT
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
python2 build_base_image.py --installer=<<path_to_binary>>/APIGateway_7.7.20200330_Install_linux-x86-64_BN3.run --os="centos7" --out-image <<ACR_URL>>/<<IMAGE_BASE_NAME>>:7.7-<<BUILD>>
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

3. Build an ANM image ([Axway documentation](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigw_containers/docker_script_anmimage/index.html))

This image will be use to generate 
- API Admin Node Manager component

``` Bash
python2 build_anm_image.py --out-image=<<ACR_URL>>/<<IMAGE_ANM_NAME>>:7.7-<<BUILD>> --parent-image <<ACR_URL>>/<<IMAGE_BASE_NAME>>:7.7-<<BUILD>> --domain-cert certs/DefaultDomain/DefaultDomain-cert.pem --domain-key certs/DefaultDomain/DefaultDomain-key.pem --domain-key-pass-file certs/DefaultDomain/pass.txt --license <<FULL_PATH_TO_YOUR_LICENCE.lic>> --anm-username=admin --anm-pass-file=anmpass.txt
```

4. Build an API Gateway image ([Axway documentation](https://docs.axway.com/bundle/axway-open-docs/page/docs/apim_installation/apigw_containers/docker_script_gwimage/index.html))

This image will be use to generate 
- API Manager component
- API Manager UI component
- API Gateway component

``` Bash
python2 build_gw_image.py --out-image=<<ACR_URL>>/<<IMAGE_GTW_NAME>>:7.7-<<BUILD>> --parent-image <<ACR_URL>>/<<IMAGE_BASE_NAME>>:7.7-<<BUILD>> --domain-cert certs/DefaultDomain/DefaultDomain-cert.pem --domain-key certs/DefaultDomain/DefaultDomain-key.pem --domain-key-pass-file certs/DefaultDomain/pass.txt --license <<full_path_to_your_license.lic>> --group-id default --merge-dir /home/centos/merge-directory/apigateway --fed <<full_path_to_your_fed>>
```
### Push Docker images into Azure Container Repository (ACR)
1. Connexion to ACR
Now we need to connect to Azure Container Repository by login in and configure as default repository :
``` Bash
az acr login --name <<ACR_NAME>>
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

Output command
``` Bash
[
  "ddi-apim-anm",
  "ddi-apim-base",
  "ddi-apim-gtw"
]
```
