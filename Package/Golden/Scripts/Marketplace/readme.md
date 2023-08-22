# get access token
Get-PartnerAppAccessToken -TenantId "3ac1585b-156d-4c6e-8ffa-8b8440611f7d" -ClientId "bc3703b6-e592-4140-aaaf-d166236ed64c" -ClientSecret "18.8Q~h_fXnX6jTKmblppds4zsQabfw1gtOmOcpn" -Resource "https://api.partner.microsoft.com"

# creation plan 

*first we need to create plan overview 
post https://api.partner.microsoft.com/v1.0/ingestion/products/b4a0b3b3-cbc0-41ca-89e4-65e6d1b144cb/variants

*then after that get the availability id then use put method
get
https://api.partner.microsoft.com/v1.0/ingestion/products/{{product_id}}/branches/getByModule(module=Availability)
get
https://api.partner.microsoft.com/v1.0/ingestion/products/{{product_id}}/featureAvailabilities/getByInstanceID(instanceID=2152924500014892651)
put
https://api.partner.microsoft.com/v1.0/ingestion/products/{{product_id}}/featureAvailabilities/2152924500014892651



# Write-Host "$json13"

# Start-Sleep -Seconds 20

# $getjsonn = Get-Listing -ProductId "$ProductOfferId" -token "$AccessToken" 

# Write-Host "$getjsonn"

# $getlistingjsonObject = ConvertFrom-Json $getlistingjson

# $getlistingIDs = $getlistingjsonObject.value[0].currentDraftInstanceID

# Write-Host "$getlistingIDs"



