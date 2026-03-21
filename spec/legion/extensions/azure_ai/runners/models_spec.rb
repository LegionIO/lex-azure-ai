# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Runners::Models do
  let(:test_class) do
    Class.new do
      extend Legion::Extensions::AzureAi::Helpers::Client
      extend Legion::Extensions::AzureAi::Runners::Models
    end
  end
  let(:api_key)  { 'test-azure-key' }
  let(:endpoint) { 'my-resource' }
  let(:conn)     { instance_double(Faraday::Connection) }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
  end

  describe '#list' do
    it 'lists available models' do
      body = { 'data' => [{ 'id' => 'gpt-4o' }, { 'id' => 'text-embedding-ada-002' }] }
      expected_path = '/openai/models?api-version=2024-10-21'
      allow(conn).to receive(:get)
        .with(expected_path)
        .and_return(instance_double(Faraday::Response, body: body))

      result = test_class.list(api_key: api_key, endpoint: endpoint)
      expect(result[:models]['data'].length).to eq(2)
    end

    it 'uses a custom api_version in the path' do
      body = { 'data' => [] }
      expected_path = '/openai/models?api-version=2024-05-01'
      allow(conn).to receive(:get)
        .with(expected_path)
        .and_return(instance_double(Faraday::Response, body: body))

      result = test_class.list(api_key: api_key, endpoint: endpoint, api_version: '2024-05-01')
      expect(result[:models]).to eq(body)
    end
  end
end
