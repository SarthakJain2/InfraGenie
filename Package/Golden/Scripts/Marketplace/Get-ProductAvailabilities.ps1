function Get-ProductAvailabilities {
    param (  
[string]$ProductId,
[string]$getids,    
[string]$token   
)

$headers = @{
    
    "Authorization" = "Bearer $token"
        
     }

$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/productavailabilities/getByInstanceID(instanceID=$getids)"


$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

return $response | ConvertTo-Json -Depth 4
    
    }
 
    
