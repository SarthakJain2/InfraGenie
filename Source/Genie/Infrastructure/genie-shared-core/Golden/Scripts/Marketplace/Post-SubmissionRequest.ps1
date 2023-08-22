function Post-Submission {
    param (
        [string]$ProductId,
        [string]$AccessToken,
        [string]$GetAvailabilityIDs,
        [string]$GetListingID,
        [string]$getpackageofferIDs,
        [string]$getpropid,
        [string]$getresellid,
        [string]$GetAvailabilityvariantIDs,
        [string]$GetAvailabilityplanIDs,
        [string]$GetListingIDs,
        [string]$getpackageIDs
        
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/submissions"
    Write-Host "$uri"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        
        'Content-Type' = 'application/json'
    }

    $body = @{
        "resourceType" = "SubmissionCreationRequest"
        "targets" = @(
            @{
                "type" = "Scope"
                "value" = "Preview"
            }
        )
        "resources" = @(
            @{
                "type" = "Availability"
                "value" = $GetAvailabilityIDs
            },
            @{
                "type" = "Listing"
                "value" = $GetListingID
            },
            @{
                "type" = "Package"
                "value" = $getpackageofferIDs
            },
            @{
                "type" = "Property"
                "value" = $getpropid
            },
            @{
                "type" = "ResellerConfiguration"
                "value" = $getresellid
            }
        )
        "variantResources" = @(
            @{
                "variantID" = $GetAvailabilityvariantIDs
                "resources" = @(
                    @{
                        "type" = "Availability"
                        "value" = $GetAvailabilityplanIDs
                    },
                    @{
                        "type" = "Listing"
                        "value" = $GetListingIDs
                    },
                    @{
                        "type" = "Package"
                        "value" = $getpackageIDs
                    }
                )
            }
        )
        "publicOption" = @{
            "publishedTimeInUtc" = "2023-06-20T00:00:00"
            "isManualPublish" = "true"
            "isAutoPromo" = "true"
            "certificationNotes" = "this is a test from API"
        }
        "extendedProperties" = @()
    } | ConvertTo-Json -Depth 10

 
    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json -Depth 10
}


