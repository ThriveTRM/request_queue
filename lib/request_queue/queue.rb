require 'set'

module RequestQueue
  class Queue
    def initialize
      @queue = Set.new
    end

    def <<(message)
      @queue << message
    end

    def process!
      filter.each(&:call)
    end
    alias process process!

    private

    def filter
      klasses = @queue.map(&:class).to_a.uniq

      klasses.inject(@queue) do |acc, klass|
        if klass.respond_to?(:filter)
          klass.filter(acc)
        else
          acc
        end
      end
    end
  end
end
