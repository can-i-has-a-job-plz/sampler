# frozen_string_literal: true

FactoryGirl.define do
  factory :event, class: Sampler::Event do
    skip_create

    transient do
      finalized true
      env { Rack::MockRequest.env_for(endpoint || 'got_nil') }
      request { ActionDispatch::Request.new(env) }
      response { ActionDispatch::Response.new(201, {}, 'body') }
    end

    sequence(:endpoint) { |n| "/endpoint#{n}" }
    initialize_with { new(endpoint, request) }

    after(:build) do |event, evaluator|
      event.finalize(evaluator.response) if evaluator.finalized
    end
  end
end
