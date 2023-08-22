using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GenieWishListCommand
    {
        /*public string folderName;

        public void ProcessWishListCommand(string foundDirectory, string templateFolderPath)
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
        }*/
       
    }
}
