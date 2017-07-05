require 'request_store'
require 'request_queue/version'
require 'request_queue/queue'
require 'request_queue/inline_queue'
require 'request_queue/fake_queue'
require 'request_queue/middleware'

module RequestQueue
  BACKENDS = {
    inline: RequestQueue::InlineQueue,
    fake: RequestQueue::FakeQueue,
    default: RequestQueue::Queue
  }

  class MissingQueueError < StandardError
  end

  class << self
    def queue=(value)
      RequestStore.store[:request_queue] = value
    end

    def queue
      RequestStore.store[:request_queue]
    end

    def enqueue(message)
      if queue.nil?
        raise MissingQueueError, 'You need to wrap this call in RequestQueue.process {}'
      end

      queue << message
    end

    def process(backend = :default)
      original_queue = self.queue
      self.queue = BACKENDS.fetch(backend).new
      result = yield if block_given?
      queue.process unless queue.nil?
      result
    ensure
      self.queue = original_queue
    end
  end
end
