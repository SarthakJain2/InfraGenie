function Get-ProductBranchByModule {
    param (
        [string]$ProductId,
        [string]$ModuleName,
        [string]$AccessToken
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/branches/getByModule(module=$ModuleName)"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop

        $response = $response | ConvertTo-Json -Depth 4

        return $response
    }
    catch {
        Write-Error "Failed to retrieve product branch by module: $($_.Exception.Message)"
        return $null
    }
}

