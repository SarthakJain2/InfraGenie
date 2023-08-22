function Get-PackageByInstanceId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$getpackageIDs,

        [Parameter(Mandatory = $true)]
        [string]$ProductId,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $Uri = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductId/packageConfigurations/getByInstanceID(instanceID=$getpackageIDs)"
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $Response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
        return $Response | ConvertTo-Json -Depth 4
    }
    catch {
        Write-Error "Failed to retrieve package configuration. Error: $($_.Exception.Message)"
    }
}
