function Get-Properties {
    param (
        [string]$ProductId,
        [string]$Token,
        [string]$PropertyInstanceIDs
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/properties/getByInstanceID(instanceID=$PropertyInstanceIDs)"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

        $response = $response | ConvertTo-Json -Depth 4

        return $response
    }
    catch {
        Write-Error "Failed to retrieve properties: $($_.Exception.Message)"
        return $null
    }
}

