using Microsoft.Extensions.Configuration;

namespace Rhipheus.Genie.Cli
{
    class GetVariables
    {
        /*private readonly IConfiguration configuration;

        public GetVariables(IConfiguration configuration)
        {
            this.configuration = configuration;
        }
        public (string DataGolden, string DataTarger, string DataIac, string DataPATTOKEN, string DataConnectionSring, string DataQueueName, int DataMaxWaitHours, string DataReplaceText,string DataFindMain, string DataFindRunFile, string DataConfigFilePath,string DataFeedName,string DataPackageName) GetData()
        {
            var dataGolden = configuration.GetSection("GenieFolder").Value;
            var dataTarger = configuration.GetSection("TargerFolder").Value;
            var dataIac = configuration.GetSection("IacFolder").Value;
            var PATTOKEN = configuration.GetSection("PATTOKEN").Value;

            var dataConnectionString = configuration.GetSection("ConnectionStringQ").Value;
            var dataqueueName = configuration.GetSection("queueName").Value;
            var dataMaxWaitHoursString = configuration.GetSection("maxWaitHours").Value;
            int dataMaxWaitHours = int.Parse(dataMaxWaitHoursString);
            var dataReplaceText = configuration.GetSection("ReplaceText").Value;
            var dataFindMain = configuration.GetSection("FindMain").Value;
            var dataFindRunFile = configuration.GetSection("FindRunFile").Value;
            var dataConfigFilePath = configuration.GetSection("ConfigFilePath").Value;
            var dataFeedName = configuration.GetSection("feedName").Value;
            var dataPackageName = configuration.GetSection("packageName").Value;
            return (dataGolden, dataTarger,dataIac, PATTOKEN, dataConnectionString, dataqueueName, dataMaxWaitHours,dataReplaceText,dataFindMain,dataFindRunFile,dataConfigFilePath,dataFeedName,dataPackageName);
        }*/
    }
}