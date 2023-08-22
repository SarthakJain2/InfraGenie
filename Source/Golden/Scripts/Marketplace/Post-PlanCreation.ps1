function Create-Listing {
    param (
        [string]$ProductId,
        [string]$AccessToken
    )

    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/variants"
    $headers = @{
        Authorization = "Bearer $AccessToken"
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

