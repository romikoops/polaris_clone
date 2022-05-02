# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Carrier < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Legacy::Carrier.select("carriers.id as carrier_id, carriers.code AS carrier_code")
        end

        def join_arguments
          { "carrier_code" => "carrier_code" }
        end

        def frame_types
          { "carrier_id" => :object, "carrier" => :object }
        end
      end
    end
  end
end
