using Azure.Storage.Queues.Models;
using Azure.Storage.Queues;
using Azure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Rhipheus.Genie.Cli
{
    public class GenieBackoffRetryStrategy
    {
        private readonly TimeSpan _maxWaitTime;
        private readonly TimeSpan _initialWaitTime;
        private int _attempt;

       
        public GenieBackoffRetryStrategy(TimeSpan maxWaitTime, TimeSpan? initialWaitTime = null)
        {
            _maxWaitTime = maxWaitTime;
            _initialWaitTime = initialWaitTime ?? TimeSpan.FromSeconds(1);
            _attempt = 0;
        }

        public int MaxAttempts => (int)Math.Ceiling(Math.Log(_maxWaitTime.TotalSeconds / _initialWaitTime.TotalSeconds, 2));

        public TimeSpan GetNextDelay()
        {
            var nextDelay = TimeSpan.FromSeconds(_initialWaitTime.TotalSeconds * Math.Pow(2, _attempt));
            _attempt++;
            if (nextDelay > _maxWaitTime)
            {
                nextDelay = _maxWaitTime;
            }

            return nextDelay;
        }
        public async Task<QueueMessage[]> ReceiveMessagesWithRetryAsync(QueueClient queueClient, int maxMessages)
        {
            GenieBackoffRetryStrategy retryStrategy = new GenieBackoffRetryStrategy(TimeSpan.FromSeconds(10), TimeSpan.FromSeconds(1));
            int retryCount = 0;
            while (retryCount < retryStrategy.MaxAttempts)
            {
                try
                {
                    var messageResponse = await queueClient.ReceiveMessagesAsync(maxMessages: 1, visibilityTimeout: TimeSpan.FromSeconds(5));
                    var messages = messageResponse.Value;
                    // Console.WriteLine("Messages from queue: " + messages.Length);
                    TimeSpan nextDelay = retryStrategy.GetNextDelay();
                    await Task.Delay(nextDelay);
                    retryCount++;
                    return messages;
                }
                catch (RequestFailedException ex)
                {
                    Console.WriteLine("Error Occured:" + ex);
                }
            }
            throw new Exception("Failed to receive messages from the queue within the maximum number of attempts.");
        }
    }
}
