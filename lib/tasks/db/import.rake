# frozen_string_literal: true

require 'aws-sdk-s3'

namespace :db do
  APP_ROOT = Pathname.new(File.expand_path('../../../', __dir__))
  BACKUPS_BUCKET = 'itsmycargo-backups'
  RESOURCES_BUCKET = 'itsmycargo-resources'
  SEED_PATH = APP_ROOT.join('tmp/cache')

  namespace :import do
    task :fetch, [:profile, :date] do |_, args|
      DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

      # Instantiates a client
      client = Aws::S3::Client.new

      puts "Preparing Database Reload (profile #{args[:profile]})"

      # Find requested dumps
      bucket = args[:profile] == 'production' ? BACKUPS_BUCKET : RESOURCES_BUCKET
      seed_file = SEED_PATH.join("#{args[:profile]}.sqlc")
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

      object = if args[:date]
                 seeds.find { |s| s.key[/-#{args[:date]}.sqlc$/] }
               else
                 seeds.max_by(&:key)
               end

      unless object
        puts "!!! Cannot find database seed with #{args[:date]} !!!"
        exit(1)
      end

      # Check if we have latest database file
      if seed_file.exist? && seed_file.mtime >= object.last_modified
        puts 'Database cache up-to-date, skipping download.'
        next
      end

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
      if (aws = `which aws`.strip).present?
        system(aws, 's3', 'cp', "s3://#{bucket}/#{object.key}", seed_file.to_s) || exit(1)
      else
        puts ' *** For faster download, please install aws-cli ***'
        client.get_object(
          response_target: seed_file,
          bucket: bucket,
          key: object.key
        )
      end

      FileUtils.touch(seed_file, mtime: object.last_modified)

      puts '  Done.'
    end

    task :restore, [:profile] do |_, args| # rubocop:disable Rails/RakeEnvironment
      database_name = ENV.fetch('DATABASE_NAME') { ActiveRecord::Base.configurations[Rails.env]['database'] }
      seed_file = SEED_PATH.join("#{args[:profile]}.sqlc")

      puts 'Re-create development database'
      Rake::Task['db:create'].invoke

      puts 'Restore from Database Seed'
      cmd = "pg_restore --dbname=#{database_name} --no-owner --no-privileges --jobs=#{Etc.nprocessors} #{seed_file}"

      system(cmd) || exit(1)
      Rake::Task['db:environment:set'].invoke
    end

    task :clean do # rubocop:disable Rails/RakeEnvironment
      puts 'Cleaning Seed Files...'
      Dir[SEED_PATH.join('*.sqlc')].each(&:unlink)
    end
  end
end
