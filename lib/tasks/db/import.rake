# frozen_string_literal: true

namespace :db do
  APP_ROOT = Pathname.new(File.expand_path('../../../', __dir__))
  SEED_FILE = APP_ROOT.join('tmp/full_anon.sqlc')
  KEYFILE = File.join(ENV.fetch('HOME', ''), '.gcloud_developer.json')

  desc 'Import latest Development Seed database'
  task import: %w(db:import:fetch db:import:restore) do
    puts 'Cleaning Seed File...'
    SEED_FILE.unlink
  end

  namespace :import do
    task fetch: :environment do
      DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

      puts 'Downloading latest Database Seed file...'

      ENV['GOOGLE_CLOUD_KEYFILE'] = KEYFILE if File.exist?(KEYFILE)

      begin
        require 'google/cloud/storage'

        # Instantiates a client
        storage = Google::Cloud::Storage.new(project: 'itsmycargo-main')

        bucket = storage.bucket('itsmycargo-main-engineering-resources')
        file = bucket.file('db/full_anon.sql.gz')

        # Warn if seed file is out-of-date
        puts ''
        puts "  Created: #{file.created_at} (#{DateHelper.time_ago_in_words(file.created_at)} ago)"
        if file.created_at < 1.day.ago
          puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
          puts '!!!!!                          !!!!!'
          puts '!!!!! STALE DATABASE SEED FILE !!!!!'
          puts '!!!!!                          !!!!!'
          puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        end

        file.download(SEED_FILE.to_s)
        puts '  Done.'
      rescue Google::Cloud::PermissionDeniedError
        unless File.exist?(ENV['GOOGLE_CLOUD_KEYFILE'])
          puts ''
          puts 'GOOGLE_CLOUD_KEYFILE is not defined.'
          puts ''
          puts 'Please point environment vaeriable GOOGLE_CLOUD_KEYFILE to Developer Service Credentials File'
          puts 'e.g. GOOGLE_CLOUD_KEYFILE=$HOME/.gcloud_credentials.json bin/rake db:import'
          puts ''
          exit 1
        end

        raise
      end
    end

    task :restore do
      require 'open3'
      require 'zlib'

      puts 'Re-create development database'
      Rake::Task['db:create'].invoke

      puts 'Restore from Database Seed'
      gzip_cmd = "gzip -cd #{SEED_FILE}"
      psql_cmd = "psql -q -v ON_ERROR_STOP=1 #{ENV.fetch('DATABASE_NAME', 'imcr_development')}"

      system("#{gzip_cmd} | #{psql_cmd}") || exit(1)
    end
  end
end
