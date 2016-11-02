# frozen_string_literal: true
def rand_string
  Array.new(5) { ('a'..'z').to_a.sample }.join
end

describe 'Creating a Sample' do
  before do
    Sampler.configuration.whitelist << ''
    %i(get post patch put delete).each do |m|
      Sampler.configuration.tag_with m, ->(e) { e.method == m }
    end
  end

  shared_examples 'creates a sample' do
    it 'should create a sample' do
      expect(action).to change(Sample, :count).by(1)
    end
    context 'created sample' do
      before { action.call }
      subject(:sample) { Sample.last }
      it 'should have proper endpoint' do
        expect(sample.endpoint).to eq("/#{endpoint}")
      end
      it 'should have proper url' do
        expect(sample.url).to eq(url)
      end
      it 'should have proper method' do
        expect(sample.method).to eq(method)
      end
      it 'should have proper params' do
        expect(sample.params).to eq(params)
      end
      it 'should have proper request_body' do
        expect(sample.request_body).to eq(request_body)
      end
      it 'should have proper response_body' do
        expect(sample.response_body).to eq(response_body)
      end
      it 'should have proper tags' do
        expect(sample.tags).to eq([method.to_s])
      end
    end
  end

  shared_examples 'request with method' do |m|
    let(:method) { m.to_s }
    let(:endpoint) { rand_string }
    let(:response_body) { "whatever_#{params['reply']}" }
    let(:request_params) do
      h = Array.new(5) { [rand_string, rand_string] }.to_h
      h['reply'] = rand_string
      h
    end
    let(:action) do
      lambda do
        opts = if Rails.version >= '5.0.0' then { params: request_params }
               else request_params
               end
        send(method, "/#{path}", opts)
      end
    end

    context 'when path has no query string' do
      let(:path) { endpoint }
      let(:params) { request_params }
      let(:request_body) do
        return '' if method == 'get'
        params.map { |k, v| "#{k}=#{v}" }.join('&')
      end
      let(:url) do
        return "http://www.example.com/#{path}" unless method == 'get'
        query_string = params.map { |k, v| "#{k}=#{v}" }.join('&')
        "http://www.example.com/#{path}?#{query_string}"
      end
      include_examples 'creates a sample'
    end

    context 'when path has query string' do
      let(:path) { "#{endpoint}?query=string" }
      let(:params) { request_params.merge('query' => 'string') }
      let(:request_body) do
        return '' if method == 'get'
        request_params.map { |k, v| "#{k}=#{v}" }.join('&')
      end
      let(:url) do
        return "http://www.example.com/#{path}" unless method == 'get'
        query_string = params.map { |k, v| "#{k}=#{v}" }.join('&')
        "http://www.example.com/#{endpoint}?#{query_string}"
      end
      include_examples 'creates a sample'
    end
  end

  %i(get post patch put delete).each do |m|
    context "when method #{m}" do
      include_examples 'request with method', m
    end
  end
end
