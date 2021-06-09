# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class Rates < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Truckings::Rates
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Truckings::Rates
          end
        end
      end
    end
  end
end
