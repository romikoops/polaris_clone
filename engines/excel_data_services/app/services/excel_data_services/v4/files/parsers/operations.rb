# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Operations < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[operations].freeze

          def operations
            @operations ||= schema_data[:operations].map do |operation_class_name|
              "ExcelDataServices::V4::Operations::#{operation_class_name}".constantize
            end
          end
        end
      end
    end
  end
end
