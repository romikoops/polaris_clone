# frozen_string_literal: true

namespace :db do
  APP_ROOT = Pathname.new(File.expand_path('../../../', __dir__))
  BACKUPS_BUCKET = 'itsmycargo-backups'
  RESOURCES_BUCKET = 'itsmycargo-resources'
  SEED_FILE = APP_ROOT.join('tmp', 'database.sqlc')

  namespace :import do
    task :fetch, [:profile] do |t, args|
      DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

      if File.exist?(SEED_FILE)
        puts 'Database seed file exists - skipping.'
        next
      end

      puts 'Downloading latest Database Seed file...'

      begin
        require 'aws-sdk-s3'

        # Instantiates a client
        client = Aws::S3::Client.new

        # Find requested dumps
        bucket = args[:profile] == 'production' ? BACKUPS_BUCKET : RESOURCES_BUCKET
        seeds = []
        marker = nil
        loop do
          response = client.list_objects(
            bucket: bucket,
            prefix: "imc-react-api/#{args[:profile]}-",
            marker: marker
          )

          seeds += response.contents
          marker = response.next_marker
          break if marker.nil?
        end

        object = seeds.sort.last

        # Warn if seed file is out-of-date
        puts ''
        puts "  Created: #{object.last_modified} (#{DateHelper.time_ago_in_words(object.last_modified)} ago)"
        if object.last_modified < 1.day.ago
          puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
          puts '!!!!!                          !!!!!'
          puts '!!!!! STALE DATABASE SEED FILE !!!!!'
          puts '!!!!!                          !!!!!'
          puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        end

        # Speed up download if possible
        if (aws = `which aws`.strip)
          system(aws, 's3', 'cp', "s3://#{bucket}/#{object.key}", SEED_FILE.to_s) || exit(1)
        else
          puts ' *** For faster download, please install aws-cli ***'
          client.get_object(
            response_target: SEED_FILE.to_s,
            bucket: bucket,
            key: object.key)
        end

        puts '  Done.'
      end
    end

    task :restore do
      database_name = ENV.fetch('DATABASE_NAME') { ActiveRecord::Base.configurations[Rails.env]['database'] }

      puts 'Re-create development database'
      Rake::Task['db:create'].invoke

      puts 'Restore from Database Seed'
      cmd = "pg_restore --dbname=#{database_name} --no-owner --no-privileges #{SEED_FILE}"

      system(cmd) || exit(1)
      Rake::Task['db:environment:set'].invoke
    end

    task :clean do
      puts 'Cleaning Seed File...'
      SEED_FILE.unlink
    end
  end
end
