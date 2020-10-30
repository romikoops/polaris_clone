# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Targets
      class List < ExcelDataServices::Schemas::Targets::Base
        def perform
          coordinate_target.split(",").map { |coordinate| coordinate.split("|") }
        end
      end
    end
  end
end
