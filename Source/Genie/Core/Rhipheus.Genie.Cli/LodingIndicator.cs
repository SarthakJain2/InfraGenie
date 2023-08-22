using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    class LoadingIndicator
    {
        private const int delay = 100;
        private bool isRunning = false;

        public void Start()
        {
            this.isRunning = true;
            Task.Run(() =>
            {
                while (this.isRunning)
                {
                    Console.Write(".");
                    Thread.Sleep(delay);
                }
            });
        }

        public void Stop()
        {
            this.isRunning = false;
        }
    }
}
