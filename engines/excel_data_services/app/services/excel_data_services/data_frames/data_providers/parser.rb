# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DataProviders
      class Parser
        attr_reader :cell, :header, :section

        delegate :sheet_name, :row, :col, :label, to: :cell, allow_nil: true

        def initialize(cell:, header:, section:)
          @cell = cell
          @header = header
          @section = section
        end

        def value
          sanitized_value
        end

        def error
          @error ||= validator_klass.validate(cell: cell, header: header, value: sanitized_value)
        end

        def sanitized_value
          @sanitized_value ||= sanitizer_klass.sanitize(value: cell&.value, attribute: header)
        end

        def sanitizer_klass
          "ExcelDataServices::DataFrames::Sanitizers::#{section}".safe_constantize
        end

        def validator_klass
          "ExcelDataServices::DataFrames::Validators::#{section}".safe_constantize
        end
      end
    end
  end
end
