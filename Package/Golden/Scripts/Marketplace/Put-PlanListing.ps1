function Put-PlanList {
    param (  
[string]$ProductId,   
[string]$token,
[string]$currentlistingids,
[string]$currentlistingids1
 
)
$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$currentlistingids"
$Headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    'If-Match'      = '"$currentlistingids1"'
    
}


$body = @{
    resourceType = "AzureListing"
    listingContacts = @(
        @{
            type = "CustomerSupport"
            email = ""
            name = ""
            phone = ""
            uri = ""
        },
        @{
            type = "Engineering"
            email = ""
            name = ""
            phone = ""
            uri = ""
        }
    )
    gettingStartedInstructions = ""
    languageCode = "en-us"
    title = "Pay-As-You-Go"
    description = "<b>Contact for more information</b>"
    shortDescription = "First month free, then ₹0/month"
    keywords = @()
    "@odata.etag" = $currentlistingids1
    "id" = $currentlistingids
} | ConvertTo-Json -Depth 4

$response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body

return $response | ConvertTo-Json -Depth 10
}

