function Create-ImageUpload {
    param (
        [string]$ProductID
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packages"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        resourceType = "AzureApplicationPackage"
        filename = "ama-helloworlds.zip"
        } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}
$ProductId = "b4a0b3b3-cbc0-41ca-89e4-65e6d1b144cb"
$AccessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5wYXJ0bmVyLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zYWMxNTg1Yi0xNTZkLTRjNmUtOGZmYS04Yjg0NDA2MTFmN2QvIiwiaWF0IjoxNjgzODcwNzkzLCJuYmYiOjE2ODM4NzA3OTMsImV4cCI6MTY4Mzg3NDY5MywiYWlvIjoiRTJaZ1lDZ3VXYkVxNzhXYXh3NHlHV1ZUZEwrY0J3QT0iLCJhcHBpZCI6ImJjMzcwM2I2LWU1OTItNDE0MC1hYWFmLWQxNjYyMzZlZDY0YyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZC8iLCJvaWQiOiJjYzNhYjcwZS00OTUyLTQ1NGItYTc0ZS0wZTFlNGNlZDUxM2EiLCJyaCI6IjAuQVgwQVcxakJPbTBWYmt5UC1vdUVRR0VmZmY3UGtFbm9CSXRPZ0lvUmRXQkxoNS1jQUFBLiIsInN1YiI6ImNjM2FiNzBlLTQ5NTItNDU0Yi1hNzRlLTBlMWU0Y2VkNTEzYSIsInRpZCI6IjNhYzE1ODViLTE1NmQtNGM2ZS04ZmZhLThiODQ0MDYxMWY3ZCIsInV0aSI6IkMzR2JZNF9lT2ttbnRkWFNuV0tlQUEiLCJ2ZXIiOiIxLjAifQ.AxfqxtGgLMIM9rBxn04vXORmOhNr0UBP7dFNJoxX_Hr8D6e6YqqEUR3OBiAhL4b6qvGGFWtfOv75wAeK_5hLqQ9PxsJVJ4SOIHmYTyMjcXrdZh7yU3zpEOggVCfm0XkxZN7eZ7uWs4O1TR2aglHOC0iGZfghST00jXxiCtYqFdaGVXJtA54yHlsqOGAm6oxzetZ9BA3nXZzugSKKtzD5NEfkt7ESJkRdcdt3DlozRZPV3N4bE-y3uwvlgc7j1Xd6Asj5Gfi1onbY0SvMkYIa7ECHupc8J98oPcgO9nS2sU1kCopLGRpXZ0ohjn0qyQ8l0V37iUYUZthUQd_p40z0Uw"
$jsonFile = Create-ZipCreate -ProductID $ProductId 

Write-Host "$jsonFile"

& .\azcopy.exe copy ama-helloworlds.zip "https://ingestionpackagesprod1.blob.core.windows.net/file/3042304091520753760?sv=2018-03-28&sr=b&sig=c%2Bg9Bi44NJjsEKGrJwKvlx93Uk%2BkcI6FHZnaVJwvNLY%3D&se=2023-05-13T06%3A37%3A16Z&sp=rwl"

