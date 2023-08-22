# Link Command
.\link.ps1 -SourceFolder .\golden -TargetFolder .\infragenie-core
.\Relink.ps1 -SourceFolder .\golden -TargetFolder .\infragenie-core

# Markeplace Statup script

.\marketplace.ps1 -ExistingNetworkId "/subscriptions/ece96d80-c934-4839-bb90-c2f9ff7c94f9/resourceGroups/rg-core-dev-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-spoknet-dev-001" -NetworkingType internal
