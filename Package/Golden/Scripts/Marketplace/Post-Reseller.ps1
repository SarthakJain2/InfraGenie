function Create-Reseller {
    param (
        [string]$ProductID,
        [string]$token
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/resellerConfiguration"
    $headers = @{
        Authorization = "Bearer $token"
        
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
