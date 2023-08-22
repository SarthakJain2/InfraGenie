
#az login --scope https://graph.microsoft.com//.default --tenant "f1172fb4-61aa-4343-b8ba-61a5535abdaf"
Param (
    [string] $SubscriptionId, #Defaults to the subscription of the user logged in
    # Defaults to rg-<projectName>-<environment>-<location>-<index>.
    # If provided, it will be used as the Resource Group name.  However, the resources inside will follow 
    # the naming convention <resourceType>-<projectName>-<environment>-<index>
    [string] $ResourceGroupName, 
    [string] $ProjectName,
    [string] $Environment,    
    [string] $Index,
    [string] $Location,
    [bool]  $WhitelistClient = $false,
    [string] $PrincipalId, #Defaults to the Principal ID of the user logged in
    [string] $ImageReferenceId, #Defaults to whatever found on the configuration files.  If none, found, an image will be created
    [string] $GalleryResourceGroupName, #Defaults to rg-<projectName>-<environment>-<location>-<index>
    [string] $GalleryProjectName = "core",
    [string] $Domain
)

$ErrorActionPreference = 'Stop'
$userType = $(az account show | ConvertFrom-Json).user.type

if ($userType -eq "user") {
    $user = $(az ad signed-in-user show) | ConvertFrom-Json
    $principalName = $user.userPrincipalName
    $Domain = $principalName.Substring($principalName.IndexOf("@") + 1).ToLower().Trim()
}
elseif ($userType -eq "servicePrincipal") {
    if ($Domain -eq "") {
        Write-Host "Domain must be supplied when running as a service principal" -ForegroundColor Red
        return
    }

    $user = $(az account show | ConvertFrom-Json)
    $principalName = $(az ad sp show --id $user.user.name | ConvertFrom-Json).appDisplayName
}

#Make sure the Principal ID is of the person that's signed in when run manually
if ( $PrincipalId -eq "" ) {
    Write-Host "PrincipalId not supplied... Getting the same from the logged in user" -ForegroundColor DarkYellow
    $PrincipalId = $user.Id
}

Write-Host "Logged in User Principal: $principalName"
Write-Host "Domain of the logged in user: $Domain"
Write-Host "PrincipalId: $PrincipalId"

$settings = .\scripts\Get-AppSettings.ps1 -Domain $Domain -Environment $Environment -ProjectName $ProjectName

if ($Location -eq "") {
    $Location = $settings.Location

    if ($Location -eq "") {
        Write-Error "Location must be supplied and when not provided in appSettings-$Environment.json"
        return
    }

    Write-Host "Defaulting to Location '$Location' from appSettings-$Environment.json"
}

if ( $SubscriptionId -eq "") {
    Write-Host "Subscription Id not supplied... Getting the same from appSettings-$Environment.json"
    [string] $subscriptionName = .\scripts\Get-SubscriptionName.ps1 -Domain $Domain -Environment $Environment -ProjectName $ProjectName

    if ($subscriptionName -eq "") {
        return
    }

    Write-Host "Defaulting to subscription '$subscriptionName'"
    az account set -s "$subscriptionName"
    $SubscriptionId = $(az account show --query id --output tsv)
}
else {
    $query = "[?id == " + "'" + $SubscriptionId + "'] | [0].name"
    $subscriptionName = $(az account list --query "$query" --output tsv)
    Write-Host "Defaulting to subscription '$subscriptionName'"
    az account set -s "$SubscriptionId"
}

if ($ResourceGroupName -eq "") {
    $ResourceGroupName = "rg-$ProjectName-$Environment-$Location-$Index"
    Write-Host "Defaulting to Resource Group '$ResourceGroupName'"
}

if ( $(az group exists -g $ResourceGroupName) -eq 'false' ) {
    Write-Host "Creating Resource Group $ResourceGroupName"
    az group create --name $ResourceGroupName --location $Location
}
else {
    Write-Warning "Resource Group $ResourceGroupName already exists"
}

if ($GalleryResourceGroupName -eq "") {
    $GalleryResourceGroupName = $ResourceGroupName
    Write-Host "Defaulting to Gallery Resource Group '$GalleryResourceGroupName'"
}

if ( $(az group exists -g $GalleryResourceGroupName) -eq 'false' ) {
    Write-Host "Creating Resource Group $GalleryResourceGroupName"
    az group create --name $GalleryResourceGroupName --location $Location
}
else {
    Write-Warning "Resource Group $GalleryResourceGroupName already exists"
}


#Whitelist local IPAddress
$ips = ($WhitelistClient) ? "['" + (Invoke-RestMethod ifconfig.me/ip).Trim() + "']" : '[]'

[PSCustomObject] $paramTags = (.\scripts\Merge-Parameters.ps1 -ParametersFile .\main.parameters.json  -Domain $Domain -ProjectName $ProjectName -Environment $Environment)

if ($ImageReferenceId -eq "") {
    Write-Host "Image Reference Id override not supplied...defaulting to value from parameter file"
    if ( $paramTags.parameters.imageReferenceId.value -eq "") {       
        Write-Host "Image Reference Id is empty in parameter file.. Attempting to create image"
        Push-Location
        Set-Location .\vm-scaleset-image
        .\run.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $GalleryResourceGroupName -ProjectName $GalleryProjectName -Environment $Environment -Index $Index -Location $Location
        Pop-Location

        if ($LastExitCode -ne 0) {
            Write-Host "Error Creating Image!" -ForegroundColor Red
            return
        }

        $ImageReferenceId = "$(az deployment group list -g $GalleryResourceGroupName --query "[?name == 'imagegallery'].properties.outputs.imageVersionId.value" --output tsv)"
    }
    else {
        Write-Host "Image Reference Id from parameter file being used: $ImageReferenceId"
        $ImageReferenceId = $paramTags.parameters.imageReferenceId.value
    }
}
else {
    Write-Host "Image Reference Id override being used: $ImageReferenceId"
}

$json = ($paramTags | ConvertTo-Json -Depth 5)
Write-Host "Running main with: "
Write-Host "PrincipalId: $PrincipalId"
Write-Host "ImageRefefenceId: $ImageReferenceId"
Write-Host "Whitelisted IPs: $ips"
Write-Host "Parameters: "
Write-Host $json
Write-Host "---------------------------------------"

$deploymentName = "main-$(Get-Date -f "yyyyMMddhhmmss")"
Set-Content -Path .\dynamic-params.json -Value $json -Force
#az deployment group create -g $ResourceGroupName -f ./main.bicep -p ./main.parameters.json location="$Location" principalId="$principalId" imageReferenceId="$imageReferenceId" coreTags = "$($paramTags.parameters.coreTags.value)"
az deployment group create --name $deploymentName -g $ResourceGroupName -f ./main.bicep -p dynamic-params.json env=$Environment location="$Location" projectName=$ProjectName principalId="$principalId" imageReferenceId="$imageReferenceId" whitelistedIPs=$ips indexOverride=$Index  --query "properties.outputs" --output tsv

Write-Host "------------------"

if ($LastExitCode -eq 0) {
    Write-Host "Deployment Successful!" -ForegroundColor Green
    Remove-Item .\dynamic-params.json

    Write-Host "Checking if the deployment had post deployment keyvault secrets"
    $vaults = $(az resource list -g $ResourceGroupName --query "[?type == 'Microsoft.KeyVault/vaults']")

    if ($vaults.length -ge 1) {
        Write-Host "Vault(s) found!"  -ForegroundColor DarkCyan
        $vaults | ForEach-Object { 
            Write-Host "Getting secrets from $($_.name) ----------------"
            az keyvault secret list --vault-name $_.name --query "[].name" --output tsv | ForEach-Object { 
                az keyvault secret show --vault-name $_.name -n $_ --query "{name: name, value: value}" 
            }  
            Write-Host "---------------------------------------"  -ForegroundColor DarkCyan
        }
    }
    else {
        Write-Host "No Vault(s) found!"
    }

    if (Test-Path -Path ".\post-deploy.ps1") {
        Write-Host "Running post-deploy.ps1"
        .\post-deploy.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ProjectName $ProjectName -Environment $Environment -Index $Index -Location $Location -DeploymentName $deploymentName
    }
    else {
        Write-Host "No post-deploy.ps1 found"
    }

    if (Test-Path -Path ".\post-deploy-tests.ps1") {
        Write-Host "Running post-deploy.ps1"
        .\post-deploy-tests.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ProjectName $ProjectName -Environment $Environment -Index $Index -Location $Location -DeploymentName $deploymentName
    }
    else {
        Write-Host "No post-deploy.sh found"
    }
}
else {
    Write-Host "Deployment Failed!" -ForegroundColor Red
}
