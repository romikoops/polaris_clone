# frozen_string_literal: true

module Gemhelper
  def self.common_gems(spec)
    spec.add_development_dependency 'factory_bot_rails'
    spec.add_development_dependency 'ffaker'
    spec.add_development_dependency 'fuubar'
    spec.add_development_dependency 'pry'
    spec.add_development_dependency 'rspec-rails'
    spec.add_development_dependency 'rspec_junit_formatter'
    spec.add_development_dependency 'simplecov'
    spec.add_development_dependency 'simplecov-cobertura'
    spec.add_development_dependency 'simplecov-workspace-lcov'
    spec.add_development_dependency 'timecop'
    spec.add_development_dependency 'webmock'
  end
end
