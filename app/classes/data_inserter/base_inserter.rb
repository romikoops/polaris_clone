# frozen_string_literal: true

module DataInserter
  class BaseInserter
    def initialize(tenant:, data:)
      @tenant = tenant
      @data = data

      @stats = {}
      post_initialize
    end

    def perform(_should_generate_trips = true)
      raise StandardError, "The data doesn't contain the correct format!" unless valid?(@data)
    end

    def stats
      @stats.merge!(local_stats)
    end

    private

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def local_stats
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end
  end
end
