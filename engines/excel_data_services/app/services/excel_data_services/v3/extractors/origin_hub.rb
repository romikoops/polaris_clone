# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Extractors
      class OriginHub < ExcelDataServices::V3::Extractors::Hub
        def prefix
          "origin"
        end
      end
    end
  end
end
