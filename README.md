# lex-azure-ai

Legion Extension that connects LegionIO to Azure AI Services (Azure OpenAI).

## Purpose

Wraps the Azure OpenAI REST API as named runners consumable by any LegionIO task chain. Provides chat completions, embeddings, and model listing. Use this extension when you need direct access to the Azure OpenAI API surface within the LEX runner/actor lifecycle. For simple chat/embed workflows, consider `legion-llm` instead.

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

## API Coverage

| Runner | Methods |
|--------|---------|
| `Chat` | `create` |
| `Embeddings` | `create` |
| `Models` | `list` |

## Version

0.1.5

## Related

- `lex-foundry` — Azure AI Foundry management API (model catalog, deployments, connections)
- `legion-llm` — High-level LLM interface across all providers including Azure OpenAI
- `extensions-ai/CLAUDE.md` — Architecture patterns shared across all AI extensions

## License

MIT
