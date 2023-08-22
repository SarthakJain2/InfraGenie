$jsonFilePath = "D:\InfraGenie-1\Package\Golden\Golden\Scripts\Marketplace\parameter.json"
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$jsonObject = $jsonContent | ConvertFrom-Json

$name = $jsonObject.name
$TenantId = $jsonObject.TenantId
$ClientId = $jsonObject.ClientId
$ClientSecret = $jsonObject.ClientSecret
$Resource = $jsonObject.Resource
$moduleName = $jsonObject.moduleName


. .\Get-PartnerAccessToken.ps1

. .\Post-CreateAzureApplication.ps1
. .\Post-PlanCreation.ps1
. .\Get-ProductBranchByModule.ps1
. .\Get-Properties.ps1
. .\Put-AzureProperty.ps1
. .\Get-Listing.ps1
. .\Get-ListingByInstanceID.ps1

. .\Put-OfferListings.ps1
. .\Post-Image-216x216.ps1
. .\Put-UpdateImage216x216.ps1
. .\Post-Image-215x115.ps1
. .\Put-UpdateImage215x115.ps1
. .\Post-Image-90x90.ps1
. .\Put-UpdateImage90x90.ps1
. .\Post-Image-48x48.ps1
. .\Put-UpdateImage48x48.ps1
. .\Get-ImageUpdate.ps1
. .\Get-Availability.ps1
. .\Get-ProductAvailabilities.ps1

. .\Put-AzurePreviewAudience.ps1
. .\Get-PlanListing.ps1
. .\Get-PlanListingByInstanceID.ps1
. .\Put-PlanListing.ps1
. .\Post-ZipCreate.ps1
. .\Put-UploadZip.ps1
. .\Get-Package.ps1
. .\Get-PackageInstanceId.ps1
. .\Put-FinalZipUpload.ps1
. .\Post-Reseller.ps1


$json = Get-PartnerAppAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret -Resource $Resource


$jsonObject = ConvertFrom-Json $json
$AccessToken = $jsonObject.access_token


$ProductOfferId = Create-AzureApplication -name $name -offerId $offerId

Write-Host "Product Id: $ProductOfferId"

Start-Sleep -Seconds 10

$planlisting = Create-Listing -ProductID "$ProductOfferId" -token "$AccessToken"

Start-Sleep -Seconds 20

$property = Get-ProductBranchByModule -productId "$ProductOfferId" -moduleName $moduleName -token "$AccessToken"

$propertyObject = ConvertFrom-Json $property
$propertyInstanceIDs = $propertyObject.value[0].currentDraftInstanceID

Start-Sleep -Seconds 20

$getjson = Get-properties -ProductId "$ProductOfferId" -token "$AccessToken" -propertyinstanceIDs $propertyInstanceIDs

$getjsonObject = ConvertFrom-Json $getjson
$currentDraftInstanceIDs1 = $getjsonObject.value[0].'@odata.etag'
Write-Host "eTag value: $currentDraftInstanceIDs1".Replace('"','').Replace("'","")
$currentDraftInstanceIDs2 = $getjsonObject.value[0].id
Write-Host "ProjectID: $currentDraftInstanceIDs2"

Start-Sleep -Seconds 20

$putjson = Put-properties -ProductId "$ProductOfferId" -token "$AccessToken" -InstanceID "$currentDraftInstanceIDs2"

Start-Sleep -Seconds 20

$getlisting = Get-Listings -ProductId "$ProductOfferId" -token "$AccessToken" 

$getlistingObject = ConvertFrom-Json $getlisting
$getlistingIDs = $getlistingObject.value[0].currentDraftInstanceID

Write-Host "Listing instance id: $getlistingIDs"

Start-Sleep -Seconds 20

$getlistinginstanceid = Get-ListingByInstanceID -ProductId "$ProductOfferId" -token "$AccessToken" -InstanceID $getlistingIDs

$getjsonObjects = ConvertFrom-Json $getlistinginstanceid
$currentlistingIDs1 = $getjsonObjects.value[0].'@odata.etag'
Write-Host "eTag value: $currentlistingIDs1".Replace('"','').Replace("'","")
$currentlistingIDs = $getjsonObjects.value[0].id
Write-Host "ProjectID: $currentlistingIDs"

Start-Sleep -Seconds 20

$putlistingid = Put-offerlisting -ProductId "$ProductOfferId" -token "$AccessToken" -currentlistingids "$currentlistingIDs" -currentlistingids1 "$currentlistingIDs1"

Start-Sleep -Seconds 20

$216x216image = Post-Image-216x216 -ProductId "$ProductOfferId" -token "$AccessToken" -currentlistingids "$currentlistingIDs"

$getimage216x216jsonObject = ConvertFrom-Json $216x216image

$getimage216x216 = $getimage216x216jsonObject.fileSasUri

& "D:\InfraGenie-1\Package\Golden\Golden\Assets\azcopy.exe" copy "D:\InfraGenie-1\Package\Golden\Golden\Assets\Genie_ai_216x216.png" $getimage216x216

Start-Sleep -Seconds 20

$215x115image = Post-Image-215x115 -ProductId "$ProductOfferId" -token "$AccessToken" -currentlistingids "$currentlistingIDs"
 
$getimage215x115jsonObject = ConvertFrom-Json $215x115image

$getimage215x115 = $getimage215x115jsonObject.fileSasUri

& "D:\InfraGenie-1\Package\Golden\Golden\Assets\azcopy.exe" copy "D:\InfraGenie-1\Package\Golden\Golden\Assets\Genie_ai_215x115.png" $getimage215x115

Start-Sleep -Seconds 20

$90x90image = Post-Image-90x90 -ProductId "$ProductOfferId" -token "$AccessToken" -currentlistingids "$currentlistingIDs"

$getimage90x90jsonObject = ConvertFrom-Json $90x90image

$getimage90x90 = $getimage90x90jsonObject.fileSasUri

& "D:\InfraGenie-1\Package\Golden\Golden\Assets\azcopy.exe" copy "D:\InfraGenie-1\Package\Golden\Golden\Assets\Genie_ai_90x90.png" $getimage90x90

Start-Sleep -Seconds 20

$48x48image = Post-Image-48x48 -ProductId "$ProductOfferId" -token "$AccessToken" -currentlistingids "$currentlistingIDs"

$getimage48x48jsonObject = ConvertFrom-Json $48x48image

$getimage48x48 = $getimage48x48jsonObject.fileSasUri

& "D:\InfraGenie-1\Package\Golden\Golden\Assets\azcopy.exe" copy "D:\InfraGenie-1\Package\Golden\Golden\Assets\Genie_ai_48x48.png" $getimage48x48

Start-Sleep -Seconds 20

$updatedimageids = Get-ImagesByInstanceID -ProductId "$ProductOfferId" -token "$AccessToken" -InstanceID "$currentlistingIDs"

$get216x216jsonObjects = ConvertFrom-Json $updatedimageids
$etag216x216 = $get216x216jsonObjects.value[0].'@odata.etag'
Write-Host "Etag 216x216: $etag216x216".Replace('"','').Replace("'","")
$id216x216 = $get216x216jsonObjects.value[0].id
Write-Host "ProjectID 216x216: $id216x216"

Start-Sleep -Seconds 10

$updateimage216x216 = Put-UpdateImage216x216 -token "$AccessToken" -ProductID "$ProductOfferId" -InstanceID "$currentlistingIDs" -Updatedid "$id216x216" -FilesasUri "$getimage216x216" -updatedeTag "$etag216x216"
Write-Host "$updateimage216x216"

$get215x115jsonObjects = ConvertFrom-Json $updatedimageids
$etag215x115 = $get215x115jsonObjects.value[1].'@odata.etag'
Write-Host "Etag 215x115: $etag215x115".Replace('"','').Replace("'","")
$id215x115 = $get215x115jsonObjects.value[1].id
Write-Host "ProjectID 215x115: $id215x115"

Start-Sleep -Seconds 10

$updateimage215x115 = Put-UpdateImage215x115 -token "$AccessToken" -ProductID "$ProductOfferId" -InstanceID "$currentlistingIDs" -Updatedid "$id215x115" -FilesasUri "$getimage215x115" -updatedeTag "$etag215x115"
Write-Host "$updateimage215x115"

$get90x90jsonObjects = ConvertFrom-Json $updatedimageids
$etag90x90 = $get90x90jsonObjects.value[2].'@odata.etag'
Write-Host "Etag 90x90: $etag90x90".Replace('"','').Replace("'","")
$id90x90 = $get90x90jsonObjects.value[2].id
Write-Host "ProjectID 90x90: $id90x90"

Start-Sleep -Seconds 10

$updateimage90x90 = Put-UpdateImage90x90 -token "$AccessToken" -ProductID "$ProductOfferId" -InstanceID "$currentlistingIDs" -Updatedid "$id90x90" -FilesasUri "$getimage90x90" -updatedeTag "$etag90x90"
Write-Host "$updateimage90x90"

$get48x48jsonObjects = ConvertFrom-Json $updatedimageids
$etag48x48 = $get48x48jsonObjects.value[3].'@odata.etag'
Write-Host "Etag 48x48: $etag48x48".Replace('"','').Replace("'","")
$id48x48 = $get48x48jsonObjects.value[3].id
Write-Host "ProjectID 48x48: $id48x48"

Start-Sleep -Seconds 10

$updateimage48x48 = Put-UpdateImage48x48 -token "$AccessToken" -ProductID "$ProductOfferId" -InstanceID "$currentlistingIDs" -Updatedid "$id48x48" -FilesasUri "$getimage48x48" -updatedeTag "$etag48x48"
Write-Host "$updateimage48x48"

Start-Sleep -Seconds 20


$getjson = Get-Availability -ProductId "$ProductOfferId" -token "$AccessToken" 



$getjsonObject = ConvertFrom-Json $getjson

$getIDs = $getjsonObject.value[0].currentDraftInstanceID

Write-Host "Availability instance id: $getIDs"

Start-Sleep -Seconds 20

$getjson1 = Get-ProductAvailabilities -ProductId "$ProductOfferId" -token "$AccessToken" -getids "$getIDs"


$getjson12Object = ConvertFrom-Json $getjson1
$previewInstancetag = $getjson12Object.value[0]."@odata.etag"


Write-Host "Preview Instanceid: $previewInstancetag".Replace('"','').Replace("'","")


Start-Sleep -Seconds 20

$json13= Put-AzurePreviewAudience -ProductId "$ProductOfferId" -token "$AccessToken" -previewinstancetag "$previewInstancetag" -getids "$getIDs"



Start-Sleep -Seconds 05

$getplanlisting = Get-PlanListings -ProductId "$ProductOfferId" -token "$AccessToken"

$getplanlistingjsonObjects = ConvertFrom-Json $getplanlisting
$planlistingIDs = $getplanlistingjsonObjects.value[2].currentDraftInstanceID
Write-Host "PlanlistingInstanceID: $planlistingIDs"

Start-Sleep -Seconds 05

$getlistinginstanceid = Get-PlanListingByInstanceId -ProductId "$ProductOfferId" -token "$AccessToken" -InstanceID "$planlistingIDs"

$getplaninstancejsonObjects = ConvertFrom-Json $getlistinginstanceid
$listingetagIDs = $getplaninstancejsonObjects.value[0].'@odata.etag'
Write-Host "eTag: $listingetagIDs".Replace('"','').Replace("'","")
$listingIDs = $getplaninstancejsonObjects.value[0].id
Write-Host "ID: $listingIDs"

Start-Sleep -Seconds 10

$putplanjson = Put-PlanList -ProductId "$ProductOfferId" -token "$AccessToken" -currentlistingids "$listingIDs" -currentlistingids1 "$listingetagIDs"

Write-Host "$putplanjson"

$putzipFile = Create-ZipCreate -ProductID "$ProductOfferId" -token "$AccessToken"

Write-Host "$putzipFile"

Start-Sleep 05

$putzipjsonObjects = ConvertFrom-Json $putzipFile
$putzipetagIDs = $putzipjsonObjects.'@odata.etag'
Write-Host "eTag: $putzipetagIDs".Replace('"','').Replace("'","")
$putzipIDs = $putzipjsonObjects.id
Write-Host "ID: $putzipIDs"
$posturizip = $putzipjsonObjects.fileSasUri
Write-Host "$posturizip"


& "D:\InfraGenie-1\Package\Golden\Golden\Assets\azcopy.exe" copy "D:\InfraGenie-1\Package\Golden\Golden\Assets\ama-helloworlds.zip" $posturizip


$zipupdateFile = Create-ZipUpload -ProductID "$ProductOfferId" -token "$AccessToken" -currentlistingids "$putzipIDs" -currentlistingids1 "$putzipetagIDs" -FilesasUri "$posturizip"

Write-Host "$zipupdateFile"

$getpackageFile = Get-Package -ProductId "$ProductOfferId" -token "$AccessToken"

$getpackagejsonObjects = ConvertFrom-Json $getpackageFile

$getpackageIDs = $getpackagejsonObjects.value[1].currentDraftInstanceID
Write-Host "ID: $getpackageIDs"

Start-Sleep 25

$getpackageid = Get-PackageByInstanceId -ProductId "$ProductOfferId" -token "$AccessToken" -InstanceID "$getpackageIDs"

$getpackagejsonObjects = ConvertFrom-Json $getpackageid
$packageinstanceetagIDs = $getpackagejsonObjects.value[0].'@odata.etag'
Write-Host "Package eTag value: $packageinstanceetagIDs".Replace('"','').Replace("'","")
$getpackageinstanceIDs = $getpackagejsonObjects.value[0].id
Write-Host "Get packageID: $getpackageinstanceIDs"

Start-Sleep 20

$FinalzipFile = Create-ZipFinalUpload -ProductID "$ProductOfferId" -token "$AccessToken" -getpackageIds $getpackageinstanceIDs -packageinstanceetagIDs "$packageinstanceetagIDs" -putzipIDs "$putzipIDs"

Write-Host "$FinalzipFile"

$reseller = Create-Reseller -ProductID "$ProductOfferId" -token "$AccessToken"










