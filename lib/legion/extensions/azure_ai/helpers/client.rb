# frozen_string_literal: true

require 'faraday'
require 'multi_json'

module Legion
  module Extensions
    module AzureAi
      module Helpers
        module Client
          module_function

          def client(api_key:, endpoint:, _api_version: '2024-10-21', **)
            Faraday.new(url: "https://#{endpoint}.openai.azure.com") do |conn|
              conn.request :json
              conn.response :json, content_type: /\bjson$/
              conn.headers['api-key'] = api_key
              conn.headers['Content-Type'] = 'application/json'
            end
          end
        end
      end
    end
  end
end
