namespace Rhipheus.Genie.Web.Api.Services
{
    public interface IFirstRunService
    {
        //bool IsFirstRun { get; }
        bool CheckFirstRun(IWebHostEnvironment env);
        void DeleteFirstRunFile(IWebHostEnvironment env);

    }
    public class FirstRunService : IFirstRunService
    {
        //public bool IsFirstRun { get; private set; }

        public bool CheckFirstRun(IWebHostEnvironment env)
        {
            string filePath = Path.Combine(env.ContentRootPath, "firstrun.txt");
            return File.Exists(filePath);
        }
        public void DeleteFirstRunFile(IWebHostEnvironment env)
        {
            string filePath = Path.Combine(env.ContentRootPath, "firstrun.txt");
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
            }
        }
    }
}
