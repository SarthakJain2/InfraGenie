function Put-UpdateImage215x115 {
    param (   
    [string]$ProductID, 
    [string]$token,
    [string]$InstanceID,
    [string]$Updatedid,
    [string]$FilesasUri,
    [string]$updatedeTag
 
)
$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/listings/$InstanceID/images/$Updatedid"
$Headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    'If-Match'      = '"$updatedeTag"'
    
}


$body = @{
    resourceType = "ListingImage"
    fileName = "Genie_ai_215x115.png"
    type = "AzureLogoWide"
    fileSasUri = $FilesasUri
    state = "Uploaded"
    description = ""
    order = 0
    "@odata.etag" = $updatedeTag
    "id"= $Updatedid

} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 

return $response | ConvertTo-Json -Depth 4

}
