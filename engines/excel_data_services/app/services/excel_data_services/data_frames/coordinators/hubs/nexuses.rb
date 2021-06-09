# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Hubs
        class Nexuses < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator
            ExcelDataServices::DataFrames::Combinators::Hubs::Nexuses
          end

          def restructurer
            ExcelDataServices::DataFrames::Restructurers::Hubs::Nexuses
          end
        end
      end
    end
  end
end
