# frozen_string_literal: true

namespace :db do
  APP_ROOT = Pathname.new(File.expand_path('../../../', __dir__))
  SEED_FILE = APP_ROOT.join('tmp/full_anon.sqlc')

  desc 'Import latest Development Seed database'
  task import: %w(db:import:fetch db:import:restore) do
    puts 'Cleaning Seed File...'
    SEED_FILE.unlink
  end

  namespace :import do
    task fetch: :environment do
      ENV['GOOGLE_CLOUD_KEYFILE'] ||= File.join(ENV['HOME'], '.gcloud_developer.json')

      # Ensure we have required environment variable pointing to developer service account
      unless File.exist?(ENV['GOOGLE_CLOUD_KEYFILE'])
        puts ''
        puts 'GOOGLE_CLOUD_KEYFILE is not defined.'
        puts ''
        puts 'Please point environment vaeriable GOOGLE_CLOUD_KEYFILE to Developer Service Credentials File'
        puts 'e.g. GOOGLE_CLOUD_KEYFILE=$HOME/.gcloud_credentials.json bin/rake db:import'
        puts ''
        exit 1
      end

      puts 'Downloading latest Database Seed file...'

      require 'google/cloud/storage'

      # Instantiates a client
      storage = Google::Cloud::Storage.new(project: 'itsmycargo-main')

      bucket = storage.bucket('itsmycargo-main-engineering-resources')
      file = bucket.file('db/full_anon.sqlc')
      puts "  Created: #{file.created_at}"
      file.download(SEED_FILE.to_s)
      puts '  Done.'
    end

    task :restore do
      puts 'Re-create development database'
      Rake::Task['db:create'].invoke

      puts 'Restore from Database Seed'
      restore_cmd = %W[
        pg_restore -d #{ENV.fetch('DATABASE_NAME', 'imcr_development')} -x -O -c --if-exists #{SEED_FILE}
      ].join(' ')
      system(restore_cmd) || exit(1)
    end
  end
end
