# frozen_string_literal: true
describe Sampler::Middleware, type: :request do
  subject(:delegate) do
    s = ActiveSupport::Notifications.subscribe('request.sampler') {}
    s.instance_variable_get(:@delegate)
  end

  it 'should send request.sampler notifications' do
    should receive(:call).with('request.sampler', any_args).once
    get '/'
  end
end
