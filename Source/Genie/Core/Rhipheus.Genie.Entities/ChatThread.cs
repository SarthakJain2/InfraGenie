using System;
using System.Collections.Generic;

namespace Rhipheus.Genie.Entities;

public partial class ChatThread
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public DateTime DateCreated { get; set; }

    public virtual ICollection<ChatMessage> ChatMessages { get; set; } = new List<ChatMessage>();
}
