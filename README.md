# lex-azure-ai

Legion Extension that connects LegionIO to Azure AI Services (Azure OpenAI).

## Installation

Add to your Gemfile:

```ruby
gem 'lex-azure-ai'
```

## Usage

### Standalone Client

```ruby
require 'legion/extensions/azure_ai'

client = Legion::Extensions::AzureAi::Client.new(
  api_key: 'your-azure-api-key',
  endpoint: 'my-resource',
  api_version: '2024-10-21'
)

result = client.create(
  deployment: 'gpt-4o',
  messages: [{ role: 'user', content: 'Hello!' }]
)
```

### Runners Directly

```ruby
Legion::Extensions::AzureAi::Runners::Chat.create(
  deployment: 'gpt-4o',
  messages: [{ role: 'user', content: 'Hello!' }],
  api_key: 'your-key',
  endpoint: 'my-resource'
)

Legion::Extensions::AzureAi::Runners::Embeddings.create(
  deployment: 'text-embedding-ada-002',
  input: 'Hello world',
  api_key: 'your-key',
  endpoint: 'my-resource'
)

Legion::Extensions::AzureAi::Runners::Models.list(
  api_key: 'your-key',
  endpoint: 'my-resource'
)
```

## License

MIT
