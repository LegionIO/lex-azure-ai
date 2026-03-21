# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Runners::Chat do
  let(:test_class) do
    Class.new do
      extend Legion::Extensions::AzureAi::Helpers::Client
      extend Legion::Extensions::AzureAi::Runners::Chat
    end
  end
  let(:api_key)    { 'test-azure-key' }
  let(:endpoint)   { 'my-resource' }
  let(:deployment) { 'gpt-4o' }
  let(:conn)       { instance_double(Faraday::Connection) }
  let(:response)   { instance_double(Faraday::Response, body: response_body) }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
  end

  describe '#create' do
    let(:response_body) do
      { 'id' => 'chatcmpl-123', 'choices' => [{ 'message' => { 'content' => 'Hello!' } }] }
    end

    it 'creates a chat completion' do
      messages = [{ role: 'user', content: 'Hi' }]
      expected_path = "/openai/deployments/#{deployment}/chat/completions?api-version=2024-10-21"
      allow(conn).to receive(:post)
        .with(expected_path, hash_including(messages: messages))
        .and_return(response)

      result = test_class.create(deployment: deployment, messages: messages, api_key: api_key, endpoint: endpoint)
      expect(result[:result]).to eq(response_body)
    end

    it 'includes optional parameters when provided' do
      messages = [{ role: 'user', content: 'Hi' }]
      expected_path = "/openai/deployments/#{deployment}/chat/completions?api-version=2024-10-21"
      allow(conn).to receive(:post)
        .with(expected_path, hash_including(temperature: 0.7, max_tokens: 100))
        .and_return(response)

      result = test_class.create(
        deployment:  deployment,
        messages:    messages,
        api_key:     api_key,
        endpoint:    endpoint,
        temperature: 0.7,
        max_tokens:  100
      )
      expect(result[:result]).to eq(response_body)
    end

    it 'uses a custom api_version in the path' do
      messages = [{ role: 'user', content: 'Hi' }]
      expected_path = "/openai/deployments/#{deployment}/chat/completions?api-version=2024-05-01"
      allow(conn).to receive(:post)
        .with(expected_path, anything)
        .and_return(response)

      result = test_class.create(
        deployment:  deployment,
        messages:    messages,
        api_key:     api_key,
        endpoint:    endpoint,
        api_version: '2024-05-01'
      )
      expect(result[:result]).to eq(response_body)
    end
  end
end
