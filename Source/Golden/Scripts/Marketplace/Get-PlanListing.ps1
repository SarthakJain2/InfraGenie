function Get-PlanListings {
    param (
        [string]$ProductId,
        [string]$AccessToken
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/branches/getByModule(module=Listing)"

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

        $response = $response | ConvertTo-Json

        return $response
    }
    catch {
        Write-Error "Failed to retrieve plan listings: $($_.Exception.Message)"
        return $null
    }
}

