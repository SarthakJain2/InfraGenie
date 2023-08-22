function Create-AzureApplication {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$OfferId,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $Uri = "https://api.partner.microsoft.com/v1.0/ingestion/products"
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    $Body = @{
        "resourceType" = "AzureApplication"
        "name" = $Name
        "externalIDs" = @(
            @{
                "type" = "AzureOfferID"
                "value" = $OfferId
            }
        )
        "isModularPublishing" = $true
    } | ConvertTo-Json

    try {
        $Response = Invoke-RestMethod -Method Post -Uri $Uri -Headers $Headers -Body $Body
        return $Response.id
    }
    catch {
        Write-Error "Failed to create Azure application. Error: $_"
    }
}

$OfferId = [Guid]::NewGuid().ToString()

