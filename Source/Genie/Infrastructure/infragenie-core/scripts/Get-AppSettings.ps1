param (
    [string] $Domain,
    [string] $Environment = 'sbx',
    [string] $ProjectName
)

if ($domain -eq "") {
    $user = $(az ad signed-in-user show) | ConvertFrom-Json
    $principalName = $user.userPrincipalName
    $Domain = $principalName.Substring($principalName.IndexOf("@") + 1).ToLower().Trim()
    Write-Host "Defaulting to logged in user's domain: $Domain"
}

[PSCustomObject] $settings = {}
$root = $(git rev-parse --show-toplevel)


if ($ProjectName -ne "") {
    Write-Host "Looking for Project '$ProjectName' specific settings file"

    $settingsFile = "$root\Source\Golden\.tags\$Domain\appSettings-$ProjectName-$Environment.json"

    Write-Host "Looking for $settingsFile"

    if ( $(Test-Path -Path $settingsFile) -eq $false ) {
        Write-Host "$settingsFile not found!" -ForegroundColor Red
    }
    else {
        $settings = $(Get-Content -Path $settingsFile | ConvertFrom-Json)
        return $settings
    }
}
else {
    Write-Host "ProjectName not specified, skipping project specific settings file"
}

$settingsFile = "$root\Source\Golden\.tags\$Domain\appSettings-$Environment.json"

Write-Host "Looking for $settingsFile"

if ( $(Test-Path -Path $settingsFile) -eq $false ) {
    Write-Host "$settingsFile not found!" -ForegroundColor Red
    return $settings
}

$settings = $(Get-Content -Path $settingsFile | ConvertFrom-Json)

return $settings