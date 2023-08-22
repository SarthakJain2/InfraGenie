function Put-OfferListing {
    param (  
        [string]$ProductId,   
        [string]$AccessToken,
        [string]$GetListingInstanceId,
        [string]$GetListingEtag
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/listings/$GetListingInstanceId"
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
        'If-Match' = $GetListingEtag
    }

    $body = @{
        resourceType = "AzureListing"
        summary = "InfraGenie is OpenAI ChatGPT based platform for Deploying Azure Infrastructure rapidly using a chat web interface"
        listingUris = @(
            @{
                type = "PrivacyUri"
                uri = "https://privacy.microsoft.com/en-us/privacystatement"
            },
            @{
                type = "PublicCloudSupport"
                uri = "https://privacy.microsoft.com/en-us/privacystatement/support/v2"
            }
        )
        listingContacts = @(
            @{
                type = "CustomerSupport"
                email = "akshay@rhipheus.com"
                name = "Akshay Vidap"
                phone = "+91-8390289898"
                uri = ""
            },
            @{
                type = "Engineering"
                email = "hrushikesh@rhipheus.com"
                name = "Hrushikesh Walujkar"
                phone = "+91-7249000624"
                uri = ""
            },
            @{
                type = "ChannelManager"
                email = "vyas@rhipheus.com"
                name = "Vyas Bharghava"
                phone = "+1-206-619-5322"
                uri = ""
            }
        )
        gettingStartedInstructions = ""
        languageCode = "en-us"
        title = "InfraGenie Standard"
        description = "<span dir=`"ltr`"><p>InfraGenie.ai can be used within an enterprise to <br></p><p>`n1. Create a brand new version of Azure Foundation using Hub / Spoke model<br>`n2. Create infrastructure for specific projects by the Architecture diagram uploaded<br>`n3. Update or modify the infrastructure using a Chat based interface<br>`n4. DevOps teams can collaborate with Genie by having the generated code - very much human readable - checked-in and DevOps pipelines created</p>`n</span>"
        shortDescription = "InfraGenie is OpenAI ChatGPT based platform for Deploying Azure Infrastructure rapidly"
        keywords = @(
            "ChatGPT",
            "IaC",
            "DevOps"
        )
        "@odata.etag" = $GetListingEtag
        "id" = $GetListingInstanceId
    } | ConvertTo-Json -Depth 4

    $response = Invoke-RestMethod -Uri $url -Method PUT -Headers $Headers -Body $body 
    return $response | ConvertTo-Json -Depth 4
}

