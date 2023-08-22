function Create-Reseller {
    param (
        [string]$ProductId,
        [string]$AccessToken
    )

    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/resellerConfiguration"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = "ResellerConfiguration"
        resellerChannelState = "Disabled"
        tenantIds = @()
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}

