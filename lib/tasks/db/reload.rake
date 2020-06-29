# frozen_string_literal: true

if Rails.env.development?
  require "database_reloader"

  namespace :db do
    desc "Reloads full database (truncate and pull latest dump)"
    task reload: :environment do
      Rake::Task["db:reload:full"].invoke
    end

    namespace :reload do
      desc "Reloads slim database (truncate and pull latest dump)"
      task :slim, [:date] => [:environment] do |_, args|
        DatabaseReloader.perform(profile: "slim", date: args[:date])
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end

      desc "Reloads full database (truncate and pull latest dump)"
      task :full, [:date] => [:environment] do |_, args|
        DatabaseReloader.perform(profile: "full", date: args[:date])
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end

      desc "Reloads production database (AUTHORIZED ONLY)"
      task :production, [:date] => [:environment] do |_, args|
        DatabaseReloader.perform(profile: "production", date: args[:date])
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end
    end
  end
end
