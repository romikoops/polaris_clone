# frozen_string_literal: true

module DataParser
  class BaseParser
    attr_reader :results, :stats, :hub, :tenant, :path, :hub_id

    def initialize(args={ _user: current_user })
      params = args[:params]
      @stats = _stats
      @results = _results
      if args[:hub_id]
        @hub_id = args[:hub_id]
        @hub = Hub.find(@hub_id)
      end
      @xlsx = open_file(args[:path])
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
        type: "trucking"
      }.merge(local_stats)
    end

    def local_stats
      {}
    end

    def _results
      {}
    end

    def open_json(path)
      JSON.parse(File.read("#{Rails.root}#{path.to_s}"))
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
