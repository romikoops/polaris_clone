# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Modifiers < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "modifier" => "downcase"
            }
          end
        end
      end
    end
  end
end
