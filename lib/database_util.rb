require "database_util/downloader"
require "database_util/restorer"

class DatabaseUtil
  def self.reload(profile:)
    new(profile: profile).reload
  end

  def self.restore(profile:)
    new(profile: profile).restore
  end

  def initialize(profile:)
    @profile = profile
  end

  def reload
    downloader.download
    restorer.load(seed_file: downloader.seed_file)
    restorer.create
  end

  def restore
    unless restorer.exists?
      downloader.download
      restorer.load
    end
    restorer.create
  end

  private

  attr_reader :profile

  def downloader
    @downloader ||= Downloader.new(profile: profile)
  end

  def restorer
    @restorer ||= Restorer.new(profile: profile)
  end
end
