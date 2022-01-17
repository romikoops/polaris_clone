# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Formatters
      class RoutingCarrier < ExcelDataServices::V3::Formatters::Carrier
        def target_attribute
          "routing_carrier_id"
        end
      end
    end
  end
end
