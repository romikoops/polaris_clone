# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class TenantVehicle < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[carrier_id service mode_of_transport organization_id].freeze

        def insertable_data
          sliced_frame = rows_for_insertion[ATTRIBUTE_KEYS]
          sliced_frame["name"] = sliced_frame.delete("service")
          sliced_frame.to_a.uniq
        end

        def target_attribute
          "tenant_vehicle_id"
        end
      end
    end
  end
end
