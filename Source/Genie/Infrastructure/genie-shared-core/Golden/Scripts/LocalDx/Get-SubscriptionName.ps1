param (
    [string] $Domain,
    [string] $Environment = 'sbx',
    [string] $ProjectName
)

# [PSCustomObject] $settings = ..\LocalDx\Get-AppSettings.ps1 -Domain $Domain -Environment $Environment -ProjectName $ProjectName

[string] $subscriptionName = ""
# Check if logged in user has access to any Azure subscription
[Array] $subscriptionNames = $(az account list --query "[].name" --output tsv)

if ($subscriptionNames.Count -eq 0) {
    Write-Host "No Azure subscription found for the logged in user. Please login with a user that has access to an Azure subscription." -ForegroundColor Red
    return
}
elseif ($subscriptionNames.Count -gt 1) {
    Write-Warning "More than one Azure subscription found for the logged in user!"

    if ($settings.PSObject.Properties.Name -contains "subscriptionName") {
        $subscriptionName = $settings.subscriptionName
        Write-Host "Defaulting to appSettings-$Environment.json supplied '$subscriptionName'"
    }
    else {
        Write-Host "appSettings.json does not contain a 'subscriptionName' property" -ForegroundColor Red
        return
    }
}
else {
    $subscriptionName = $subscriptionNames[0]
    Write-Host "Found Azure subscription: $($subscriptionName)"
}

return $subscriptionName