# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class HubAvailabilities < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Truckings::HubAvailabilities
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Truckings::HubAvailabilities
          end
        end
      end
    end
  end
end
