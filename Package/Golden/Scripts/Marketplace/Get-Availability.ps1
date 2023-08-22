function Get-Availability {
    param (
        [string]$ProductId,
        [string]$token
    )

    $headers = @{
        "Authorization" = "Bearer $token"
    }

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/branches/getByModule(module=Availability)"

    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

    return $response | ConvertTo-Json
}


