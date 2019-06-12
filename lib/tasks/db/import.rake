# frozen_string_literal: true

namespace :db do
  APP_ROOT = Pathname.new(File.expand_path('../../../', __dir__))
  BUCKET = 'itsmycargo-main-engineering-resources'
  SEED_FILE = APP_ROOT.join('tmp/full_anon.sqlc')
  SEED_FILE_NAME = 'db/full_anon.sql.gz'

  desc 'Reloads database (truncate and pull latest dump)'
  task :reload do
    Rake::Task['db:import:fetch'].invoke

    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    Rake::Task['db:import:restore'].invoke

    Rake::Task['db:import:clean'].invoke

    Rake::Task['db:migrate'].invoke unless ENV['SKIP_MIGRATE']
  end

  desc 'Import latest Development Seed database'
  task :import do
    Rake::Task['db:import:fetch'].invoke
    Rake::Task['db:import:restore'].invoke
    Rake::Task['db:import:clean'].invoke
  end

  namespace :import do
    task :fetch do
      DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

      puts 'Downloading latest Database Seed file...'

      begin
        require 'google/cloud/storage'

        # Instantiates a client
        storage = Google::Cloud::Storage.new(project: 'itsmycargo-main')

        bucket = storage.bucket(BUCKET)
        file = bucket.file(SEED_FILE_NAME)

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
          system(gsutil, 'cp', "gs://#{BUCKET}/#{SEED_FILE_NAME}", SEED_FILE.to_s)
        else
          puts ' *** For faster download, please install gsutil ***'
          file.download(SEED_FILE.to_s)
        end

        puts '  Done.'
      rescue Google::Cloud::PermissionDeniedError
        puts ''
        puts 'Cannot access GCS Bucket `itsmycargo-main-engineering-resources`'
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
