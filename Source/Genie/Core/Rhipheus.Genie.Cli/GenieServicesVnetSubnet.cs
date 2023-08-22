using System.Net;

namespace Rhipheus.Genie.Cli
{
    public class GenieServicesVnetSubnet
    {
       /* public string Name { get; set; }
        public bool RequiredDedicatedSubnet { get; set; }
        public string AddressPrefix { get; set; }
        public string Role { get; set; }

        // list of services as input if RequiredDedicatedSubnet is true then calculate Vnet & Subnet
        public void CalculateAndAssignProperties(List<GenieServicesVnetSubnet> services)
        {
            IPNetwork network = IPNetwork.Parse("10.0.0.0/16");//Starting range

            foreach (var service in services)
            {
                if (service.RequiredDedicatedSubnet)
                {
                    var subnets = IPNetwork.Subnet(network, 24);
                    service.AddressPrefix = subnets.First().ToString();//next service will get next address
                    network = subnets.Skip(1).First();
                    Console.WriteLine(service.Name);
                    Console.WriteLine(service.AddressPrefix);
                }
                else
                {
                    service.Role = "primary"; //RquiredDedicatedSubnet is false
                }
            }
        }*/
    }

}
