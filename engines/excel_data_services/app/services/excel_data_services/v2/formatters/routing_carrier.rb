# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Formatters
      class RoutingCarrier < ExcelDataServices::V2::Formatters::Carrier
        def target_attribute
          "routing_carrier_id"
        end
      end
    end
  end
end
