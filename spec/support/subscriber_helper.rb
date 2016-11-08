# frozen_string_literal: true
module SubscriberHelper # :nodoc:
  def listeners
    lf = Sampler::Notifications.notifier.listeners_for('request.sampler')
    # Select only unicast listeners, we don't want to have multicast subscribers
    #    created with `.subscribe(nil, &block)` to be returned here
    lf
      .select { |l| l.instance_variable_get(:@pattern) == 'request.sampler' }
  end

  RSpec.shared_context 'cleanup subscribers' do
    before do
      # Just to have another listener during tests
      Sampler::Subscriber.new
    end
  end
end

RSpec.configure do |config|
  config.include_context 'cleanup subscribers', :subscriber
  config.include SubscriberHelper, :subscriber
end
