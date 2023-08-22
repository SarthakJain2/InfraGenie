using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GenieWishMainBicepModifycs
    {
        public async Task ProcessMainBicep(string env,string projectName,string services,string mainBicepPath, string mainPath)
        {
            string contents = await File.ReadAllTextAsync(mainBicepPath);
            string pattern = @"(module \w+ '.*?\.bicep' = if \(.*?\) \{.*?})";
            Regex regex = new Regex(pattern, RegexOptions.Singleline);
            Match match = regex.Match(contents);
            string[] serviceModules = services.Split(',');
            if (match.Success)
            {
                string moduleBlock = match.Value;
                string[] blocks = moduleBlock.Split("\nmodule ", StringSplitOptions.None);
                string originalModule = blocks[0];
                originalModule = Regex.Replace(originalModule, @"params:\s*\{(.|\n)*?\}", "params: {}", RegexOptions.Singleline);

                for (int i = 0; i < serviceModules.Length; i++)
                {
                    string firstModule = originalModule;
                    string serviceNameWithoutHyphen = serviceModules[i].Replace("-", "").Replace(".", "");
                    string moduleSignature = $"module {serviceNameWithoutHyphen}";
                   /* if (contents.Contains(moduleSignature))
                    {
                        Console.WriteLine($"Module {serviceNameWithoutHyphen} is already present in the main file");
                        Console.WriteLine($"Skipping module {serviceNameWithoutHyphen}.");
                        continue;
                    }*/
                    firstModule = Regex.Replace(firstModule, "module \\w+", $"module {serviceNameWithoutHyphen}");                    
                    firstModule = Regex.Replace(firstModule, "(?<='[^']/'[^']/)*global(?=\\.bicep')", $"{serviceModules[i]}");
                    firstModule = Regex.Replace(firstModule, "(name: ').*(')", $"$1{serviceModules[i]}$2");
                    Regex pathRegex = new Regex("(?<=').*?(?=\\.bicep')");
                    Match pathMatch = pathRegex.Match(firstModule);                    

                    if (!pathMatch.Success)
                    {
                        Console.WriteLine($"Failed to extract module path for service {serviceModules[i]}.");
                        continue;
                    }
                    string mainBicepContent = await File.ReadAllTextAsync(mainBicepPath);
                    Dictionary<string, string> mainParameters = await ExtractBicepParameters(mainBicepPath);
                    HashSet<string> mainVariables = await ExtractBicepVariables(mainBicepPath);


                    string modulePath = pathMatch.Value;
                    string bicepFilePath = Path.Combine(mainPath, modulePath + ".bicep");
                    Dictionary<string, string> parameters = await ExtractBicepParameters(bicepFilePath);

                    StringBuilder newModuleParams = new StringBuilder();
                    foreach (var param in parameters)
                    {
                        string paramName = param.Key;
                        string paramType = param.Value;

                        if (!mainParameters.ContainsKey(paramName) && !mainVariables.Contains(paramName))
                        {
                            if (paramName.Contains("Password"))
                            {                                
                                mainBicepContent = "@secure()"+"\n"+$"param {paramName} {paramType}\n" + mainBicepContent;
                            }
                            else
                            {
                                mainBicepContent = $"param {paramName} {paramType}\n" + mainBicepContent;
                                mainParameters.Add(paramName, paramType);
                            }
                           
                        }

                        string jsonPath = "domain.All.json"; //$"domain.{projectName}.json"; //domain.All.json;
                        string jsonContent = await File.ReadAllTextAsync(jsonPath);
                        JObject jsonValues = JObject.Parse(jsonContent);

                        string jsonServicePath = "domain.ServiceSpec.json";// $"domain.{projectName}.{env}.json";// "domain.ServiceSpec.json";
                        string jsonServiceParam = await File.ReadAllTextAsync(jsonServicePath);
                        JObject jsonServiceValues = JObject.Parse(jsonServiceParam);
                        string value = FindValueInJObject(jsonValues, paramName) ?? FindValueInJObject(jsonServiceValues, paramName);
                        if (value != null)
                        {                            
                            string formattedValue;
                            if (paramType == "bool")
                            {
                                formattedValue = $"{value}";
                            }
                            else if (paramType == "string" )
                            {
                                formattedValue = $"'{value}'";
                            }
                            else if (paramType == "array")
                            {
                                var arrValue = value.ToString().Split(',');
                                formattedValue = string.Join(',', arrValue.Select(x => $"{x.Trim()}"));    

                            }
                            else
                            {
                                formattedValue = $"'{value}'"; 
                            }

                            newModuleParams.AppendLine($"   {paramName}: {formattedValue}");
                        }           

                        else
                        {
                            newModuleParams.AppendLine($"   {paramName}: {paramName}");
                        }
                        
                    }                    
                    int paramBlockStart = firstModule.IndexOf("params: {");
                    int paramBlockEnd = firstModule.IndexOf("}", paramBlockStart);
                    if (paramBlockStart != -1 && paramBlockEnd != -1)
                    {
                        firstModule = firstModule.Insert(paramBlockEnd, newModuleParams.ToString());
                    }
                    mainBicepContent += "\n" + firstModule;
                    await File.WriteAllTextAsync(mainBicepPath, mainBicepContent);
                    Console.WriteLine("main modified with new services");

                }
            }
            else
            {
                Console.WriteLine("No module found in the file.");
            }
        }
        private string FindValueInJObject(JObject jobject, string paramName)
        {
            foreach (var section in jobject)
            {
                if (section.Value is JObject nestedObject)
                {
                    if (nestedObject[paramName] != null)
                    {
                        return nestedObject[paramName].ToString();
                    }
                }
            }
            return null;
        }
        private static async Task<Dictionary<string, string>> ExtractBicepParameters(string filePath)
        {
            Dictionary<string, string> parameters = new Dictionary<string, string>();
            string content = await File.ReadAllTextAsync(filePath);
            var lines = content.Split('\n');

            foreach (var line in lines)
            {
                if (line.StartsWith("param"))
                {
                    var parts = line.Split(' ');
                    if (parts.Length >= 3)
                    {
                        string paramName = parts[1];
                        string paramType = parts[2];
                        parameters.Add(paramName, paramType);
                    }
                }
            }

            return parameters;
        }
        async Task<HashSet<string>> ExtractBicepVariables(string path)
        {           
            HashSet<string> variables = new HashSet<string>();
            string[] lines = await File.ReadAllLinesAsync(path);
            foreach (string line in lines)
            {
                if (line.Trim().StartsWith("var "))
                {                    
                    string varName = line.Split(' ')[1];
                    variables.Add(varName);
                }
            }
            return variables;
        }


    }
}
