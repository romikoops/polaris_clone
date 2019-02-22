# frozen_string_literal: true

module DataValidator
  class BaseValidator
    attr_reader :results, :stats, :hub, :tenant, :path, :hub_id

    def initialize(args = { _user: current_user })
      @tenant = Tenant.find(args[:tenant])
      post_initialize(args)
    end

    def perform
      raise NotImplementedError, "This method must be implemented in #{self.class.name} "
    end

    protected

    def post_initialize(_args)
      nil
    end

    def _stats
      {
        type: 'trucking'
      }.merge(local_stats)
    end

    def local_stats
      {}
    end

    def _results
      {}
    end

    def open_json(path)
      JSON.parse(File.read("#{Rails.root}#{path}"))
    end

    def open_file(path)
      file = File.open(path)
      Roo::Spreadsheet.open(file)
    end

    def uuid
      SecureRandom.uuid
    end

    def debug_message(message)
      puts message if DEBUG
    end
  end
end
