function Push-GitHubToAzureDevOps {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GitHubRepoUrl,
        
        [Parameter(Mandatory = $true)]
        [string]$GitHubRepo1Url,
        
        [Parameter(Mandatory = $true)]
        [string]$AzureDevOpsRepoUrl,
        
        [Parameter(Mandatory = $true)]
        [string]$ProjectType
    )

    if ($ProjectType -eq "Nodejs") {

        git clone $GitHubRepoUrl

        $repoName = (Split-Path -Path $GitHubRepoUrl -Leaf).Replace('.git', '')
        Set-Location -Path $repoName

        git remote set-url origin $AzureDevOpsRepoUrl

        git push -u origin master
    }
    else {

        git clone $GitHubRepo1Url

        $repoName = (Split-Path -Path $GitHubRepo1Url -Leaf).Replace('.git', '')
        Set-Location -Path $repoName

        git remote set-url origin $AzureDevOpsRepoUrl

        git push -u origin master
    }
}