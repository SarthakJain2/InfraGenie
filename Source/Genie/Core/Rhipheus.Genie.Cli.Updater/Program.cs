using System;
using System.Diagnostics;
using System.IO;

class Program
{
    static void Main(string[] args)
    {

        if (args.Length < 2)
        {
            Console.WriteLine("Please provide both new and old version paths.");
            return;
        }
        var newVersionPath = args[0];
        var oldVersionPath = args[1];
        if (!Directory.Exists(newVersionPath) || !Directory.Exists(oldVersionPath))
        {
            Console.WriteLine("One or both of the specified directories do not exist.");
            return;
        }       
        var processes = Process.GetProcessesByName("Genie");
        if (processes.Length > 0)
        {
            processes[0].WaitForExit();
        }        
        string[] oldFiles = Directory.GetFiles(oldVersionPath, "*.old");
        foreach (string oldFile in oldFiles)
        {
            File.Delete(oldFile);
        }        
        foreach (var newPathFile in Directory.EnumerateFiles(newVersionPath, "*.*", SearchOption.AllDirectories))
        {
            string fileName = Path.GetFileName(newPathFile);
            string destFile = Path.Combine(oldVersionPath, fileName);
            File.Copy(newPathFile, destFile, true);
        }       
        var startExePath = Path.Combine(oldVersionPath, "genie.exe");
        if (File.Exists(startExePath))
        {
            //Process.Start(startExePath);
            //Console.WriteLine("Genie Upgraded Successfully..............");
            try
            {
                Process.Start(startExePath);
                Console.WriteLine("Genie Upgraded Successfully..............");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to start genie.exe: {ex.Message}");
            }
        }
        else
        {
            Console.WriteLine($"Could not find executable to start: {startExePath}");
        }

        Environment.Exit(0);
    }
}

