# frozen_string_literal: true

require 'legion/extensions/azure_ai/version'
require 'legion/extensions/azure_ai/helpers/client'
require 'legion/extensions/azure_ai/runners/chat'
require 'legion/extensions/azure_ai/runners/embeddings'
require 'legion/extensions/azure_ai/runners/models'
require 'legion/extensions/azure_ai/client'

module Legion
  module Extensions
    module AzureAi
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
