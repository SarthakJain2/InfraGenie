function Post-Image-215x115 {
    param (
        [string]$ProductId,    
        [string]$token,
        [string]$currentlistingids
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$currentlistingids/images"
    $headers = @{
        Authorization = "Bearer $token"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = "ListingImage"
        fileName = "Genie_ai_215x115.png"
        type = "AzureLogoWide"
        state = "PendingUpload"
        description = ""
        order = 0
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}



