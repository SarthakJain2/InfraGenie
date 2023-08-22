Please checkin all Genie Infra code inside the infrastructure folder 
To develop locally, you need run run.ps1
    run.ps1 will have parameters in run.json
    run.ps1 will call go-genie.ps1
    gogenie.ps1 will call the InfraGenie package feed and install and extract the package using the Genie CLI

        ### This is a service principal login 
        genie login azure --tenant-id 72f988bf-86f1-41af-91ab-2d7cd011db47 --client-id 1950a258-227b-4e31-a9cf-717495945fc2 --client-secret 1234567890

        ### This is a standard user login 
        genie login azure --tenant-id 72f988bf-86f1-41af-91ab-2d7cd011db47 --username vyas@rhipheus.com --password HelloSpock@123

        genie login devops with username OR with PAT
        genie login devops --url https://dev.azure.com/rhipheus --username vyas@rhipheus.com --password HelloSpock@123

        genie login devops --PAT "U4a8Q~w4rzZG8sTAHEUsj~xBsi-2O~vXlu.EOaYw"

        genie config --feed-name Tools --feed-url https://dev.azure.com/rhipheus/Genie.InfraGenie.Tools
        genie config --feed-name Golden --feed-url https://dev.azure.com/rhipheus/Genie.InfraGenie.Golden

        cd c:\Rhipheus\IaC
        Download from dev.azure.com or use nuget.exe.  Get the Tools package
            Rhipheus.Genie.Tools.nupkg
                genie.exe
                    Should check for all dependencies and let the user know if any tools are missing (nuget.exe, az cli, etc.)
           
        genie prep --folder-name telehealth-core --project-name thealth --feed-name Tools
        genie prep --folder-name telehealth-core --project-name thealth --feed-url https://dev.azure.com/rhipheus/packages/infraGenie.pkg

        genie prep --project-name telehlth --folder-name telehealth-core
            Defaults to --feed-name golden 
            Create new only folder (--folder-name parameter) ONLY if it does not exist
            cd <--folder-name>
            Should download InfraGenie.nupkg
            Should unzip and create Golden folder
            Copy the .tags folder to outside the project folder
            Should check each file in GenieFx already present.  if present, skip.  If not present, create        
            1. Call the InfraGenie package feed and install and extract the package using the Genie CLI
    Then it will call main.bicep


