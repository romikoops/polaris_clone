# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class OriginHub < ExcelDataServices::V2::Extractors::Hub
        def prefix
          "origin"
        end
      end
    end
  end
end
