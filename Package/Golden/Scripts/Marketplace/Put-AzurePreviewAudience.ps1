
function Put-AzurePreviewAudience {
    param (  
# [string]$Instanceid,
[string]$ProductId,
[string]$token,
[string]$previewinstancetag,
[string]$getids
 
)

$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/productavailabilities/$getids"
$Headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    'If-Match'      = "$previewinstancetag"
    
}

$body = @{
    resourceType = "ProductAvailability"
    visibility = "Public"
    audiences = @(
        @{
            type = "PreviewMarketplaceGroup"
            values = @("a36d04f9-c570-4d41-98eb-d8c78282b7d4")
        }
    )
} | ConvertTo-Json -Depth 4
  
$response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 

return $response | ConvertTo-Json -Depth 4

}
