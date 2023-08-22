. .\get_product_branches.ps1
function Get-ProductAvailabilitiesByInstanceID {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InstanceID,
        [Parameter(Mandatory = $true)]
        [string]$ProductID,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )
    
    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/listings/getByInstanceID(instanceID=$instanceID)"
    
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    
    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    
    return $response | ConvertTo-Json -Depth 4
}

# Usage example
$productID = "b4a0b3b3-cbc0-41ca-89e4-65e6d1b144cb"
$instanceID = $currentDraftInstanceIDs
$accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5wYXJ0bmVyLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zYWMxNTg1Yi0xNTZkLTRjNmUtOGZmYS04Yjg0NDA2MTFmN2QvIiwiaWF0IjoxNjgzMjYzNjQxLCJuYmYiOjE2ODMyNjM2NDEsImV4cCI6MTY4MzI2NzU0MSwiYWlvIjoiRTJaZ1lKai9LM2F0L09mdFRVYWN2dzQxeHhVNkFBQT0iLCJhcHBpZCI6ImJjMzcwM2I2LWU1OTItNDE0MC1hYWFmLWQxNjYyMzZlZDY0YyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZC8iLCJvaWQiOiJjYzNhYjcwZS00OTUyLTQ1NGItYTc0ZS0wZTFlNGNlZDUxM2EiLCJyaCI6IjAuQVgwQVcxakJPbTBWYmt5UC1vdUVRR0VmZmY3UGtFbm9CSXRPZ0lvUmRXQkxoNS1jQUFBLiIsInN1YiI6ImNjM2FiNzBlLTQ5NTItNDU0Yi1hNzRlLTBlMWU0Y2VkNTEzYSIsInRpZCI6IjNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZCIsInV0aSI6IlZtN2hETjhjdkVXdkhTWXR1cXVwQUEiLCJ2ZXIiOiIxLjAifQ.hpM1mc5-x3SM3HAPpMrx_ccN07Nu1Q0h86sa4yfKcRMtpdPXVXbr598E_thRKpxjVAonw0uY7qMcWSCHEkYSrfcBDzs5W8Gn5bpL5EvvTJnf1NWdAEbFrb-_m7mdB69MnldzMa73pAL1yu3sLtISCbbRQ7OlZGsBjLZxeB2ku-C7QRosGS-dWa4LwP7WBQpc43aE30uvSDxRnCRh-HxMkm0zl2c8OHyjwGm8Z22T5AjLDGmn8-LsXEVriZ3AZJiL2mrgQmcSULXcE64_pkLUtN3tIzIWgZajx-qxVxEmPchJbEJUhaslhrNp0aO24A_6nET00lXjW004ES9S3OLsrA"
Get-ProductAvailabilitiesByInstanceID -InstanceID $instanceID -AccessToken $accessToken -ProductID $productID
