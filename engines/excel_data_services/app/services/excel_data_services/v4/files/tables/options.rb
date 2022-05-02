# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Tables
        class Options
          OPTIONAL_BOOLEAN_VALUES = [true, false, nil].freeze

          attr_reader :options

          def initialize(options: {})
            @options = options
          end

          def sanitizer
            @sanitizer ||= options[:sanitizer] || "text"
          end

          def validator
            @validator ||= options[:validator] || "string"
          end

          def required
            @required ||= options[:required].present?
          end

          def unique
            @unique ||= options[:unique].present?
          end

          def alternative_keys
            @alternative_keys ||= options[:alternative_keys] || []
          end

          def fallback
            @fallback ||= options[:fallback]
          end

          def type
            @type ||= options[:type] || :object
          end

          def dynamic
            @dynamic ||= options[:dynamic].present?
          end

          def header_row
            @header_row ||= options[:header_row]
          end

          def column_length
            @column_length ||= options[:column_length]
          end

          def column_index
            @column_index ||= options[:column_index]
          end

          def fallback_configured?
            @fallback_configured ||= options.key?(:fallback)
          end

          def errors
            %i[dynamic unique required].each_with_object([]) do |key, errs|
              next if OPTIONAL_BOOLEAN_VALUES.include?(options[key])

              errs << ExcelDataServices::V4::Files::Error.new(
                type: :type_error,
                row_nr: nil,
                col_nr: nil,
                sheet_name: nil,
                reason: "Option ['#{key}'] must be a boolean value or left blank",
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::BooleanValueMissing
              )
            end
          end
        end
      end
    end
  end
end
