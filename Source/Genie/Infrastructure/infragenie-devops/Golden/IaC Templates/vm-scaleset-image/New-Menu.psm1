using namespace System.Management.Automation.Host

function New-Menu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Question
    )
    
    [string[]] $choices = 
       "Prerequisites Only",
       "VHD Only",
       "Managed Disk Only",
       "Image Gallery Only",
       "Run All",
       "Run VHD, MD & Gallery",
       "Run MD & Gallery"

    $options = [ChoiceDescription[]] (
        [ChoiceDescription]::new('&Prerequisites', 'Run Prerequisites'),
        [ChoiceDescription]::new('&VHD', 'Create VHD'),
        [ChoiceDescription]::new('&Managed Disk', 'Create Managed Disk'),
        [ChoiceDescription]::new('&Image Gallery', 'Add Disk to Gallery'),
        [ChoiceDescription]::new('Run &All', 'Run all'),
        [ChoiceDescription]::new('&1. No Prereq', 'Run all but Prerequisites'),
        [ChoiceDescription]::new('&2. No VHD', 'Run all but Prerequisites & VHD')
    )

    return $choices[$host.ui.PromptForChoice($Title, $Question, $options, 5)]
}
