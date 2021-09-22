# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class FeeMetadata < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "carrier" => "string",
              "direction" => "downcase",
              "truck_type" => "downcase",
              "cargo_class" => "downcase",
              "service" => "string"
            }
          end

          def default_values
            {
              "service" => "standard",
              "carrier" => "",
              "mode_of_transport" => "truck_carriage"
            }
          end
        end
      end
    end
  end
end
