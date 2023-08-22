function Put-UpdateImage90x90 {
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
    fileName = "Genie_ai_90x90.png"
    type = "AzureLogoMedium"
    fileSasUri = $FilesasUri
    state = "Uploaded"
    description = ""
    order = 0
    "@odata.etag" = $updatedeTag
    "id"= $Updatedid

} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 

return $response | ConvertTo-Json -Depth 4

# process the response as needed
}
# $token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5wYXJ0bmVyLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zYWMxNTg1Yi0xNTZkLTRjNmUtOGZmYS04Yjg0NDA2MTFmN2QvIiwiaWF0IjoxNjg0MDc3NzcxLCJuYmYiOjE2ODQwNzc3NzEsImV4cCI6MTY4NDA4MTY3MSwiYWlvIjoiRTJaZ1lQQTk3WlEralZsdjRTWk5nNnk4aFZjdkFnQT0iLCJhcHBpZCI6ImJjMzcwM2I2LWU1OTItNDE0MC1hYWFmLWQxNjYyMzZlZDY0YyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZC8iLCJvaWQiOiJjYzNhYjcwZS00OTUyLTQ1NGItYTc0ZS0wZTFlNGNlZDUxM2EiLCJyaCI6IjAuQVgwQVcxakJPbTBWYmt5UC1vdUVRR0VmZmY3UGtFbm9CSXRPZ0lvUmRXQkxoNS1jQUFBLiIsInN1YiI6ImNjM2FiNzBlLTQ5NTItNDU0Yi1hNzRlLTBlMWU0Y2VkNTEzYSIsInRpZCI6IjNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZCIsInV0aSI6IjVOc1VxaW5WYlVxaHFKaVFlRDB5QUEiLCJ2ZXIiOiIxLjAifQ.gncR-GkfCKbS3w-pEM48T3ae9mTSc3Z34nd3RQ-8LHLLezVbIqdApveVctxVrRLhSv2z5j89PxB6yw4Pat1Z2EpMdEvIqz9V-DwR3JtzhVGt0zX2FpfQpogyXVUrtyo-M126YgP1KD99uki4K_nh3jI-zOXxR2EsVypvGlBsETLyg6rgWfZxkxl9m5rUXm1R4_cRKie-kRtkuQnb1HxGtvLTokDj10liSeWK1I4Eotv3cO40CDvcaA7ZMbsdDiiNvRwQ2wQo74YgVxulTACuEdvlbeJgrq1YDA1N9pmEaf1_wAp-3IHEzQ0QLtFDawbeYpgWKt-BrdOWnxCyQjz8Ug"

# $Productid = "d2a535ee-e63b-4299-87a4-7d1e7268502b"
# $Instanceid = "7853f7c2-5cea-dfc9-7514-ddcf3af01559"
# $UpdatedId = "f11ebcaa-8ba1-7fdf-5942-3b55b5c5edcc"
# $updatedeTag = "4e036f89-0000-0800-0000-6460cf910000"
# $FilesasUri = "https://ingestionpackagesprod1.blob.core.windows.net/file/3018478626842683399?sv=2018-03-28&sr=b&sig=%2Fd4QbbAgASE%2BWKJhFQQ5qKOJprE9tiZ0eSsqQbx7WJI%3D&se=2023-05-15T15%3A44%3A46Z&sp=rwl"
