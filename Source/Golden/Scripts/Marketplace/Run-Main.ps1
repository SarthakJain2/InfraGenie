$parameterPath = ".\parameter.json"
$jsonContent = Get-Content -Path $parameterPath -Raw
$jsonObject = $jsonContent | ConvertFrom-Json

$Name = $jsonObject.Name
$TenantId = $jsonObject.TenantId
$ClientId = $jsonObject.ClientId
$ClientSecret = $jsonObject.ClientSecret
$Resource = $jsonObject.Resource
$ModuleName = $jsonObject.ModuleName
$FileName = $jsonObject.FileName
$FileName_216x216 = $jsonObject.FileName_216x216
$FileName_215x115 = $jsonObject.FileName_215x115
$FileName_90x90 = $jsonObject.FileName_90x90
$FileName_48x48 = $jsonObject.FileName_48x48

. .\Get-PartnerAccessToken.ps1
. .\Post-CreateAzureApplication.ps1
. .\Get-Property.ps1
. .\Get-Resellconfiguration.ps1
. .\Post-PlanCreation.ps1
. .\Get-ProductBranchByModule.ps1
. .\Get-OfferProperties.ps1
. .\Put-Properties.ps1
. .\Get-Listing.ps1
. .\Get-ListingByInstanceId.ps1
. .\Put-OfferListing.ps1
. .\Post-Image-216x216.ps1
. .\Post-Image-215x115.ps1
. .\Post-Image-90x90.ps1
. .\Post-Image-48x48.ps1
. .\Get-ImageUpdate.ps1
. .\Put-UpdateImage216x216.ps1
. .\Put-UpdateImage215x115.ps1
. .\Put-UpdateImage90x90.ps1
. .\Put-UpdateImage48x48.ps1
. .\Get-Availabilities.ps1
. .\Get-ProductAvailabilities.ps1
. .\Put-PreviewAudience.ps1
. .\Get-PlanListing.ps1
. .\Get-PlanListingByInstanceId.ps1
. .\Put-PlanListing.ps1
. .\Get-FeatureAvailabilities.ps1
. .\Put-FeatureAvailabilities.ps1
. .\Post-ZipCreate.ps1
. .\Put-UploadZip.ps1
. .\Get-Package.ps1
. .\Get-PackageByInstanceId.ps1
. .\Put-FinalZipUpload.ps1
. .\Post-Reseller.ps1
. .\Post-SubmissionRequest.ps1


$getpaat = Get-PartnerAppAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret -Resource $Resource
$getpaatObject = ConvertFrom-Json $getpaat
$AccessToken = $getpaatObject.access_token

$OfferGuidId = Create-AzureApplication -Name $Name -OfferId $OfferId -AccessToken $AccessToken
Write-Host "Offer GUID ID: $OfferGuidId"

Start-Sleep 10

$PostListing = Create-Listing -ProductId $OfferGuidId -AccessToken $AccessToken

Start-Sleep 10

$Getpbbm = Get-ProductBranchByModule -ProductId $OfferGuidId -ModuleName $ModuleName -AccessToken $AccessToken
$GetpbbmObject = ConvertFrom-Json $Getpbbm
$GetpbbmInstanceIDs = $GetpbbmObject.value[0].currentDraftInstanceID

Start-Sleep 10

$Getproperties = Get-Properties -ProductId $OfferGuidId -AccessToken $AccessToken -PropertyInstanceIDs $GetpbbmInstanceIDs
$GetpropertiesObject = ConvertFrom-Json $Getproperties
$GetpropertiesEtag = $GetpropertiesObject.value[0].'@odata.etag'
Write-Host "Properties eTag ID: $GetpropertiesEtag".Replace('"','').Replace("'","")
$GetpropertiesInstanceIDs = $GetpropertiesObject.value[0].id
Write-Host "Properties Instance ID: $GetpropertiesInstanceIDs"

Start-Sleep 10

$PutProperties = Put-properties -ProductId $OfferGuidId -AccessToken $AccessToken -InstanceID $GetpropertiesInstanceIDs -PropertiesTag $GetpropertiesEtag

Start-Sleep 10

$GetListing = Get-Listings -ProductId $OfferGuidId -AccessToken $AccessToken
$GetListingObject = ConvertFrom-Json $GetListing
$GetListingID = $GetListingObject.value[0].currentDraftInstanceID
$GetListingIDs = $GetListingObject.value[2].currentDraftInstanceID
Write-Host "Offer Listing Instance Id: $GetListingID"
Write-Host "Plan Listing Instance Id: $GetListingIDs"

Start-Sleep 10

$GetListingInstanceId = Get-ListingByInstanceID -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingID $GetListingID
$GetListingInstanceIdObjects = ConvertFrom-Json $GetListingInstanceId
$GetListingEtag = $GetListingInstanceIdObjects.value[0].'@odata.etag'
Write-Host "Offer Listing Etag Value: $GetListingEtag".Replace('"','').Replace("'","")
$GetListingInstanceId = $GetListingInstanceIdObjects.value[0].id
Write-Host "Offer Listing Instance Id: $GetListingInstanceId"

Start-Sleep 10

Put-OfferListing -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -GetListingEtag $GetListingEtag

Start-Sleep 10

$216x216Image = Post-Image-216x216 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -FileName_216x216 $FileName_216x216
$PostImage216x216Object = ConvertFrom-Json $216x216Image
$PostImage216x216 = $PostImage216x216Object.fileSasUri
& "..\..\Assets\azcopy.exe" copy "..\..\Assets\$FileName_216x216" $PostImage216x216

Start-Sleep 10

$215x115Image = Post-Image-215x115 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -FileName_215x115 $FileName_215x115
$PostImage215x115Object = ConvertFrom-Json $215x115Image
$PostImage215x115 = $PostImage215x115Object.fileSasUri
& "..\..\Assets\azcopy.exe" copy "..\..\Assets\$FileName_215x115" $PostImage215x115

Start-Sleep 10

$90x90Image = Post-Image-90x90 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -FileName_90x90 $FileName_90x90
$PostImage90x90Object = ConvertFrom-Json $90x90Image
$PostImage90x90 = $PostImage90x90Object.fileSasUri
& "..\..\Assets\azcopy.exe" copy "..\..\Assets\$FileName_90x90" $PostImage90x90

Start-Sleep 10

$48x48Image = Post-Image-48x48 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -FileName_48x48 $FileName_48x48
$PostImage48x48Object = ConvertFrom-Json $48x48Image
$PostImage48x48 = $PostImage48x48Object.fileSasUri
& "..\..\Assets\azcopy.exe" copy "..\..\Assets\$FileName_48x48" $PostImage48x48

Start-Sleep 10

$UpdatedImageIds = Get-ImagesByInstanceID -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId 
$get216x216jsonObjects = ConvertFrom-Json $UpdatedImageIds
$etag216x216 = $get216x216jsonObjects.value[0].'@odata.etag'
Write-Host "Etag 216x216: $etag216x216".Replace('"','').Replace("'","")
$id216x216 = $get216x216jsonObjects.value[0].id
Write-Host "ProjectID 216x216: $id216x216"

Start-Sleep 10

$updateimage216x216 = Put-UpdateImage216x216 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -Updatedid "$id216x216" -FilesasUri $PostImage216x216 -updatedeTag "$etag216x216" -FileName_216x216 $FileName_216x216
Write-Host "$updateimage216x216"
$get215x115jsonObjects = ConvertFrom-Json $UpdatedImageIds
$etag215x115 = $get215x115jsonObjects.value[1].'@odata.etag'
Write-Host "Etag 215x115: $etag215x115".Replace('"','').Replace("'","")
$id215x115 = $get215x115jsonObjects.value[1].id
Write-Host "ProjectID 215x115: $id215x115"

Start-Sleep 10

$updateimage215x115 = Put-UpdateImage215x115 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -Updatedid "$id215x115" -FilesasUri $PostImage215x115 -updatedeTag "$etag215x115" -FileName_215x115 $FileName_215x115
Write-Host "$updateimage215x115"
$get90x90jsonObjects = ConvertFrom-Json $UpdatedImageIds
$etag90x90 = $get90x90jsonObjects.value[2].'@odata.etag'
Write-Host "Etag 90x90: $etag90x90".Replace('"','').Replace("'","")
$id90x90 = $get90x90jsonObjects.value[2].id
Write-Host "ProjectID 90x90: $id90x90"

Start-Sleep 10

$updateimage90x90 = Put-UpdateImage90x90 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -Updatedid "$id90x90" -FilesasUri $PostImage90x90 -updatedeTag "$etag90x90" -FileName_90x90 $FileName_90x90
Write-Host "$updateimage90x90"
$get48x48jsonObjects = ConvertFrom-Json $UpdatedImageIds
$etag48x48 = $get48x48jsonObjects.value[3].'@odata.etag'
Write-Host "Etag 48x48: $etag48x48".Replace('"','').Replace("'","")
$id48x48 = $get48x48jsonObjects.value[3].id
Write-Host "ProjectID 48x48: $id48x48"

Start-Sleep 10

$updateimage48x48 = Put-UpdateImage48x48 -ProductId $OfferGuidId -AccessToken $AccessToken -GetListingInstanceId $GetListingInstanceId -Updatedid "$id48x48" -FilesasUri $PostImage48x48 -updatedeTag "$etag48x48" -FileName_48x48 $FileName_48x48
Write-Host "$updateimage48x48"

Start-Sleep 10

$GetAvailability = Get-Availability -ProductId $OfferGuidId -AccessToken $AccessToken 
$GetAvailabilityObject = ConvertFrom-Json $GetAvailability
$GetAvailabilityIDs = $GetAvailabilityObject.value[0].currentDraftInstanceID
$GetAvailabilityplanIDs = $GetAvailabilityObject.value[1].currentDraftInstanceID
$GetAvailabilityvariantIDs = $GetAvailabilityObject.value[1].variantID
Write-Host "Availability Offer InstanceId: $GetAvailabilityIDs"
Write-Host "Availability Plan InstanceId: $GetAvailabilityplanIDs"
Write-Host "Variant InstanceId: $GetAvailabilityvariantIDs"

$GetProductAvailabilities = Get-ProductAvailabilities -ProductId $OfferGuidId -AccessToken $AccessToken -GetAvailabilityIDs $GetAvailabilityIDs
$GetProductAvailabilitiesObject = ConvertFrom-Json $GetProductAvailabilities
$ProductAvailabilitiesInstancetag = $GetProductAvailabilitiesObject.value[0]."@odata.etag"
Write-Host "Product Availability Instanceid: $ProductAvailabilitiesInstancetag".Replace('"','').Replace("'","")

$PutAzurePreviewAudience = Put-AzurePreviewAudience -ProductId $OfferGuidId -AccessToken $AccessToken -ProductAvailabilitiesInstancetag $ProductAvailabilitiesInstancetag -GetAvailabilityIDs $GetAvailabilityIDs

Start-Sleep 10

$GetPlanListing = Get-PlanListings -ProductId $OfferGuidId -AccessToken $AccessToken
$GetPlanListingObjects = ConvertFrom-Json $GetPlanListing
$GetOfferListingIDs = $GetPlanListingObjects.value[0].currentDraftInstanceID
$GetPlanListingIDs = $GetPlanListingObjects.value[2].currentDraftInstanceID
Write-Host "Offer Listing instance id: $GetOfferListingIDs"
Write-Host "Plan listing InstanceID: $GetPlanListingIDs"

Start-Sleep 10

$GetListingInstanceId = Get-PlanListingByInstanceId -ProductId $OfferGuidId -AccessToken $AccessToken -InstanceID $GetPlanListingIDs
$GetListingInstanceIdObjects = ConvertFrom-Json $GetListingInstanceId
$PlanListingetagIDs = $GetListingInstanceIdObjects.value[0].'@odata.etag'
Write-Host "Plan Listing eTag Value: $PlanListingetagIDs".Replace('"','').Replace("'","")
$PlanListingIDs = $GetListingInstanceIdObjects.value[0].id
Write-Host "Plan Listing Instance ID: $PlanListingIDs"

Start-Sleep 10

$PutPlanListing = Put-PlanListing -ProductId $OfferGuidId -AccessToken $AccessToken -PlanListingIDs $PlanListingIDs -PlanListingetagIDs $PlanListingetagIDs

$GetFeatureInstance = Get-FeatureAvailabilitiesByInstanceID -ProductId $OfferGuidId -AccessToken $AccessToken -GetAvailabilityplanIDs $GetAvailabilityplanIDs 
$GetFeatureInstancejson = ConvertFrom-Json $GetFeatureInstance
$GetFeatureInstanceeTag = $GetFeatureInstancejson.value[0].'@odata.etag'
Write-Host "Feature eTag value: $GetFeatureInstanceeTag".Replace('"','').Replace("'","")
$GetFeatureInstanceIDs = $GetFeatureInstancejson.value[0].id
Write-Host "FeatureID InstanceId: $GetFeatureInstanceIDs"

Start-Sleep 10

$putplanjson = Put-FeatureAvailabilities -ProductId $OfferGuidId -AccessToken $AccessToken -GetFeatureInstanceeTag $GetFeatureInstanceeTag -GetFeatureInstanceIDs $GetFeatureInstanceIDs

Start-Sleep 20

$putzipFile = Create-ZipCreate -ProductID $OfferGuidId -AccessToken $AccessToken -FileName $FileName
Write-Host "$putzipFile"

Start-Sleep 20

$putzipjsonObjects = ConvertFrom-Json $putzipFile
$putzipetagIDs = $putzipjsonObjects.'@odata.etag'
Write-Host "eTag: $putzipetagIDs".Replace('"','').Replace("'","")
$putzipIDs = $putzipjsonObjects.id
Write-Host "ID: $putzipIDs"
$posturizip = $putzipjsonObjects.fileSasUri
Write-Host "$posturizip"
& "..\..\Assets\azcopy.exe" copy "..\..\Assets\$FileName" $posturizip

Start-Sleep 20

$zipupdateFile = Create-ZipUpload -ProductID $OfferGuidId -AccessToken $AccessToken -putzipIDs $putzipIDs -putzipetagIDs $putzipetagIDs -posturizip $posturizip -FileName $FileName
Write-Host "$zipupdateFile"

Start-Sleep 10

$getpackageFile = Get-Package -ProductId $OfferGuidId -AccessToken $AccessToken
$getpackagejsonObjects = ConvertFrom-Json $getpackageFile
$index=0
$rindex=1
foreach($obj in $getpackagejsonObjects.value){
    if ($obj.PSObject.Properties.Name -contains "variantID") {
        break;
    }
    $index++
}
if ($index -gt 1) {
    Write-Error "Variantid not found in response"
}
else {
    $rindex=($index -eq 0)?1:0
}
$getpackageofferIDs = $getpackagejsonObjects.value[$rindex].currentDraftInstanceID
$getpackageIDs = $getpackagejsonObjects.value[$index].currentDraftInstanceID
Write-Host "Offer package ID: $getpackageofferIDs"
Write-Host "Plan package ID: $getpackageIDs"

Start-Sleep 50

$getpackagebyinstance = Get-PackageByInstanceId -ProductId $OfferGuidId -AccessToken $AccessToken -getpackageIDs $getpackageIDs
$getpackageObjects = ConvertFrom-Json $getpackagebyinstance
$packageinstanceetagIDs = $getpackageObjects.value[0].'@odata.etag'
Write-Host "Package eTag value: $packageinstanceetagIDs".Replace('"','').Replace("'","")
$getpackageinstanceIDs = $getpackageObjects.value[0].id
Write-Host "Get packageID: $getpackageinstanceIDs"

Start-Sleep 20

$FinalzipFile = Create-ZipFinalUpload -ProductId $OfferGuidId -AccessToken $AccessToken -getpackageIds $getpackageinstanceIDs -packageinstanceetagIDs "$packageinstanceetagIDs" -putzipIDs "$putzipIDs"
Write-Host "$FinalzipFile"

Start-Sleep 10

$getprop = Get-Property -ProductId $OfferGuidId -AccessToken $AccessToken
$getjsonProp = ConvertFrom-Json $getprop
$getpropid = $getjsonProp.value[0].currentDraftInstanceID
Write-Host "Property instance id: $getpropid"

Start-Sleep 10

$getresell = Get-Resellconfiguration -ProductId $OfferGuidId -AccessToken $AccessToken
$getjsonResell = ConvertFrom-Json $getresell
$getresellid = $getjsonResell.value[0].currentDraftInstanceID
Write-Host "Reseller instance id: $getresellid"

$Reseller = Create-Reseller -ProductId $OfferGuidId -AccessToken $AccessToken

Start-Sleep 30

Post-Submission -ProductId $OfferGuidId -AccessToken $AccessToken -GetAvailabilityIDs $GetAvailabilityIDs -GetListingID $GetListingID -getpackageofferIDs $getpackageofferIDs -getpropid $getpropid -getresellid $getresellid -GetAvailabilityvariantIDs $GetAvailabilityvariantIDs -GetAvailabilityplanIDs $GetAvailabilityplanIDs -GetListingIDs $GetListingIDs -getpackageIDs $getpackageIDs

