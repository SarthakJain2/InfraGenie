function Put-UpdateImage48x48 {
    param (   
    [string]$ProductId, 
    [string]$AccessToken,
    [string]$GetListingInstanceId,
    [string]$Updatedid,
    [string]$FilesasUri,
    [string]$updatedeTag,
    [string]$FileName_48x48
 
)
$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$GetListingInstanceId/images/$Updatedid"
$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/json"
    'If-Match'      = '"$updatedeTag"'
    
}


$body = @{
    resourceType = "ListingImage"
    fileName = $FileName_48x48
    type = "AzureLogoSmall"
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
