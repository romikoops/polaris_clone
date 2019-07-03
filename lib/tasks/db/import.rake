# frozen_string_literal: true

namespace :db do
  APP_ROOT = Pathname.new(File.expand_path('../../../', __dir__))
  PROJECT = 'itsmycargo-main'
  BUCKET = 'itsmycargo-main-engineering-resources'
  SEED_FILE = APP_ROOT.join('tmp/seed.sql.gz')

  namespace :import do
    task :fetch, [:profile] do |t, args|
      seed_profile = args[:profile]

      DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

      puts 'Downloading latest Database Seed file...'

      begin
        require 'google/cloud/storage'

        # Instantiates a client
        storage = Google::Cloud::Storage.new(project: PROJECT)

        bucket = storage.bucket(BUCKET)
        file = bucket.file("db/#{args[:profile]}.sql.gz")

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

        # Speed up download if possible
        if (gsutil = `which gsutil`.strip)
          system(gsutil, 'cp', "gs://#{BUCKET}/#{"db/#{args[:profile]}.sql.gz"}", SEED_FILE.to_s)
        else
          puts ' *** For faster download, please install gsutil ***'
          file.download(SEED_FILE.to_s)
        end

        puts '  Done.'
      rescue Google::Cloud::PermissionDeniedError
        puts ''
        puts "Cannot access GCS Bucket `#{BUCKET}`"
        puts ''
        puts 'Please run following command:'
        puts ''
        puts '    $ gcloud auth application-default login'
        puts ''

        exit 1
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

    task :clean do
      puts 'Cleaning Seed File...'
      SEED_FILE.unlink
    end
  end
end
