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
    it { should have_button('Delete all samples') }

    it 'should show all existing endpoints and all sampled endpoints' do
      on_page = page.find_all(:xpath, '//tbody/tr/td[position() <= 2]')
                    .map(&:text).each_slice(2).map { |x, y| [x, y] }
      expected = base_samples.keys + (%w(GET POST).map { |m| ['/no_route', m] })

      expect(on_page).to match_array(expected)
    end

    it 'should have "Delete" buttons for endpoints with samples' do
      page.all(:xpath, '//tbody/tr')[0..3].each do |row|
        expect(row).to have_button('Delete')
      end
    end

    it 'should not have "Delete" buttons for endpoints without samples' do
      page.all(:xpath, '//tbody/tr')[4..samples_count].each do |row|
        expect(row).not_to have_button('Delete')
      end
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

    context '"Delete all samples" button' do
      it 'should delete all samples' do
        expect { find_button('Delete all samples').click }
          .to change(Sampler::Sample, :count).to(0)
      end
    end
    context '"Delete" button' do
      let(:ep) do
        page.all(:xpath, '//tbody/tr[1]/td[position() <= 2]').map(&:text)
      end
      let(:button) do
        page.find(:xpath, '//tbody/tr[1]').find_button('Delete')
      end
      subject(:action) { -> { button.click } }

      it 'should delete proper number of samples' do
        should change(Sampler::Sample, :count).by(-3)
      end

      it 'should delete all samples for endpoint & method' do
        opts = { endpoint: ep.first, request_method: ep.last }
        should change { Sampler::Sample.where(opts).count }.to(0)
      end
    end
  end
end
