function Create-NewProjectFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectFolder,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RootFolder
        
    )

    $newFolder = Join-Path -Path $RootFolder -ChildPath $ProjectFolder
    $goldenFolder = Join-Path -Path $newFolder -ChildPath "golden"

    if (!(Test-Path -Path $newFolder)) {
        $null = New-Item -ItemType Directory -Path $newFolder
    }

    if (!(Test-Path -Path $goldenFolder)) {
        $null = New-Item -ItemType Directory -Path $goldenFolder
    }
}