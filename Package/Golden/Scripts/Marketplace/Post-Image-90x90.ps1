function Post-Image-90x90 {
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
        fileName = "Genie_ai_90x90.png"
        type = "AzureLogoMedium"
        state = "PendingUpload"
        description = ""
        order = 0
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}



