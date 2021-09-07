# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Carrier < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Legacy::Carrier.select("carriers.id as carrier_id, carriers.code AS carrier")
        end

        def join_arguments
          { "carrier" => "carrier" }
        end

        def frame_types
          { "carrier_id" => :object, "carrier" => :object }
        end

        def error_reason(row:)
          "The carrier '#{row['carrier']}' cannot be found."
        end

        def required_key
          "carrier_id"
        end
      end
    end
  end
end
