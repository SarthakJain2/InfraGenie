using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using static System.CommandLine.Help.HelpBuilder;

namespace Rhipheus.Genie.Cli
{
    public class GenieWishCommand
    {
        
        public  string folderName;
        public string packageName;
        public string CurrentDirectory;
        public string foundDirectory;
        public string templateFolderPath;
        public string GoldenFolder { get; set; }
        public string IacFolder { get; set; }
       

        public readonly AppSettings _appSettings; 
        GenieWishDefaultParams genieWishDefaultParams= new GenieWishDefaultParams();
        GenieWishServiceSpec genieWishServiceSpec = new GenieWishServiceSpec();
        GenieWishMainBicepModifycs genieMainModify = new GenieWishMainBicepModifycs();
        //GenieServicesVnetSubnet genieVnetSubnet=new GenieServicesVnetSubnet();
        public GenieWishCommand(AppSettings appSettings)
        {
            _appSettings = appSettings;
            GoldenFolder = _appSettings.GoldenFolder;
            IacFolder = _appSettings.IacFolder;
            CurrentDirectory = Directory.GetCurrentDirectory();            
            foundDirectory = FindDirectory(CurrentDirectory, GoldenFolder);           
            templateFolderPath = Path.Combine(foundDirectory, "IaC Templates");
        }
       
        public async Task ProcessWishCommand(string services, string component,string mode, string env)
        {
            string getmode = mode;
            string getcomponent = component;
            string getenv = env;
            string mainPath = Directory.GetParent(foundDirectory).FullName;
            string runfilePath = Path.Combine(mainPath, "run.ps1");
            string mainBicepPath = Path.Combine(mainPath, "main.bicep");
            string mainParameterPath = Path.Combine(mainPath, "main.parameters.json");
            string runcontents = await File.ReadAllTextAsync(runfilePath);
            Regex regex1 = new Regex(@"\$ProjectName\s*=\s*""([^""]*)""");  
            Match match1 = regex1.Match(runcontents);

            if (match1.Success)
            {
                string projectName = match1.Groups[1].Value; 
                Console.WriteLine(projectName);

                //for service specific
                // await genieWishServiceSpec.ProcessServiceSpecParameters(projectName, getenv);

                //for default paramerters 
                //  await genieWishDefaultParams.ProcessDefaultParameters(projectName,getcomponent,mode,mainParameterPath);
                await genieMainModify.ProcessMainBicep(env,projectName,services, mainBicepPath, mainPath);
            }
            else
            {
                Console.WriteLine("The word 'projectName' was not found in the file.");
            }
           // await genieVnetSubnet.CalculateAndAssignProperties(services);
           // await genieMainModify.ProcessMainBicep(services,mainBicepPath,mainPath);
            
        }
        
       public void ProcessWishListCommand()
        {
            if (foundDirectory != null)
            {                
                if (Directory.Exists(templateFolderPath))
                {
                    string[] bicepFiles = Directory.GetFiles(templateFolderPath, "*.bicep");

                    List<ServiceDescription> serviceDescriptions = new List<ServiceDescription>();

                    foreach (string file in bicepFiles)
                    {
                        string fileName = Path.GetFileName(file);
                        

                        ServiceDescription description = new ServiceDescription
                        {
                            Name = fileName.Replace(".bicep", ""),
                            Description = fileName.Replace(".bicep", ""),
                            Template = fileName,
                            Icon = fileName.Replace(".bicep", ".svg"),
                            Label = fileName.Replace(".bicep", ""),
                            Prefix = "prefix", 
                            Defaults = new Defaults { Dev = new Dev() }
                        };

                        serviceDescriptions.Add(description);
                    }

                    var json = JsonConvert.SerializeObject(serviceDescriptions, Formatting.Indented);
                    File.WriteAllText("service-description1.json", json);
                    var jsonData = File.ReadAllText("service-description1.json");
                    List<ServiceDescription> services = JsonConvert.DeserializeObject<List<ServiceDescription>>(jsonData);

                    string dividerLine = "-------------------------------+------------------------------------------------------";
                    Console.WriteLine(dividerLine);
                    Console.WriteLine("| {0,-30} | {1,-50}|", "Name", "Description");
                    Console.WriteLine(dividerLine);

                    foreach (var service in services)
                    {
                        Console.WriteLine("| {1,-30} | {1,-50}|", service.Name, service.Description);
                        Console.WriteLine(dividerLine);
                    }

                }
                else
                {
                    Console.WriteLine($"The folder path '{templateFolderPath}' does not exist.");
                }
            }
            else
            {
                Console.WriteLine($"Directory '{folderName}' not found.");
            }
        }
        public string FindDirectory(string startDirectory, string folderName)
        {
            try
            {
                foreach (var directory in Directory.GetDirectories(startDirectory))
                {
                    if (new DirectoryInfo(directory).Name == folderName)
                    {
                        return directory;
                    }

                    var foundInSubDirectory = FindDirectory(directory, folderName);
                    if (foundInSubDirectory != null)
                    {
                        return foundInSubDirectory;
                    }
                }
            }
            catch (UnauthorizedAccessException e)
            {
                Console.WriteLine(e.Message);
            }

            return null;
        }

    }
    public class Dev
    {
        public string sku { get; set; }
    }

    public class Defaults
    {
        public Dev Dev { get; set; }
    }

    public class ServiceDescription
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string Template { get; set; }
        public string Icon { get; set; }
        public string Label { get; set; }
        public string Prefix { get; set; }
        public Defaults Defaults { get; set; }
    }

}
