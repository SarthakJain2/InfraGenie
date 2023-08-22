using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Api.Models
{
    internal class PrepModel
    {
        public string GoldenFolder { get; set; }
        public string TargetFolder { get; set; }
        public string IacFolder { get; set; }
        public string PatToken { get; set; }

        public string replaceText { get; set; }
        public string findMain { get; set; }
        public string findRunFile { get; set; }
        public string extractPath { get; set; }
        public Feed Feed { get; set; }
        public string ConfigFilePath { get; set; }
        public string searchPatternFile { get; set; }
    }
}
