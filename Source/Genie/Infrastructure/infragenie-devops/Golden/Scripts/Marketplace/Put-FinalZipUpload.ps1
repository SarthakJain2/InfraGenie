function Create-ZipFinalUpload {
    param (
        [string]$ProductId,
        [string]$AccessToken,
        [string]$putzipIds,
        [string]$packageinstanceetagIds,
        [string]$getpackageIds
    )
    $uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packageConfigurations/$getpackageIDs"
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
        "publicAzureTenantID" = "3ac1585b-156d-4c6e-8ffa-8b8440611f7d"
        "publicAzureAuthorizations" = @(
            @{
                "principalID" = "c40cc170-a660-48fc-9ef2-06ba8a811121"
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



