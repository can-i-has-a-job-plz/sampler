Sampler.configure do |config|
  # Class of probe model, ORM will be determined for that model all probes will
  #  be saved as instances of that model
  config.probe_class = <%= model_name.classify %>
  #
  # Whitelisting/blacklisting:
  # whitelist (blacklist works the same way) is, basically, a set of rules for
  #   filtering events. Rules can be:
  #   1. String -- returns true if string is subscting of event's url
  #   2. Regexp -- returns true if event's url matches regexp
  #   3. Proc -- proc will be called w/ event provided and it'll return true
  #        unless proc execution result nil or false. Description of the event
  #        object can be found at the bootom of the file.
  # If at least one rule returns true, list returns true.
  # By default both lists are empty, so no probes will be saved since no rules
  #   in the whitelist returns `true`.
  # config.whitelist << %r{my/lovely/endpoint/}
  # config.whitelist << ''
  # config.blacklist << ->(e) { event.response.content_type != 'text/plain' }
  #
  # Tagging filters work exactly the same as white/blacklists.
  #   each tag has own filterset, if filterset returns true -- tag will be
  #   applied to saved probe
  # config.tag_with "slow", ->(e) { event.duration > 200 }
  #
  # Rate limiting
  # config.max_probes_per_hour = 100
  # If there is more that max_probes_per_hour probes for the last 60 minutes,
  #   oldes ones will be deleted
  # config.max_probes_per_endpoint = 10
  # If there is more than max_probes_per_endpoint probes for the specific
  #   endpoint, oldest ones will be deleted
  # config.retention_period = 3600
  # Probes older that retention_period seconds will be removed.
end

Sampler.start # start Sampler, can be stopped with `Sampler.stop`

# Event is basically ActiveSupport::Notifications::Event
# See also http://guides.rubyonrails.org/active_support_instrumentation.html
#
# payload is a Hash with the following keys:
# endpoint: request path
# url: full url of request (schema+host+port+path+query_string)
# method: is a Symbol of request method (:get, :post, etc)
# params: request params decoded with ActionDispatch
# request: ActionDispatch::Request with the request info.
#   NB! request can be changed by next rack middlewares/apps, so provided info
#   can differ from real request's one.
# request_body: body of the request as String
# response_body: body of the response as String
# response: ActionDispatch::Response object, see :request for NB!.
#
# All keys has getters, so you can get `event.payload[:ur;]`, for example,
#   as `event.payload.url`
