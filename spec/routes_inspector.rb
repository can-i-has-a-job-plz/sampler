# frozen_string_literal: true

describe Sampler::RoutesInspector do
  # TODO: write proper spec
  context '#routes' do
    subject(:routes) { described_class.new.routes }
    let(:expected) do
      # rubocop:disable Metrics/LineLength
      [{ name: 'authors', verb: 'GET', path: '/authors(.:format)', reqs: 'authors#index' },
       { name: '', verb: 'POST', path: '/authors(.:format)', reqs: 'authors#create' },
       { name: 'new_author', verb: 'GET', path: '/authors/new(.:format)', reqs: 'authors#new' },
       { name: 'edit_author', verb: 'GET', path: '/authors/:id/edit(.:format)', reqs: 'authors#edit' },
       { name: 'author', verb: 'GET', path: '/authors/:id(.:format)', reqs: 'authors#show' },
       { name: '', verb: 'PATCH', path: '/authors/:id(.:format)', reqs: 'authors#update' },
       { name: '', verb: 'PUT', path: '/authors/:id(.:format)', reqs: 'authors#update' },
       { name: '', verb: 'DELETE', path: '/authors/:id(.:format)', reqs: 'authors#destroy' },
       { name: '', verb: 'GET', path: '/books/:id(.:format)', reqs: 'controller#action {:id=>/\\d+/}' },
       { name: '', verb: 'GET', path: '/books/*whatever(.:format)', reqs: 'controller#action' },
       { name: 'samples', verb: 'GET', path: '/sampler/samples(.:format)', reqs: 'sampler/samples#index' }]
      # rubocop:enable Metrics/LineLength
    end
    it 'should return proper routes' do
      should eql(expected)
    end
  end
end
