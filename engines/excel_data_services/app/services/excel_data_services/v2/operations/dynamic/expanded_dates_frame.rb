# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Operations
      module Dynamic
        class ExpandedDatesFrame
          # This class will take the denormalised rows and group them by the validities,
          # duplicating each row for each of the main validity periods. The result will be ready to pass the Conflicts::Resolver (ie no conflicting validities within the sheet)

          def initialize(row:, row_frame:)
            @row = row
            @row_frame = row_frame
          end

          attr_reader :row, :row_frame

          def frame
            Rover::DataFrame.new(
              validities.map do |validity|
                validity.merge(
                  "original_effective_date" => row["effective_date"],
                  "original_expiration_date" => row["expiration_date"],
                  "sheet_name" => row["sheet_name"],
                  "row" => row["row"]
                )
              end
            )
          end

          private

          def validities
            @validities ||= date_pairs.each_with_object([]) do |(first_date, last_date), result|
              expiration_date = effective_dates.include?(last_date) ? last_date - 1.day : last_date
              effective_date = expiration_dates.include?(first_date) ? first_date + 1.day : first_date
              next if expiration_date <= effective_date

              result << {
                "effective_date" => effective_date,
                "expiration_date" => expiration_date
              }
            end
          end

          def date_pairs
            row_frame[%w[effective_date expiration_date]].to_a.flat_map(&:values)
              .compact.uniq.sort
              .select { |date| main_validity.cover?(date) }
              .each_cons(2)
          end

          def effective_dates
            @effective_dates ||= row_frame["effective_date"].to_a.uniq
          end

          def expiration_dates
            @expiration_dates ||= row_frame["expiration_date"].to_a.uniq
          end

          def main_validity
            @main_validity ||= Range.new(*row.values_at("effective_date", "expiration_date"))
          end
        end
      end
    end
  end
end
