require 'request_queue/middleware'

module RequestQueue
  class Railtie < ::Rails::Railtie
    initializer 'request_queue.insert_middleware' do |app|
      app.config.middleware.insert_after(
        RequestStore::Middleware,
        RequestQueue::Middleware
      )
    end
  end
end
