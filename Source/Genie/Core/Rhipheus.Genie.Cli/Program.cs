using Azure.Core;
using Azure.Identity;
using Azure.Storage.Queues;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.CommandLine;
using System.CommandLine.NamingConventionBinder;
using System.IO.Compression;
using System.Net.Http.Headers;
using System.Text;
using System.CommandLine.DragonFruit;
using Azure.Storage.Queues.Models;
using Azure;
using System.IO;
using System;
using System.Text.RegularExpressions;
using Newtonsoft.Json;
using System.Text.Json;
using Newtonsoft.Json.Converters;
using System.Text.Json.Serialization;
using Rhipheus.Genie.Core;
using System.Reflection;
using System.Diagnostics;
using Rhipheus.Genie.Api.Models;

namespace Rhipheus.Genie.Cli
{

    public class Program
    {
        public string feedName1;
        public string packageName1;
        public string connectionString;
        public string queueName;
        private bool force;
        public string threadId;
        public QueueClient queueClient;

        public static object GenieServerCommand { get; set; }

        public static async Task<int> Main(string[] args)
        {
            var program = new Program();
            return await program.RunAsync(args);
        }
        public async Task<int> RunAsync(string[] args)
        {
            var basePath = Directory.GetParent(AppContext.BaseDirectory);
            var serviceCollection = new ServiceCollection();
            var configuration = new ConfigurationBuilder()
                .SetBasePath(basePath.FullName)
                .AddJsonFile("appsettings.json")
                .Build();
            var connectionString = configuration.GetSection("ConnectionStringQ").Value;
            var queueName = configuration.GetSection("queueName").Value;

            if (string.IsNullOrEmpty(connectionString))
            {
                throw new Exception("Connection string is null or empty. Please check your configuration.");
            }

            var queueClient = new QueueClient(connectionString, queueName);
            bool isLoggedIn = false;

            var appSettings = new AppSettings
            {
                GoldenFolder = configuration.GetSection("GenieFolder").Value,
                TargetFolder = configuration.GetSection("TargerFolder").Value,
                IacFolder = configuration.GetSection("IacFolder").Value,
                PatToken = configuration.GetSection("PATTOKEN").Value,                              
                maxWaitHours = int.Parse(configuration.GetSection("maxWaitHours").Value),
                replaceText = configuration.GetSection("ReplaceText").Value,
                findMain = configuration.GetSection("FindMain").Value,
                findRunFile = configuration.GetSection("FindRunFile").Value,
                extractPath = configuration.GetSection("ExtractPath").Value,                
                configFilePath = configuration.GetSection("ConfigFilePath").Value,
                feedName1 = configuration.GetSection("feedName").Value,                
                packageName1 = configuration.GetSection("packageName").Value,               
                connectionString = connectionString,
                queueName = queueName,
                queueClient = queueClient,

            };
            GenieLoginCommand genieLoginCommand = new GenieLoginCommand();
            GeniePATLoginCommand geniePATLoginCommand = new GeniePATLoginCommand();
            GeniePrepCommand geniePrepCommand = new GeniePrepCommand(appSettings);
            GenieConfigCommand genieConfigCommand = new GenieConfigCommand(appSettings);            
            GenieServerCommand genieServerCommand = new GenieServerCommand(appSettings,threadId);
            GenieUpgradeCommand genieUpgradeCommand = new GenieUpgradeCommand(appSettings);

            serviceCollection.AddSingleton<IConfiguration>(configuration);
            serviceCollection.AddSingleton<GetVariables>();

            var serviceProvider = serviceCollection.BuildServiceProvider();
            var getVariablesInstanse = serviceProvider.GetService<GetVariables>();          

            //declarations for command extraction
            var folderNameOption = new Option<string>("--folder-name", "The folder name");
            var projectNameOption = new Option<string>("--project-name", "The project name");
            var packageUrlOption = new Option<string>("--package-url", "The package URL");
            var forceOption = new Option<bool>("--force", getDefaultValue: () => false, description: "Force download and extraction even if folder exists.");
            var cleanOption = new Option<bool>("--clean", getDefaultValue: () => false, description: "Clean up will remove files that are not present in the Golden package but is present in the folder.");
            var azureLOption = new Argument<string>("azureL", "Login as azure service user");
            var tenantIdOption = new Option<string>("--tenant-id", "The Tenant Id");
            var clientIdOption = new Option<string>("--client-id", "The client Id");
            var clientSecretOption = new Option<string>("--client-secret", "The client Secret Id");
            var devopsLOption = new Argument<string>("devops", "Login as a Azure DevOps");
            var PATOption = new Option<string>("--pat", "The PAT Token");
            var urlOption = new Option<string>("--url", "Login DevOps Url");
            var feedNameOption = new Option<string>("--feed-name", "The feed name");
            var feedUrlOption = new Option<string>("--feed-url", "The feed URL");
            var packageNameOption = new Option<string>("--package-name", "The name of Package");
            var servicesOption = new Option<string>("--services", "Azure Services");
            var modeOption = new Option<string>("--mode", "Operating Mode");
            var envOption = new Option<string>("--env", "Environment");
            var componentOption = new Option<string>("--component", "Component");
            var servicelistOption = new Option<bool>("--services-list", "Services List");           

            var wishCommand = new Command("wish", "genie wish command for services")
            {
                servicelistOption,
                servicesOption,
                componentOption,
                modeOption,
                envOption
            };

            var azureLoginCommand = new Command("azure", "Executes login command")
             {
                 tenantIdOption,
                 clientIdOption,
                 clientSecretOption
             };

            var devopsLoginCommand = new Command("devops", "Executes Azure DevOps Login")
             {
                 PATOption,
                 urlOption
             };

            var loginCommand = new Command("login", "Logs in to Azure or DevOps");
            loginCommand.AddCommand(azureLoginCommand);
            loginCommand.AddCommand(devopsLoginCommand);

            var prepCommand = new Command("prep", "Execute preparation command")
            {
                folderNameOption,
                projectNameOption,
                packageNameOption,
                forceOption,
                cleanOption

            };
            var configCommand = new Command("config", "Configures the application")
            {
                feedNameOption,
                feedUrlOption,
                packageNameOption,
                packageUrlOption
            };
            var downloadCommand = new Command("download", "Download the latest packages")
            {
                feedNameOption,
                packageNameOption,
                packageUrlOption,
                folderNameOption
            };
            var upgradeCommand = new Command("upgrade", "Upgrade the Url")
            {
                feedNameOption,
                packageNameOption,
                
            };

            upgradeCommand.Handler = CommandHandler.Create<string, string>(async (feedName, packageName) =>
            {
                feedName = appSettings.feedName1;
                packageName = appSettings.packageName1;
                await genieUpgradeCommand.ProcessUpgradeCommand(feedName, packageName);
            });
            //genie download command
            downloadCommand.Handler = CommandHandler.Create<string, string, string, string>(async (feedName, packageName, packageUrl, folderName) =>
            {                
                feedName = appSettings.feedName1;
                packageName = appSettings.packageName1;
                if (string.IsNullOrEmpty(folderName))
                {
                    folderName = Directory.GetCurrentDirectory();
                    Console.WriteLine("Using current folder");
                    await geniePrepCommand.ProcessPrepCommand(folderName, feedName, packageName, force = true);
                }
                else
                {
                    await geniePrepCommand.ProcessPrepCommand(folderName, feedName, packageName);
                }

            });

            configCommand.Handler = CommandHandler.Create<string, string, string, string>((feedName, feedUrl, packageName, packageUrl) =>
            {
                ValidateUrl(feedUrl, "feedUrl");
                ValidateUrl(packageUrl, "packageUrl");
                genieConfigCommand.ProcessConfigCommand(feedName, feedUrl, packageName, packageUrl);
            });

            //login handler
            azureLoginCommand.Handler = CommandHandler.Create<string, string, string>((tenantId, clientId, clientSecret) =>
            {
                genieLoginCommand.ProcessLoginCommand(tenantId, clientId, clientSecret);
                isLoggedIn = genieLoginCommand.IsUserLoggedIn();

                if (isLoggedIn)
                {
                    Console.WriteLine("User is logged in.");
                }
                else
                {
                    Console.WriteLine("User is not logged in.");
                }
            });
            //login DevOps User handler
            devopsLoginCommand.Handler = CommandHandler.Create<string, string>((pat, url) =>
            {
                geniePATLoginCommand.ProcessLoginPATCommand(pat, url);
                isLoggedIn = geniePATLoginCommand.IsUserLoggedIn();
            });
            //prep handler
            prepCommand.Handler = CommandHandler.Create<string, string, string, bool, bool>(async (folderName, projectName, packageName, force, clean) =>
            {

                await geniePrepCommand.ProcessPrepCommand(folderName, projectName, packageName.ToLower(), force, clean);
            });

            wishCommand.Handler = CommandHandler.Create<bool, string, string, string,string>(async (serviceslist, services,component, mode, env) =>
            {
                GenieWishCommand genieWishCommand = new GenieWishCommand(appSettings);
                if (isLoggedIn)
                {
                    Console.WriteLine("User is not logged in. Please login to continue.");
                    return;
                }
                else
                {
                    Console.WriteLine("User already logged In");
                    if (args.Contains("--services-list"))
                    {
                        genieWishCommand.ProcessWishListCommand();
                    }
                    else if (args.Contains("--services"))
                    {
                        await genieWishCommand.ProcessWishCommand(services, component, mode, env);
                    }
                    else
                    {
                        Console.WriteLine("Invalid command. Please provide either --serviceslist or --services.");
                    }
                }

            });

          
            var rootCommand = new RootCommand
            {
                
                new Option<bool>(
                "--server",
                description: "Runs the server"),

            };
            rootCommand.Description = "Genie CLI helps create IaC bicep for project infrastructure, generate code for specific services, check-in code, establish DevOps pipelines etc.";
            rootCommand.AddCommand(downloadCommand);
            rootCommand.AddCommand(upgradeCommand);
            rootCommand.AddCommand(prepCommand);
            rootCommand.AddCommand(loginCommand);
            rootCommand.AddCommand(wishCommand);
            rootCommand.AddCommand(configCommand);
            
           
            rootCommand.Handler = CommandHandler.Create<bool>(async (server) =>
            {
                if (server)
                {
                    await genieServerCommand.RetrieveFromServer(queueClient);
                }
                else
                {
                    rootCommand.Invoke("-h");
                }
            });
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i].StartsWith("--"))
                {
                    args[i] = args[i].ToLower();
                }
            }

            return await rootCommand.InvokeAsync(args);
        }


        public void ValidateUrl(string Url, string parameterName)
        {
            if (!Uri.TryCreate(Url, UriKind.Absolute, out _) ||
                !Uri.IsWellFormedUriString(Url, UriKind.Absolute))
            {
                throw new ArgumentException($"Invalid URL format for {parameterName}.", nameof(Url));
            }
        }

    }
    public class AppSettings
    {
        public QueueClient queueClient;
        public object searchAppSettingsFile;

        public string GoldenFolder { get; set; }
        public string TargetFolder { get; set; }
        public string IacFolder { get; set; }
        public string PatToken { get; set; }        
        public string connectionString { get; set; }
        public string queueName { get; set; }       
        public int maxWaitHours { get; set; }
        public string replaceText { get; set; }
        public string findMain { get; set; }
        public string findRunFile { get; set; }
        public string extractPath { get; set; }
        public Feed Feed { get; set; } 
        public string configFilePath { get; set; }
        public string feedName1 { get; set; }
        
        public string packageName1 { get; set; }
        public string searchPatternFile { get; internal set; }
    }

    public class Package
    {
        public string Name { get; set; }
        public string path { get; set; }
    }

    public class Feed
    {
        public string Name { get; set; }
        public string path { get; set; }
        public List<Package> Packages { get; set; }
    }
    public class Config
    {
        public AI AI { get; set; }
        public List<Feed> Feeds { get; set; }
    }
    public class AI
    {
        public string path { get; set; }

    }
}




























