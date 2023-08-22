using System;
using System.Collections.Generic;

namespace Rhipheus.Genie.Entities;

public partial class Document
{
    public Guid Id { get; set; }

    public Guid LinkedId { get; set; }

    public string LinkType { get; set; } = null!;

    public string Location { get; set; } = null!;

    public virtual ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();
}
