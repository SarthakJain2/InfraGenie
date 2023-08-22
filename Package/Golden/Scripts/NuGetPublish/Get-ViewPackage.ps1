function Get-ArtifactsFeedPackages {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$FeedID,

        [Parameter(Mandatory = $true)]
        [string]$PAT
    )

    $Url = "https://feeds.dev.azure.com/$Organization/$ProjectName/_apis/packaging/feeds/$FeedID/packages?api-version=7.0"

    Write-Host "View Package API Url: $Url"

    $Headers = @{
        Authorization  = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(":$PAT"))
        "Content-Type" = "application/json"
    }

    $Response = Invoke-RestMethod -Method Get -Uri $Url -Headers $Headers

    return $Response.value | ConvertTo-Json -Depth 10
}
