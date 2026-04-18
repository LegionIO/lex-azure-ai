# Changelog

## [0.1.6] - 2026-04-17

### Added
- Content Safety runner with `check_text` method for Azure AI Content Safety `text:analyze` API (#4)
- `content_safety_client` factory method in `Helpers::Client` for Cognitive Services endpoint
- Configurable severity threshold (default 2, range 0-6) with normalized blocked/reasons response

## [0.1.5] - 2026-04-06

### Added
- Credential-only identity module for Phase 8 Broker integration (`Identity` module with `provide_token`)

## [0.1.4] - 2026-03-31

### Added
- Standardized `usage:` key in Chat and Embeddings runner return hashes, exposing `input_tokens`, `output_tokens`, `cache_read_tokens`, and `cache_write_tokens` for consumption by legion-llm CostEstimator and metering

## [0.1.3] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.2] - 2026-03-22

### Changed
- Add legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport as runtime dependencies
- Update spec_helper with real sub-gem helper stubs for Helpers::Lex

## [0.1.0] - 2026-03-21

### Added
- Initial release
- Chat completions runner via Azure OpenAI deployment
- Embeddings runner via Azure OpenAI deployment
- Models listing runner
- Standalone Client class
- Faraday-based HTTP client with api-key header authentication
