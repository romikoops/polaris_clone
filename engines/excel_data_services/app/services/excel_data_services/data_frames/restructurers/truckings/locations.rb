# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Truckings
        class Locations < ExcelDataServices::DataFrames::Restructurers::Base
          def restructured_data
            frame
          end
        end
      end
    end
  end
end
