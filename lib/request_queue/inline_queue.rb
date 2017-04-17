require 'request_queue/queue'

module RequestQueue
  class InlineQueue < Queue
    def <<(message)
      message.call
    end

    def process
    end
  end
end
