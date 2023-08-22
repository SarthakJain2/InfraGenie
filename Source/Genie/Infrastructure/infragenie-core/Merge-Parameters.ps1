# Defaults could change based on what domain the dev was last debugging the scripts for
# This script is used to merge the parameters from the main.parameters.json file with the customter, project, and environment specific tags from the json files in the .tags folder
# The tags are merged in the following order:
#   1. Domain tags
#   2. Domain and Environment tags
#   3. Domain, amd Project tags
#   4. Domain, Project, and Environment tags
# The tags are merged in the order above so that the most specific tags are applied last and override the more generic tags
Param (
    [string] $Domain = 'ogdevops.onmicrosoft.com',
    [string] $ProjectName,
    [string] $Environment = 'sbx',
    [string] $ParameterFile = './main.parameters.json'
)

$ErrorActionPreference = 'Stop'

function recurseTags {
    param (
        [PSCustomObject] $pTags,
        [PSCustomObject] $mTags
    )


    Write-Host "Looking to add / update tags of $($pTags.PSObject.Properties.Name)"

    foreach ($mTag in $mTags.PSObject.Properties) {

        Write-Host "Processing tag $($mTag.Name)"
        $props = $pTags.PSObject.Properties

        if ($mTag.Value -is [PSCustomObject]) {
            Write-Host "Tag $($mTag.Name) is an object.  Recursing..."
            $props[$mTag.Name].value = recurseTags -pTags $props[$mTag.Name].value -mTags $mTag.Value
        }
        else {

            if ( $props.Value -is [PSCustomObject]) {
                $props = $props.Value.PSObject.Properties

                if ( $props.Name -contains $mTag.Name) {
                    Write-Host "updating $($mTag.Name) with $($mTag.Value)"
                    $props[$mTag.Name].Value = $mTag.Value            
                }
                else {
                    Write-Host "Adding a new tag $($mTag.Name) with $($mTag.Value)"
                    $pTags.value | Add-Member -Name $mTag.Name -Value $mTag.Value -MemberType NoteProperty
                }
                
            }
            else {

                if ( $props.Name -contains $mTag.Name) {
                    Write-Host "updating $($mTag.Name) with $($mTag.Value)"
                    $props[$mTag.Name].Value.value = $mTag.Value            
                }
                else {
                    Write-Host "Adding a new tag $($mTag.Name) with $($mTag.Value)"
                    $value = [PSCustomObject] @{
                        value = $mTag.Value
                    }
                    $pTags | Add-Member -Name $mTag.Name -Value $value -MemberType NoteProperty
                }

            }

            
        }
    }
    return $pTags
}

[PSCustomObject] $paramTags = Get-Content $ParameterFile | ConvertFrom-Json
$files = @("../.tags/$Domain/$Domain.json", "../.tags/$Domain/$Domain-$Environment.json")
if( $ProjectName -ne '') {
    $files += @("../.tags/$Domain/$Domain-$ProjectName.json", "../.tags/$Domain/$Domain-$ProjectName-$Environment.json")
}

foreach ($file in $files) {
    Write-Host "Looking for file $file"

    if (Test-Path -Path $file) {
        Write-Host "Found file $file"
        [PSCustomObject] $tags = Get-Content $file | ConvertFrom-Json
        $paramTags.parameters = recurseTags -pTags $paramTags.parameters -mTags $tags
    }
    else {
        Write-Warning "File $file not found.  Skipping..."
    }
}

# Always automatically override created-by with the logged in user
$user = $(az ad signed-in-user show --query "{displayName: displayName, userPrincipalName: userPrincipalName}") | ConvertFrom-Json
[PSCustomObject] $tags = @{ "coreTags" = @{ "created-by" = "$($user.displayName) <$($user.userPrincipalName)>" } } | ConvertTo-Json | ConvertFrom-Json
$paramTags.parameters = recurseTags -pTags $paramTags.parameters -mTags $tags

return $paramTags
