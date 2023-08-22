#az login --scope https://graph.microsoft.com//.default --tenant "f1172fb4-61aa-4343-b8ba-61a5535abdaf"
Param (
    [string] $SubscriptionId, #Defaults to the subscription of the user logged in
    [string] $ResourceGroupName, #Defaults to rg-<projectName>-<environment>-<location>-<index>
    [string] $ProjectName = "genie",  
    [string] $Environment = "dev",    
    [string] $Index = "001",
    [string] $Location,
    [bool]  $WhitelistClient = $false,
    [string] $PrincipalId, #Defaults to the Principal ID of the user logged in
    [string] $ImageReferenceId, #Defaults to whatever found on the configuration files.  If none, found, an image will be created
    [string] $GalleryResourceGroupName, #Defaults to rg-<projectName>-<environment>-<location>-<index>
    [string] $GalleryProjectName = "core",
    [string] $Domain
)

$ErrorActionPreference = 'Stop'

.\run-main.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ProjectName $ProjectName -Environment $Environment -Index $Index -Location $Location -WhitelistClient $WhitelistClient -PrincipalId $PrincipalId -ImageReferenceId $ImageReferenceId -GalleryResourceGroupName $GalleryResourceGroupName -GalleryProjectName $GalleryProjectName -Domain $Domain
