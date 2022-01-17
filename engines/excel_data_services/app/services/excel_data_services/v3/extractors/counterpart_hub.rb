# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Extractors
      class CounterpartHub < ExcelDataServices::V3::Extractors::Hub
        def prefix
          "counterpart"
        end
      end
    end
  end
end
