using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GenieWishServiceSpec
    {
        public async Task ProcessServiceSpecParameters(string projectName, string getenv)
        {
            string jsonServiceFilePath = $"domain.{projectName}.{getenv}.json";
            var serviceSpecific = new
            {
                env = getenv,
                pricingTier = "Basic",
                instanceCount = 1,
                environmentVariables = new Dictionary<string, string>
                    {
                        { "Variable1", "Value1" },
                        { "Variable2", "Value2" },
                    }
            };
            string json = JsonConvert.SerializeObject(serviceSpecific, Formatting.Indented);
            await File.WriteAllTextAsync(jsonServiceFilePath, json);
        }
    }
}
