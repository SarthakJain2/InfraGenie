Function Get-AzureDevOpsBuildID {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$PAT
    )

    $BaseUrl = "https://dev.azure.com/${Organization}/_apis/projects/${ProjectName}?api-version=7.0"

    Write-Host "Get Build Id API Url: $BaseUrl"

    $Headers = @{
        Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(":$PAT"))
        "Content-Type" = "application/json"
    }

    do {
        try {
            $Response = Invoke-RestMethod -Uri $BaseUrl -Method Get -Headers $Headers
        }
        catch {
            Start-Sleep -Seconds 10
        }
    } while (!$Response)

    Write-Host "Build created successfully NAME '$ProjectName' with ID $($Response.id)."
    return $Response.id
}
