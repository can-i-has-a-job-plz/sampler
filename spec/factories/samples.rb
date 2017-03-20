# frozen_string_literal: true

FactoryGirl.define do
  factory :sample, class: 'Sampler::Sample' do
    endpoint '/whatever'
    url { "http://example.org#{endpoint}" }
    request_method 'GET'
    params { { 'param1' => 'value1', 'params2' => 'value2' } }
    request_body ''
    response_body ''
    tags { %w() }
  end
end
