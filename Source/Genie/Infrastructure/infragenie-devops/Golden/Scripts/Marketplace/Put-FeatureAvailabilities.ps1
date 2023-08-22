function Put-FeatureAvailabilities {
    param (  
        [string]$ProductId,   
        [string]$AccessToken,
        [string]$GetFeatureInstanceeTag,
        [string]$GetFeatureInstanceIDs
    )

    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/featureavailabilities/$GetFeatureInstanceIDs`?%24expand=MarketStates,PriceSchedule,Trial"
    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type" = "application/json"
        'If-Match' = $GetFeatureInstanceeTag
    }

    $body = @{
        resourceType = "FeatureAvailability"
        visibility = "Public"
        marketStates = @(
            @{
                marketCode = "US"
                state = "Enabled"
            }
        )
        properties = @(
            @{
                type = "ApplicableClouds"
                value = "PublicAzure"
            }
        )
        priceSchedules = @(
            @{
                isBaseSchedule = $true
                friendlyName = "Default"
                schedules = @(
                    @{
                        retailPrice = @{
                            openPrice = 0.0
                            currencyCode = "USD"
                        }
                        pricingModel = "Recurring"
                        priceCadence = @{
                            type = "Month"
                            value = 1
                        }
                    }
                )
            },
            @{
                isBaseSchedule = $false
                marketCodes = @("US")
                friendlyName = "United States"
                schedules = @(
                    @{
                        retailPrice = @{
                            openPrice = 0.0
                            currencyCode = "USD"
                        }
                        pricingModel = "Recurring"
                        priceCadence = @{
                            type = "Month"
                            value = 1
                        }
                    }
                )
            }
        )
        customMeters = @()
        "@odata.etag" = $GetFeatureInstanceeTag
        "id" = $GetFeatureInstanceIDs
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri $url -Method PUT -Headers $headers -Body $body 

    return $response 
}

