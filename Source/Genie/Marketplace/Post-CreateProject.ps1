Function Create-AzureDevOpsProject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$PAT,

        [Parameter(Mandatory = $true)]
        [string]$ProcessTemplate
    )

    $Headers = @{
        Authorization  = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(":$PAT"))
        "Content-Type" = "application/json"
    }

    $Url = "https://dev.azure.com/$Organization/_apis/projects?api-version=7.0"

    Write-Host "Create Project API Url: $Url"

    $Body = @{
        name         = $ProjectName
        capabilities = @{
            versioncontrol  = @{
                sourceControlType = "Git"
            }
            processTemplate = @{
                templateTypeId = $ProcessTemplate
            }
        }
    } | ConvertTo-Json

    $Response = Invoke-RestMethod -Uri $Url -Method Post -ContentType "application/json" -Headers $Headers -Body $Body

    Write-Host "Azure DevOps project '$ProjectName' created successfully with ID $($Response.id)."
    return $Response.id
}

