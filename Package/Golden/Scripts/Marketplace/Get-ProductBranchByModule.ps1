function Get-ProductBranchByModule {
    param(
        [string]$productId,
        [string]$moduleName,
        [string]$token
    )

    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$productId/branches/getByModule(module=$moduleName)"
    $headers = @{
        Authorization = "Bearer $token"
        'Content-Type' = 'application/json'
    }
    $body = @{
        productId      = $productId
        modulename = $moduleName 
    }
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -Body $body

    
    return $response | ConvertTo-Json -Depth 4
} 



