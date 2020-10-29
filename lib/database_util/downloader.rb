require "aws-sdk-s3"

class DatabaseUtil
  class Downloader
    APP_ROOT = Pathname.new(File.expand_path("../../", __dir__))
    DATAHUB_BUCKET = "itsmycargo-datahub"
    SEED_PATH = APP_ROOT.join("tmp")

    def initialize(profile:)
      @profile = profile
    end

    def download
      puts "Seed file: #{seed_object.last_modified} (#{DateHelper.time_ago_in_words(seed_object.last_modified)} ago)"

      return unless stale?

      s3_download(bucket: bucket, key: seed_object.key, file: tmp_file)

      FileUtils.mv(tmp_file, seed_file)
      FileUtils.touch(seed_file, mtime: seed_object.last_modified)
    end

    def seed_file
      @seed_file ||= SEED_PATH.join("#{profile}.sqlc")
    end

    private

    attr_reader :profile

    DateHelper = Class.new { include ActionView::Helpers::DateHelper }.new

    def tmp_file
      @tmp_file ||= SEED_PATH.join("#{profile}.download")
    end

    def stale?
      (seed_file.exist? && seed_file.mtime < seed_object.last_modified) || !seed_file.exist?
    end

    def stale_seed?
      seed_object.last_modified < 2.days.ago
    end

    def s3_download(bucket:, key:, file:)
      if (aws = `which aws`.strip).present?
        system(aws, "s3", "cp", "s3://#{bucket}/#{key}", file.to_s) || exit(1)
      else
        puts " *** For download, please install aws-cli ***"
        puts "     brew install aws"
        puts ""
      end
    end

    def client
      @client ||= Aws::S3::Client.new
    end

    def seed_object
      @seed_object ||= available_seeds.max_by(&:key)
    end

    def bucket
      DATAHUB_BUCKET
    end

    def available_seeds
      @available_seeds ||= begin
        prefix = "production/seeds/polaris/#{profile}-"
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
end
