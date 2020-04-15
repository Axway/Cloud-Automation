#!/usr/bin/env bash
/root/.bash_profile 2>/dev/null
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

#############
# functions #
#############
function usage() { 
	echo -ne "Usage: $0 script to deploy API Management solufttion \n
                                -rg=\"string\" : Name of Azure resource group <resourceGroupName>. \n
                                -av=\"string\" : Version of API Management <apimVersion>. \n
                                -kn=\"string\" : Name of Azure Kubernetes Cluster <aksClusterName>. \n
                                -kv=\"string\" : Version of Kubernetes <kubeVersion>. \n
                                -crn=\"string\" : Name of Azure Container Registry <containerRegistryName>. \n
                                -esk=\"string\" : Preshared key to access Axway's sources <_axwayBlobSASToken>. \n
                                -usn=\"string\" : Name of Blob storage where customer file are stored <userBlobStorageName>. \n
                                -ucn=\"string\" : Container name storage where customer file are stored. \n
                                -spnn=\"string\" : Url of the Service Principal Name <servicePrincipalName>. \n
                                -spni=\"string\" : ID of the Service Principal Name <servicePrincipalName>. \n
                                -spnp=\"string\" : Password of Service principal name for AKS <_servicePrincipalPwd>. \n
                                -tid=\"string\" : tenant ID <_tenantID>. \n
                                -sfn=\"string\" : Name of Azure Storage File for AKS cluster <aksStorageFileAccountName>. \n
                                -dns=\"string\" : domain name <domainname.com>. Use azure.demoaxway.com by default. \n
                                -env=\"string\" : Environment. 3 possible values Container, standard or Cloud. \n
                                -ut=\"string\" : Usage type. 3 possible values Minimal, Standard or Full. \n
                                -pn=\"string\" : Project name. if no value, set name amplify-apim by default. \n
                                -mdm=\"Boulean\" : Define if DNS zone is manage inside the subscription. \n
                                -wbk=\"string\" : Webhook URL. if no value, log is write in file. \n
                                -debug desactivate by default <debug>\n" 1>&2; 
	exit 1; 
}

function log()
{
    mess="$(date '+%Y-%m-%d %H:%M:%S') $HOSTNAME : $1"
    echo $mess
    messConcat="$messConcat<br>$mess"
}

function f_sendLog()
{
    template='{"title":"%s","text":"%s"}'
    messJson=$(printf "$template" "$logTitle" "$messConcat")
    if [ $logWebhookName == "no" ]; then
        local logFile="/tmp/install-log-apim.log"
        $messjson >> $logFile
    else
         curl --header "Content-Type: application/json" \
         --request POST \
         --data "$messJson" \
         "$logWebhookName"
    #Init variable for next logs
    fi
    messjson=""
    messConcat=""
}

function f_Verify_File() {
    local localFile=$1
    if [ -f "${local_file}" ];then
        log "[INFO]  File [${localFile}] verified."
    else
        log "[ERROR] File [${localFile}] not found!"
        f_sendLog
        exit
    fi
}

f_Check_Nb_Params()
{
    local NbReal=$1
    local NbExpected=$2

    if [[ $NbReal -ne $NbExpected ]]; then
        log "[ERROR] Illegal number of parameters in function ${FUNCNAME[0]}"
        f_sendLog
        return 001
    fi
}

f_Create_Folder () {
    if [ ! -d "$1" ];then
        mkdir -p $1
    fi
}

function f_Install_AzureCli ()
{
    local urlGpgKeyMS="https://packages.microsoft.com/keys/microsoft.asc"
	package-cleanup --cleandupes
	yum install -y python-devel
	if ! [ -x "$(command -v az)" ]; then
		log "[INFO]  Start Azure CLI installation."
		rpm --import $urlGpgKeyMS
		sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
		yum install azure-cli -y --skip-broken
	else
		log "[INFO]  Azure cli already installed. Skip this step!"
	fi
}

function f_Install_Docker ()
{
	local uriGitDocker="https://download.docker.com/linux/centos/docker-ce.repo"

	log "[INFO]  Start Docker installation."
	yum install -y yum-utils device-mapper-persistent-data lvm2 dos2unix
	yum-config-manager --add-repo $uriGitDocker
	yum install docker-ce docker-ce-cli -y
	usermod -a -G docker $adminUser
	systemctl start docker
	if [[ $(docker --version) ]]; then 
		log "[INFO]  Docker Install OK"
	else
		log "[ERROR] Docker Install NOK - Error"
        f_sendLog
        exit 1
	fi
}

function f_Install_KubeClient ()
{
	if ! [ -x "$(command -v kubectl)" ]; then 
		log "[INFO]  Start Kubectl client installation."
		curl -LO https://storage.googleapis.com/kubernetes-release/release/v${kubeVersion}/bin/linux/amd64/kubectl
		chmod +x ./kubectl
		mv ./kubectl /usr/local/bin/kubectl
		log "[INFO]  Kubectl client installed"
	else
		log "[INFO]  kubectl client already installed. Skip this step!"
	fi
}

function f_Install_Helm ()
{
	local uriGitHelm="https://git.io/get_helm.sh"

	if ! [ -x "$(command -v helm)" ]; then 
		log "[INFO]  Helm installation in progress"
    	curl -LO $uriGitHelm
    	chmod 700 get_helm.sh
    	./get_helm.sh
		rm -f get_helm.sh
        mkdir /root/.helm
        export HELM_HOME=/root/.helm
	else
		log "[INFO]  Helm already installed. Nothing to do."
	fi
}

function f_Build_Bastion ()
{
    log "[INFO]  Install XFCE and xrdp"
    yum update -y --exclude=WALinuxAgent
    yum install -y epel-release
    yum install -y xrdp
    systemctl enable xrdp
    systemctl start xrdp
    yum groupinstall -y "Xfce"
    for i in $(ls -d /home/)
    do
        echo "xfce4-session" >> $i/.XClients
        chmod a+x $i/.XClients
    done
    
    systemctl restart xrdp
    log "[INFO]  Bastion configuration finished."
}

function f_Azure_Login () 
{
    log "[INFO]  Login to azure with SPN $servicePrincipalName"
	az login --service-principal -u $servicePrincipalId --password $_servicePrincipalPwd --tenant $_tenantID > /dev/null
}

function f_Get_Sources ()
{
	local licenceName=""
    local apimPackageName=""
    licenseLocation=""
    fedLocationGW=""
    envLocationGW=""
    dbLibLocation="$installFolder/dependencies/mysql-connector-java-5.1.46.jar"

    log "Create folder tree"
    f_Create_Folder $installFolder
    f_Create_Folder $dataFolder
    f_Create_Folder $productsFolder
    f_Create_Folder $depFolder
    f_Create_Folder $helmFolder

	log "Get User files from storage"
    if  [[ -n $(az storage blob list --account-name $userBlobStorageName --container-name $dataContainerName --output tsv | grep '.lic') ]]; then
        log "Licence key is present"
        az storage blob download-batch --account-name $userBlobStorageName \
                        --source $dataContainerName \
                        --destination $dataFolder \
                        --output tsv
        licenseName="$(basename $dataFolder/*.lic)"
        log "$licenseName will be used" 
        if [[ $licenseName =~ \ |\' ]];then
            mv "$dataFolder/${licenseName}" "$dataFolder/${licenseName// /_}"
        fi
        licenseLocation="$(ls $dataFolder/*.lic)"
    else
        log "Installation aborted! licence key not found."
        f_sendLog
        exit 1
    fi
    f_check_license version $apimVersionLt
    f_check_license deployment_type $licenseType
    f_check_license expires $timestamp

	log "Get Axway files from storage"
    az storage blob download-batch --account-name $userBlobStorageName \
                    --source $productsContainerName \
                    --pattern APIGateway_$apimVersion* \
                    --destination $productsFolder \
                    --output tsv

    apimProductLocation=$(ls $productsFolder/APIGateway_$apimVersion*.run)
    if [[ $(echo $apimProductLocation | wc -l) -eq 1 ]]; then
        apimPackageName=$(basename $apimProductLocation)
        log "Apim product package finded. Use package $apimPackageName"
    else
        log "Installation aborted! Apim package not found."
        f_sendLog
        exit 1
    fi

    apimSourceLocation=$(ls $productsFolder/APIGateway_$apimVersion*DockerScripts.tar.gz)
    if [[ $(echo $apimSourceLocation | wc -l) -eq 1 ]]; then
        sourcePackageName=$(basename $apimSourceLocation)
        log "Apim sources package finded. Use package $sourcePackageName"
        tar -xzf $apimSourceLocation --directory $productsFolder
        emtFolder=$(ls $productsFolder | grep apigw-emt)
        mv $productsFolder/$emtFolder/* $installFolder 
    else
        log "Installation aborted! Apim emt source not found."
        f_sendLog
        exit 1
    fi

	log "Get Helmchart source"
    az storage blob download-batch --account-name $userBlobStorageName \
                    --source $helmContainerName \
                    --destination $helmFolder \
                    --output tsv

	log "Get dependencies source"
    az storage blob download-batch --account-name $userBlobStorageName \
                    --source $depContainerName \
                    --destination $depFolder \
                    --output tsv

    if [ $apiportal == "true" ] ; then
    	log "Get APIPortal source storage"
        az storage blob download-batch --account-name $userBlobStorageName \
                    --source $productsContainerName \
                    --pattern APIPortal_$apimVersion* \
                    --destination $productsFolder \
                    --output tsv
        portalProductLocation=$(ls $productsFolder/APIPortal_$apimVersion*.tgz)
        if [[ $(echo $portalProductLocation | wc -l) -eq 1 ]]; then
            portalPackageName=$(basename $portalProductLocation)
            log "Portal package find. Use package $portalPackageName"
        else
            log "Installation aborted! Portal package not found."
            f_sendLog
            exit 1
        fi
    fi

    log "Define all permission on file and convert file in unix format"
    dos2unix $installFolder/Dockerfiles/emt-nodemanager/scripts/*
    dos2unix $installFolder/Dockerfiles/emt-gateway/scripts/*
    dos2unix $installFolder/Dockerfiles/emt-analytics/scripts/*
    chmod 755 $installFolder/Dockerfiles/emt-nodemanager/scripts/*
    chmod 755 $installFolder/Dockerfiles/emt-gateway/scripts/*
    chmod 755 $installFolder/Dockerfiles/emt-analytics/scripts/*

    #Search .fed in customer Folder
    if [ -e $dataFolder/*.fed ]; then
        log "fed file found in customer blob !"
        fedLocationGW="$(ls $dataFolder/*.fed)"
    else
        log "No customer fed. Use default fed by Axway"
        fedLocationGW="$(ls $installFolder/quickstart/defaultfed.fed)"
    fi

    #if [ -e $dataFolder/*.env ]; then
    #    log "env file found in customer blob !"
    #    envLocationGW="$(ls $userDestinationFile/envSettings.props)"
    #else
    #    log "No customer fed. Use default fed by Axway"
    #    envLocationGW="$(ls $installFolder/quickstart/envSettings.props)"
    #fi
}

function f_Setup_ACR ()
{
	local aksClientId=""
	local acrId=""
	local acrRole="acrpush"

	log "[INFO]  Start ACR configuration"
	# Set Acr by default & create role Assignment
    az acr login --name $containerRegistryName
	az configure --defaults acr=$containerRegistryName
	aksClientId=$(az aks show --resource-group $resourceGroupName --name $aksClusterName --query "servicePrincipalProfile.clientId" --output tsv)
	acrId=$(az acr show --name $containerRegistryName --resource-group $resourceGroupName --query "id" --output tsv)
	az role assignment create --assignee $aksClientId --role $acrRole --scope $acrId

	log "[INFO]  End ACR configuration"
}

function f_Setup_AFP ()
{
    local aksStorageFileShareSize="100"
    local aksConnectionString=""

    log "[INFO]  Start create share on Azure file and get shared key"
    #Get all credential to connect
    aksConnectionString=`az storage account show-connection-string -n $aksStorageFileAccountName -g $resourceGroupName -o tsv`
    _aksStorageFileSharedKey=$(az storage account keys list --resource-group $resourceGroupName --account-name $aksStorageFileAccountName --query "[0].value" -o tsv)

    #Create share for AKS Cluster with the same name - Quota mustn't be under 100G
    az storage share create -n $aksStorageFileShareEvents --connection-string $aksConnectionString --quota $aksStorageFileShareSize

    #Create share for APIportal
    if [ $apiportal == "true" ]; then
        az storage share create -n $aksStorageFilePortalContent --connection-string $aksConnectionString --quota $aksStorageFileShareSize
    fi

    log "[INFO]  End configuration of Azure file"
}

function f_Setup_Helm ()
{
	local serviceAccountName="tiller"
	local namespaceHelm="kube-system"
	local clusterRole="cluster-admin"
	local helmClientVersion=""
	local helmServerVersion=""
    local retryDelay=5

    kubectl create serviceaccount $serviceAccountName --namespace $namespaceHelm
	kubectl create clusterrolebinding $serviceAccountName \
			--clusterrole=$clusterRole \
			--serviceaccount=$namespaceHelm:$serviceAccountName

    helm init -c
    helm init --service-account $serviceAccountName --node-selectors "beta.kubernetes.io/os"="linux" --tiller-namespace $namespaceHelm
    helm repo update
    if [ -d /root/.helm/repository ]; then
        log "[INFO]  Helm client correctly configured for current user"
    else
        log "[ERROR] Helm client not configured. /root/.helm/repository does not exist."
        f_sendLog
        exit 1
    fi

	#Verify if Tiller is correctly deploy on AKS cluster : 
    sleep 10
	while [[ ! $(kubectl get pods --namespace $namespaceHelm | grep "$serviceAccountName" | grep "Running" || true ) ]]; do 
		log "[INFO]  Pod $serviceAccountName has not already deployed. Retry in ${retryDelay}s"  
		sleep $retryDelay
	done
    sleep 15
    log "[INFO]  Tiller should now be deployed on AKS cluster"

    #Verify helm version for both (client & server) after 30s :
    helmClientVersion=$(helm version --short | sed '1d;s/.*: //')
    helmServerVersion=$(helm version --short | sed '2d;s/.*: //')
    if [ "$helmClientVersion" = "$helmServerVersion" ]; then
        log "[INFO]  Installation complete. Helm $helmClientVersion is deployed on client and server"
    else
		log "[ERROR] Helm Client ($helmClientVersion) is different with Server($helmServerVersion)."
        f_sendLog
        exit 1
    fi
}

f_push_images () {
    local urlRepo=$1
    local imageName=$2

    if [[ -n "$(docker images -q $imageName)" ]]; then
        log "[INFO]  Image $imageName is available in local."
        docker tag $imageName $urlRepo/$imageName
        docker push $urlRepo/$imageName
    else
        log "[ERROR] Image $imageName not found in local registry."
        f_sendLog
	    exit 1
    fi
}

f_Manage_Dns () {
    log "[INFO]  Set record A and CNAME for component"
    az network dns record-set a add-record -g $dnsRGName -z $domainName -n $projectName.$environment -a $aksPublicIP
    az network dns record-set cname set-record -g $dnsRGName -z $domainName -n anm.$projectName.$environment -c $projectName.$environment.$domainName
    az network dns record-set cname set-record -g $dnsRGName -z $domainName -n api.$projectName.$environment -c $projectName.$environment.$domainName
    az network dns record-set cname set-record -g $dnsRGName -z $domainName -n api-manager.$projectName.$environment -c $projectName.$environment.$domainName
    if [ $apiportal == "true" ] ; then
        az network dns record-set cname set-record -g $dnsRGName -z $domainName -n api-portal.$projectName.$environment -c $projectName.$environment.$domainName
    fi
}

f_check_license () {
    local param=$1
    local value=$2

    if [ $param == "expires" ]; then
        log "[INFO]  Check date if Licenses is not expired"
        local expirationDate=$(sed -n -e "s/^.*${param}=//p" $licenseLocation)
        if [ $(date -d $expirationDate +%s) -ge $value ];then
            log "[INFO] License expiration date is good."
        else
            log "[ERROR] License is expired. Installation aborted !"
            f_sendLog
            exit 1
        fi
    elif [ $(sed -n -e "s/^.*${param}=//p" $licenseLocation) == $value ];then
        log "[INFO]  parameter $param match with $value"
    else
        log "[ERROR] Parameter $param is missing or different to $value in license file. Install aborted !"
        f_sendLog
        exit 1
    fi
}

function f_Setup_Ingress ()
{
    local retryDelay=5
    local kubeCertFile="certfile.yaml"
    local certManagerVersion="0.11"
    local namespaceCM="cert-manager"

    log "[INFO]  Deploy Helm Cert-manager package."
    kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-${certManagerVersion}/deploy/manifests/00-crds.yaml
    kubectl create namespace $namespaceCM
    kubectl label namespace $namespaceCM cert-manager.io/disable-validation=true
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install jetstack/cert-manager --namespace $namespaceCM \
            --name cert-manager \
            --version v${certManagerVersion}.0 \
            --set webhook.enabled=false

cat <<EOF > $kubeCertFile
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: "$apimNamespace"
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $adminEmail
    privateKeySecretRef:
      name: letsencrypt-prod
    http01: {}
EOF

    log "[INFO]  Deploy Helm Nginx Package."
    helm install stable/nginx-ingress --namespace $apimNamespace --set controller.replicaCount=2 \
            --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
            --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
            --set controller.service.externalTrafficPolicy=Local \
            --set controller.service.loadBalancerIP="$aksPublicIP" \
            --set-string controller.config.use-http2=false \
            --set-string controller.ssl_procotols=TLSv1.2 \
            --set rbac.create=true
    log "[INFO]  nginx ingress deployment complete with helm ! "

	while [[ $(kubectl get service -l app=nginx-ingress --namespace $apimNamespace | grep "pending") ]]; do 
		log "[INFO]  Public IP is pending in Ingress service. Check in ${retryDelay}s"  
		sleep $retryDelay
	done
}

function f_Setup_AKS () 
{
    local retryDelay=10
    local cmdSecretApim=""
    local cmdSecretAFP=""
    local ipAKSName="AKSIngressPublicIP"
    local aksPublicIPId=""
    aksSecretDockerName="azure-container-registry"
    aksSecretFileName="azure-file"
    aksSecretApp="apim-password"
    aksSecretDbRootName="dbmysqlroot"
    aksSecretDbPortalName="dbmysqlportal"
    aksSecretDbAnalyticsName="dbmysqlanalytics"

    log "[INFO]  Start configuration of AKS."
    az aks get-credentials --resource-group $resourceGroupName --name $aksClusterName
    export KUBECONFIG=/root/.kube/config
    kubectl cluster-info

    #Create namespace with projet-name
    kubectl create namespace $apimNamespace

    log "[INFO]  Configure secret in Kubernetes."
    #Grant the kube-system user with admin-permission
    kubectl create clusterrolebinding kubernetes-dashboard -n kube-system \
                    --clusterrole=cluster-admin \
                    --serviceaccount=kube-system:kubernetes-dashboard

    #Add secret for pull images from ACR
    kubectl create secret docker-registry $aksSecretDockerName \
                    --namespace ${apimNamespace} \
                    --docker-server $containerRegistryURL \
                    --docker-username $servicePrincipalName \
                    --docker-password $_servicePrincipalPwd

    #Add secret for connect to Azure Files Account
    kubectl create secret generic $aksSecretFileName \
                    --namespace ${apimNamespace} \
                    --from-literal=azurestorageaccountname=$aksStorageFileAccountName \
                    --from-literal=azurestorageaccountkey=$_aksStorageFileSharedKey

    #Add secret for connect for db user
    cmdSecretApim="kubectl create secret generic $aksSecretApp --namespace ${apimNamespace}"
    cmdSecretApim="$cmdSecretApim --from-literal=$aksSecretDbAnalyticsName=$_analyticsdbPass"
    cmdSecretApim="$cmdSecretApim --from-literal=$aksSecretDbRootName=$_rootdbPass"
    eval $cmdSecretApim

    log "[INFO]  Set Public IP for Ingress."
    rgAKSName=$(az aks show --resource-group $resourceGroupName --name $aksClusterName --query nodeResourceGroup -o tsv)
    aksPublicIP=$(az network public-ip create --resource-group $rgAKSName --sku Standard --name $ipAKSName --allocation-method static --query publicIp.ipAddress -o tsv --allocation-method static)
    log "[INFO]  Public static IP generated for AKS ingress : $aksPublicIP."
    log "[INFO]  End configuration of AKS."
}

function f_Manage_Certificate ()
{
	cd $installFolder
#Check if a certificate is in customer data
	if [ -e /home/axway/customerdata/*.csr ]; then
		log "[INFO]  Certificat found in customer data!"
		csrLocation="$(ls /home/axway/customerdata/*.csr)"
		python gen_domain_cert.py --domain-id=mydomain --pass-file=/tmp/pass.txt --out=csr --O=MyOrg
        #Partie à revoir et à tester ultérieurement
        certLocation=$(dirname $(ls certs/*/*cert.pem))
        certDomainKey="DefaultDomain-key.pem"
        certDomainPass="pass.txt"
	else
		log "[INFO]  No specific certificate found. Use Axway default file !"
		python gen_domain_cert.py --default-cert
        certLocation="certs/DefaultDomain"
        certDomainCert="DefaultDomain-cert.pem"
        certDomainKey="DefaultDomain-key.pem"
        certDomainPass="pass.txt"
        echo "changeme" > $certLocation/$certDomainPass
	fi
}

function f_Build_ImageBase ()
{
    ((stepNb++))
    logTitle="Step $stepNb: Build base image"
	local osType="centos7"
	baseImageName="apigw-base"
    baseImage=$baseImageName:$buildTag

    log "[INFO]  Start Creating base image"
	cd $installFolder
	python build_base_image.py --installer=$apimProductLocation \
		--os=$osType \
		--out-image $baseImage

    f_push_images $containerRegistryURL $baseImage
    log "Step $stepNb: Completed"
    f_sendLog
}

f_build_portal () {
	apiPortalImageName="api-portal"
    apiPortalImage=$apiPortalImageName:$buildTag
    ((stepNb++))
    logTitle="Step $stepNb: Deploy API Portal from container example"

    docker import $portalProductLocation $apiPortalImage
    f_push_images $containerRegistryURL $apiPortalImage

    log "Step $stepNb: Completed"
    f_sendLog
}

f_Build_anm () {
    ((stepNb++))
    logTitle="Step $stepNb: Build Admin Node Manager image"
    local fipsModeEnable=""
    local apimProductName="$(basename $installFolder/Packages/API*.run)"
    local mergeFolder="$installFolder/Dockerfiles/emt-nodemanager/apigateway"
    local mergeFolderDblib="$mergeFolder/ext/lib/"
    local dbPort=3306
    local anmUsername="admin"
    local _adminANMPass="changeme"
    local metricsDbPassFile="$installFolder/metricsdbpass.txt"
    local anmPassFile="$installFolder/anmdbpass.txt"
	anmImageName="apigw-anm"
    anmImage=$anmImageName:$buildTag

	cd $installFolder
	#Add jar JDBC driver in merge folder
    f_Create_Folder $mergeFolderDblib
    cp $dbLibLocation $mergeFolderDblib

    echo $_adminANMPass > $anmPassFile

    echo $_analyticsdbPass > $metricsDbPassFile
    log "[INFO]  Creation of Admin Node Manager image with metrics for analytics"
        python build_anm_image.py --out-image=$anmImage \
            --parent-image ${containerRegistryURL}/$baseImage \
            --domain-cert $certLocation/$certDomainCert \
            --domain-key $certLocation/$certDomainKey \
            --domain-key-pass-file $certLocation/$certDomainPass \
            --license $licenseLocation \
            --anm-username=$anmUsername \
            --anm-pass-file=$anmPassFile \
            --metrics \
            --metrics-db-url jdbc:mysql://mysql-aga:${dbPort}/$dbAnalyticsName \
            --metrics-db-username $dbAnalyticsUsername \
            --metrics-db-pass-file $metricsDbPassFile \
            --merge-dir $mergeFolder
        rm -f $metricsDbPassFile $anmPassFile

    f_push_images $containerRegistryURL $anmImage

    log "Step $stepNb: Completed"
    f_sendLog
}

f_build_gw () {
    ((stepNb++))
    logTitle="Step $stepNb: Build gateway image"
    local groupId="DefaultGroup"
    local mergeFolder="$installFolder/Dockerfiles/emt-gateway/apigateway"
    local mergeFolderDblib="$mergeFolder/ext/lib/"
    #local mergeFolderEnvlib="$mergeFolder/groups/emt-group/emt-service/conf"
	mgrImageName="apigw-mgr"
	mgrImage=$mgrImageName:$buildTag

    cd $installFolder
    #Add jar JDBC driver in merge folder
    f_Create_Folder $mergeFolderDblib
    #f_Create_Folder $mergeFolderEnvlib
    cp $dbLibLocation $mergeFolderDblib
    #cp $envLocationGW $mergeFolderEnvlib

    python build_gw_image.py --out-image=$mgrImage \
        --parent-image ${containerRegistryURL}/$baseImage \
        --domain-cert $certLocation/$certDomainCert \
        --domain-key $certLocation/$certDomainKey \
        --domain-key-pass-file $certLocation/$certDomainPass \
        --license $licenseLocation \
        --group-id $groupId \
        --merge-dir $mergeFolder \
        --fed $fedLocationGW
    f_push_images $containerRegistryURL $mgrImage

    log "Step $stepNb: Completed"
    f_sendLog
}

f_build_helm () {
    helmChartVersion=$(grep version $helmFolder/$helmPackageName/Chart.yaml | sed -n -e 's/^.*version: //p')
    helmPackageFullName="${helmPackageName}-${helmChartVersion}.tgz"
    helm package $helmFolder/$helmPackageName -d $helmFolder
    az acr helm push --name $containerRegistryName $helmFolder/$helmPackageFullName
    log "Push Helm $helmPackageFullName on regsitry $containerRegistryURL"
}

###############
# Main script #
###############
# Initialize parameters specified from command line
logTitle="Set context & init variables"
options=':hd-:'
stepNb=1
messConcat=""
# Set if customers files are presents
#todo : test file is present
anmFedLocation="no"

while getopts "$options" arg; do
        case "${arg}" in
                -  ) value="${OPTARG#*=}"
                     case "${OPTARG}" in
                        rg=?*   ) resourceGroupName=$value; log "resourceGroupName : $resourceGroupName" ;;
                        rg*     ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        av=?*   ) apimVersion=$value; log "apimVersion: $apimVersion" ;;
                        av*     ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        kn=?*   ) aksClusterName=$value; log "aksClusterName : $aksClusterName" ;;
                        kn*     ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        kv=?*   ) kubeVersion=$value; log "kubeVersion : $kubeVersion" ;;
                        kv*     ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        crn=?*  ) containerRegistryName=$value; log "containerRegistryName : $containerRegistryName" ;;
                        crn*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
#                        esk=?*  ) _axwayBlobSASToken=$value; log "_axwayBlobSASToken : $_axwayBlobSASToken" ;;
#                        esk*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        usn=?*  ) userBlobStorageName=$value; log "userBlobStorageName : $userBlobStorageName" ;;
                        usn*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        user=?*  ) adminUser=$value; log "user : $adminUser" ;;
                        user*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        spnn=?* ) servicePrincipalName=$value; log "servicePrincipalName : $servicePrincipalName" ;;
                        spnn*   ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        spni=?* ) servicePrincipalId=$value; log "servicePrincipalId : $servicePrincipalId" ;;
                        spni*   ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        spnp=?* ) _servicePrincipalPwd=$value; log "_servicePrincipalPwd : $_servicePrincipalPwd" ;;
                        spnp*   ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        tid=?*  ) _tenantID=$value; log "_tenantID : $_tenantID" ;;
                        tid*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        sfn=?*  ) aksStorageFileAccountName=$value; log "aksStorageFileAccountName : $aksStorageFileAccountName" ;;
                        sfn*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        dns=?*  ) domainName=$value; log "domainName : $domainName" ;;
                        dns*    ) log "No value. set domain name by default."; domainName="azure.demoaxway.com" ;;
                        zoneRGN=?*  ) dnsRGName=$value; log "RG DNS zone : $dnsRGName" ;;
                        zoneRGN*    ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                        env=?*   ) environment=$value; log "environment : $environment" ;;
                        env*     ) log "No value. set container by default."; environment="container" ;;
                        pn=?*   ) projectName=$value; log "projectName : $projectName" ;;
                        pn*     ) log "No value. set apim-demo by default."; projectName="apim" ;;
                        mail=?* ) adminEmail=$value; log "admin Email : $adminEmail" ;;
                        mail*   ) "No arg for --$OPTARG option" >&2; exit 2 ;;
                        mdm=?* ) manageDnsRecord=$value; log "manageDnsRecord : $manageDnsRecord" ;;
                        mdm*   ) log "No value. set manageDnsRecord by default."; manageDnsRecord="false" ;;
                        wbk=?*  ) logWebhookName=$value; log "webhook Url : $logWebhookName" ;;
                        wbk*    ) log "No value. set apim-demo by default."; logWebhookName="no" ;;
                        prt=?*  ) apiportal=$value; log "webhook Url : $apiportal" ;;
                        prt*    ) log "No value. set yes by default."; apiportal="true" ;;
                        help    ) usage ;;
                        debug   ) debug="yes" ;;
                        *       ) log "No arg for --$OPTARG option" >&2; exit 2 ;;
                     esac;;
                d  ) debug="yes" ;;
                h  ) usage ;;
        esac
done
if [ $# -lt 18 ]
then
    log "[ERROR] Arguments are missing. Only $# parameters defined"
    f_sendLog
    usage
fi
shift $((OPTIND-1))

if [ $# -ge 1 ]
then
    log "[ERROR] Too many arguments : $#"
    f_sendLog
    usage
fi

#Init global variables - Theses variable MUST be added in a pipeline
helmPackageName="amplify-apim-${apimVersion%%-*}"
helmDeployName="$projectName-$helmPackageName-$environment"

timestamp=$(date +%s)
aksStorageFileShareEvents="gw-events"
aksStorageFileShareLogs="apim-logs"
apimNamespace="$projectName-$environment"
apimVersionLt=${apimVersion%.*}
buildTag=$apimVersion.$timestamp
licenseType="docker"

dataContainerName="data"
depContainerName="dependencies"
productsContainerName="products"
helmContainerName="helmcharts"
installFolder="/opt/axway/amplify-apim-$apimVersion"
dataFolder="$installFolder/$dataContainerName"
productsFolder="$installFolder/$productsContainerName"
depFolder="$installFolder/$depContainerName"
helmFolder="$installFolder/$helmContainerName"
containerRegistryURL="$containerRegistryName.azurecr.io"

xrdpPath=/etc/xrdp
desktopPath=/tmp

#Issue with ampersand - variable is cut at the first ampersand
logWebhookName=$(echo "$logWebhookName"|tr '*' '&')
#_axwayBlobSASToken=$(echo "$_axwayBlobSASToken"|tr '*' '&')

#Generate Password for DB
_analyticsdbPass=$(gpg --gen-random --armor 1 12| tr '/' '*')
_rootdbPass=$(gpg --gen-random --armor 1 12| tr '/' '*')
dbAnalyticsUsername="report"
dbAnalyticsName="analytics"
dnsIngressTraffic="api.$projectName.$environment.$domainName"
dnsIngressManager="api-manager.$projectName.$environment.$domainName"
dnsIngressAnm="anm.$projectName.$environment.$domainName"

#Init apiportal variables
if [ $apiportal == "true" ];then
    aksStorageFilePortalContent="apiportal-contents"
    aksSecretDbPortalName="dbmysqlportal"
    dnsIngressPortal="api-portal.$projectName.$environment.$domainName"
    _portaldbPass=$(gpg --gen-random --armor 1 12 |tr '/' '*')
else
    dnsIngressPortal="none"
fi

log "[INFO]  Axway Product $apimVersion is going to be deployed"
log "[INFO]  The product will be deploy in namespace kubernetes $apimNamespace"
log "[INFO]  Ingress will use FQDN $projectName.$domainName"
f_sendLog


logTitle="Step $stepNb: Preparation of the host"
f_Install_AzureCli
f_Install_Docker
f_Install_KubeClient
f_Install_Helm
f_Azure_Login
log "Step $stepNb: Completed"
f_sendLog

((stepNb++))
logTitle="Step $stepNb: Download sources from BlobStorage"
f_Get_Sources
log "Step $stepNb: Completed"
f_sendLog

((stepNb++))
logTitle="Step $stepNb: Setup components"
f_Setup_ACR
f_Setup_AFP
f_Setup_AKS
if [ $manageDnsRecord == "true" ];then
    f_Manage_Dns
fi
f_Setup_Helm
f_Setup_Ingress
log "Step $stepNb: Completed"
f_sendLog

f_Manage_Certificate
f_Build_ImageBase
f_Build_anm
f_build_gw
if [ $apiportal == "true" ];then
    f_build_portal
fi
f_build_helm

((stepNb++))
logTitle="Step $stepNb: Deploy Packages HELM"
az acr helm repo add --name $containerRegistryName
helm repo update
helm install $containerRegistryName/$helmPackageName --name $helmDeployName --namespace $apimNamespace
            --set global.namespace=$apimNamespace
            --set global.apimVersion=$apimVersion
            --set global.apimName=$containerRegistryURL
            --set global.apimSecret=$aksSecretDockerName
            --set anm.buildtag=$buildTag
            --set anm.ingressName=$dnsIngressAnm
            --set apimgr.buildtag=$buildTag
            --set apimgr.ingressName=$dnsIngressManager
            --set apitraffic.buildTag=$buildTag
            --set apitraffic.ingressName=$dnsIngressTraffic
            --set apitraffic.share.secret=$aksSecretFileName
            --set apitraffic.share.name=$aksStorageFileShareEvents
            --set cassandra.keyspace=${projectName}_${environment}_1
            --set apiportal.ingressName=$dnsIngressPortal \
            --set apiportal.share.secret=$aksSecretFileName \
            --set apiportal.share.name=$aksStorageFilePortalContent \
            --set apiportal.enabled=$apiportal
log "Step $stepNb: End Packages HELM deployement"
f_sendLog

((stepNb++))
logTitle="Step $stepNb: Configure Bastion"
f_Build_Bastion
log "Step $stepNb: End Bastion configuration"
f_sendLog

((stepNb++))
logTitle="Step $stepNb: Post installation"
log "[INFO]  API MGR $apimVersion Installation complete. Here below all informations."
log "[INFO]  Sensitives data like Mysql root Password, certificates, Azure File premium account are stored inside Kubernetes secret. You can consult their values from Kubernetes Dashboard."
log "[INFO]  API Traffic : $dnsIngressTraffic " 
log "[INFO]  API Gateway Manager : $dnsIngressAnm with user admin and password changeme"
log "[INFO]  API Manager : $dnsIngressManager with user apiadmin and password changeme"
log "Step $stepNb: Install Completed."
f_sendLog