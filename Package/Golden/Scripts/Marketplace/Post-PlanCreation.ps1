function Create-Listing {
    param (
        [string]$ProductID,
        [string]$token
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/variants"
    $headers = @{
        Authorization = "Bearer $token"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = "AzureSkuVariant"
        state = "Active"
        friendlyName = "Pay-As-You-Go"
        conversionPaths = "*"
        externalID = "infragenie"
        certificationsAzureGovernment = @()
        cloudAvailabilities = @("public-azure")
        subType = "managed-application"
        extendedProperties = @()
    } | ConvertTo-Json -Depth 4

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json -Depth 4
}



