require 'test_helper'

class RequestQueueTest < Minitest::Test
  class Message
    attr_reader :hits

    def initialize
      @hits = 0
    end

    def process
      @hits += 1
    end

    def processed?
      @hits > 0
    end
  end

  def test_enqueue
    message = Message.new

    RequestQueue.process do
      RequestQueue.enqueue(message)
      refute message.processed?
    end

    assert message.processed?
  end
end
