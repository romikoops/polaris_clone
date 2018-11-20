# frozen_string_literal: true

module DataInserter
  class BaseInserter
    def initialize(tenant:, data:, options: {})
      # Expected data structure:
      # {
      #   "Sheet1": [
      #     {
      #       header1: "...",
      #       header2: 0.0,
      #       fees: {
      #         "fee1": 0.0
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
      @options = options
    end

    def perform
      raise StandardError, "The data doesn't contain the correct format!" unless data_valid?(@data)
    end

    private

    attr_reader :options

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def data_valid?(_data)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def append_hub_suffix(name, mot)
      name + ' ' + {
        'ocean' => 'Port',
        'air'   => 'Airport',
        'rail'  => 'Railyard',
        'truck' => 'Depot'
      }[mot]
    end
  end
end
