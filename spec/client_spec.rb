# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Client do
  let(:api_key)      { 'test-azure-key' }
  let(:endpoint)     { 'my-resource' }
  let(:faraday_conn) { instance_double(Faraday::Connection) }
  let(:client)       { described_class.new(api_key: api_key, endpoint: endpoint) }

  before do
    allow(Faraday).to receive(:new).and_return(faraday_conn)
  end

  it 'stores config on initialization' do
    expect(client.config[:api_key]).to eq(api_key)
    expect(client.config[:endpoint]).to eq(endpoint)
    expect(client.config[:api_version]).to eq('2024-10-21')
  end

  it 'accepts a custom api_version' do
    c = described_class.new(api_key: api_key, endpoint: endpoint, api_version: '2024-05-01')
    expect(c.config[:api_version]).to eq('2024-05-01')
  end

  it 'passes extra opts through to config' do
    c = described_class.new(api_key: api_key, endpoint: endpoint, timeout: 30)
    expect(c.config[:timeout]).to eq(30)
  end

  it 'includes Chat runner methods' do
    expect(client).to respond_to(:create)
  end

  it 'includes Models runner methods' do
    expect(client).to respond_to(:list)
  end

  describe '#create (embeddings delegation, last-included module wins)' do
    let(:response_body) { { 'data' => [{ 'embedding' => [0.1, 0.2] }] } }
    let(:response)      { instance_double(Faraday::Response, body: response_body) }

    it 'delegates create to the Embeddings runner via the internal client' do
      allow(faraday_conn).to receive(:post).and_return(response)

      result = client.create(
        deployment: 'text-embedding-ada-002',
        input:      'hello',
        api_key:    api_key,
        endpoint:   endpoint
      )
      expect(result[:result]).to eq(response_body)
    end
  end

  describe '#list (models delegation)' do
    let(:response_body) { { 'data' => [{ 'id' => 'gpt-4o' }] } }
    let(:response)      { instance_double(Faraday::Response, body: response_body) }

    it 'delegates list to the Models runner via the internal client' do
      allow(faraday_conn).to receive(:get).and_return(response)

      result = client.list(api_key: api_key, endpoint: endpoint)
      expect(result[:models]).to eq(response_body)
    end
  end
end
