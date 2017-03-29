# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sampler/version'

Gem::Specification.new do |spec|
  spec.name          = 'sampler'
  spec.version       = Sampler::VERSION
  spec.authors       = ['ojab']
  spec.email         = ['ojab@ojab.ru']

  spec.summary       = 'Just a gem to get a job'
  spec.description   = "Let's instrument something"
  spec.homepage      = 'http://cultofmartians.com/tasks/api-endpoint-sampler.html'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.5'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'shoulda-matchers', '~> 3.1'
  spec.add_development_dependency 'factory_girl_rails', '~> 4.8'
  spec.add_development_dependency 'database_cleaner', '~> 1.5'
  spec.add_development_dependency 'poltergeist', '~> 1.14'
  spec.add_development_dependency 'sprockets', '~> 3.0'
  spec.add_development_dependency 'jquery-rails'

  spec.add_dependency 'rails', '~> 5.0.0'
  spec.add_dependency 'pg'
end
