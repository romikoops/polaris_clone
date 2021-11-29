# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class DestinationHub < ExcelDataServices::V2::Extractors::Hub
        def prefix
          "destination"
        end
      end
    end
  end
end
