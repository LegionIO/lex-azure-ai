# frozen_string_literal: true

require 'legion/extensions/azure_ai/helpers/client'
require 'legion/extensions/azure_ai/runners/chat'
require 'legion/extensions/azure_ai/runners/embeddings'
require 'legion/extensions/azure_ai/runners/models'
require 'legion/extensions/azure_ai/runners/content_safety'

module Legion
  module Extensions
    module AzureAi
      class Client
        include Legion::Extensions::AzureAi::Runners::Chat
        include Legion::Extensions::AzureAi::Runners::Embeddings
        include Legion::Extensions::AzureAi::Runners::Models
        include Legion::Extensions::AzureAi::Runners::ContentSafety

        attr_reader :config

        def initialize(api_key:, endpoint:, api_version: '2024-10-21', **opts)
          @config = { api_key: api_key, endpoint: endpoint, api_version: api_version, **opts }
        end

        private

        def client(**override_opts)
          merged = config.merge(override_opts)
          Legion::Extensions::AzureAi::Helpers::Client.client(**merged)
        end
      end
    end
  end
end
