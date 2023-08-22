using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//using Microsoft.AspNetCore.Http;

namespace Rhipheus.Genie.Api.Models
{
    public class ChatMessageBinding
    {
        public Guid ThreadId { get; set; }
        public Guid GroupId { get; set; }

        public string Request { get; set; } = null!;
       
    }
}
