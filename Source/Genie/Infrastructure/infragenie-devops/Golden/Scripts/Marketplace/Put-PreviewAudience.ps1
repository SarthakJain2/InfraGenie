function Put-AzurePreviewAudience {
    param (  
        [string]$ProductId,
        [string]$AccessToken,
        [string]$ProductAvailabilitiesInstancetag,
        [string]$GetAvailabilityIDs
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/productavailabilities/$GetAvailabilityIDs"
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
        'If-Match' = "$ProductAvailabilitiesInstancetag"
    }

    $body = @{
        resourceType = "ProductAvailability"
        visibility = "Public"
        audiences = @(
            @{
                type = "PreviewMarketplaceGroup"
                values = @("ece96d80-c934-4839-bb90-c2f9ff7c94f9")
            }
        )
    } | ConvertTo-Json -Depth 4

    $response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 

    return $response | ConvertTo-Json -Depth 4
}

