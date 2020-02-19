# frozen_string_literal: true

namespace :db do
  desc 'Reloads slim database (truncate and pull latest dump)'
  task :reload do # rubocop:disable Rails/RakeEnvironment
    Rake::Task['db:reload:full'].invoke
  end

  namespace :reload do
    desc 'Reloads slim database (truncate and pull latest dump)'
    task :slim, [:date] do |_, args| # rubocop:disable Rails/RakeEnvironment
      Rake::Task['db:import:fetch'].invoke('slim', args[:date])
      Rake::Task['db:reload:common'].invoke('slim')
    end

    desc 'Reloads full database (truncate and pull latest dump)'
    task :full, [:date] do |_, args| # rubocop:disable Rails/RakeEnvironment
      Rake::Task['db:import:fetch'].invoke('full', args[:date])
      Rake::Task['db:reload:common'].invoke('full')
    end

    desc 'Reloads production database (AUTHORIZED ONLY)'
    task :production, [:date] do |_, args| # rubocop:disable Rails/RakeEnvironment
      Rake::Task['db:import:fetch'].invoke('production', args[:date])
      Rake::Task['db:reload:common'].invoke('production')
    end

    task :common, [:profile] do |_, args| # rubocop:disable Rails/RakeEnvironment
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke

      Rake::Task['db:import:restore'].invoke(args[:profile])

      Rake::Task['db:migrate'].invoke unless ENV['SKIP_MIGRATE']
      Rake::Task['db:test:prepare'].invoke unless ENV['SKIP_MIGRATE']

      Rake::Task['tenants:domains'].invoke if ENV['SKIP_MIGRATE']
    end
  end
end
