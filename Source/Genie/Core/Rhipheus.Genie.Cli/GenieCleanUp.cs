using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GenieCleanUp
    {
        public void CleanUp(string folderName)
        {
            if (string.IsNullOrWhiteSpace(folderName))
            {
                Console.WriteLine("Folder name is null or empty. Please provide a valid folder name.");
                return;
            }
            else
            {
                string goldenFolderPath = Path.Combine(folderName, "Golden");

                if (string.IsNullOrWhiteSpace(goldenFolderPath) || !Directory.Exists(goldenFolderPath))
                {
                    Console.WriteLine("Golden folder path is null, empty or doesn't exist. Please ensure the Golden folder exists in the provided path.");
                    return;
                }
                HashSet<string> goldenFiles = Directory.GetFiles(goldenFolderPath, "*", SearchOption.AllDirectories)
                    .Select(path => Path.GetRelativePath(goldenFolderPath, path)).ToHashSet();
                string packagePath = folderName;
                // Get a list of files in your current directory
                List<string> currentFiles = Directory.GetFiles(packagePath, "*", SearchOption.AllDirectories)
               .Select(path => Path.GetRelativePath(packagePath, path)).ToList();
                foreach (var currentFile in currentFiles)
                {
                    // If the file does not exist in the golden directory, delete it                     
                    if (!goldenFiles.Contains(currentFile))
                    {
                        string fileToDelete = Path.Combine(folderName, currentFile);
                        if (fileToDelete.Contains(goldenFolderPath))
                        {
                            break;
                        }
                        File.Delete(fileToDelete);
                        Console.WriteLine($"Removed file {fileToDelete} as it was not found in the golden package");
                    }
                }
            }
        }

    }
}
