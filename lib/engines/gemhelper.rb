# frozen_string_literal: true

module Gemhelper
  def self.common(spec)
    runtime(spec)
    development(spec)
  end

  def self.runtime(spec)
    spec.add_dependency 'activerecord-postgis-adapter', '5.2.2'
    spec.add_dependency 'config', '~> 2.2'
    spec.add_dependency 'paper_trail', '~> 10.3'
    spec.add_dependency 'pg', '>= 0.18', '< 2.0'
    spec.add_dependency 'rails', '5.2.2'
    spec.add_dependency 'strong_migrations', '~> 0.6'
  end

  def self.development(spec)
    spec.add_development_dependency 'factory_bot_rails'
    spec.add_development_dependency 'ffaker'
    spec.add_development_dependency 'fuubar'
    spec.add_development_dependency 'pry'
    spec.add_development_dependency 'rspec', '~> 3.9'
    spec.add_development_dependency 'rspec-rails'
    spec.add_development_dependency 'rspec-retry'
    spec.add_development_dependency 'rspec_junit_formatter'
    spec.add_development_dependency 'simplecov'
    spec.add_development_dependency 'simplecov-cobertura'
    spec.add_development_dependency 'timecop'
    spec.add_development_dependency 'webmock'
  end
end
