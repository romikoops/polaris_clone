# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class Locations < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Truckings::Locations
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Truckings::Locations
          end
        end
      end
    end
  end
end
