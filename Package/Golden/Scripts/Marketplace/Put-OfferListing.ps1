$accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5wYXJ0bmVyLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zYWMxNTg1Yi0xNTZkLTRjNmUtOGZmYS04Yjg0NDA2MTFmN2QvIiwiaWF0IjoxNjgzNTM3MzI2LCJuYmYiOjE2ODM1MzczMjYsImV4cCI6MTY4MzU0MTIyNiwiYWlvIjoiRTJaZ1lPaTcrdEF2OWZsejNxVjJNdytlWnhRL0JnQT0iLCJhcHBpZCI6ImJjMzcwM2I2LWU1OTItNDE0MC1hYWFmLWQxNjYyMzZlZDY0YyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZC8iLCJvaWQiOiJjYzNhYjcwZS00OTUyLTQ1NGItYTc0ZS0wZTFlNGNlZDUxM2EiLCJyaCI6IjAuQVgwQVcxakJPbTBWYmt5UC1vdUVRR0VmZmY3UGtFbm9CSXRPZ0lvUmRXQkxoNS1jQUFBLiIsInN1YiI6ImNjM2FiNzBlLTQ5NTItNDU0Yi1hNzRlLTBlMWU0Y2VkNTEzYSIsInRpZCI6IjNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZCIsInV0aSI6InpmcndEVDV1YWtHSDFzT3EyeV9SQUEiLCJ2ZXIiOiIxLjAifQ.gOOGGRox8xkpdb-H-EscHA9ThazxxEWGuLUQNsozZjfvBIPa1rS2cqdVokP-eRcN6T_lFGn7nYmolkhAnwlfntROKPGf4dMf_AbKKlZm9Tm6XRfeL-QihOBMkKBw_tiMVM7PfacBQoFcE9l3hncBqWaOGwCEzZchCoD48wOzKTOChKWSrqHt6QxwPWr8TqaeMt05Q3ifjSLLsslZcunT0ASm5RB2_ttLOQP51JkpRF4Jf2ejJ69VrUBZq43ESyDrnYLH2VLvFLQtWqlnyq8-QMY0eXo7OLh2RZECy7gGaRERJIHkHQHYqPPw4xO5xjJSOZeO3IZxi-4wregrlvAnfQ"
$product_id = "ff9c30db-abbd-4df1-aec1-083fcf5a7235"
$instance_id = "c00e821f-7a25-6791-ac95-4f8dfe4e9a24"

# $if_match = "220204f5-0000-0200-0000-6454ce250"

$url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$product_id/properties/$instance_id"
$Headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
    'If-Match'      = '"9214a855-0000-0800-0000-6458879f0000"'
    
}

$body = @{
    resourceType = "AzureProperty"
    termsOfUse = "test-11"
    leveledCategories = @{
        "developer-tools-azure-apps" = @(
            "devService"
        )
    }
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 

# process the response as needed