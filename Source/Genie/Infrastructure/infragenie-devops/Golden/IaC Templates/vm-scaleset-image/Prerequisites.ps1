#You may have to run the below if you get an error about MFA being expired
#az login --scope https://graph.microsofct.com//.default
#.\Prerequisites.ps1 -SubscriptionName "Primary Sandbox" -ResourceGroupName "vyas.bharghava.testing"

Param (
    [string] $SubscriptionName = "",
    [string] $SubscriptionId = "",
    [string] $ResourceGroupName = "",
    [string] $ServiceAccountName = "SandboxSentinel"
)

if ($SubscriptionName -eq "" -and $SubscriptionId -eq "") {
    $SubscriptionId = $(az account show --query id --output tsv)
}
elseif ($SubscriptionName -ne "") {
    $SubscriptionId = $(az account show -s $SubscriptionName --query id --output tsv)
}


[string] $scope = "/subscriptions/$SubscriptionId" + (($ResourceGroupName -ne "")? "/resourceGroups/$ResourceGroupName": "")

Write-Host "az ad sp create-for-rbac --name ""$ServiceAccountName"" --role 'Owner' --scopes ""$scope"""
[PSCustomObject] $json = $(az ad sp create-for-rbac --name "$ServiceAccountName" --role "Owner" --scopes "$scope" --query "{ ClientId: appId, ClientSecret: password }" --output json | ConvertFrom-Json)

return $json