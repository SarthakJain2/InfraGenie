using Rhipheus.Genie.Core;
using System;
using System.Collections.Generic;
using System.IO.Compression;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
   
    public class GenieDownloadAndExtract
    {
        
        public string packagePath;
        public string packageUrl;
        public AppSettings _appSettings;
        public string extractPath;
        public string ConfigFilePath;
        public object PatToken;       

        public GenieDownloadAndExtract(AppSettings appSettings,string extractPath, string PatToken, string ConfigFilePath)
        {
            _appSettings = appSettings;
            this.extractPath = extractPath;
            this.PatToken = PatToken;
            this.ConfigFilePath = ConfigFilePath;
           
        }

        public async Task DownloadAndExtract(string folderName, string packageName)
        {
            Config config = null;
            try
            {
                if (File.Exists(ConfigFilePath))
                {
                    var existingJson = File.ReadAllText(ConfigFilePath);
                    if (!string.IsNullOrWhiteSpace(existingJson))
                    {
                        config = GenieConfigCommand.Deserialize<Config>(existingJson);
                        foreach (var feed in config.Feeds)
                        {
                            var package = feed.Packages.FirstOrDefault(p => p.Name == packageName);
                            if (package != null)
                            {
                                packageUrl = package.path;                                
                                break;
                            }
                        }
                    }
                }
            }
            catch (System.Text.Json.JsonException ex)
            {
                Console.WriteLine("Error: Invalid JSON format in genie.config.");
                Console.WriteLine(ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: An unexpected error occurred.");
                Console.WriteLine(ex.Message);
            }

            if (packageUrl != null)
            {
                HttpClient client = new HttpClient();
                var base64PAT = Convert.ToBase64String(Encoding.ASCII.GetBytes($":{PatToken}"));
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", base64PAT);
                Console.WriteLine("Downloding & Extraction process started\n");
                LoadingIndicator loadingIndicator = new LoadingIndicator();
                loadingIndicator.Start();
                byte[] data = await client.GetByteArrayAsync(packageUrl).ConfigureAwait(false);                
                if (folderName != null && !string.IsNullOrEmpty(packageName))
                {
                    packagePath = Path.Combine(folderName, "package.nupkg");
                    await File.WriteAllBytesAsync(packagePath, data).ConfigureAwait(false);
                    extractPath = Path.Combine(folderName);                    
                    if (extractPath != null)
                    {
                        ZipFile.ExtractToDirectory(packagePath, extractPath, true);
                        loadingIndicator.Stop();
                        Console.Write(Environment.NewLine);
                        Console.WriteLine("The package has been downloaded and extracted successfully.");                        
                        string[] unwantedFolders = { "_rels", "package" };
                        string[] unwantedFileExtensions = { "*.xml", "*.nuspec" };
                        foreach (string folder in unwantedFolders)
                        {
                            string folderPath = Path.Combine(extractPath, folder);
                            if (Directory.Exists(folderPath))
                            {
                                Directory.Delete(folderPath, true);
                            }
                        }
                        foreach (string extension in unwantedFileExtensions)
                        {
                            string[] files = Directory.GetFiles(extractPath, extension, SearchOption.AllDirectories);
                            foreach (string file in files)
                            {
                                File.Delete(file);
                            }
                        }
                    }
                    else
                    {
                        Console.WriteLine("Extract path is null.");
                    }
                }
                else
                {
                    Console.WriteLine("Folder name or package name is null or empty.");
                }
            }
            else
            {
                Console.WriteLine($"Package '{packageName}' not found in the config file.");
            }
        }       

        public async Task ProcessBicepFile(string bicepFilePath, string iacpath)
        {
            if (!string.IsNullOrEmpty(bicepFilePath))
            {
                Console.WriteLine($"Found main: {bicepFilePath}");
                string fileContent = await File.ReadAllTextAsync(bicepFilePath);                
                Regex modulePathRegex = new(@"module\s+\w+\s+'(?<path>.*?)'", RegexOptions.Compiled);
                var matches = modulePathRegex.Matches(fileContent);
                string updatedContent = fileContent;               
                foreach (Match match in matches)
                {
                    var modulePath = match.Groups["path"].Value;
                    if (modulePath.EndsWith(".bicep"))
                    {                        
                        var cleanPath = modulePath.Replace("./", "");                        
                        updatedContent = updatedContent.Replace($"'{modulePath}'", $"'{cleanPath}'");
                    }
                }
                await File.WriteAllTextAsync(bicepFilePath, updatedContent);
                Console.WriteLine("Module path changes in main.bicep");
            }
            else
            {
                Console.WriteLine("Main.bicep file not found");
            }

            if (iacpath is null)
            {
                throw new ArgumentNullException(nameof(iacpath));
            }
        }

        

        public async Task ReplaceProjectNameInPSFile(string PSFilePath, string projectName)
        {
            if (!string.IsNullOrEmpty(PSFilePath))
            {
                Console.WriteLine($"Found file: {PSFilePath}");
                string fileContent = await File.ReadAllTextAsync(PSFilePath);
                string replaceText = _appSettings.replaceText;
                string newProjectName = projectName.ToString();
                string updatedContent = fileContent.Replace(replaceText, newProjectName);
                await File.WriteAllTextAsync(PSFilePath, updatedContent);
                Console.WriteLine("File Contents and Name has been replaced with ProjectName");
            }
            else
            {
                Console.WriteLine("file not found in the package.");
            }
        }       

    }
}
