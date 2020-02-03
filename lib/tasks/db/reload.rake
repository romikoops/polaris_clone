# frozen_string_literal: true

namespace :db do
  desc 'Reloads slim database (truncate and pull latest dump)'
  task :reload do
    Rake::Task['db:reload:slim'].invoke
  end

  namespace :reload do
    desc 'Reloads slim database (truncate and pull latest dump)'
    task :slim, [:date] do |_, args|
      Rake::Task['db:import:fetch'].invoke('slim', args[:date])
      Rake::Task['db:reload:common'].invoke
    end

    desc 'Reloads full database (truncate and pull latest dump)'
    task :full, [:date] do |_, args|
      Rake::Task['db:import:fetch'].invoke('full', args[:date])
      Rake::Task['db:reload:common'].invoke
    end

    desc 'Reloads production database (AUTHORIZED ONLY)'
    task :production, [:date] do |_, args|
      Rake::Task['db:import:fetch'].invoke('production', args[:date])
      Rake::Task['db:reload:common'].invoke
    end

    task :common do
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke

      Rake::Task['db:import:restore'].invoke

      Rake::Task['db:import:clean'].invoke

      Rake::Task['db:migrate'].invoke unless ENV['SKIP_MIGRATE']
      Rake::Task['db:test:prepare'].invoke unless ENV['SKIP_MIGRATE']

      Rake::Task['tenants:domains'].invoke if ENV['SKIP_MIGRATE']
    end
  end
end
