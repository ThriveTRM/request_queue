require 'request_store'
require 'request_queue/version'
require 'request_queue/queue'
require 'request_queue/inline_queue'
require 'request_queue/fake_queue'
require 'request_queue/middleware'
require 'request_store/railtie' if defined?(Rails::Railtie)

module RequestQueue
  BACKENDS = {
    inline: RequestQueue::InlineQueue,
    fake: RequestQueue::FakeQueue,
    default: RequestQueue::Queue
  }

  class MissingQueueError < StandardError
  end

  class << self
    def backend
      @backend || BACKENDS[:default]
    end

    def use(type)
      @backend = BACKENDS.fetch(type)
    end

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

    def process
      self.queue = backend.new
      yield if block_given?
      queue.process
    ensure
      self.queue = nil
    end
  end
end
