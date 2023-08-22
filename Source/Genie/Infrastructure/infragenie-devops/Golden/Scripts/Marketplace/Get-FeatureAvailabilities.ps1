function Get-FeatureAvailabilitiesByInstanceID {
    param (
        [string]$GetAvailabilityplanIDs,
        [string]$ProductId,
        [string]$AccessToken
    )

    $Url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/featureAvailabilities/getByInstanceID(instanceID=$GetAvailabilityplanIDs)?%24expand=MarketStates,PriceSchedule,Trial"

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $Response = Invoke-RestMethod -Method Get -Uri $Url -Headers $Headers
        return $Response | ConvertTo-Json -Depth 10
    }
    catch {
        Write-Error "Failed to retrieve feature availabilities. Error: $($_.Exception.Message)"
    }
}

