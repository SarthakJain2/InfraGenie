$offerId = [Guid]::NewGuid().ToString()
function Create-AzureApplication {
    param (
        [string]$name,
        [string]$offerId
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = 'AzureApplication'
        name = $name
        externalIDs = @(
            @{
                type = 'AzureOfferID'
                value = $offerId
            }
        )
        isModularPublishing = $true       
    } | ConvertTo-Json
    # Write-Host "$body"
    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response.id
}
