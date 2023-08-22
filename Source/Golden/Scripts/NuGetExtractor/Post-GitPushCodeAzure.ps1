function Create-PushCodeInto-Azure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,
        
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,
        
        [Parameter(Mandatory = $true)]
        [string]$PAT,
        
        [Parameter(Mandatory = $true)]
        [string]$RepoName,
        
        [Parameter(Mandatory = $true)]
        [string]$BranchName,
        
        [Parameter(Mandatory = $true)]
        [string]$LocalCodeDirectory
    )

    $repoUrl = "https://dev.azure.com/$Organization/$ProjectName/_apis/git/repositories?api-version=7.0"

    Write-Host "Repository URL: $repoUrl"

    $basicAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PAT"))
    $headers = @{
        Authorization  = "Basic $basicAuth"
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers

    Write-Host "Response: $response"

    $repoId = ($response.value | Where-Object { $_.name -eq $RepoName }).id

    Write-Host "Repo ID: $repoId"

    Set-Location $LocalCodeDirectory

    git init

    $remoteUrl = "https://${Organization}:$PAT@$Organization.visualstudio.com/$ProjectName/_git/$RepoName"
    git remote add origin $remoteUrl

    git add .
    git commit -m "Initial commit"

    git push -u origin $BranchName
}