$jsonFilePath = "D:\Marketplace\Nuget Extractor\parameter.json"
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$jsonObject = $jsonContent | ConvertFrom-Json


$PAT = $jsonObject.PAT
$Organization = $jsonObject.Organization
$processTemplate = $jsonObject.processTemplate
$projectName = $jsonObject.projectName
$ProjectType = $jsonObject.ProjectType
$rootFolder = $jsonObject.rootFolder
$outputDir = $jsonObject.outputDir
$packageName = $jsonObject.packageName
$GitHubRepoUrl = $jsonObject.GitHubRepoUrl
$GitHubRepo1Url = $jsonObject.GitHubRepo1Url
$url = $jsonObject.url
$Bicepfile = $jsonObject.Bicepfile


. .\Post-CreateLocalFolder.ps1
. .\Post-CreateProjects.ps1
. .\Post-GitPushCodeAzure.ps1
. .\Post-GithubLinksPush.ps1


$basicAuth = ("{0}:{1}" -f "", $PAT)
$basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
$basicAuth = [System.Convert]::ToBase64String($basicAuth)
$headers = @{
    Authorization  = ("Basic {0}" -f $basicAuth)
    "Content-Type" = "application/json"
}


$packagePath = Join-Path -Path $outputDir -ChildPath "$packageName.nupkg"
Invoke-WebRequest -Uri $url -Headers $headers -OutFile $packagePath

Create-NewProjectFolder -ProjectFolder $projectName -RootFolder $RootFolder

$extractPath = Join-Path -Path $outputDir -ChildPath "$projectName\golden"
Expand-Archive -Path $packagePath -DestinationPath $extractPath

$bicepFiles = @("$extractPath\content\$Bicepfile.bicep")
$projectDir = Join-Path -Path $outputDir -ChildPath $projectName

foreach ($file in $bicepFiles) {
    Move-Item -Path $file -Destination $projectDir
}

Remove-Item -Path $extractPath -Recurse -Force



$projectId = Create-AzureDevOpsProject -PAT $PAT -Organization $Organization -ProjectName $projectName -ProcessTemplate $processTemplate

$projectId1 = Create-AzureDevOpsProject -PAT $PAT -Organization $Organization -ProjectName "${projectName}-IaC" -ProcessTemplate $processTemplate

Start-Sleep -Seconds 10

Create-PushCodeInto-Azure -Organization $Organization -projectName $projectName -PAT $PAT -repoName $projectName -branchName "master" -localCodeDirectory $projectDir

Start-Sleep -Seconds 5

Push-GitHubToAzureDevOps -GitHubRepoUrl $GitHubRepoUrl -GitHubRepo1Url $GitHubRepo1Url -AzureDevOpsRepoUrl "https://dev.azure.com/ajaymaile/${projectName}-IaC/_git/${projectName}-IaC" -ProjectType $ProjectType