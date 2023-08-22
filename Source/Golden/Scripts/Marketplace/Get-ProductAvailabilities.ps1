function Get-ProductAvailabilities {
    param (
        [string]$ProductId,
        [string]$GetAvailabilityIDs,
        [string]$AccessToken
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/productavailabilities/getByInstanceID(instanceID=$GetAvailabilityIDs)"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

        $response = $response | ConvertTo-Json -Depth 4

        return $response
    }
    catch {
        Write-Error "Failed to retrieve product availabilities: $($_.Exception.Message)"
        return $null
    }
}
