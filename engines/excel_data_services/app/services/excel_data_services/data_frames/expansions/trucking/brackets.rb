# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Expansions
      module Trucking
        class Brackets < ExcelDataServices::DataFrames::Base
          def performing_modules
            [ExcelDataServices::Expanders::Brackets]
          end
        end
      end
    end
  end
end
