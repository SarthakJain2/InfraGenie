using System;
using System.Collections.Generic;

namespace Rhipheus.Genie.Api.Models;

public partial class Tenant
{
    public Guid Id { get; set; }

    public string TenantId { get; set; } = null!;
}
