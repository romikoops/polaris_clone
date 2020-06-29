require "aws-sdk-s3"

class DatabaseReloader # rubocop:disable Rails/Output
  APP_ROOT = Pathname.new(File.expand_path("../", __dir__))
  BACKUPS_BUCKET = "itsmycargo-backups"
  RESOURCES_BUCKET = "itsmycargo-datahub"
  SEED_PATH = APP_ROOT.join("tmp/cache")

  def self.perform(profile:, date: nil)
    new(profile: profile, date: date).perform
  end

  def initialize(profile:, date:)
    @profile = profile
    @date = date
  end

  def perform
    fail("Only run database reloader in development") unless Rails.env.development?

    download
    reload
  end

  def download
    Downloader.perform(profile: profile, date: date, seed_file: seed_file)
  end

  def reload
    Reloader.perform(seed_file: seed_file)
  end

  private

  attr_reader :profile, :date

  DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

  def seed_file
    @seed_file ||= SEED_PATH.join("#{profile}.sqlc")
  end

  class Downloader
    def self.perform(profile:, date:, seed_file:)
      new(profile: profile, date: date, seed_file: seed_file).perform
    end

    def initialize(profile:, date:, seed_file:)
      @profile = profile
      @date = date
      @seed_file = seed_file
    end

    def perform
      puts "Seed file: #{seed_object.last_modified} (#{DateHelper.time_ago_in_words(seed_object.last_modified)} ago)"

      puts "Skipping seed file download" && return unless stale?

      s3_download(bucket: bucket, key: seed_object.key, file: seed_file)
      FileUtils.touch(seed_file, mtime: seed_object.last_modified)
    end

    private

    attr_reader :profile, :date, :seed_file

    def stale?
      seed_file.exist? && seed_file.mtime < seed_object.last_modified
    end

    def stale_seed?
      seed_object.last_modified < 2.days.ago
    end

    def s3_download(bucket:, key:, file:)
      puts "Downloading s3://#{bucket}/#{key} to #{file}"

      # Speed up download if possible
      if (aws = `which aws`.strip).present?
        system(aws, "s3", "cp", "s3://#{bucket}/#{key}", file.to_s) || exit(1)
      else
        puts " *** For faster download, please install aws-cli ***"
        client.get_object(
          response_target: seed_file,
          bucket: bucket,
          key: key
        )
      end
    end

    def client
      @client ||= Aws::S3::Client.new
    end

    def seed_object
      @seed_object ||= if date
        available_seeds.find { |s| s.key[/-#{date}.sqlc$/] }
      else
        available_seeds.max_by(&:key)
      end
    end

    def bucket
      @bucket ||= profile == "production" ? BACKUPS_BUCKET : RESOURCES_BUCKET
    end

    def available_seeds
      @available_seeds ||= begin
        prefix = profile == "production" ? "polaris/#{profile}-" : "production/seeds/polaris/#{profile}-"
        seeds = []
        marker = nil
        loop do
          response = client.list_objects(
            bucket: bucket,
            prefix: prefix,
            marker: marker
          )

          seeds += response.contents
          marker = response.next_marker
          break if marker.nil?
        end
        seeds
      end
    end
  end

  class Reloader
    def self.perform(seed_file:)
      new(seed_file: seed_file).perform
    end

    def initialize(seed_file:)
      @seed_file = seed_file
    end

    def perform
      truncate
      restore
    end

    private

    attr_reader :profile, :seed_file

    def truncate
      puts "Truncating database #{database_name}"

      sql = <<-SQL
        DO $$ DECLARE
          r RECORD;
        BEGIN
          FOR r IN (select nspname from pg_catalog.pg_namespace where nspname not like 'pg_%' and nspname != 'information_schema') LOOP
            EXECUTE 'DROP SCHEMA ' || quote_ident(r.nspname) || ' CASCADE';
          END LOOP;
        END $$;
        CREATE SCHEMA IF NOT EXISTS public;
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end

    def restore
      puts "Restoring #{seed_file} to #{database_name}"
      puts ""
      puts "NOTE: Restore takes around 50 minutes. After (optional) progress bar"
      puts "      is done, PostgreSQL will be silently indexing data, which takes"
      puts "      around 30 minutes."
      puts ""

      pg_restore_cmd = `which pg_restore`.strip
      pv_cmd = `which pv`.strip

      fail("Please install PostgreSQL (pg_restore)") if pg_restore_cmd.blank?

      cmd = if pv_cmd.present?
        "#{pv_cmd} -ptabi 1 #{seed_file} " \
          "| #{pg_restore_cmd} --dbname=#{database_name} --no-owner --no-privileges"
      else
        puts "NOTE: To get progress bar, install pv (brew install pv)"
        "#{pg_restore_cmd} --dbname=#{database_name} --no-owner --no-privileges #{seed_file}"
      end

      system(cmd) || exit(1)
    end

    def database_name
      @database_name ||= ENV.fetch("DATABASE_NAME") { ActiveRecord::Base.configurations[Rails.env]["database"] }
    end
  end
end
