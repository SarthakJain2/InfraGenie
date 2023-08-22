using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GeniePrepFindAndRename
    {     
        public AppSettings _appSettings;
        private string replaceText;

        public GeniePrepFindAndRename(AppSettings appSettings, string replaceText)
        {
            _appSettings = appSettings;
            this.replaceText = replaceText;

        }

        public string FindFileAndRename(string tagpath, string projectName, string searchPattern)
        {            
            string[] tags = Directory.GetFiles(tagpath, searchPattern, SearchOption.AllDirectories);
            if (tags.Length > 0)
            {
                string oldFilePath = tags[0];
                string directoryPath = Path.GetDirectoryName(oldFilePath);
                string replaceText = _appSettings.replaceText;
                string projectNameStr = projectName.ToString();
                string newFileName = searchPattern.Replace(replaceText, projectNameStr);
                string newFilePath = Path.Combine(directoryPath, newFileName);

                if (File.Exists(newFilePath))
                {
                    File.Delete(newFilePath);
                }

                File.Move(oldFilePath, newFilePath);
                return newFilePath;
            }
            return null;
        }

       
    }
}
