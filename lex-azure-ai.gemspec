# frozen_string_literal: true

require_relative 'lib/legion/extensions/azure_ai/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-azure-ai'
  spec.version       = Legion::Extensions::AzureAi::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Azure AI'
  spec.description   = 'Connects LegionIO to Azure AI Services (Azure OpenAI)'
  spec.homepage      = 'https://github.com/LegionIO/lex-azure-ai'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-azure-ai'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-azure-ai'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-azure-ai'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-azure-ai/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 2.0'
  spec.add_dependency 'multi_json'
end
