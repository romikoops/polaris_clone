# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Brackets < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "bracket" => "string"
            }
          end
        end
      end
    end
  end
end
