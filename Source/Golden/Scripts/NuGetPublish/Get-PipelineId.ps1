Function Get-AzureDevOpsPipelineId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PAT,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$Organization
    )

    $Url = "https://dev.azure.com/$Organization/$ProjectName/_apis/pipelines?api-version=7.0"

    Write-Host "Get Pipeline Id API Url: $Url"

    $Headers = @{
        Authorization  = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(":$PAT"))
        "Content-Type" = "application/json"
    }

    try {
        $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method Get
        return $Response.value.id
    }
    catch {
        Write-Host $_.Exception.Message
        return $null
    }
}
