$jsonFilePath = "D:\Ajay\Vyas\Infragenie\InfraGenie\Source\Genie\Marketplace\parameter.json"
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$jsonObject = $jsonContent | ConvertFrom-Json


$PAT = $jsonObject.PAT 
$Organization = $jsonObject.Organization 
$pipelineName = $jsonObject.pipelineName
$processTemplate = $jsonObject.processTemplate 
$localCodeDirectory = $jsonObject.localCodeDirectory 
$branchName = $jsonObject.branchName
$path = $jsonObject.path
$projectName = $jsonObject.projectName

. .\Post-CreatePipeline.ps1
. .\Post-CreateProject.ps1

#CreateProject
$projectId = Create-AzureDevOpsProject -PAT $PAT -Organization $Organization -ProjectName $projectName -ProcessTemplate $processTemplate
Write-Host "$projectId"


#CreatePipeline
$pipelineId = Create-Pipeline -Organization $Organization -projectName $projectName -pat $PAT -pipelineName $pipelineName -repoName $projectName -branchName $branchName -localCodeDirectory $localCodeDirectory -path $path 
Write-Host "$pipelineId"