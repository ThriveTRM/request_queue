require 'request_queue/queue'

module RequestQueue
  class FakeQueue < Queue
    attr_reader :queue

    def process
    end
  end
end
