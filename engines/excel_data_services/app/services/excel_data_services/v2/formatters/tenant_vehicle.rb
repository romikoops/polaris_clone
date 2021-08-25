# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class TenantVehicle < ExcelDataServices::V2::Formatters::Base
        ATTRIBUTE_KEYS = %w[carrier_id service mode_of_transport organization_id].freeze

        def insertable_data
          sliced_frame = frame[ATTRIBUTE_KEYS]
          sliced_frame["name"] = sliced_frame.delete("service")
          sliced_frame.to_a.uniq
        end
      end
    end
  end
end
