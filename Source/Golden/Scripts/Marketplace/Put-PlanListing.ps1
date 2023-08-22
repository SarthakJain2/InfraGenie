function Put-PlanListing {
    param (  
    [string]$ProductId,   
    [string]$AccessToken,
    [string]$PlanListingIDs,
    [string]$PlanListingetagIDs
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$PlanListingIDs"
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
        'If-Match'      = '"$PlanListingetagIDs"'
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
        "@odata.etag" = $PlanListingetagIDs
        "id" = $PlanListingIDs
    } | ConvertTo-Json -Depth 4
    
    $response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body
    
    return $response | ConvertTo-Json -Depth 10
    }
    
    