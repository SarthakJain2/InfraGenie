function Get-ImagesByInstanceID {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GetListingInstanceId,
        [Parameter(Mandatory = $true)]
        [string]$ProductId,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )
    
    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$GetListingInstanceId/images"
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    
    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    
    return $response | ConvertTo-Json -Depth 4
}


