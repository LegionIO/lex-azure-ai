# frozen_string_literal: true

require 'legion/extensions/azure_ai/helpers/client'

module Legion
  module Extensions
    module AzureAi
      module Runners
        module ContentSafety
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
                blocked:    !blocked_categories.empty?,
                reasons:    blocked_categories.map { |c| c['category'] },
                categories: categories_analysis,
                raw:        response.body
              }
            }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end
