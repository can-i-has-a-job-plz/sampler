# frozen_string_literal: true

Sampler.configure do |config|
  # Logger that will be used by Sampler
  config.logger = Rails.logger

  # whitelist -- Regexp, sample will be saved if it's endpoint matches
  config.whitelist = /sampler/

  # blacklist -- Set, sample will not be saved if it's endpoint is included
  # config.blacklist << '/my/lovely/endpoint/123'

  # Tagging -- lambda with arity 1, tag will be applied `if lamda.call(event)`
  # config.tag_with "slow", ->(e) { event.duration > 200 }

  # Execution interval (seconds) -- how often Samples will be saved from
  # temporary storage into DB.
  config.execution_interval = 60

  # Maximum number of samples for the [endpoint, request_method] tuple.
  # Old samples will be deleted if exceeded. No limit if nil.
  # config.max_per_endpoint = nil
end

# start Sampler, can be stopped with `Sampler.stop`
Sampler.start unless Rails.const_defined?('Console')

# Event is a struct with a following keyss:
# endpoint: request path
# url: full url of request (schema+host+port+path+query_string)
# request_method: is a String of request method ('GET', 'POST', etc)
# params: request params decoded with ActionDispatch
# request: ActionDispatch::Request with the request info.
#   NB! request can be changed by next rack middlewares/apps, so provided info
#   can differ from real request's one.
# request_body: body of the request as String
# response_body: body of the response as String, nil if app raised
# response: ActionDispatch::Response object, see :request for NB!.
#   If app raised, exception will be returned instead if response.
# created_at: when app execution started
# updated_at: when app execution completed
