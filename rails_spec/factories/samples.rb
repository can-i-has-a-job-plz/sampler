# frozen_string_literal: true
FactoryGirl.define do
  factory :sample do
    endpoint '/whatever'
    url { "http://example.org#{endpoint}" }
    add_attribute(:method, 'get')
    params { { 'param1' => 'value1', 'params2' => 'value2' } }
    tags { %w(some tags) }
    request_body ''
    response_body ''
  end
end
