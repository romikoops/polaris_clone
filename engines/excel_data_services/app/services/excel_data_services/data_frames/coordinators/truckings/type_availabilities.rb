# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class TypeAvailabilities < ExcelDataServices::DataFrames::Coordinators::Truckings::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Truckings::TypeAvailabilities
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Truckings::TypeAvailabilities
          end
        end
      end
    end
  end
end
