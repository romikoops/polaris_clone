# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Hubs::Hubs
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Hubs::Hubs
          end
        end
      end
    end
  end
end
