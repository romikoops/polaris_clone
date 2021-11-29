# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class LocalChargeFees < ExcelDataServices::V2::Validators::Base
        def extract_state
          @state
        end

        def append_errors_to_state
          frame.each_row do |frame_row|
            @state.errors |= RowValidator.new(row: frame_row).errors
          end
        end

        class RowValidator
          def initialize(row:)
            @row = row
          end

          def errors
            [
              range_validation,
              standard_validation,
              base_validation
            ].compact
          end

          private

          attr_reader :row

          def range_validation
            return if rate_basis.exclude?("_RANGE")

            if row.values_at("range_min", "range_max").any?(&:blank?)
              error(message: "Range configured rows require the values in RANGE_MIN and RANGE_MAX to be present")
            elsif row["range_min"] > row["range_max"]
              error(message: "Range configured rows require the values in RANGE_MIN are lower than those in RANGE_MAX")
            end
          end

          def standard_validation
            return if row.values_at(*row_value_keys).all?(&:present?)

            error(message: "#{rate_basis} requires values in all the following columns: #{row_value_keys.join(', ')}.")
          end

          def base_validation
            return unless rate_basis.include?("_X_") && row["base"].blank?

            error(message: "When the rate basis includes \"_X_\", there must be a value provided in the BASE column")
          end

          def rate_basis
            @rate_basis ||= row["rate_basis"]
          end

          def row_value_keys
            @row_value_keys ||= rate_basis.split("_").reject { |part| part.in?(%w[PER X RANGE FLAT]) }.map(&:downcase)
          end

          def error(message:)
            ExcelDataServices::V2::Error.new(
              type: :warning,
              row_nr: row["row"],
              sheet_name: row["sheet_name"],
              reason: message,
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end
        end
      end
    end
  end
end
