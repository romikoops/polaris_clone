# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class ChargeFees < ExcelDataServices::V4::Validators::Base
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
              range_presence_validations,
              range_value_validation,
              standard_validation,
              stowage_validation,
              base_validation
            ].compact.flatten
          end

          private

          attr_reader :row

          def range_presence_validations
            return if rate_basis.exclude?("_RANGE")

            %w[range_min range_max].select { |attribute| row[attribute].blank? }.map do |attribute|
              error(message: "Range configured rows require the values in #{attribute.upcase} to be present", attribute: attribute)
            end
          end

          def range_value_validation
            return if rate_basis.exclude?("_RANGE")

            error(message: "Range configured rows require the values in RANGE_MIN are lower than those in RANGE_MAX", attribute: "range_max") if row.values_at("range_min", "range_max").all?(&:present?) && row["range_min"] > row["range_max"]
          end

          def standard_validation
            return if row.values_at(*row_value_keys).all?(&:present?) || stowage_fee?

            error(message: "#{rate_basis} requires values in all the following columns: #{row_value_keys.join(', ')}.", attribute: "rate_basis")
          end

          def stowage_validation
            return unless stowage_fee?
            return if row.values_at(*row_value_keys).any?(&:present?)

            error(message: "#{rate_basis} requires values in either of the following columns: #{row_value_keys.join(', ')}.", attribute: "rate_basis")
          end

          def base_validation
            return unless rate_basis.include?("_X_") && row["base"].blank?

            error(message: "When the rate basis includes \"_X_\", there must be a value provided in the BASE column", attribute: "base")
          end

          def rate_basis
            @rate_basis ||= row["rate_basis"]
          end

          def row_value_keys
            @row_value_keys ||= row.keys & (rate_basis_value_keys + %w[rate value])
          end

          def rate_basis_value_keys
            @rate_basis_value_keys ||= rate_basis.split("_").reject { |part| part.in?(%w[PER X RANGE FLAT]) }.map(&:downcase)
          end

          def error(message:, attribute:)
            ExcelDataServices::V4::Error.new(
              type: :warning,
              row_nr: row["#{attribute}_row"],
              col_nr: row["#{attribute}_column"],
              sheet_name: row["sheet_name"],
              reason: message,
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
          end

          def stowage_fee?
            rate_basis == "PER_UNIT_TON_CBM_RANGE"
          end
        end
      end
    end
  end
end
