using Azure.Storage.Queues.Models;
using Azure.Storage.Queues;
using Azure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Threading;
using Rhipheus.Genie.Api.Models;
using System.IO.Compression;
using System.Diagnostics;
using System.Reflection;

namespace Rhipheus.Genie.Cli
{
    class GenieServerCommand
    {       
        public  string threadId;
        public int nextDelay;
        public AppSettings _appSettings;
        private readonly GeniePrepCommand _geniePrepCommand;
        private readonly GenieWishCommand _genieWishCommand;
        private readonly GenieUpgradeCommand _genieUpgradeCommand;
        private readonly string connectionString;
        private readonly string queueName;
        private readonly int maxWaitHours;        
        bool force=false;        
        string mountedDriePath = "/files";
        private readonly TimeSpan _maxWaitTime;
        private readonly TimeSpan _initialWaitTime;
        private readonly int _attempt;


        public string ConfigFilePath { get; set; }
        GenieLoginCommand genieLoginCommand = new GenieLoginCommand();
        GeniePATLoginCommand geniePATLoginCommand = new GeniePATLoginCommand();
        
       

        public GenieServerCommand(AppSettings appSettings,string threadId)
        {
            _appSettings = appSettings;
            this.threadId = "9b01981c-bbe1-4bdd-bf46-8b7117dd9cea";
            _geniePrepCommand = new GeniePrepCommand(_appSettings);
            _genieWishCommand = new GenieWishCommand(_appSettings);
            _genieUpgradeCommand = new GenieUpgradeCommand(_appSettings);
            connectionString = _appSettings.connectionString;
            queueName = _appSettings.queueName;
            maxWaitHours = _appSettings.maxWaitHours;
           
        }        
        
        public async Task RetrieveFromServer(QueueClient queueClient)
        {
            string currentDirectory = Directory.GetCurrentDirectory();
            //Directory.SetCurrentDirectory(mountedDriePath);
            mountedDriePath=Path.Combine(currentDirectory,mountedDriePath);
            HashSet<string> executedCommands = new HashSet<string>();
            try
            {

                while (true)
                {
                    if (await queueClient.ExistsAsync())
                    {
                        Console.WriteLine("The queue exists.");
                    }
                    else
                    {
                        await queueClient.CreateIfNotExistsAsync();
                        Console.WriteLine("The queue didn't exist, so it was created.");
                    }

                    QueueProperties queueProperties = await queueClient.GetPropertiesAsync();

                    if (queueProperties.ApproximateMessagesCount > 0)
                    {
                        GenieBackoffRetryStrategy backoffRetry = new GenieBackoffRetryStrategy(_maxWaitTime, _initialWaitTime);
                        QueueMessage[] peekedMessages = await backoffRetry.ReceiveMessagesWithRetryAsync(queueClient, maxMessages: 10);
                        foreach (QueueMessage peekedMessage in peekedMessages)
                        {
                            try
                            {                                
                                GenieRequest request = JsonConvert.DeserializeObject<GenieRequest>(peekedMessage.MessageText);
                                if (request.ThreadId != threadId)
                                {
                                    continue;
                                }
                                StringBuilder sb = new StringBuilder();
                                sb.Append(request.Request);
                                sb.Append(" ");
                                sb.Append(request.Command);
                                foreach (var param in request.Parameters)
                                {
                                    sb.Append(" ");
                                    sb.Append(param.Name);
                                    sb.Append(" ");
                                    sb.Append(param.Value);
                                }
                                string commandString = sb.ToString();

                                Console.WriteLine("Getting Command from the queue:\n" + commandString);
                                string[] tokens = commandString.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                                if (tokens.Length < 2)
                                {
                                    Console.WriteLine("Invalid command: " + request.Command);
                                    continue;
                                }

                                string commandKey = string.Join(' ', tokens);
                                string command = tokens[1];


                                if (executedCommands.Contains(commandKey))
                                {
                                    Console.WriteLine("Command has already been executed. Skipping.");
                                    continue;
                                }
                                
                                command = tokens[1];
                                switch (command)
                                {
                                    case "prep":
                                        string projectName = tokens[Array.IndexOf(tokens, "--project-name") + 1];
                                        string folderName = tokens[Array.IndexOf(tokens, "--folder-name") + 1];
                                        string packageName = tokens[Array.IndexOf(tokens, "--package-name") + 1];
                                        string threadFolderPath = Path.Combine(mountedDriePath, threadId);
                                        folderName = Path.Combine(threadFolderPath, folderName);
                                        await _geniePrepCommand.ProcessPrepCommand(folderName, projectName, packageName);
                                        break;
                                    case "login":
                                        string tenantId = tokens[Array.IndexOf(tokens, "--tenant-id") + 1];
                                        string clientId = tokens[Array.IndexOf(tokens, "--client-id") + 1];
                                        string clientSecret = tokens[Array.IndexOf(tokens, "--client-secret") + 1];
                                        string pat = tokens[Array.IndexOf(tokens, "--pat") + 1];
                                        string url = tokens[Array.IndexOf(tokens, "--url") + 1];
                                        if (tokens.Contains("azure"))
                                        {
                                            genieLoginCommand.ProcessLoginCommand(tenantId, clientId, clientSecret);
                                        }
                                        else
                                        {
                                            geniePATLoginCommand.ProcessLoginPATCommand(pat, url);
                                        }
                                        break;
                                    case "wish":
                                        string services = tokens[Array.IndexOf(tokens, "--services") + 1];
                                        string component = tokens[Array.IndexOf(tokens, "--component") + 1];
                                        string mode = tokens[Array.IndexOf(tokens, "--mode") + 1];
                                        string env = tokens[Array.IndexOf(tokens, "--env") + 1];
                                        if (tokens.Contains("--services-list"))
                                        {
                                            _genieWishCommand.ProcessWishListCommand();
                                        }
                                        else
                                        {                                           
                                            await _genieWishCommand.ProcessWishCommand(services, component, mode, env);
                                        }
                                        break;
                                    case "download":
                                        folderName = tokens[Array.IndexOf(tokens, "--folder-name") + 1];
                                        string feedName = _appSettings.feedName1;
                                        packageName = _appSettings.packageName1;
                                        threadFolderPath = Path.Combine(mountedDriePath, threadId);
                                        folderName = Path.Combine(threadFolderPath, folderName);
                                        await _geniePrepCommand.ProcessPrepCommand(folderName, feedName, packageName);
                                        break;
                                    case "upgrade":
                                        feedName = _appSettings.feedName1;
                                        packageName = _appSettings.packageName1;                                      
                                        await _genieUpgradeCommand.ProcessUpgradeCommand(feedName,packageName);                                      
                                        break;

                                    default:
                                        Console.WriteLine($"Unsupported command: {command}");
                                        break;
                                }
                                //_ = await queueClient.DeleteMessageAsync(peekedMessage.MessageId, peekedMessage.PopReceipt);

                                executedCommands.Add(commandKey);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine(e.ToString());
                            }

                        }
                    }
                    else
                    {
                        Console.WriteLine("No messages in the queue Queue is Empty.");
                    }
                    await Task.Delay(nextDelay);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error retrieving messages from the queue:" + ex.Message);
            }
        }
       
    }  
    
}
