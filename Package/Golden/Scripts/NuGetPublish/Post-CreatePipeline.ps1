function Create-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$PAT,

        [Parameter(Mandatory = $true)]
        [string]$PipelineName,

        [Parameter(Mandatory = $true)]
        [string]$RepoName,

        [Parameter(Mandatory = $true)]
        [string]$BranchName,

        [Parameter(Mandatory = $true)]
        [string]$LocalCodeDirectory,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $RepoUrl = "https://dev.azure.com/$Organization/$ProjectName/_apis/git/repositories?api-version=7.0"

    Write-Host "Create Repo API Url: $RepoUrl"

    $Headers = @{
        Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PAT"))
    }

    $Response = Invoke-RestMethod -Uri $RepoUrl -Method Get -Headers $Headers
    $RepoId = $Response.value | Where-Object { $_.name -eq $RepoName } | Select-Object -ExpandProperty id

    Write-Host "Repo ID for '$ProjectName': $RepoId"

    Set-Location -Path $LocalCodeDirectory

    git init

    $RemoteUrl = "https://${Organization}:${PAT}@$Organization.visualstudio.com/$ProjectName/_git/$RepoName"

    Write-Host "Remote Url: https://dev.azure.com/${Organization}/$ProjectName/_git/$RepoName"

    git remote set-url origin $RemoteUrl

    # git remote add origin $RemoteUrl

    git add .
    git commit -m "Initial commit"

    git push -u origin $BranchName

    $PipelineUrl = "https://dev.azure.com/$Organization/$ProjectName/_apis/pipelines?api-version=7.0"

    Write-Host "Create Pipeline API Url: $PipelineUrl"

    $PipelineBody = @{
        configuration = @{
            type       = "yaml"
            repository = @{
                id            = $RepoId
                name          = $RepoName
                type          = "azureReposGit"
                defaultBranch = "refs/heads/$BranchName"
            }
            path       = $Path
        }
        name          = $PipelineName
    } | ConvertTo-Json

    $PipelineResponse = Invoke-RestMethod -Uri $PipelineUrl -Method Post -ContentType "application/json" -Headers $Headers -Body $PipelineBody

    $PipelineResponse

    $BuildUrl = "https://dev.azure.com/$Organization/$ProjectName/_apis/build/builds?api-version=7.0"

    Write-Host "Create Build API Url: $BuildUrl"

    $BuildBody = @{
        definition = @{
            id = $PipelineResponse.id
        }
    } | ConvertTo-Json
    Write-Host "$BuildBody"
    $BuildResponse = Invoke-RestMethod -Uri $BuildUrl -Method Post -ContentType "application/json" -Headers $Headers -Body $BuildBody

    $BuildResponse

    Write-Host "$BuildResponse"
}
