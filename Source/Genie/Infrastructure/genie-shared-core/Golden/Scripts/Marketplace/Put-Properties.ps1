function Put-Properties {
    param (  
        [string]$ProductId,
        [string]$InstanceID,
        [string]$PropertiesTag,   
        [string]$AccessToken
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/properties/$InstanceID"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
        'If-Match' = "$PropertiesTag"
    }

    $body = @{
        resourceType = "AzureProperty"
        termsOfUse = "test"
        leveledCategories = @{
            "developer-tools-azure-apps" = @(
                "devService"
            )
        }
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri $url -Method PUT -Headers $headers -Body $body 

    return $response | ConvertTo-Json -Depth 4
}

