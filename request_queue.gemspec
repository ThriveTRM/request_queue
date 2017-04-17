# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_queue/version'

Gem::Specification.new do |spec|
  spec.name          = 'request_queue'
  spec.version       = RequestQueue::VERSION
  spec.authors       = ['Ray Zane']
  spec.email         = ['raymondzane@gmail.com']

  spec.summary       = 'Dedupe tasks on a per-request basis'
  spec.homepage      = 'https://github.com/rzane/request_queue'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'request_store'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
