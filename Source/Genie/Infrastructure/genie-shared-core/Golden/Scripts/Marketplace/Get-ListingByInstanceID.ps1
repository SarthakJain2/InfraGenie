function Get-ListingByInstanceID {
    param (
        [string]$GetListingID,
        [string]$ProductId,
        [string]$AccessToken
    )

    $Url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/listings/getByInstanceID(instanceID=$GetListingID)"

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $Response = Invoke-RestMethod -Method Get -Uri $Url -Headers $Headers
        return $Response | ConvertTo-Json -Depth 4
    }
    catch {
        Write-Error "Failed to retrieve listing. Error: $($_.Exception.Message)"
    }
}

