using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Threading.Tasks;
//At Same Location to download New .exe
namespace Rhipheus.Genie.Cli
{
    public class GenieUpgradeCommand
    {
        public AppSettings _appSettings;
        private GeniePrepCommand _geniePrepCommand;
        
        public GenieUpgradeCommand(AppSettings appSettings)
        {
            _appSettings = appSettings;
            _geniePrepCommand = new GeniePrepCommand(_appSettings);
        }
        public string GenieExePath => Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        public string TempDirectory => Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
        
        public bool force = false;
        public async Task ProcessUpgradeCommand(string feedName, string packageName)
        {
            Console.WriteLine("Default FeedName As:-" + feedName);
            Console.WriteLine("Default PackageName As:-" + packageName);

            if (string.IsNullOrEmpty(GenieExePath))
            {
                Console.WriteLine("Genie executable path is not configured.");
                return;
            }

            var tempFile = Path.Combine(GenieExePath);
            Console.WriteLine("New exe downloaded at location" + tempFile);
            await _geniePrepCommand.ProcessPrepCommand(tempFile, feedName, packageName, force = true);
            string directoryPath = Path.Combine(GenieExePath, "Rhipheus.Genie.Cli");
            var assemblies = AppDomain.CurrentDomain.GetAssemblies()
            .Where(a => a.Location.StartsWith(Path.GetFullPath(GenieExePath)));
            foreach (var assembly in assemblies)
            {
                var location = assembly.Location;
                var targetFileName = string.Concat(location, ".old");
                if (File.Exists(targetFileName))
                {
                    var fileAttributes = File.GetAttributes(targetFileName);
                    if ((fileAttributes & FileAttributes.ReadOnly) == FileAttributes.ReadOnly)
                    {
                        File.SetAttributes(targetFileName, fileAttributes & ~FileAttributes.ReadOnly);
                    }
                    File.Delete(targetFileName);
                }
                File.Copy(location, targetFileName);
            }
            try
            {
                string currentPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
                DirectoryInfo directoryInfo = Directory.GetParent(currentPath);
                while (directoryInfo.Name != "Core")
                {
                    directoryInfo = directoryInfo.Parent;
                }
                string updaterPath = Path.Combine(directoryInfo.FullName, "Rhipheus.Genie.Cli.Updater", "bin", "Debug", "net7.0");
                string updaterExePath = Path.Combine(updaterPath, "Rhipheus.Genie.Cli.Updater.exe");
                var startInfo = new ProcessStartInfo
                {
                    FileName = updaterExePath,
                    Arguments = $"\"{directoryPath}\" \"{GenieExePath}\"",
                    UseShellExecute = true
                };
                var process = Process.Start(startInfo);
                if (process == null)
                {
                    Console.WriteLine("Failed to start process.");
                }
                else
                {
                    Console.WriteLine("Process started with ID: " + process.Id);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("An error occurred while trying to start the updater: " + e.Message);
            }
            finally
            {
                Environment.Exit(0);
            }
        }
    }


}






//At different Location to download new Exe
/*using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{ 
    public class GenieUpgradeCommand
    {
        public AppSettings _appSettings;
        private GeniePrepCommand _geniePrepCommand;
        public string currentPath;
        //public string userName;
        //public string NewAssemblyFolder;
        public GenieUpgradeCommand(AppSettings appSettings)
        {
            _appSettings = appSettings;
            _geniePrepCommand = new GeniePrepCommand(_appSettings);
           // userName = Environment.UserName;
           // NewAssemblyFolder = $"C:\\Users\\{userName}\\Downloads";
        }
        public string GenieExePath => Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        public string TempDirectory => Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
        public string NewAssemblyFolder = @"c:\downloads";
        public bool force = false;
        public async Task ProcessUpgradeCommand(string feedName, string packageName)
        {
            Console.WriteLine("Default FeedName As:-" + feedName);
            Console.WriteLine("Default PackageName As:-" + packageName);

            if (string.IsNullOrEmpty(GenieExePath))
            {
                Console.WriteLine("Genie executable path is not configured.");
                return;
            }

            var tempFile = Path.Combine(NewAssemblyFolder);
            Console.WriteLine("New exe downloaded at location" + tempFile);
            await _geniePrepCommand.ProcessPrepCommand(tempFile, feedName, packageName, force = true);
            string directoryPath = @"C:\Downloads\Rhipheus.Genie.Cli";
            //string directoryPath = $"C:\\Users\\{userName}\\Downloads\\Rhipheus.Genie.Cli";
            var assemblies = AppDomain.CurrentDomain.GetAssemblies()
            .Where(a => a.Location.StartsWith(Path.GetFullPath(GenieExePath))); 
            foreach (var assembly in assemblies)
            {
                var location = assembly.Location;
                var targetFileName = string.Concat(location, ".old");
                if (File.Exists(targetFileName))
                {
                    var fileAttributes = File.GetAttributes(targetFileName);
                    if ((fileAttributes & FileAttributes.ReadOnly) == FileAttributes.ReadOnly)
                    {
                        File.SetAttributes(targetFileName, fileAttributes & ~FileAttributes.ReadOnly);
                    }
                    File.Delete(targetFileName);
                }
                File.Copy(location, targetFileName);
            }
            try
            {
                string currentPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location); 
                DirectoryInfo directoryInfo = Directory.GetParent(currentPath);                
                while (directoryInfo.Name != "Core")
                {
                    directoryInfo = directoryInfo.Parent;
                }                
                string updaterPath = Path.Combine(directoryInfo.FullName, "Rhipheus.Genie.Cli.Updater", "bin", "Debug", "net7.0");
                string updaterExePath = Path.Combine(updaterPath, "Rhipheus.Genie.Cli.Updater.exe");               
                var startInfo = new ProcessStartInfo
                {                    
                    FileName= updaterExePath,
                    Arguments = $"\"{directoryPath}\" \"{GenieExePath}\"",
                    UseShellExecute = true
                };
                var process = Process.Start(startInfo);
                if (process == null)
                {
                    Console.WriteLine("Failed to start process.");
                }
                else
                {
                    Console.WriteLine("Process started with ID: " + process.Id);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("An error occurred while trying to start the updater: " + e.Message);
            }
            finally
            {
                Environment.Exit(0);
            }
        }  
    }


}
*/
