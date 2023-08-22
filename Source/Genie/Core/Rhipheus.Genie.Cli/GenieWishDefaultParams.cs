using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GenieWishDefaultParams
    {
        public async Task ProcessDefaultParameters(string projectName,string getcomponent,string mode,string mainParameterPath)
        {
            string jsonFilePath = $"domain.{projectName}.json";
            var defaultParameters = new
            {
                subscriptionId = "subscription-id",
                resourceGroup = "resource-group-name",
                location = "westus",
                component = getcomponent,
                kind = "kind",
                nameSuffix = "suffix",
                nameSuffixShort = "sfx",
                hypenlessNameSuffix = "hypenfx",
                existingNetworkId = mode == "public" ? "" : "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>",
                subnetName = "exampleSubnet",
                dnsZoneResourceGroupId = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>",               
                skuName = "standard_LRS",
                sqlSku = "standard",
                requiredDedicatedSubnet = "false",
                cider = mode == "isolated" ? "16" : "24"
            };

            string jsonD = JsonConvert.SerializeObject(defaultParameters, Formatting.Indented);
            await File.WriteAllTextAsync(jsonFilePath, jsonD);
            string existingJson = await File.ReadAllTextAsync(mainParameterPath);
            JObject existingData = JObject.Parse(existingJson);
            JObject parameters = (JObject)existingData["parameters"];
            JObject newData = JObject.Parse(jsonD);
            foreach (var property in newData.Properties())
            {
                JObject parameterValue = new JObject();
                parameterValue["value"] = property.Value;
                parameters[property.Name] = parameterValue;
            }
            string updatedJson = JsonConvert.SerializeObject(existingData, Formatting.Indented);
            await File.WriteAllTextAsync(mainParameterPath, updatedJson);
        }
    }
}
