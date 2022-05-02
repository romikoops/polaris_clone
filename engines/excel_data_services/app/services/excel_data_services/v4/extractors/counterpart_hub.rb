# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class CounterpartHub < ExcelDataServices::V4::Extractors::Hub
        def prefix
          "counterpart"
        end
      end
    end
  end
end
