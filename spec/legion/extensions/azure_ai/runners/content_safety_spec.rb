# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Runners::ContentSafety do
  let(:test_class) do
    Class.new do
      extend Legion::Extensions::AzureAi::Helpers::Client
      extend Legion::Extensions::AzureAi::Runners::ContentSafety
    end
  end
  let(:api_key)  { 'test-azure-key' }
  let(:endpoint) { 'my-resource' }
  let(:conn)     { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response, body: response_body) }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
  end

  describe '#check_text' do
    let(:response_body) do
      {
        'categoriesAnalysis' => [
          { 'category' => 'Hate', 'severity' => 0 },
          { 'category' => 'Violence', 'severity' => 0 },
          { 'category' => 'SelfHarm', 'severity' => 0 },
          { 'category' => 'Sexual', 'severity' => 0 }
        ]
      }
    end

    it 'returns blocked: false when all severities are below threshold' do
      expected_path = '/contentsafety/text:analyze?api-version=2024-09-01'
      allow(conn).to receive(:post)
        .with(expected_path, hash_including(text: 'hello world'))
        .and_return(response)

      result = test_class.check_text(content: 'hello world', api_key: api_key, endpoint: endpoint)
      expect(result[:result][:blocked]).to be false
      expect(result[:result][:reasons]).to be_empty
    end

    it 'returns blocked: true with reasons when severities meet threshold' do
      flagged_body = {
        'categoriesAnalysis' => [
          { 'category' => 'Hate', 'severity' => 4 },
          { 'category' => 'Violence', 'severity' => 0 },
          { 'category' => 'SelfHarm', 'severity' => 0 },
          { 'category' => 'Sexual', 'severity' => 2 }
        ]
      }
      allow(conn).to receive(:post)
        .and_return(instance_double(Faraday::Response, body: flagged_body))

      result = test_class.check_text(content: 'bad content', api_key: api_key, endpoint: endpoint)
      expect(result[:result][:blocked]).to be true
      expect(result[:result][:reasons]).to contain_exactly('Hate', 'Sexual')
    end

    it 'respects a custom severity_threshold' do
      mild_body = {
        'categoriesAnalysis' => [
          { 'category' => 'Hate', 'severity' => 2 },
          { 'category' => 'Violence', 'severity' => 1 }
        ]
      }
      allow(conn).to receive(:post)
        .and_return(instance_double(Faraday::Response, body: mild_body))

      result = test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint, severity_threshold: 4)
      expect(result[:result][:blocked]).to be false
      expect(result[:result][:reasons]).to be_empty
    end

    it 'includes categories in the request body when provided' do
      allow(conn).to receive(:post) do |_path, body|
        expect(body[:categories]).to eq(%w[Hate Violence])
        response
      end

      test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint,
                            categories: %w[Hate Violence])
    end

    it 'omits categories from request body when not provided' do
      allow(conn).to receive(:post) do |_path, body|
        expect(body).not_to have_key(:categories)
        response
      end

      test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint)
    end

    it 'uses a custom api_version in the path' do
      expected_path = '/contentsafety/text:analyze?api-version=2023-10-01'
      allow(conn).to receive(:post)
        .with(expected_path, anything)
        .and_return(response)

      test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint,
                            api_version: '2023-10-01')
    end

    it 'returns the expected result structure' do
      allow(conn).to receive(:post).and_return(response)

      result = test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint)
      expect(result).to have_key(:result)
      expect(result[:result]).to have_key(:blocked)
      expect(result[:result]).to have_key(:reasons)
      expect(result[:result]).to have_key(:categories)
      expect(result[:result]).to have_key(:raw)
    end

    it 'includes the raw response body' do
      allow(conn).to receive(:post).and_return(response)

      result = test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint)
      expect(result[:result][:raw]).to eq(response_body)
    end

    it 'handles empty categoriesAnalysis gracefully' do
      empty_body = { 'categoriesAnalysis' => [] }
      allow(conn).to receive(:post)
        .and_return(instance_double(Faraday::Response, body: empty_body))

      result = test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint)
      expect(result[:result][:blocked]).to be false
      expect(result[:result][:reasons]).to be_empty
      expect(result[:result][:categories]).to be_empty
    end

    it 'handles missing categoriesAnalysis key gracefully' do
      allow(conn).to receive(:post)
        .and_return(instance_double(Faraday::Response, body: {}))

      result = test_class.check_text(content: 'text', api_key: api_key, endpoint: endpoint)
      expect(result[:result][:blocked]).to be false
      expect(result[:result][:categories]).to eq([])
    end
  end
end
