function Get-PlanListingByInstanceId {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InstanceID,
        [Parameter(Mandatory = $true)]
        [string]$ProductID,
        [Parameter(Mandatory = $true)]
        [string]$token
    )
    
    $url = "https://api.partner.microsoft.com/v1.0/ingestion/products/$ProductID/listings/getByInstanceID(instanceID=$instanceID)"
    
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    
    return $response | ConvertTo-Json -Depth 4
}

