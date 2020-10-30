# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Values < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "value" => "decimal"
            }
          end
        end
      end
    end
  end
end
