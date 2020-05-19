# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  namespace :docs do
    desc "Generate API Documentation from API specs"
    task api: :environment do
      Dir["engines/*"].each do |engine|
        next unless File.directory?(File.join(engine, "spec/api"))

        puts "==> Generating docs for #{File.basename(engine)}"

        Dir.chdir(engine) do
          Bundler.with_clean_env do
            sh("SKIP_COVERAGE=1 bundle exec rspec spec/api --format Rswag::Specs::SwaggerFormatter --order defined")
          end
        end
      end
    end
  end
end
