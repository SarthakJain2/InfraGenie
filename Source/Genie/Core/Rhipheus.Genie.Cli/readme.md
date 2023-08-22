To execute the genie cli from solution,
use command as,
(for example) 
dotnet run genie --server,
dotnet run genie login azure --tenant-id 3ac1585b-156d-4c6e-8ffa-8b8440611f7d --client-id bc3703b6-e592-4140-aaaf-d166236ed64c --client-secret 18.8Q~h_fXnX6jTKmblppds4zsQabfw1gtOmOcpn
genie prep --folder-name app-service-golden --project-name asppoc1 --package-name Golden
-------------------------------------------------------

To execute the genie cli from exe (.\genie.exe)
use the command as,
(go to the path where .exe is stored) then use command as 
genie --server
genie login azure --tenant-id 3ac1585b-156d-4c6e-8ffa-8b8440611f7d --client-id bc3703b6-e592-4140-aaaf-d166236ed64c --client-secret 18.8Q~h_fXnX6jTKmblppds4zsQabfw1gtOmOcpn
genie prep --folder-name app-service-golden --project-name asppoc1 --package-name Golden
---------------------------------------

genie config command (Executes only one time)
genie config --feed-name "InfraGenie" --feed-url "https://pkgs.dev.azure.com/rhipheus/_packaging/InfraGenie/nuget/v3/index.json" --package-name "infra" --package-url "https://pkgs.dev.azure.com/rhipheus/_apis/packaging/feeds/InfraGenie/nuget/packages/Rhipheus.InfraGenie.Infra/Versions/1.0.0-CI-20230723-133035/content?api-version=7.0-preview.1"
genie config --feed-name "InfraGenie" --feed-url "https://pkgs.dev.azure.com/rhipheus/_packaging/InfraGenie/nuget/v3/index.json" --package-name "golden" --package-url "https://pkgs.dev.azure.com/rhipheus/_apis/packaging/feeds/InfraGenie/nuget/packages/Rhipheus.InfraGenie.Golden/Versions/1.0.0-CI-20230723-133254/content?api-version=7.0-preview.1"
genie config --feed-name "InfraGenie" --feed-url "https://pkgs.dev.azure.com/rhipheus/_packaging/InfraGenie/nuget/v3/index.json" --package-name "tools" --package-url "https://pkgs.dev.azure.com/rhipheus/_apis/packaging/feeds/InfraGenie/nuget/packages/Rhipheus.InfraGenie.Tools/Versions/1.0.0-CI-20230722-165943/content?api-version=7.0-preview.1"
--------------------------------------------------

genie Download command
genie download --folder-name example1
genie download
------------------------------

genie wish command
genie wish --services-list
genie wish --services storage-account,sql --mode public --env dev
---------------------------------------

genie upgrade command
genie upgrade