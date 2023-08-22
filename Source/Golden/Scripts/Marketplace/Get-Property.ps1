function Get-Property {
    param (
        [string]$ProductId,
        [string]$AccessToken
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/branches/getByModule(module=Property)"

    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

    return $response | ConvertTo-Json
}




