$jsonFilePath = "D:\InfraGenie-1\Package\Golden\Golden\Scripts\NuGetPublish\parameter.json" 
$jsonContent = Get-Content -Path $jsonFilePath -Raw 
$jsonObject = $jsonContent | ConvertFrom-Json 

$PAT = $jsonObject.PAT 
$Organization = $jsonObject.Organization 
$pipelineName = $jsonObject.pipelineName
$processTemplate = $jsonObject.processTemplate 
$localCodeDirectory = $jsonObject.localCodeDirectory 
$branchName = $jsonObject.branchName
$yamlFilePath = $jsonObject.yamlFilePath
$path = $jsonObject.path
$projectName = $jsonObject.projectName
$feedName = $jsonObject.feedName

$project = ".\Post-CreateProject.ps1"
$buildIDScript = ".\Get-BuildId.ps1"
$feedAndPermissionScript = ".\Post-CreateFeedAndPermission.ps1"
$pipelineScript = ".\Post-CreatePipeline.ps1"
$pipelineIdScript = ".\Get-PipelineId.ps1"
$pipelineStatusScript = ".\Get-CheckPipelineStatus.ps1"
$viewPackageScript = ".\Get-ViewPackage.ps1"

. $project
. $buildIDScript
. $feedAndPermissionScript
. $pipelineScript
. $pipelineIdScript
. $pipelineStatusScript
. $viewPackageScript

$buildID = Get-AzureDevOpsBuildID -PAT $PAT -Organization $Organization -ProjectName $projectName
if ($buildID) {
    $feedID = Create-AzureDevOpsFeedAndPermission -ProjectName $projectName -buildID $buildID -feedName $feedName
}
else {
    $projectId = Create-AzureDevOpsProject -PAT $PAT -Organization $Organization -ProjectName $projectName -ProcessTemplate $processTemplate
    Start-Sleep -Seconds 20
    $buildID = Get-AzureDevOpsBuildID -PAT $PAT -Organization $Organization -ProjectName $projectName
    $feedID = Create-AzureDevOpsFeedAndPermission -ProjectName $projectName -buildID $buildID -feedName $feedName
}

Write-Host "buildID $($buildID) and feedID $($feedID)"

$yamlFileContent = Get-Content $yamlFilePath
$yamlFileContent = $yamlFileContent -replace "buildID", "$buildID"
$yamlFileContent = $yamlFileContent -replace "feedID", "$feedID"
$yamlFileContent | Set-Content $yamlFilePath

Create-Pipeline -Organization $Organization -projectName $projectName -pat $PAT -pipelineName $pipelineName -repoName $projectName -branchName $branchName -localCodeDirectory $localCodeDirectory -path $path 

$yamlFileContent = $yamlFileContent -replace "$buildID", "buildID"
$yamlFileContent = $yamlFileContent -replace "$feedID", "feedID"
$yamlFileContent | Set-Content $yamlFilePath

$pipelineId = Get-AzureDevOpsPipelineId -Organization $Organization -PAT $PAT -ProjectName $projectName

Check-PipelineStatus -PAT $PAT -Organization $Organization -projectName $projectName -pipelineId $pipelineId

$organization = $Organization
$project = $projectName
$feedId = $feedID
$pat = $PAT

$FeedDetails = Get-ArtifactsFeedPackages -Organization $organization -Project $project -FeedId $feedId -PAT $pat

$Details = ConvertFrom-Json $FeedDetails
$packageName = $Details.Name
$packageVersion = $Details.versions.version

Write-Host "Download Package API Url: https://pkgs.dev.azure.com/$Organization/$projectName/_apis/packaging/feeds/$feedName/nuget/packages/$packageName/Versions/$packageVersion/content?api-version=7.0-preview.1"
