# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class Fees < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Truckings::Fees
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Truckings::Fees
          end
        end
      end
    end
  end
end
