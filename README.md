# lex-azure-ai

[![Gem Version](https://img.shields.io/gem/v/lex-azure-ai.svg)](https://rubygems.org/gems/lex-azure-ai)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4-red.svg)](https://www.ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Legion Extension that connects LegionIO to Azure AI Services — Azure OpenAI and Azure AI Content Safety.

## Purpose

Wraps the Azure AI REST APIs as named runners consumable by any LegionIO task chain. Provides chat completions, embeddings, model listing, and content safety moderation. Use this extension when you need direct access to the Azure AI API surface within the LEX runner/actor lifecycle. For simple chat/embed workflows, consider `legion-llm` instead.

## Installation

Add to your Gemfile:

```ruby
gem 'lex-azure-ai'
```

Then run:

```bash
bundle install
```

## Quick Start

```ruby
require 'legion/extensions/azure_ai'

client = Legion::Extensions::AzureAi::Client.new(
  api_key:  'your-azure-api-key',
  endpoint: 'my-resource'
)

# Chat completion
chat = client.create(
  deployment: 'gpt-4o',
  messages:   [{ role: 'user', content: 'Hello!' }]
)
puts chat[:result]['choices'].first['message']['content']

# Content safety check
safety = client.check_text(
  content:  'some user-generated text',
  endpoint: 'my-content-safety-resource',
  api_key:  'your-content-safety-key'
)
puts "Blocked: #{safety[:result][:blocked]}"
```

## API Coverage

| Runner | Method | Azure API | Auth Header |
|--------|--------|-----------|-------------|
| `Chat` | `create` | Azure OpenAI — Chat Completions | `api-key` |
| `Embeddings` | `create` | Azure OpenAI — Embeddings | `api-key` |
| `Models` | `list` | Azure OpenAI — Models | `api-key` |
| `ContentSafety` | `check_text` | Azure AI Content Safety — `text:analyze` | `Ocp-Apim-Subscription-Key` |

## Usage

### Chat Completions

```ruby
result = Legion::Extensions::AzureAi::Runners::Chat.create(
  deployment:  'gpt-4o',
  messages:    [{ role: 'user', content: 'Hello!' }],
  api_key:     'your-key',
  endpoint:    'my-resource',
  temperature: 0.7,       # optional
  max_tokens:  1000       # optional
)
# => { result: { 'choices' => [...], 'usage' => {...} },
#      usage: { input_tokens: 10, output_tokens: 20, ... } }
```

### Embeddings

```ruby
result = Legion::Extensions::AzureAi::Runners::Embeddings.create(
  deployment: 'text-embedding-ada-002',
  input:      'Hello world',
  api_key:    'your-key',
  endpoint:   'my-resource'
)
# => { result: { 'data' => [{ 'embedding' => [...] }] },
#      usage: { input_tokens: 2, output_tokens: 0, ... } }
```

### Models

```ruby
result = Legion::Extensions::AzureAi::Runners::Models.list(
  api_key:  'your-key',
  endpoint: 'my-resource'
)
# => { models: { 'data' => [{ 'id' => 'gpt-4o' }, ...] } }
```

### Content Safety

```ruby
result = Legion::Extensions::AzureAi::Runners::ContentSafety.check_text(
  content:            'text to analyze',
  api_key:            'your-content-safety-key',
  endpoint:           'my-content-safety-resource',
  severity_threshold: 2,                    # default 2, range 0-6
  categories:         %w[Hate Violence],    # optional filter; defaults to all four
  api_version:        '2024-09-01'          # default
)
# => { result: {
#        blocked:    false,
#        reasons:    [],
#        categories: [
#          { 'category' => 'Hate',     'severity' => 0 },
#          { 'category' => 'Violence', 'severity' => 0 }, ...
#        ],
#        raw: { ... }
#      } }
```

**Categories:** Hate, Violence, SelfHarm, Sexual — severity range 0–6. Any category at or above `severity_threshold` triggers `blocked: true`.

### Standalone Client

The `Client` class includes all runners and stores credentials so you don't repeat them:

```ruby
client = Legion::Extensions::AzureAi::Client.new(
  api_key:     'your-key',
  endpoint:    'my-resource',
  api_version: '2024-10-21'  # default
)

client.create(deployment: 'gpt-4o', messages: [...])
client.list
```

> **Note:** `check_text` requires `endpoint:` and `api_key:` as explicit arguments because Content Safety uses a different Azure resource and auth mechanism than OpenAI.

## Azure Service Endpoints

This gem talks to two distinct Azure services with different base URLs and authentication:

| Service | Base URL | Auth Header |
|---------|----------|-------------|
| Azure OpenAI | `https://{endpoint}.openai.azure.com` | `api-key` |
| Azure AI Content Safety | `https://{endpoint}.cognitiveservices.azure.com` | `Ocp-Apim-Subscription-Key` |

The `endpoint` parameter is typically the Azure resource name (e.g., `my-resource`).

## Identity

The `Identity` module provides credential-only integration with the LegionIO Broker identity system:

```ruby
Legion::Extensions::AzureAi::Identity.provide_token
# => Legion::Identity::Lease (or nil if no key configured)
```

API keys are resolved from `Legion::Settings` at `:llm → :providers → :azure → :api_key`.

## Development

```bash
bundle install
bundle exec rspec        # 45 examples, 5 spec files
bundle exec rubocop      # 0 offenses expected
```

## Related

- [`lex-foundry`](https://github.com/LegionIO/lex-foundry) — Azure AI Foundry management API (model catalog, deployments, connections)
- [`legion-llm`](https://github.com/LegionIO/legion-llm) — High-level LLM interface across all providers including Azure OpenAI
- [`extensions-ai/CLAUDE.md`](../CLAUDE.md) — Architecture patterns shared across all AI extensions

## License

MIT — see [LICENSE](LICENSE) for details.
