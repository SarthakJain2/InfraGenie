using System;
using System.Collections.Generic;

namespace Rhipheus.Genie.Entities;

public partial class ChatMessage
{
    public Guid Id { get; set; }

    public Guid ThreadId { get; set; }

    public Guid GroupId { get; set; }

    public string Request { get; set; } = null!;

    public string Response { get; set; } = null!;

    public int Attempt { get; set; }

    public Guid? DocumentId { get; set; }

    public DateTime? DateCreated { get; set; }

    public virtual Document? Document { get; set; }

    public virtual ChatThread Thread { get; set; } = null!;
}
