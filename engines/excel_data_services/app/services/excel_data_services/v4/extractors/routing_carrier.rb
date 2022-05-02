# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class RoutingCarrier < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Routing::Carrier.select("routing_carriers.id as routing_carrier_id, routing_carriers.code AS carrier_code")
        end

        def join_arguments
          { "carrier_code" => "carrier_code" }
        end

        def frame_types
          { "routing_carrier_id" => :object, "carrier" => :object }
        end
      end
    end
  end
end
