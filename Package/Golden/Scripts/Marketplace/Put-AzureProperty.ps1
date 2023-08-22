function Put-properties {
    param (  
[string]$ProductId,
[string]$Instanceid,    
[string]$token
 
)
$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/properties/$Instanceid"
$Headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    'If-Match'      = "$currentDraftInstanceIDs1"
    
}


$body = @{
    resourceType = "AzureProperty"
    termsOfUse = "test"
    leveledCategories = @{
        "developer-tools-azure-apps" = @(
            "devService"
        )
    }
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 

return $response | ConvertTo-Json -Depth 4

}
