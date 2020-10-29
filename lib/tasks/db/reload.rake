# frozen_string_literal: true

if Rails.env.development?
  require "database_util"

  namespace :db do
    desc "Reloads full database (truncate and pull latest dump)"
    task reload: :environment do
      Rake::Task["db:reload:full"].invoke
    end

    namespace :reload do
      desc "Reloads full database (truncate and pull latest dump)"
      task full: :environment do
        DatabaseUtil.reload(profile: "full")
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end

      desc "Reloads production database (AUTHORIZED ONLY)"
      task production: :environment do
        DatabaseUtil.reload(profile: "production")
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end
    end

    desc "Restore full database (restore from template)"
    task restore: :environment do
      Rake::Task["db:reload:full"].invoke
    end

    namespace :restore do
      desc "Restores full database from template"
      task full: :environment do
        DatabaseUtil.restore(profile: "full")
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end

      desc "Restores production database from template"
      task production: :environment do
        DatabaseUtil.restore(profile: "production")
        Rake::Task["db:migrate"] unless ENV["SKIP_MIGRATE"]
      end
    end
  end
end
