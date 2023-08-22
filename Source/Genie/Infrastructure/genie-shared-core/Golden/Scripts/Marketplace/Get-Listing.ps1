function Get-Listings {
    param (
        [string]$ProductId,
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    $Url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/branches/getByModule(module=Listing)"

    try {
        $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get
        return $Response | ConvertTo-Json
    }
    catch {
        Write-Error "Failed to retrieve listings. Error: $($_.Exception.Message)"
    }
}

