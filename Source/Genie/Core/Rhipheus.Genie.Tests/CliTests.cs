namespace Rhipheus.Genie.Tests
{
    [TestClass]
    public class CliTests
    {
        [TestMethod]
        public void TestPrep()
        {
            var command = "genie prep --project-name genie --folder-name infragenie-core --feed-url https://";
            ExecuteCommand(command);
            Assert.IsTrue(Directory.Exists("infragenie-core"));
            Assert.IsTrue(File.Exists(@"infragenie-core/InfraGenie.nupkg"));
            Assert.IsTrue(Directory.Exists(@"infragenie-core/InfraGenie"));
            Assert.IsTrue(Directory.Exists(@"infragenie-core/InfraGenie/Core"));
            Assert.IsTrue(Directory.Exists(@"infragenie-core/InfraGenie/GenieFx"));
        }

        public void ExecuteCommand(string command)
        {

        }

    }
}