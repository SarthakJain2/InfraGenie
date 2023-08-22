namespace Rhipheus.Genie.Entities
{
    public class GenieRequest
    {
        public string? Command { get; set; }
        public Parameter[] Parameters { get; set; }
    }

    public class Parameter
    {
        public string? Name { get; set; }
        public string? Value { get; set; }
    }
}