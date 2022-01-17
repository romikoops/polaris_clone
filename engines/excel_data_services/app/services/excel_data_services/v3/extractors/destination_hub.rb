# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Extractors
      class DestinationHub < ExcelDataServices::V3::Extractors::Hub
        def prefix
          "destination"
        end
      end
    end
  end
end
