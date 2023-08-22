
function Get-PartnerAppAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,

        [Parameter(Mandatory = $true)]
        [string]$Resource
    )

    $tokenEndpoint = "https://login.microsoftonline.com/$TenantId/oauth2/token"

    $body = @{
        grant_type    = "client_credentials"
        client_id     = $ClientId
        client_secret = $ClientSecret
        resource      = $Resource
    }

    

     $response = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body 
    
    

     $response = $response | ConvertTo-Json -Depth 4
     return $response

} 



