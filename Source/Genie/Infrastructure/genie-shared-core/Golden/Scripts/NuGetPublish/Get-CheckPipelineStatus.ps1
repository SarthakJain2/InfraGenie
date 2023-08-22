function Check-PipelineStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PAT,

        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$PipelineId
    )

    $url = "https://dev.azure.com/$Organization/$ProjectName/_apis/pipelines/$PipelineId/runs?api-version=7.0"

    Write-Host "DevOps Pipeline Status API Url: $url"

    $basicAuth = "{0}:{1}" -f "", $PAT
    $basicAuthBytes = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
    $basicAuthBase64 = [System.Convert]::ToBase64String($basicAuthBytes)
    $headers = @{
        Authorization  = "Basic $basicAuthBase64"
        "Content-Type" = "application/json"
    }

    do {
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers

        $pipelineRun = $response.value[0]

        if ($pipelineRun.result -eq "succeeded") {
            Write-Host "Pipeline run succeeded for '$($pipelineRun.name)'."
            break
        }
        elseif ($pipelineRun.result -eq "failed") {
            Write-Host "Pipeline run failed for '$($pipelineRun.name)'."
            break
        }
        else {
            Write-Output "Pipeline run is still in progress. Waiting for 10 seconds before checking again..."
            Start-Sleep -Seconds 10
        }
    } while ($true)
}
