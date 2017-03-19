# frozen_string_literal: true

describe 'SamplerApp', type: :rack_request do
  context 'response' do
    before { post '/' }

    context 'status' do
      it { expect(last_response.status).to eql(201) }
    end

    context 'headers' do
      it do
        expect(last_response.headers).to eql('Header' => 'Value',
                                             'Content-Length' => '0')
      end
    end

    context 'body' do
      context 'when request body is "what=ever"' do
        before { post '/', what: :ever }
        it { expect(last_response.body).to eql('what=ever') }
      end
      before { post '/', not: :fake }
      context 'when requst body is "not=fake"' do
        it { expect(last_response.body).to eql('not=fake') }
      end
    end
  end
end
