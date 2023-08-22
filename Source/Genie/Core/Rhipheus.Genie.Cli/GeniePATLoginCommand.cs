using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    class GeniePATLoginCommand
    {
        public bool isLoggedIn = false;
        public void ProcessLoginPATCommand(string pat, string url)
         {

             string encodedPat = Convert.ToBase64String(Encoding.ASCII.GetBytes($":{pat}"));
             HttpClient client = new HttpClient();
             client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
             client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", encodedPat);
             string apiUrl = $"{url}/_apis/projects?api-version=2.0";
             HttpResponseMessage response = client.GetAsync(apiUrl).Result;
             Console.WriteLine("Response Status Code: " + response.StatusCode);
             string responseContent = response.Content.ReadAsStringAsync().Result;
             if (response.IsSuccessStatusCode && !responseContent.Contains("Azure DevOps Services | Sign In"))
             {
                 Console.WriteLine("Login successful");
                 isLoggedIn=true;
             }
             else
             {
                 Console.WriteLine($"Failed to authenticate with Azure DevOps. Status code: {response.StatusCode}");
                 isLoggedIn=false;
                 //return;
             }
         }
        public bool IsUserLoggedIn()
        {
            return isLoggedIn;
        }
        /*public async void ProcessLoginPATCommand(string pat, string url)
        {
            string encodedPat = Convert.ToBase64String(Encoding.ASCII.GetBytes($":{pat}"));
            HttpClient client = new HttpClient();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", encodedPat);
            string apiUrl = $"{url}/_apis/projects?api-version=2.0";
            HttpResponseMessage response = await client.GetAsync(apiUrl);
            Console.WriteLine("Response Status Code: " + response.StatusCode);
            string responseContent = await response.Content.ReadAsStringAsync();
            if (response.IsSuccessStatusCode && !responseContent.Contains("Azure DevOps Services | Sign In"))
            {
                Console.WriteLine("Login successful");

                // Get the user profile information
                string userApiUrl = $"{url}/_apis/graph/users?api-version=6.0-preview.1";
                HttpResponseMessage userResponse = await client.GetAsync(userApiUrl);
                string userResponseContent = await userResponse.Content.ReadAsStringAsync();

                // Parsing the JSON response content
                dynamic responseObject = JsonConvert.DeserializeObject(userResponseContent);
                dynamic usersArray = responseObject.value;
                dynamic firstUser = usersArray[0];
                string userName = firstUser.displayName;
                string userEmail = firstUser.mailAddress;

                Console.WriteLine("User Name: " + userName);
                Console.WriteLine("User Email: " + userEmail);
            }
            else
            {
                Console.WriteLine($"Failed to authenticate with Azure DevOps. Status code: {response.StatusCode}");
                return;
            }
        }*/

    }
}
