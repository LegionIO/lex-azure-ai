# frozen_string_literal: true

require 'legion/extensions/azure_ai/helpers/client'

module Legion
  module Extensions
    module AzureAi
      module Runners
        module Chat
          extend Legion::Extensions::AzureAi::Helpers::Client

          def create(deployment:, messages:, api_key:, endpoint:, api_version: '2024-10-21',
                     max_tokens: nil, temperature: nil, **)
            body = { messages: messages }
            body[:max_tokens] = max_tokens if max_tokens
            body[:temperature] = temperature if temperature

            path = "/openai/deployments/#{deployment}/chat/completions?api-version=#{api_version}"
            response = client(api_key: api_key, endpoint: endpoint, api_version: api_version).post(path, body)
            { result: response.body }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end
