# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      module Dynamic
        class MonthDateValues
          MONTHS_GERMAN_TO_ENGLISH_LOOKUP = {
            "MAI" => "MAY",
            "OKT" => "OCT",
            "DEZ" => "DEC"
          }.freeze

          def initialize(month:, row:)
            @month = month
            @row = row
          end

          def perform
            { "effective_date" => effective_date, "expiration_date" => new_expiration_date }
          end

          private

          attr_reader :month, :row

          def effective_date
            [month_as_range.first, validity.first].max if month_is_valid?
          end

          def new_expiration_date
            [month_as_range.last, validity.last].min if month_is_valid?
          end

          def month_as_range
            @month_as_range ||= [validity.first.year, validity.last.year]
              .uniq
              .map { |year| month_as_range_for(year: year) }
              .find { |month_as_range| validity.overlaps?(month_as_range) }
          end

          def month_abreviation
            abrv_month = I18n.transliterate(month[0..2]).upcase
            MONTHS_GERMAN_TO_ENGLISH_LOOKUP[abrv_month] || month
          end

          def month_is_valid?
            !(month.blank? || month.casecmp("n/a").zero? || month_as_range.blank?)
          end

          def validity
            @validity ||= Range.new(row["effective_date"], row["expiration_date"])
          end

          def month_as_range_for(year:)
            month_as_date = Date.parse("#{month_abreviation} #{year}")
            Range.new(month_as_date, month_as_date.end_of_month)
          end
        end
      end
    end
  end
end
