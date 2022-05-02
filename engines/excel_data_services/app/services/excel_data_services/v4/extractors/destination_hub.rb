# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class DestinationHub < ExcelDataServices::V4::Extractors::Hub
        def prefix
          "destination"
        end
      end
    end
  end
end
