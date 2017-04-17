# RequestQueue

This is a utility for deduping work on a per-request basis. It works like this:

1. When the request starts, create a queue.
2. Add some work to the queue by calling `RequestQueue.enqueue(some_job)`.
3. Before the request ends, you'll have opportunity to dedupe the work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_queue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request_queue

## Usage

A a job can be any callable, so for example:

```ruby
job = proc { puts 'Hello' }

RequestQueue.enqueue(job)
RequestQueue.enqueue(job)
```

This would output 'Hello' once at the end of the request.

#### Using objects

Because `RequestQueue` accepts any callable, you can also use an object.

```ruby
class Job
  def initialize(message)
    @message = message
  end

  def call
    puts @message
  end
end

job = Job.new('Hello')
RequestQueue.enqueue(job)
RequestQueue.enqueue(job)
```

#### Advanced Deduping

Sometimes, you need a little more control over the deduping.

```ruby
class Job
  def self.filter(jobs)
    jobs.uniq_by(&:message)
  end

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def call
    puts message
  end
end

RequestQueue.enqueue Job.new('Hello')
RequestQueue.enqueue Job.new('Hello')
```

In this example, the job instances are unique, so they wouldn't be automatically deduped. But, when the class of a message responds to `filter`, it will be called and give you the opportunity to provide custom dedupe logic.

## Testing

When testing, sometimes you want a little more control. As such, `RequestQueue` offers multiple queue backends:

* `:default` - Runs jobs at the end of the request.
* `:fake` - Never runs jobs, and allows you to inspect the queue with `RequestQueue.queue.queue`.
* `:inline` - Runs jobs immediately and never adds them to the queue.

To change the queueing backend, you can just say `RequestQueue.use`:

```ruby
RequestQueue.use :inline
```

**NOTE:** Only use the `use` method in the testing environment. It is not thread-safe.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ray Zane/request_queue.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
