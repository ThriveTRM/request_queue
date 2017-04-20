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

  def test_enqueue
    message = Message.new

    q.process do
      q.enqueue(message)
      refute message.called?
    end

    assert message.called?
  end

  def test_dedupe
    message = Message.new

    q.process do
      q.enqueue(message)
      q.enqueue(message)
    end

    assert_equal 1, message.hits
  end

  def test_manual_dedupe
    m1 = Message.new
    m2 = FilterMessage.new

    q.process do
      q.enqueue(m1)
      q.enqueue(m2)
    end

    refute m1.called?
    refute m2.called?
  end

  def test_backend_default
    q.process :default do
      assert_kind_of q::Queue, q.queue
    end
  end

  def test_backend_fake
    q.process :fake do
      assert_kind_of RequestQueue::FakeQueue, q.queue
    end
  end

  def test_backend_inline
    q.process :inline do
      assert_kind_of RequestQueue::InlineQueue, q.queue
    end
  end

  def test_fake_queue
    message = Message.new

    q.process :fake do
      q.enqueue(message)
      assert_equal 1, q.queue.queue.length
    end

    refute message.called?
  end

  def test_inline_queue
    message = Message.new

    q.process :inline do
      q.enqueue(message)
      assert message.called?
    end

    assert_equal 1, message.hits
  end

  def test_nesting
    assert_nil q.queue

    q.process do
      assert_kind_of RequestQueue::Queue, q.queue

      q.process :fake do
        assert_kind_of RequestQueue::FakeQueue, q.queue

        q.process :inline do
          assert_kind_of RequestQueue::InlineQueue, q.queue
        end
      end
    end

    assert_nil q.queue
  end

  def test_process_returns_value_from_block
    assert_equal 1, q.process { 1 }
  end

  private

  def q
    RequestQueue
  end
end
