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
    [string] $DeploymentName
)

[PSCustomObject] $paramTags = (.\Golden\Scripts\LocalDx\Merge-Parameters.ps1 -ParametersFile .\main.parameters.json  -Domain $domain -ProjectName $ProjectName -Environment $Environment)

#Create a group in the directory
#az ad group create --display-name $ProjectName-security-group --mail-nickname $ProjectName-security-group
#$groupId = az ad group show --group $ProjectName-security-group --query id --output tsv

Write-Host "Processing access rights!"
foreach ($assignee in $paramTags.parameters.assignees) {
    Write-Host "For: $assignee.adUsername"
    foreach ($role in $assignee.roles) {
        Write-Host "Assigning '$role' access"
        az synapse role assignment create --workspace-name syn-synapoc-sbx-001 --role $assignee.role --assignee $assignee.adUsername
    }
}
