# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class Metadata < ExcelDataServices::DataFrames::Coordinators::Truckings::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Truckings::Metadata
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Truckings::Metadata
          end
        end
      end
    end
  end
end
