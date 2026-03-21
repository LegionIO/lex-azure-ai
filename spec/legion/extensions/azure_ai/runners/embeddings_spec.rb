# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Runners::Embeddings do
  let(:test_class) do
    Class.new do
      extend Legion::Extensions::AzureAi::Helpers::Client
      extend Legion::Extensions::AzureAi::Runners::Embeddings
    end
  end
  let(:api_key)    { 'test-azure-key' }
  let(:endpoint)   { 'my-resource' }
  let(:deployment) { 'text-embedding-ada-002' }
  let(:conn)       { instance_double(Faraday::Connection) }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
  end

  describe '#create' do
    it 'creates embeddings for input text' do
      body = { 'data' => [{ 'embedding' => [0.1, 0.2, 0.3] }] }
      expected_path = "/openai/deployments/#{deployment}/embeddings?api-version=2024-10-21"
      allow(conn).to receive(:post)
        .with(expected_path, hash_including(input: 'Hello'))
        .and_return(instance_double(Faraday::Response, body: body))

      result = test_class.create(deployment: deployment, input: 'Hello', api_key: api_key, endpoint: endpoint)
      expect(result[:result]['data'].first['embedding']).to eq([0.1, 0.2, 0.3])
    end

    it 'uses a custom api_version in the path' do
      body = { 'data' => [] }
      expected_path = "/openai/deployments/#{deployment}/embeddings?api-version=2024-05-01"
      allow(conn).to receive(:post)
        .with(expected_path, anything)
        .and_return(instance_double(Faraday::Response, body: body))

      result = test_class.create(
        deployment:  deployment,
        input:       'Hello',
        api_key:     api_key,
        endpoint:    endpoint,
        api_version: '2024-05-01'
      )
      expect(result[:result]).to eq(body)
    end
  end
end
