#region init
Set-StrictMode -Version Latest

Clear-Host
$d = get-date

Write-Host "Starting Deployment $d"

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "scriptFolder" $scriptFolder

set-location $scriptFolder

. ".\GetAppConfig.ps1"

#endregion get configuration


#region internal script variables

$templateFile = "..\azuredeploy.json"
$jsonNestedFiles = "..\nestedtemplates"
$resourceGroupName = "RG-$globalPrefix-$projectName"
$resourceGroupDeploymentName = "$resourceGroupName-Deployed"

$applicationHomepage = $servicePrincipalName
$scriptsContainerName = "armtemplates"
$artifactsStorageAccountName = $sourceBlobStorageName
$artifactsResourceGroupName = $resourceGroupName

#resource group parameter names
$projectParameterName = "projectName"
$domainNameParameterName = "domainName"
$dnsRGNameParamaterName = "dnsRGName"

$servicePrincipalParameterName = "servicePrincipalName"

$AKSClientIDParameterName = "_servicePrincipalID"
$AKSClientSecretParameterName = "_servicePrincipalSecret"
$tenantIDParameterName = "_tenantID"

$sourceBlobStorageNameParameterName = "sourceBlobStorageName"

$webhookUrlParameterName = "webhookUrl"
$emailParameterName = "email"
$adminPasswordParameterName = "_adminPassword"

$apimVersionParameterName = "apimVersion"
$manageDNSParameterName = "manageDNS"
$environmentParameterName = "environment"

$artifactsResourceGroupDeploymentName = "$artifactsResourceGroupName-Deployed"

#endregion internal script variables

#Login-AzAccount
#Select-AzSubscription -SubscriptionId $subscriptionId

Get-AzResourceGroup -Name $artifactsResourceGroupName -ev notPresent -ea 0

if ($notPresent)
{
    New-AzResourceGroup `
	-Name $artifactsResourceGroupName `
	-Location $resourceLocation `
    -Tag @{Name=$resourceTagName;Value=$resourceTagValue} `
    -Verbose
}


#Artefacts Storage Account creation for Scripts - Linked templates repository
$storageObject = Get-AzResource -ResourceType "Microsoft.Storage/storageAccounts" | `
                 Where-Object {$_.Name -eq $artifactsStorageAccountName}        

if  ( !$storageObject ) {
    $storageLocation = (Get-AzResourceGroup -ResourceGroupName $artifactsResourceGroupName).Location
    $result = New-AzStorageAccount -ResourceGroupName $artifactsResourceGroupName -Location $storageLocation `
                                        -Name $artifactsStorageAccountName -SkuName Standard_LRS
    If ($result.ProvisioningState -eq "Succeeded") {
        $result | Out-String "Created new Storage Account '$artifactsStorageAccountName', in '$storageLocation'"
      
        $artifactsStorageAccountKey = Get-AzStorageAccountKey -resourcegroupname $artifactsResourceGroupName -name $artifactsStorageAccountName
        $artifactsStorageAccountContext = New-AzStorageContext -storageaccountname $artifactsStorageAccountName -storageaccountkey $artifactsStorageAccountKey[0].Value
        }
    else {
        "Failed to create new Storage Account '$artifactsStorageAccountName'"
    }
}
else
{
    $artifactsStorageAccountKey = Get-AzStorageAccountKey -resourcegroupname $artifactsResourceGroupName -name $artifactsStorageAccountName
    $artifactsStorageAccountContext = New-AzStorageContext -storageaccountname $artifactsStorageAccountName -storageaccountkey $artifactsStorageAccountKey[0].Value
}

$ScriptsStorageAccountContainer = (Get-AzStorageContainer -Context $artifactsStorageAccountContext | Where-Object{$_.Name -eq $scriptsContainerName})

if ($ScriptsStorageAccountContainer -eq $null) {
    New-AzStorageContainer -Name $scriptsContainerName -Context $artifactsStorageAccountContext -Permission Off `
            -ConcurrentTaskCount 8 -ServerTimeoutPerRequest 10 -ClientTimeoutPerRequest 10
    "Created new Storage Container '$ScriptsStorageAccountContainer'"
}

#Copy main json in blob storage /
#Set-AzStorageBlobContent -File $templateFile -Container $scriptsContainerName -Blob $templateFile -Context $artifactsStorageAccountContext -Force

#Copy of all bash scripts in blob storage scripts
#$files = Get-ChildItem $scriptFolder | where {($_.Extension -eq '.sh')}
#foreach($file in $files)
#{
#    $fileName = $file
#    $blobName = "customer/scripts/$file"
#    write-host "copying $fileName to $blobName"
#    Set-AzStorageBlobContent -File $filename -Container $scriptsContainerName -Blob $blobName -Context $artifactsStorageAccountContext -Force
#} 
#Copy of all arm templates in blob storage nestedTemplate
#$files = Get-ChildItem $jsonNestedFiles | where {($_.Extension -eq '.json')}
#foreach($file in $files)
#{
#    $fileName = $file
#    $blobName = "armtemplates/nestedtemplates/$file"
#    write-host "copying $fileName to $blobName"
#    Set-AzStorageBlobContent -File "$jsonNestedFiles\$filename" -Container $scriptsContainerName -Blob $blobName -Context $artifactsStorageAccountContext -Force
#}

# AKS Platform Deployment
Get-AzResourceGroup -Name $resourceGroupName -ev errorVariable -ea 0

#If Resource group does not exist $errorVariable will contain the message "Provided resource group does not exist"

if ($errorVariable)
{
    New-AzResourceGroup `
	-Name $resourceGroupName `
	-Location $resourceLocation `
    -Tag @{Name=$resourceTagName;Value=$resourceTagValue} `
    -Verbose
}

$registeredApp = Get-AzADApplication -IdentifierUri $servicePrincipalName

if (!$registeredApp )
{
    $azureAdApplication = New-AzADApplication -DisplayName $applicationDisplayName `
         -HomePage $applicationHomepage -IdentifierUris $servicePrincipalName #-Password $password

    $_AKSClientID = $azureAdApplication.ApplicationId.Guid 
    $sp = New-AzADServicePrincipal -ApplicationId  $azureAdApplication.ApplicationId
    $_tenantID = (Get-AzContext).Tenant.Id

    $_AKSClientSecret = (New-Object PSCredential $sp.ID,$sp.Secret).GetNetworkCredential().Password

    Start-Sleep -s 50

    Write-Host "ServicePrincipal should be there now (hopefully)"
    
    $stopLoopv = $false
    Do {
        $spGet = Get-AzADApplication -ApplicationId $azureAdApplication.ApplicationId | Get-AzADServicePrincipal
        if ($spGet) {
            if ($spGet.Id -ne "") {   
                Write-Host "ServicePrincipal" $spGet.Id "seems to be there now"
                $stopLoop = $true
                }
            }
        if (!$stopLoop) {Start-Sleep -s 5}
    }
    until ($stopLoop)

    Start-Sleep -s 50

    New-AzRoleAssignment -RoleDefinitionName 'Owner' `
        -ServicePrincipalName $servicePrincipalName -ResourceGroupName $resourceGroupName

    Write-Host "Role assignment should be effective now (hopefully)"
        
    $stopLoop = $false
    Do {
        $role = Get-AzRoleAssignment -ServicePrincipalName $servicePrincipalName -ResourceGroupName $resourceGroupName
        if ($role) {
            Write-Host "Role" $Role.RoleDefinitionName "shoud be assigned now"
            $stopLoop = $true
            }
        else {
            Start-Sleep -s 5
            }
        }
    until ($stopLoop)
 
    Write-Host "ServicePrincipal has been created on main resourceGroup and assigned following role:" $role.RoleDefinitionName

    Start-Sleep -s 20

    New-AzRoleAssignment -RoleDefinitionName 'Owner' `
    -ServicePrincipalName $servicePrincipalName -ResourceGroupName $artifactsResourceGroupName

    Write-Host "Role assignment should be effective now (hopefully)"
        
    $stopLoop = $false
    Do {
        $role = Get-AzRoleAssignment -ServicePrincipalName $servicePrincipalName -ResourceGroupName $artifactsResourceGroupName
        if ($role) {
            Write-Host "Role" $Role.RoleDefinitionName "shoud be assigned now"
            $stopLoop = $true
            }
        else {
            Start-Sleep -s 5
            }
        }
    until ($stopLoop)
 
    Write-Host "ServicePrincipal has been created on artifactsResourceGroupName and assigned following role:" $role.RoleDefinitionName

}
else
{
    Write-Host "Nothing to do"

}


$mandatoryParameters = New-Object -TypeName Hashtable

if ($mandatoryParameters[$projectParameterName] -eq $null) {
    $mandatoryParameters[$projectParameterName] = $projectName.ToLower()
}

if ($mandatoryParameters[$servicePrincipalParameterName] -eq $null) {
    $mandatoryParameters[$servicePrincipalParameterName] = $servicePrincipalName
}

if ($mandatoryParameters[$AKSClientIDParameterName] -eq $null) {
    $mandatoryParameters[$AKSClientIDParameterName] = ConvertTo-SecureString -AsPlainText -Force ($_AKSClientID)
}

if ($mandatoryParameters[$domainNameParameterName] -eq $null) {
    $mandatoryParameters[$domainNameParameterName] = $domainName
}

if ($mandatoryParameters[$AKSClientSecretParameterName] -eq $null) {
    $mandatoryParameters[$AKSClientSecretParameterName] = ConvertTo-SecureString -AsPlainText -Force ($_AKSClientSecret)
}

if ($mandatoryParameters[$tenantIDParameterName] -eq $null) {
    $mandatoryParameters[$tenantIDParameterName] = ConvertTo-SecureString -AsPlainText -Force ($_tenantID)
}

if ($mandatoryParameters[$apimVersionParameterName] -eq $null) {
    $mandatoryParameters[$apimVersionParameterName] = $apimVersion
}

if ($mandatoryParameters[$emailParameterName] -eq $null) {
    $mandatoryParameters[$emailParameterName] = $email
}

if ($mandatoryParameters[$adminPasswordParameterName] -eq $null) {
    $mandatoryParameters[$adminPasswordParameterName] = ConvertTo-SecureString -AsPlainText -Force ($_adminPassword)
}

if ($mandatoryParameters[$webhookUrlParameterName] -eq $null) {
    $mandatoryParameters[$webhookUrlParameterName] = $webhookUrl
}

if ($mandatoryParameters[$sourceBlobStorageNameParameterName] -eq $null) {
    $mandatoryParameters[$sourceBlobStorageNameParameterName] = $sourceBlobStorageName
}

if ($mandatoryParameters[$manageDNSParameterName] -eq $null) {
    $mandatoryParameters[$manageDNSParameterName] = $manageDNS
}

if ($mandatoryParameters[$environmentParameterName] -eq $null) {
    $mandatoryParameters[$environmentParameterName] = $environment
}

if ($mandatoryParameters[$dnsRGNameParamaterName] -eq $null) {
    $mandatoryParameters[$dnsRGNameParamaterName] = $dnsRGName
}

# Resource group deploy
New-AzResourceGroupDeployment `
    -Name $resourceGroupDeploymentName `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile "$templateFile" `
    @mandatoryParameters `
    -Debug -Verbose -DeploymentDebugLogLevel All

$d = get-date
Write-Host "Stopping Deployment $d"