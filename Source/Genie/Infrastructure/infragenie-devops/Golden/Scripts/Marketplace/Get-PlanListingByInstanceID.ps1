function Get-PlanListingByInstanceId {
    param (
        [string]$InstanceID,
        [string]$ProductId,
        [string]$AccessToken
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/getByInstanceID(instanceID=$InstanceID)"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop

        $response = $response | ConvertTo-Json -Depth 4

        return $response
    }
    catch {
        Write-Error "Failed to retrieve plan listing by instance ID: $($_.Exception.Message)"
        return $null
    }
}

