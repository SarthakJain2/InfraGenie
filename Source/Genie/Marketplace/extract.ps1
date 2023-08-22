function Extract-NuGetPackages {
    param (
        [string]$LocalDownloadPath
    )

    $nugetPackages = Get-ChildItem -Path $LocalDownloadPath -Filter *.nupkg

    foreach ($package in $nugetPackages) {
        $packageName = $package.BaseName
        $packageExtractPath = Join-Path -Path $LocalDownloadPath -ChildPath $packageName

        # Create a new folder for the extracted package if it doesn't exist
        if (-Not (Test-Path $packageExtractPath -PathType Container)) {
            New-Item -ItemType Directory -Force -Path $packageExtractPath
        }

        Expand-Archive -Path $package.FullName -DestinationPath $packageExtractPath -Force
        Write-Host "Extracted: $packageName"
    }

    Write-Host "All NuGet packages extracted successfully."
}

$localDownloadPath = ".\newFiles"
Extract-NuGetPackages -LocalDownloadPath $localDownloadPath
