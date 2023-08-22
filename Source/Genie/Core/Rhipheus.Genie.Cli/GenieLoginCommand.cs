using Azure;
using Azure.Core;
using Azure.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Rhipheus.Genie.Cli
{
    class GenieLoginCommand
    {
        public bool isLoggedIn = false;
        public void ProcessLoginCommand(string tenantId, string clientId, string clientSecret)
        {
            TokenCredential credential = new ClientSecretCredential(
                              tenantId: tenantId,
                              clientId: clientId,
                              clientSecret: clientSecret
                                );
            CancellationToken cancellationToken = default;
            AccessToken token = credential.GetToken(
                new TokenRequestContext(
                    new[] { "https://management.azure.com/.default" }),
                cancellationToken);
            string accessToken = token.Token;
            if (!string.IsNullOrEmpty(accessToken))
            {
                Console.WriteLine("Successfully logged in to Azure as a Service-principal.........");
                isLoggedIn = true;
            }
            else
            {
                Console.WriteLine("Azure login failed. Access token is empty.");
                isLoggedIn = false;
                //return;
            }
           
        }
        public bool IsUserLoggedIn()
        {
            return isLoggedIn;
        }
    }
}
