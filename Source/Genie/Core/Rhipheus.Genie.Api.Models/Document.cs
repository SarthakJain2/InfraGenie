using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace Rhipheus.Genie.Api.Models;

public partial class Document
{
    public Guid Id { get; set; }

    public Guid LinkedId { get; set; }

    public string LinkType { get; set; } = null!;

    public string Location { get; set; } = null!;

    [JsonIgnore]
    public virtual ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();
}
