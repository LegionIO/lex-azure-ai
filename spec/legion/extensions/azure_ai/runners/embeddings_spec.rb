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

    it 'accepts an array of strings as input' do
      body = { 'data' => [{ 'embedding' => [0.1, 0.2] }, { 'embedding' => [0.3, 0.4] }] }
      allow(conn).to receive(:post)
        .with(anything, hash_including(input: %w[Hello World]))
        .and_return(instance_double(Faraday::Response, body: body))

      result = test_class.create(deployment: deployment, input: %w[Hello World], api_key: api_key, endpoint: endpoint)
      expect(result[:result]['data'].length).to eq(2)
    end

    it 'returns a hash with a :result key' do
      body = { 'data' => [] }
      allow(conn).to receive(:post).and_return(instance_double(Faraday::Response, body: body))

      result = test_class.create(deployment: deployment, input: 'text', api_key: api_key, endpoint: endpoint)
      expect(result).to be_a(Hash)
      expect(result).to have_key(:result)
    end

    it 'returns a :usage key with token counts' do
      body = {
        'data'  => [{ 'embedding' => [0.1, 0.2] }],
        'usage' => {
          'prompt_tokens'         => 6,
          'completion_tokens'     => 0,
          'prompt_tokens_details' => { 'cached_tokens' => 3 }
        }
      }
      allow(conn).to receive(:post).and_return(instance_double(Faraday::Response, body: body))

      result = test_class.create(deployment: deployment, input: 'text', api_key: api_key, endpoint: endpoint)
      expect(result).to have_key(:usage)
      expect(result[:usage][:input_tokens]).to eq(6)
      expect(result[:usage][:output_tokens]).to eq(0)
      expect(result[:usage][:cache_read_tokens]).to eq(3)
      expect(result[:usage][:cache_write_tokens]).to eq(0)
    end

    it 'returns zero usage when usage is absent from response' do
      body = { 'data' => [] }
      allow(conn).to receive(:post).and_return(instance_double(Faraday::Response, body: body))

      result = test_class.create(deployment: deployment, input: 'text', api_key: api_key, endpoint: endpoint)
      expect(result[:usage]).to eq(
        input_tokens:       0,
        output_tokens:      0,
        cache_read_tokens:  0,
        cache_write_tokens: 0
      )
    end

    it 'encodes the deployment name in the path' do
      body = { 'data' => [] }
      expected_path = '/openai/deployments/ada-002/embeddings?api-version=2024-10-21'
      allow(conn).to receive(:post)
        .with(expected_path, anything)
        .and_return(instance_double(Faraday::Response, body: body))

      test_class.create(deployment: 'ada-002', input: 'text', api_key: api_key, endpoint: endpoint)
    end
  end
end
