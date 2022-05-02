# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class OriginHub < ExcelDataServices::V4::Extractors::Hub
        def prefix
          "origin"
        end
      end
    end
  end
end
