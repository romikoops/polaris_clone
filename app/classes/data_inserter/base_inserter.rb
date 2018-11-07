# frozen_string_literal: true

module DataInserter
  class BaseInserter
    def initialize(tenant:, data:, args: {})
      # Expected data structure:
      # {
      #   "Sheet1": [
      #     {
      #       "header1": "...",
      #       "header2": 0.0,
      #       "Fees": {
      #         "fee1":0.0
      #       }
      #     },
      #     {
      #       ...
      #     }
      #   ],
      #   "Sheet2": [
      #     {
      #       ...
      #     },
      #     {
      #       ...
      #     }
      #   ]
      # }

      @tenant = tenant
      @data = data

      @stats = {}
      post_initialize(args)
    end

    def perform
      raise StandardError, "The data doesn't contain the correct format!" unless valid?(@data)
    end

    def stats
      @stats.merge!(local_stats)
    end

    private

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def valid?(_data)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def local_stats
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end
  end
end
