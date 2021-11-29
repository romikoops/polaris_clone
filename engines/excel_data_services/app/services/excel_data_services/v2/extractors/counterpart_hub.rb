# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class CounterpartHub < ExcelDataServices::V2::Extractors::Hub
        def prefix
          "counterpart"
        end
      end
    end
  end
end
