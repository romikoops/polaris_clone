# frozen_string_literal: true

# The Schemas::File class takes and xlsx and sees if it matches the required Schema::Sheet classes to be readable

module ExcelDataServices
  module Schemas
    module Files
      class Hubs < ExcelDataServices::Schemas::Files::Base
        def valid?
          schema.present?
        end

        def schema
          @schema ||= single_sheet(sheet_class: ExcelDataServices::Schemas::Sheet::Hubs)
        end
      end
    end
  end
end
