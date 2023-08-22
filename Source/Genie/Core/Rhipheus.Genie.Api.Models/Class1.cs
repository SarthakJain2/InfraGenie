namespace Rhipheus.Genie.Api.Models
{
    public class GenieRequest
    {
        public string? Request { get; set; }
        public string? Command { get; set; }
        public Parameter[] Parameters { get; set; }
        public string? SessionId { get; set; }
        public string ThreadId { get; set; }

    }

    public class Parameter
    {
        public string? Name { get; set; }
        public string? Value { get; set; }
    }
}