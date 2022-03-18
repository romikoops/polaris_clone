# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Parsers
        class Operations < ExcelDataServices::V3::Files::Parsers::Base
          SPLIT_PATTERN = /^(add_operation)/.freeze

          def operations
            @operations ||= []
          end

          def add_operation(class_name)
            operation_class = "ExcelDataServices::V3::Operations::#{class_name}".constantize
            @operations << operation_class unless operations.include?(operation_class)
          end
        end
      end
    end
  end
end
