# frozen_string_literal: true

module DataInserter
  class BaseInserter
    attr_reader :tenant, :data

    def initialize(tenant:, data:, options: {})
      @tenant = tenant
      @data = data
      @options = options
    end

    def perform
      raise StandardError, "The data doesn't contain the correct format!" unless data_valid?(@data)
      post_perform
    end

    private

    attr_reader :options

    def data_valid?(_data)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def append_hub_suffix(name, mot)
      name + ' ' + case mot
                   when 'ocean' then 'Port'
                   when 'air'   then 'Airport'
                   when 'rail'  then 'Railyard'
                   when 'truck' then 'Depot'
                   end
    end
  end
end
