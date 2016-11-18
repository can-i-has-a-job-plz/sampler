# frozen_string_literal: true
FactoryGirl.define do
  factory :event, class: Sampler::Event do
    skip_create

    transient do
      path { endpoint }
      response_status 200
      response_headers { {} }
    end

    sequence(:time_diff) do |n|
      initial = 0.001
      n.times { initial = initial.next_float }
      initial
    end

    endpoint '/whatever'
    request { ActionDispatch::Request.new(Rack::MockRequest.env_for(path)) }
    response do
      ActionDispatch::Response.new(*Rack::Response.new(response_body,
                                                       response_status,
                                                       response_headers))
    end
    url { request.url.freeze }
    add_attribute(:method) { request.method.freeze }
    params { request.params.freeze }
    request_body { '' }
    response_body { 'whatever' }
    start { Time.now.utc }
    finish { start + time_diff }
  end
end
