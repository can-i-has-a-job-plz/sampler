Sampler.configure do |config|
  config.probe_class = <%= model_name.classify %>
  config.logger = Rails.logger
end

Sampler.start
