# lex-azure-ai: Azure AI Services Integration for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-ai/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that connects LegionIO to Azure AI Services. Provides runners for chat completions, embeddings, model listing (via Azure OpenAI), and content safety moderation (via Azure AI Content Safety).

**GitHub**: https://github.com/LegionIO/lex-azure-ai
**License**: MIT
**Version**: 0.1.6
**Specs**: 45 examples (5 spec files)

## Architecture

```
Legion::Extensions::AzureAi
├── Runners/
│   ├── Chat             # create(deployment:, messages:, api_key:, endpoint:, api_version:, ...)
│   ├── Embeddings       # create(deployment:, input:, api_key:, endpoint:, api_version:, ...)
│   ├── Models           # list(api_key:, endpoint:, api_version:, ...)
│   └── ContentSafety    # check_text(content:, endpoint:, api_key:, severity_threshold:, ...)
├── Helpers/
│   └── Client           # Faraday-based client factory (two methods: client + content_safety_client)
├── Client               # Standalone client class (includes all runners, holds @config)
└── Identity             # Credential-only identity module for Broker integration
```

### Two Azure Services, Two Clients

`Helpers::Client` is a **module** with two factory methods:

| Factory Method | Base URL | Auth Header | Used By |
|----------------|----------|-------------|---------|
| `client(api_key:, endpoint:, ...)` | `https://#{endpoint}.openai.azure.com` | `api-key` | Chat, Embeddings, Models |
| `content_safety_client(api_key:, endpoint:, ...)` | `https://#{endpoint}.cognitiveservices.azure.com` | `Ocp-Apim-Subscription-Key` | ContentSafety |

Both build a Faraday connection with JSON request/response middleware. Runner modules `extend` `Helpers::Client` to gain these as module-level methods.

`Client` (class) provides a standalone instantiable wrapper. It holds `@config` and delegates through `Helpers::Client`. It includes all four runner modules.

## Runner Reference

### Chat — `Runners::Chat`

```ruby
create(deployment:, messages:, api_key:, endpoint:, api_version: '2024-10-21', max_tokens: nil, temperature: nil, **)
```

- POST `/openai/deployments/#{deployment}/chat/completions?api-version=#{api_version}`
- Returns `{ result: response.body, usage: { input_tokens:, output_tokens:, cache_read_tokens:, cache_write_tokens: } }`

### Embeddings — `Runners::Embeddings`

```ruby
create(deployment:, input:, api_key:, endpoint:, api_version: '2024-10-21', **)
```

- POST `/openai/deployments/#{deployment}/embeddings?api-version=#{api_version}`
- Returns `{ result: response.body, usage: { input_tokens:, output_tokens:, cache_read_tokens:, cache_write_tokens: } }`

### Models — `Runners::Models`

```ruby
list(api_key:, endpoint:, api_version: '2024-10-21', **)
```

- GET `/openai/models?api-version=#{api_version}`
- Returns `{ models: response.body }` (note: `models` key, not `result`)

### ContentSafety — `Runners::ContentSafety`

```ruby
check_text(content:, endpoint:, api_key:, severity_threshold: 2, categories: nil, api_version: '2024-09-01', **)
```

- POST `/contentsafety/text:analyze?api-version=#{api_version}`
- Request body: `{ text: content }` (plus `categories:` if provided)
- Response parsing: reads `categoriesAnalysis` array, filters by `severity >= severity_threshold`
- Returns `{ result: { blocked:, reasons:, categories:, raw: } }`
- Categories: Hate, Violence, SelfHarm, Sexual — severity range 0–6
- Default `api_version` is `'2024-09-01'` (differs from OpenAI runners which default to `'2024-10-21'`)
- No `usage` key — Content Safety API doesn't return token counts

## Key Design Decisions

- **Azure OpenAI auth** uses the `api-key` header (not `Authorization: Bearer`). Differs from lex-openai which uses Bearer.
- **Content Safety auth** uses `Ocp-Apim-Subscription-Key` header. Different Azure service, different auth mechanism.
- **API base URLs** are constructed from the `endpoint` param. The endpoint is typically the Azure resource name (e.g., `my-resource`).
- **Two default `api_version` values**: `'2024-10-21'` for OpenAI runners, `'2024-09-01'` for Content Safety. All runners accept `api_version:` as an override.
- **Return key conventions**: Chat and Embeddings return `{ result: ... }`, Models returns `{ models: ... }`, ContentSafety returns `{ result: { blocked:, reasons:, categories:, raw: } }`.
- `include Legion::Extensions::Helpers::Lex` is guarded with `const_defined?` pattern in all runner modules.
- **Identity module** is credential-only (`provider_type: :credential`). Resolves API key from `Legion::Settings.dig(:llm, :providers, :azure, :api_key)`.

## File Map

```
lib/legion/extensions/azure_ai.rb                        # Entry point, requires all modules
lib/legion/extensions/azure_ai/version.rb                 # VERSION constant
lib/legion/extensions/azure_ai/helpers/client.rb          # Faraday factory methods (client + content_safety_client)
lib/legion/extensions/azure_ai/runners/chat.rb            # Chat completions runner
lib/legion/extensions/azure_ai/runners/embeddings.rb      # Embeddings runner
lib/legion/extensions/azure_ai/runners/models.rb          # Model listing runner
lib/legion/extensions/azure_ai/runners/content_safety.rb  # Content Safety text analysis runner
lib/legion/extensions/azure_ai/client.rb                  # Standalone Client class
lib/legion/extensions/azure_ai/identity.rb                # Broker identity integration

spec/legion/extensions/azure_ai/runners/chat_spec.rb             # 9 examples
spec/legion/extensions/azure_ai/runners/embeddings_spec.rb       # 9 examples
spec/legion/extensions/azure_ai/runners/models_spec.rb           # 4 examples
spec/legion/extensions/azure_ai/runners/content_safety_spec.rb   # 10 examples
spec/legion/extensions/azure_ai/identity_spec.rb                 # 8 examples
spec/client_spec.rb                                              # 5 examples
```

## Dependencies

| Gem | Purpose |
|-----|---------|
| `faraday` >= 2.0 | HTTP client for Azure OpenAI and Content Safety APIs |
| `multi_json` | JSON parser abstraction |
| `legion-cache`, `legion-crypt`, `legion-data`, `legion-json`, `legion-logging`, `legion-settings`, `legion-transport` | LegionIO core |

## Testing

```bash
bundle install
bundle exec rspec        # 45 examples
bundle exec rubocop      # 0 offenses expected
```

All specs use Faraday instance doubles — no network calls. The test pattern is:
1. Create an anonymous class that `extend`s the runner module
2. Stub `Faraday.new` to return an instance double
3. Assert on paths, request bodies, and parsed response structures

---

**Maintained By**: Matthew Iverson (@Esity)
**Last Updated**: 2026-04-17
