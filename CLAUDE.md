# lex-azure-ai: Azure AI Services Integration for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-ai/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that connects LegionIO to Azure AI Services (Azure OpenAI). Provides runners for chat completions, embeddings, and model listing via the Azure OpenAI REST API.

**GitHub**: https://github.com/LegionIO/lex-azure-ai
**License**: MIT
**Version**: 0.1.2
**Specs**: 22 examples

## Architecture

```
Legion::Extensions::AzureAi
├── Runners/
│   ├── Chat           # create(deployment:, messages:, api_key:, endpoint:, api_version:, ...)
│   ├── Embeddings     # create(deployment:, input:, api_key:, endpoint:, api_version:, ...)
│   └── Models         # list(api_key:, endpoint:, api_version:, ...)
├── Helpers/
│   └── Client         # Faraday-based Azure OpenAI client (module, factory method)
└── Client             # Standalone client class (includes all runners, holds @config)
```

`Helpers::Client` is a **module** with a `client(api_key:, endpoint:, ...)` factory method. It builds a Faraday connection to `https://#{endpoint}.openai.azure.com` and sets the `api-key` header. Runner modules `extend` it to gain `client(...)` as a module-level method.

`Client` (class) provides a standalone instantiable wrapper. It holds `@config` and delegates through `Helpers::Client`.

## Key Design Decisions

- Authentication uses the `api-key` header (not `Authorization: Bearer`). This is specific to Azure OpenAI — differs from lex-openai which uses Bearer.
- API base URL is constructed from the `endpoint` param: `https://#{endpoint}.openai.azure.com`. The endpoint is typically the Azure resource name (e.g., `my-resource`).
- Default `api_version` is `'2024-10-21'`. All runner methods accept `api_version:` as an override keyword.
- `Models#list` returns `{ models: response.body }` (not `{ result: ... }`). `Chat` and `Embeddings` return `{ result: response.body }`.
- `include Legion::Extensions::Helpers::Lex` is guarded with `const_defined?` pattern.

## Dependencies

| Gem | Purpose |
|-----|---------|
| `faraday` >= 2.0 | HTTP client for Azure OpenAI API |
| `multi_json` | JSON parser abstraction |

## Testing

```bash
bundle install
bundle exec rspec        # 22 examples
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)
