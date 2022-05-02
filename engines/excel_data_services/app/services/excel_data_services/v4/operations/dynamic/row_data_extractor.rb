# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      module Dynamic
        class RowDataExtractor
          INVALID_RATES = %w[n/a].freeze

          def initialize(row:, column:)
            @row = row
            @column = column
          end

          def row_data
            return [note_value] if category == :note
            return [month_value] if category == :month

            row.except(header).merge(rate_values)
          end

          private

          attr_reader :column, :row

          delegate :header, :fee_code, :category, :cargo_classes, to: :column

          def month_value
            row.except(header).merge(MonthDateValues.new(month: row[header], row: row).perform)
          end

          def value
            @value ||= INVALID_RATES.include?(row[header]) ? nil : row[header]
          end

          def rate_is_included?
            @rate_is_included ||= value.to_s.casecmp("incl").zero?
          end

          def note_value
            row.slice("row", "sheet_name").merge("remarks" => value.to_s.casecmp?("x") ? header.gsub("Dynamic:note/", "").upcase : nil)
          end

          def rate_values
            {
              "fee_code" => rate_is_included? ? included_key : fee_code,
              "fee_name" => fee_code&.upcase
            }.merge(rate_from_cell)
          end

          def rate_from_cell
            return non_money_cell unless value.is_a?(Money)

            {
              "rate" => value.cents / 100.0,
              "currency" => value.currency.iso_code
            }
          end

          def non_money_cell
            { "rate" => rate_is_included? ? 0 : value }.tap do |result|
              result["currency"] = "USD" if rate_is_included?
            end
          end

          def included_key
            "included_#{fee_code}"
          end
        end
      end
    end
  end
end
