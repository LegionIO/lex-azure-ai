# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Client do
  let(:api_key)  { 'test-azure-key' }
  let(:endpoint) { 'my-resource' }
  let(:client)   { described_class.new(api_key: api_key, endpoint: endpoint) }

  it 'stores config on initialization' do
    expect(client.config[:api_key]).to eq(api_key)
    expect(client.config[:endpoint]).to eq(endpoint)
    expect(client.config[:api_version]).to eq('2024-10-21')
  end

  it 'accepts a custom api_version' do
    c = described_class.new(api_key: api_key, endpoint: endpoint, api_version: '2024-05-01')
    expect(c.config[:api_version]).to eq('2024-05-01')
  end

  it 'includes Chat runner methods' do
    expect(client).to respond_to(:create)
  end

  it 'includes Embeddings runner methods' do
    expect(client).to respond_to(:create)
  end

  it 'includes Models runner methods' do
    expect(client).to respond_to(:list)
  end
end
