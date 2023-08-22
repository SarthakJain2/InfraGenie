function Create-ZipFinalUpload {
    param (
        [string]$ProductID,
        [string]$token,
        [string]$putzipIds,
        [string]$packageinstanceetagIds,
        [string]$getpackageIds
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/packageConfigurations/$getpackageIDs"
    $headers = @{
        Authorization = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
        'If-Match'      = $packageinstanceetagIds
    }
    
    $body = @{
        "resourceType" = "AzureManagedApplicationPackageConfiguration"
        "version" = "1.0.0"
        "allowJitAccess" = $false
        "deploymentMode" = "Complete"
        "canEnableCustomerActions" = $false
        "publicAzureTenantID" = "f7249e8e-5b08-40e2-8bb6-061e759bf673"
        "publicAzureAuthorizations" = @(
            @{
                "principalID" = "626c10ba-902d-4069-9320-f4c256a47844"
                "roleDefinitionID" = "Owner"
            }
        )
        "azureGovernmentAuthorizations" = @()
        "policies" = @()
        "packageReferences" = @(
            @{
                "type" = "AzureApplicationPackage"
                "value" = "$putzipIDs"
            }
        )
        "publisherManagementMode" = "Managed"
        "customerAccessEnableState" = "Disabled"
        "@odata.etag" = $packageinstanceetagIds
        "id" = $getpackageIds
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body
    return $response | ConvertTo-Json
}



