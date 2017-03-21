# frozen_string_literal: true

feature 'samples/index' do
  subject { page }

  describe 'when no endpoint in params' do
    let(:base_samples) do
      routes = Sampler::RoutesInspector.new.routes
      routes.map { |r| [[r[:path], r[:verb]], '0'] }.to_h
    end

    before do
      Sampler.configuration.whitelist = /authors/
      create_list(:sample, 3, request_method: 'POST',
                              endpoint: '/authors(.:format)')
      create_list(:sample, 3, request_method: 'GET', endpoint: '/no_route')
      create_list(:sample, 2, request_method: 'GET',
                              endpoint: '/authors(.:format)')
      create_list(:sample, 2, request_method: 'POST', endpoint: '/no_route')
      visit sampler.samples_path
    end

    let(:samples_count) { base_samples.size + 2 }

    it { should have_table('grouped_samples') }

    it 'should show all existing endpoints and all sampled endpoints' do
      on_page = page.find_all(:xpath, '//tbody/tr/td[position() <= 2]')
                    .map(&:text).each_slice(2).map { |x, y| [x, y] }
      expected = base_samples.keys + (%w(GET POST).map { |m| ['/no_route', m] })

      expect(on_page).to match_array(expected)
    end

    def endpoint_counts(range)
      positions = "position() >= #{range.first} and position() <= #{range.last}"
      page.all(:xpath, "//tbody/tr[#{positions}]/td[position() < 4]")
          .each_slice(3).map { |x| x.map(&:text).join(' ') }
    end

    it 'should sort by sample count first' do
      expect(endpoint_counts(0..2)).to match_array(['/authors(.:format) POST 3',
                                                    '/no_route GET 3'])
      expect(endpoint_counts(3..4)).to match_array(['/authors(.:format) GET 2',
                                                    '/no_route POST 2'])

      zero_samples = base_samples.keys
                                 .reject { |ep, _m| ep == '/authors(.:format)' }
                                 .map { |ep, m| "#{ep} #{m} 0" }
      expect(endpoint_counts(5..samples_count)).to match_array(zero_samples)
    end

    def endpoint_sampled(range)
      positions = "position() >= #{range.first} and position() <= #{range.last}"
      page.all(:xpath, "//tbody/tr[#{positions}]" \
                       '/td[position() <= 2 or position() = 4]')
          .each_slice(3).map { |x| x.map(&:text).join(' ') }
    end

    it 'should sort by sampled?' do
      expect(endpoint_sampled(0..2)).to eql(['/authors(.:format) POST true',
                                             '/no_route GET false'])
      expect(endpoint_sampled(3..4)).to eql(['/authors(.:format) GET true',
                                             '/no_route POST false'])

      zero_samples = base_samples.keys
                                 .reject { |ep, _m| ep == '/authors(.:format)' }

      sampled = zero_samples.select { |ep, _m| ep.include?('authors') }
                            .map { |ep, m| "#{ep} #{m} true" }
      expect(endpoint_sampled(5..(4 + sampled.size))).to match_array(sampled)

      not_sampled = zero_samples.reject { |ep, _m| ep.include?('authors') }
                                .map { |ep, m| "#{ep} #{m} false" }
      expect(endpoint_sampled((5 + sampled.size)..samples_count))
        .to match_array(not_sampled)
    end
  end
end
