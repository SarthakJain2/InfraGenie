function Update-ProductAvailability {
    param (
        [Parameter(Mandatory=$true)]
        [string]$BearerToken,
        [Parameter(Mandatory=$true)]
        [string]$ProductID,
        [Parameter(Mandatory=$true)]
        [string]$ProductAvailabilityID,
        [Parameter(Mandatory=$true)]
        [string]$IfMatch
    )
    
    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/productavailabilities/$ProductAvailabilityID"
    
    $headers = @{
        Authorization = "Bearer $BearerToken"
        'Content-Type' = 'application/json'
        "If-Match" = "$IfMatch"
    }
    
    $body = @{
        resourceType = 'ProductAvailability'
        visibility = 'Public'
        enterpriseLicensing = 'Online'
        audiences = @(
            @{
                type = 'PreviewMarketplaceGroup'
                value = 'a36d04f9-c570-4d41-98eb-d8c78282b7'
            }
        )
    } | ConvertTo-Json -Depth 4
    
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Body $body -Method Put
    
    return $response
}

# Call the function with the required parameters
$BearerToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5wYXJ0bmVyLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zYWMxNTg1Yi0xNTZkLTRjNmUtOGZmYS04Yjg0NDA2MTFmN2QvIiwiaWF0IjoxNjgzMjY4MDI0LCJuYmYiOjE2ODMyNjgwMjQsImV4cCI6MTY4MzI3MTkyNCwiYWlvIjoiRTJaZ1lQaHRMczN1Y24rVjZxclo0VEhUNUdab0FRQT0iLCJhcHBpZCI6ImJjMzcwM2I2LWU1OTItNDE0MC1hYWFmLWQxNjYyMzZlZDY0YyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZC8iLCJvaWQiOiJjYzNhYjcwZS00OTUyLTQ1NGItYTc0ZS0wZTFlNGNlZDUxM2EiLCJyaCI6IjAuQVgwQVcxakJPbTBWYmt5UC1vdUVRR0VmZmY3UGtFbm9CSXRPZ0lvUmRXQkxoNS1jQUFBLiIsInN1YiI6ImNjM2FiNzBlLTQ5NTItNDU0Yi1hNzRlLTBlMWU0Y2VkNTEzYSIsInRpZCI6IjNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZCIsInV0aSI6IlZVRmNrQnZxYjA2aUtGcW02ZjRjQUEiLCJ2ZXIiOiIxLjAifQ.lM_X-yl7tGfqwSAuSnI6wlVANgv-nj9k02lQH8FJd_1lHBHt_mnl7P_fgkaT4C3drHOnxS0vm1dNaMX6JuQne8ysUazV5w5W8Kv83zCXflnzYn7B2eyPwT_Mnb9qZDYSld31mjAhmYi45PWJgdh6j-q460ywFZgYEdeUNFkK3Ps3q6BxiZQewbr37c2_zWX8QiU630_1r1TCkKmZB41rOpWGpzRCtK3SkQ8YRE_2v17iq428Rsc4_qHWDTM1XIv3jA-NBo1LDCzyWBmMRLEVuZEh6FcrNDVQb9dDd121-jeEyrHkf4v8KRtCtFBeMX4ukbUSVQenuxPr2HMOKqzLig"
$ProductID = "ff9c30db-abbd-4df1-aec1-083fcf5a7235"
$ProductAvailabilityID = "2152924500014860396"
# $IfMatch = "2102e8d8-0000-0200-0000-6454a30e0000"

$result = Update-ProductAvailability -BearerToken $BearerToken -ProductID $ProductID -ProductAvailabilityID $ProductAvailabilityID 

# Display the result
$result
