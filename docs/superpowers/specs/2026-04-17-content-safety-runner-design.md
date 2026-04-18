# Azure Content Safety Runner — Design Spec

**Issue:** https://github.com/LegionIO/lex-azure-ai/issues/4
**Date:** 2026-04-17

## Problem

lex-azure-ai has runners for Chat, Embeddings, and Models but no content moderation runner. Azure AI Services provides a Content Safety API (`text:analyze`) that enterprises expect. This was identified in a competitive gap analysis against Kong AI Gateway.

## Solution

Add a `ContentSafety` runner module with a `check_text` method that calls the Azure AI Content Safety `text:analyze` endpoint. Add a `content_safety_client` factory method to `Helpers::Client` since the Content Safety API uses a different base URL and auth header than the OpenAI runners.

### Helpers::Client — new factory method

```ruby
def content_safety_client(api_key:, endpoint:, **)
  Faraday.new(url: "https://#{endpoint}.cognitiveservices.azure.com") do |conn|
    conn.request :json
    conn.response :json, content_type: /\bjson$/
    conn.headers['Ocp-Apim-Subscription-Key'] = api_key
    conn.headers['Content-Type'] = 'application/json'
  end
end
```

- Base URL: `https://#{endpoint}.cognitiveservices.azure.com` (not `.openai.azure.com`)
- Auth header: `Ocp-Apim-Subscription-Key` (not `api-key`)

### ContentSafety runner

**File:** `lib/legion/extensions/azure_ai/runners/content_safety.rb`

```ruby
module Legion::Extensions::AzureAi::Runners::ContentSafety
  extend Legion::Extensions::AzureAi::Helpers::Client

  def check_text(content:, endpoint:, api_key:, severity_threshold: 2,
                 categories: nil, api_version: '2024-09-01', **)
    body = { text: content }
    body[:categories] = categories if categories

    path = "/contentsafety/text:analyze?api-version=#{api_version}"
    response = content_safety_client(api_key: api_key, endpoint: endpoint).post(path, body)

    categories_analysis = response.body['categoriesAnalysis'] || []
    blocked_categories = categories_analysis.select { |c| c['severity'] >= severity_threshold }

    {
      result: {
        blocked: !blocked_categories.empty?,
        reasons: blocked_categories.map { |c| c['category'] },
        categories: categories_analysis,
        raw: response.body
      }
    }
  end
end
```

**Method signature:** `check_text(content:, endpoint:, api_key:, severity_threshold: 2, categories: nil, api_version: '2024-09-01', **)`

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | String | required | Text to analyze |
| `endpoint` | String | required | Azure resource name |
| `api_key` | String | required | Azure subscription key |
| `severity_threshold` | Integer | `2` | Severity at or above which a category is considered blocked (0–6) |
| `categories` | Array/nil | `nil` | Optional filter; Azure defaults to all four when omitted |
| `api_version` | String | `'2024-09-01'` | API version |

**Response format:**

```ruby
{
  result: {
    blocked: true,
    reasons: ["Hate"],
    categories: [
      { "category" => "Hate", "severity" => 4 },
      { "category" => "Violence", "severity" => 0 },
      { "category" => "SelfHarm", "severity" => 0 },
      { "category" => "Sexual", "severity" => 0 }
    ],
    raw: { ... }  # full Azure response body
  }
}
```

**Azure Content Safety categories:** Hate, Violence, SelfHarm, Sexual. Severity range 0–6.

### Integration

1. `lib/legion/extensions/azure_ai.rb` — add `require 'legion/extensions/azure_ai/runners/content_safety'`
2. `lib/legion/extensions/azure_ai/client.rb` — add `include Runners::ContentSafety`
3. Standard `include Helpers::Lex` guard at the bottom of the runner module

### Test plan

**File:** `spec/legion/extensions/azure_ai/runners/content_safety_spec.rb`

Following existing spec conventions (test class extending runner, Faraday instance doubles):

- Returns `blocked: false` when all severities are below threshold
- Returns `blocked: true` with matching reasons when severities meet/exceed threshold
- Respects custom `severity_threshold`
- Includes `categories` in request body when provided
- Uses custom `api_version` in URL path
- Returns correct `{ result: { blocked:, reasons:, categories:, raw: } }` structure
- Handles empty `categoriesAnalysis` gracefully
- Verifies correct URL path (`/contentsafety/text:analyze`)

## Not included

- `check_image` — stretch goal from the issue, will be a separate follow-up
- Audit exchange forwarding (`additional_e_to_q`) — LegionIO-level wiring, not runner concern
- HTTP error handling — Faraday raises on its own, consistent with existing runners
- No `usage` key in response — Content Safety API doesn't return token counts
