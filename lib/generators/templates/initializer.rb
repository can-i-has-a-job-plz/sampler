Sampler.configure do |config|
  # Class of probe model, ORM will be determined for that model all probes will
  #  be saved as instances of that model
  config.probe_class = <%= model_name.classify %>
  config.logger = Rails.logger
  #
  # whitelist -- Regexp, sample will be saved if it's endpoint matches
  # config.whitelist = %r{/my/lovely/endpoint/}
  # blacklist -- Set, sample will not be saved if it's endpoint is included
  # config.blacklist << '/my/lovely/endpoint/123'
  #
  # Tagging -- lambda with arity 1, tag will be applied `if lamda.call(event)`
  # config.tag_with "slow", ->(e) { event.duration > 200 }
  #
  # Rate limiting
  # config.max_probes_per_hour = 100
  # If there is more that max_probes_per_hour probes for the last 60 minutes,
  #   oldest ones will be deleted
  # config.max_probes_per_endpoint = 10
  # If there is more than max_probes_per_endpoint probes for the specific
  #   endpoint, oldest ones will be deleted
  # config.retention_period = 3600
  # Probes older that retention_period seconds will be removed.
end

Sampler.start # start Sampler, can be stopped with `Sampler.stop`

# Event is a struct with a following keyss:
# endpoint: request path
# url: full url of request (schema+host+port+path+query_string)
# method: is a Symbol of request method (:get, :post, etc)
# params: request params decoded with ActionDispatch
# request: ActionDispatch::Request with the request info.
#   NB! request can be changed by next rack middlewares/apps, so provided info
#   can differ from real request's one.
# request_body: body of the request as String
# response_body: body of the response as String, nil if app raised
# response: ActionDispatch::Response object, see :request for NB!.
#   If app raised, exception will be returned instead if response.
# start: when app execution started
# finish: when app execution completed
# duration: difference between finish and start in ms
