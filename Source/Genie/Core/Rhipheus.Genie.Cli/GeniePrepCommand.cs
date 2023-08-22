using Rhipheus.Genie.Core;
using System;
using System.Collections.Generic;
using System.IO.Compression;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Rhipheus.Genie.Api.Models;

namespace Rhipheus.Genie.Cli
{
    class GeniePrepCommand
    {
        public string packagePath;
        public string packageUrl;
        private AppSettings _appSettings;
        public string extractPath;
        public string PatToken;
        public string GoldenFolder;
        public string TargetFolder;
        public string IacFolder;
        public string replaceText;
        public string findMain;
        public string findRunFile;
        public string ConfigFilePath;
        public string searchPatternFile;
        public object searchAppSettingsFile;

        public GeniePrepCommand(AppSettings appSettings)
        {
            _appSettings = appSettings;
            extractPath = _appSettings.extractPath;
            PatToken = _appSettings.PatToken;
            GoldenFolder = _appSettings.GoldenFolder;
            TargetFolder = _appSettings.TargetFolder;
            IacFolder = _appSettings.IacFolder;
            replaceText = _appSettings.replaceText;
            findMain = _appSettings.findMain;
            findRunFile = _appSettings.findRunFile;
            ConfigFilePath = _appSettings.configFilePath;
            searchPatternFile = _appSettings.searchPatternFile;
            searchAppSettingsFile = _appSettings.searchAppSettingsFile;

        }

        public async Task ProcessPrepCommand(string folderName, string projectName, string packageName, bool force = false, bool clean = false)
        {
            if (!Directory.Exists(folderName))
            {
                Directory.CreateDirectory(folderName);
                Console.WriteLine("Directory Created");
            }
            else if (clean)
            {
                GenieCleanUp genieCleanUp = new GenieCleanUp();
                genieCleanUp.CleanUp(folderName);
                return;
            }

            else if (force)
            {
                Console.WriteLine("Directory already exists... Overwriting files...");

            }
            else
            {
                Console.WriteLine("Directory already exists. Use '--force' to overwrite files or Use '--clean' to clean folder");
                return;
            }
            GeniePrepFindAndRename geniePrepFindAndRename = new GeniePrepFindAndRename(_appSettings,replaceText);
            GenieDownloadAndExtract genieDownloadAndExtract = new GenieDownloadAndExtract(_appSettings, extractPath, PatToken, ConfigFilePath);
            await genieDownloadAndExtract.DownloadAndExtract(folderName, packageName); 
            
            if (packageName.Contains(GoldenFolder.ToLower()))
            {

                string findfolder = GoldenFolder;
                string targetFolderName = TargetFolder;
                
                string goldenFolderPath = Path.Combine(folderName,GoldenFolder);
                string genifxFolderPath = Path.Combine(goldenFolderPath, targetFolderName);
                string iacpath = Path.Combine(GoldenFolder, IacFolder).Replace("\\", "/");
                string tagpath = Path.Combine(goldenFolderPath, ".tags", "rhipheus.com");
                bool Flag = true;
                if (Directory.Exists(goldenFolderPath))
                {
                    Console.WriteLine("Golden Folder is present");
                    if (Directory.Exists(genifxFolderPath))
                    {
                        Console.WriteLine("Genifx folder exists in the extracted directory.");
                        packagePath = Directory.GetParent(Directory.GetParent(genifxFolderPath).FullName).FullName;
                        string[] files = Directory.GetFiles(genifxFolderPath);

                        foreach (string file in files)
                        {
                            string destinationFilePath = Path.Combine(packagePath, Path.GetFileName(file));
                            if (File.Exists(destinationFilePath)) 
                            {
                                string originalFileHash = GetFileHash(file);
                                string destinationFileHash = GetFileHash(destinationFilePath);

                                if (originalFileHash != destinationFileHash)
                                {                                    
                                    Console.WriteLine("The file has been modified. Choose an option:");
                                    Console.WriteLine("1. Keep modified file");
                                    Console.WriteLine("2. Use latest extracted file");
                                    Console.WriteLine("3. Keep both (merge)");

                                    int choice = int.Parse(Console.ReadLine());

                                    switch (choice)
                                    {
                                        case 1: // keep modified file
                                            File.Delete(file);
                                            Flag = true;
                                            Console.WriteLine($"{destinationFilePath} has already been modified. Keeping previous file.");
                                            break;

                                        case 2: // use latest extracted file
                                            File.Delete(destinationFilePath);
                                            File.Move(file, destinationFilePath);
                                            Flag = true;
                                            Console.WriteLine($"{destinationFilePath} has been replaced with the latest extracted file.");
                                            break;

                                        case 3: // keep both (merge)                                                
                                            string oldContent = File.ReadAllText(destinationFilePath);
                                            string newContent = File.ReadAllText(file);
                                            File.WriteAllText(destinationFilePath, oldContent + newContent);
                                            File.Delete(file);
                                            Flag = true;
                                            Console.WriteLine($"{destinationFilePath} has been merged with new changes.");
                                            break;

                                        default:
                                            Console.WriteLine("Invalid choice.");
                                            break;
                                    }
                                    continue;
                                }
                                else
                                {
                                    Flag = true;
                                    File.Delete(destinationFilePath);

                                }
                            }                           
                            File.Move(file, destinationFilePath);
                        }
                        Directory.Delete(genifxFolderPath, true);
                        Console.WriteLine("Files moved outside of the Genifx folder.");
                    }
                    else
                    {
                        Console.WriteLine("Geniefx folder does not exist in the extracted directory.");
                    }

                    string GetFileHash(string filePath)
                    {
                        using var md5 = System.Security.Cryptography.MD5.Create();
                        using var stream = File.OpenRead(filePath);
                        byte[] hash = md5.ComputeHash(stream);
                        return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
                    }
                    string FindBicepFile(string folderName)
                    {
                        string[] bicepFiles = Directory.GetFiles(folderName, findMain, SearchOption.AllDirectories);
                        return bicepFiles.Length > 0 ? bicepFiles[0] : null;
                    }
                    string FindRunPSFile(string folderName)
                    {
                        string[] PSFiles = Directory.GetFiles(folderName, findRunFile, SearchOption.AllDirectories);
                        return PSFiles.Length > 0 ? PSFiles[0] : null;
                    }      
                    if (Flag == true)
                    {
                        string bicepFilePath = FindBicepFile(folderName);
                        await genieDownloadAndExtract.ProcessBicepFile(bicepFilePath, iacpath);

                        string PSFilePath = FindRunPSFile(folderName);
                        await genieDownloadAndExtract.ReplaceProjectNameInPSFile(PSFilePath, projectName);
                    }

                    string tagFilePath = geniePrepFindAndRename.FindFileAndRename(tagpath, projectName,"rhipheus.com-genie-dev.json");
                    await genieDownloadAndExtract.ReplaceProjectNameInPSFile(tagFilePath, projectName);

                    string appSettingFilePath = geniePrepFindAndRename.FindFileAndRename(tagpath, projectName,"appSettings-genie-dev.json");
                    await genieDownloadAndExtract.ReplaceProjectNameInPSFile(appSettingFilePath, projectName);
                }
                else
                {
                    Console.WriteLine("Golden Folder does not exist.");
                }
            }
            else
            {
                Console.WriteLine("Process Completed.........");
            }


        }
    }
            
}   
