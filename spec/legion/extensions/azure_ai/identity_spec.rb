# frozen_string_literal: true

RSpec.describe Legion::Extensions::AzureAi::Identity do
  describe '.provider_name' do
    it { expect(described_class.provider_name).to eq(:azure) }
  end

  describe '.provider_type' do
    it { expect(described_class.provider_type).to eq(:credential) }
  end

  describe '.facing' do
    it { expect(described_class.facing).to be_nil }
  end

  describe '.capabilities' do
    it { expect(described_class.capabilities).to eq(%i[credentials]) }
  end

  describe '.resolve' do
    it 'returns nil (credential-only)' do
      expect(described_class.resolve).to be_nil
    end
  end

  describe '.provide_token' do
    before do
      stub_const('Legion::Settings', Class.new do
        def self.dig(*keys)
          { llm: { providers: { azure: { api_key: 'azure-test-key' } } } }.dig(*keys)
        end
      end)
      stub_const('Legion::Identity::Lease', Struct.new(:provider, :credential, :expires_at, :renewable, :issued_at, :metadata) do
        def valid? = !credential.nil?
        def token  = credential
      end)
    end

    it 'returns a Lease with the API key' do
      lease = described_class.provide_token
      expect(lease).not_to be_nil
      expect(lease.provider).to eq(:azure)
      expect(lease.credential).to eq('azure-test-key')
      expect(lease.expires_at).to be_nil
      expect(lease.renewable).to be false
    end

    context 'when api_key is nil' do
      before do
        stub_const('Legion::Settings', Class.new do
          def self.dig(*keys)
            { llm: { providers: { azure: { api_key: nil } } } }.dig(*keys)
          end
        end)
      end

      it 'returns nil' do
        expect(described_class.provide_token).to be_nil
      end
    end

    context 'when Legion::Settings is not defined' do
      before { hide_const('Legion::Settings') }

      it 'returns nil' do
        expect(described_class.provide_token).to be_nil
      end
    end
  end
end
