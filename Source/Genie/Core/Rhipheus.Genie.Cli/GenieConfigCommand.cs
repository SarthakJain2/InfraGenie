using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Linq;
using Rhipheus.Genie.Cli;

namespace Rhipheus.Genie.Core
{
    class GenieConfigCommand
    {
        private readonly AppSettings _appSettings;
        public string ConfigFilePath { get; set; }

        public GenieConfigCommand(AppSettings appSettings)
        {
            _appSettings = appSettings;
            ConfigFilePath = _appSettings.configFilePath;           
        }
        
        public void ProcessConfigCommand(string feedName, string feedUrl, string packageName, string packageUrl)
        {
            var config = LoadConfigFromFile();

            if (config == null)
            {
                config = CreateNewConfig(feedName, feedUrl, packageName, packageUrl);
            }
            else
            {
                UpdateOrCreateFeedAndPackage(config, feedName, feedUrl, packageName, packageUrl);
            }

            SaveConfigToFile(config);
        }

        private Config LoadConfigFromFile()
        {
           Config config=null;

            try
            {
                if (File.Exists(ConfigFilePath))
                {
                    Console.WriteLine("Config file exists");
                    var existingJson = File.ReadAllText(ConfigFilePath);

                    if (!string.IsNullOrWhiteSpace(existingJson))
                    {
                        config = Deserialize<Config>(existingJson);
                    }
                    else
                    {
                        Console.WriteLine("Empty config file found.");
                    }
                }
                else
                {
                    Console.WriteLine("Config file does not exist.");
                }
            }
            catch (JsonException ex)
            {
                Console.WriteLine("Error: Invalid JSON format in genie.config.");
                Console.WriteLine(ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: An unexpected error occurred.");
                Console.WriteLine(ex.Message);
            }

            return config;
        }

        private void SaveConfigToFile(Config config)
        {
            try
            {
                var jsonString = Serialize(config);
                File.WriteAllText(ConfigFilePath, jsonString);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: Could not save config file.");
                Console.WriteLine(ex.Message);
            }
        }

        private void UpdateOrCreateFeedAndPackage(Config config, string feedName, string feedUrl, string packageName, string packageUrl)
        {
            var existingFeed = config.Feeds.FirstOrDefault(f => f.Name == feedName);

            if (existingFeed != null)
            {
                UpdateOrCreatePackage(existingFeed, packageName, packageUrl);
            }
            else
            {
                CreateFeed(config, feedName, feedUrl, packageName, packageUrl);
            }
        }

        private void UpdateOrCreatePackage(Feed existingFeed, string packageName, string packageUrl)
        {
            var existingPackage = existingFeed.Packages.FirstOrDefault(p => p.Name == packageName);

            if (existingPackage != null)
            {
                Console.WriteLine($"Package '{packageName}' already exists in Feed '{existingFeed.Name}'. Overwritten");
                existingPackage.path = packageUrl;
            }
            else
            {
                Console.WriteLine($"Feed '{existingFeed.Name}' exists, but Package '{packageName}' does not. Added new Package");
                existingFeed.Packages.Add(new Package { Name = packageName, path = packageUrl });
            }
        }

        private void CreateFeed(Config config, string feedName, string feedUrl, string packageName, string packageUrl)
        {
            config.Feeds.Add(new Feed
            {
                Name = feedName,
                path = feedUrl,
                Packages = new List<Package> { new Package { Name = packageName, path = packageUrl } }
            });
            Console.WriteLine("Added New Feed");
        }

        public Config CreateNewConfig(string feedName, string feedUrl, string packageName, string packageUrl)
        {
            return new Config
            {
                AI = new AI
                {
                    path = "https://exampleUrl/ai"
                },
                Feeds = new List<Feed>
                {
                    new Feed
                    {
                        Name = feedName,
                        path = feedUrl,
                        Packages = new List<Package>
                        {
                            new Package
                            {
                                Name = packageName,
                                path = packageUrl
                            }
                        }
                    }
                }
            };
        }

        public string Serialize<T>(T instance)
        {
            return JsonSerializer.Serialize<T>(instance, new JsonSerializerOptions
            {
                WriteIndented = true,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
                Converters =
                {
                    new JsonStringEnumConverter(),
                    new ExpandoObjectConverter()
                }
            });
        }

        public static T Deserialize<T>(string json)
        {
            if (string.IsNullOrEmpty(json))
            {
                throw new ArgumentException("Json cannot be empty or null");
            }

            return JsonSerializer.Deserialize<T>(json, new JsonSerializerOptions
            {
                WriteIndented = true,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
                Converters =
                {
                    new JsonStringEnumConverter(),
                    new ExpandoObjectConverter()
                }
            });
        }
    }
}
