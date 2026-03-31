# frozen_string_literal: true

require 'legion/extensions/azure_ai/helpers/client'

module Legion
  module Extensions
    module AzureAi
      module Runners
        module Embeddings
          extend Legion::Extensions::AzureAi::Helpers::Client

          def create(deployment:, input:, api_key:, endpoint:, api_version: '2024-10-21', **)
            body = { input: input }
            path = "/openai/deployments/#{deployment}/embeddings?api-version=#{api_version}"
            response = client(api_key: api_key, endpoint: endpoint, api_version: api_version).post(path, body)
            {
              result: response.body,
              usage:  {
                input_tokens:       response.body.dig('usage', 'prompt_tokens') || 0,
                output_tokens:      response.body.dig('usage', 'completion_tokens') || 0,
                cache_read_tokens:  response.body.dig('usage', 'prompt_tokens_details', 'cached_tokens') || 0,
                cache_write_tokens: 0
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
