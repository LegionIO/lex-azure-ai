# frozen_string_literal: true

require 'legion/extensions/azure_ai/helpers/client'

module Legion
  module Extensions
    module AzureAi
      module Runners
        module Models
          extend Legion::Extensions::AzureAi::Helpers::Client

          def list(api_key:, endpoint:, api_version: '2024-10-21', **)
            path = "/openai/models?api-version=#{api_version}"
            response = client(api_key: api_key, endpoint: endpoint, api_version: api_version).get(path)
            { models: response.body }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end
