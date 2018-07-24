# frozen_string_literal: true

module DataInserter
  class BaseInserter
    attr_reader :results, :stats, :hub, :tenant, :data, :hub_id, :input_language

    def initialize(args={ _user: current_user })
      params = args[:params]
      @stats = _stats
      @results = _results
      if args[:hub_id]
        @hub_id = args[:hub_id]
        @hub = Hub.find(@hub_id)
      end
      @data = args[:data]
      @input_language = args[:input_language]
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

    def uuid
      SecureRandom.uuid
    end

    def debug_message(message)
      puts message if DEBUG
    end

  end
end
