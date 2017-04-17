module RequestQueue
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      RequestQueue.process do
        @app.call(env)
      end
    end
  end
end
