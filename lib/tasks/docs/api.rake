# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  namespace :docs do
    desc "Generate API Documentation from API specs"
    task api: :environment do
      Bundler.with_clean_env do
        sh("bundle exec rspec --pattern 'engines/api/spec/api/api/*_spec.rb' --fail-fast --format Rswag::Specs::SwaggerFormatter --order defined .")
      end
    end
  end
end
