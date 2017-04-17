require 'test_helper'

class RequestQueueTest < Minitest::Test
  class Message
    attr_reader :hits

    def initialize
      @hits = 0
    end

    def call
      @hits += 1
    end

    def called?
      @hits > 0
    end
  end

  class FilterMessage < Message
    def self.filter(messages)
      []
    end
  end

  def setup
    RequestQueue.use :default
  end

  def test_enqueue
    message = Message.new

    RequestQueue.process do
      RequestQueue.enqueue(message)
      refute message.called?
    end

    assert message.called?
  end

  def test_dedupe
    message = Message.new

    RequestQueue.process do
      RequestQueue.enqueue(message)
      RequestQueue.enqueue(message)
    end

    assert_equal 1, message.hits
  end

  def test_manual_dedupe
    m1 = Message.new
    m2 = FilterMessage.new

    RequestQueue.process do
      RequestQueue.enqueue(m1)
      RequestQueue.enqueue(m2)
    end

    refute m1.called?
    refute m2.called?
  end

  def test_use_default
    assert_nil RequestQueue.queue

    RequestQueue.process do
      assert_kind_of RequestQueue::Queue, RequestQueue.queue
    end
  end

  def test_use_fake
    RequestQueue.use :fake

    assert_nil RequestQueue.queue

    RequestQueue.process do
      assert_kind_of RequestQueue::FakeQueue, RequestQueue.queue
    end
  end


  def test_use_inline
    RequestQueue.use :inline

    assert_nil RequestQueue.queue

    RequestQueue.process do
      assert_kind_of RequestQueue::InlineQueue, RequestQueue.queue
    end
  end

  def test_fake
    RequestQueue.use :fake

    message = Message.new

    RequestQueue.process do
      RequestQueue.enqueue(message)
      assert_equal 1, RequestQueue.queue.queue.length
    end

    refute message.called?
  end

  def test_inline
    RequestQueue.use :inline

    message = Message.new

    RequestQueue.process do
      RequestQueue.enqueue(message)
      assert message.called?
    end

    assert_equal 1, message.hits
  end
end
