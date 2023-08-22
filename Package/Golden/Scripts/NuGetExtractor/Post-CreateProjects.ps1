function Create-AzureDevOpsProject {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,
        
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,
        
        [Parameter(Mandatory = $true)]
        [string]$ProcessTemplate,

        [Parameter(Mandatory = $true)]
        [string]$PAT
    )

    $basicAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PAT"))
    $headers = @{
        Authorization  = "Basic $basicAuth"
        "Content-Type" = "application/json"
    }

    $uri = "https://dev.azure.com/$Organization/_apis/projects?api-version=7.0"

    $body = @{
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

    $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers $headers -Body $body

    Write-Host "Azure DevOps project '$ProjectName' created successfully with ID $($response.id)."
    return $response.id
}