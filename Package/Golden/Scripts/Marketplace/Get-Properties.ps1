function Get-properties {
    param (  
[string]$ProductId,
[string]$token,
[string]$propertyinstanceIDs
)

$headers = @{
    
    "Authorization" = "Bearer $token"
        
     }

$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/properties/getByInstanceID(instanceID=$propertyinstanceIDs)"
# Write-Host "$url"

$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

return $response | ConvertTo-Json -Depth 4
    
    }







