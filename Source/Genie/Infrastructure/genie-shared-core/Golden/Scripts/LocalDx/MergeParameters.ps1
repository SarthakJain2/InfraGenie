Param (
    [string] $Domain = 'rhipheus.com',
    [string] $ProjectName,
    [string] $Environment = 'sbx',
    [string] $ParameterFile = './main.parameters.json'
)

$domainParamFile = "./Golden/.tags/$Domain/$Domain.json"
Write-Host "Looking for file $domainParamFile"
if (Test-Path -Path $domainParamFile) {
    Write-Host "Found file $domainParamFile"

    [PSCustomObject] $tags = Get-Content $domainParamFile | ConvertFrom-Json
    [PSCustomObject] $paramTags = Get-Content $ParameterFile | ConvertFrom-Json
    foreach ($tag in $tags.coreTags.PSObject.Properties) {
        $props = $paramTags.parameters.coreTags.value.PSObject.Properties
        if ( $props.Name -contains $tag.Name) {
            Write-Host "updating $($tag.Name) with $($tag.Value)"
            $props[$tag.Name].Value = $tag.Value
        }
        else {
            Write-Host "Adding a new tag $($tag.Name) with $($tag.Value)"
            $paramTags.parameters.coreTags.value | Add-Member -Name $tag.Name -Value $tag.Value -MemberType NoteProperty
        }
    }
}
else {
    Write-Warning "File $domainParamFile not found... Skipping ahead to project specific parameters"
}

$projectParamFile = "./Golden/.tags/$domain/$domain-$ProjectName-$Environment.json"
Write-Host "Looking for file $projectParamFile"

if (Test-Path -Path $projectParamFile) {
    Write-Host "Found file $projectParamFile"

    [PSCustomObject] $tags = Get-Content $projectParamFile | ConvertFrom-Json
    foreach ($tag in $tags.PSObject.Properties) {
        $props = $paramTags.parameters.PSObject.Properties
        if ( $props.Name -contains $tag.Name) {
            $props[$tag.Name].value.Value = $tag.Value
        }
        else {
            $paramTags.parameters.value | Add-Member -Name $tag.Name -Value $tag.Value -MemberType NoteProperty
        }
    }
}
else {
    Write-Warning "File $projectParamFile not found"
}
return $paramTags
