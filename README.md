# Sampler

Oh hai! It's sampler gem, it samples requests to Rack apps (e. g. Rails apps)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sampler', path: '../sampler'
```

And then execute:

    $ bundle

After that you'll need to create initializer/model/controller/view for sampler, it can be done by simply running

    $ bundle exec rails g sampler:install

in directory with you rails application. This command will create Sample model (and related migration), SamplesController w/ views, and `config/initializer/sampler.rb` with example configuration, and required routes:

```
samples POST   /samples(.:format)     samples#update
        GET    /samples(.:format)     samples#index
sample  GET    /samples/:id(.:format) samples#show
        DELETE /samples/:id(.:format) samples#destroy
```

See initializer for further info.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
