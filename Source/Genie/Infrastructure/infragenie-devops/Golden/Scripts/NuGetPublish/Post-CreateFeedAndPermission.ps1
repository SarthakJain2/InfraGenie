function Create-AzureDevOpsFeedAndPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$BuildID,

        [Parameter(Mandatory = $true)]
        [string]$FeedName,

        [string]$RoleName = "Contributor"
    )

    $identityDescriptor = "Microsoft.TeamFoundation.ServiceIdentity;3fc42801-d556-48f5-93bf-027a4535972c:Build:$BuildID"

    $basicAuth = ":$PAT"
    $basicAuthBytes = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
    $basicAuthBase64 = [System.Convert]::ToBase64String($basicAuthBytes)
    $headers = @{
        Authorization  = "Basic $basicAuthBase64"
        "Content-Type" = "application/json"
    }

    $orgName = $Organization
    $projectName = $ProjectName

    Write-Host "Role Type: $RoleName"
    Write-Host "Identity Descriptor: $identityDescriptor"

    $url = "https://feeds.dev.azure.com/$orgName/$projectName/_apis/packaging/Feeds?api-version=7.0"

    Write-Host "Create Feed API Url: $url"

    $body = @{
        name        = $FeedName
        permissions = @(
            @{
                role               = $RoleName
                identityDescriptor = $identityDescriptor
                displayName        = $null
                isInheritedRole    = $false
            }
        )
    } | ConvertTo-Json

    do {
        try {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -ContentType "application/json" -Body $body
        }
        catch {
            Start-Sleep -Seconds 15
        }
    } while (-not $response)

    Write-Host "Feed created successfully. Name: $FeedName, ID: $($response.id)"
    return $response.id
}
