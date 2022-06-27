# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class DateExpander
        def initialize(period:, dates:)
          @period = period
          @dates = dates
        end

        attr_reader :period, :dates

        def expand(input:)
          input.inner_join(expanded_validity_frame, on: {
            "effective_date" => "original_effective_date",
            "expiration_date" => "original_expiration_date"
          })
        end

        private

        def expanded_validity_frame
          @expanded_validity_frame ||= Rover::DataFrame.new(expanded_validities.uniq)
        end

        def expanded_validities
          unique_periods_from_frame.flat_map do |validity|
            expand_validity(
              effective_date: validity["effective_date"],
              expiration_date: validity["expiration_date"]
            ).compact
          end
        end

        def expand_validity(effective_date:, expiration_date:)
          partial_validities_for(
            effective_date: effective_date,
            expiration_date: expiration_date
          ).map do |partial_validity|
            partial_validity.merge(
              "original_effective_date" => effective_date.to_date,
              "original_expiration_date" => expiration_date.to_date
            )
          end
        end

        def partial_validities_for(effective_date:, expiration_date:)
          date_pairs(effective_date: effective_date, expiration_date: expiration_date).map do |period_start, period_end|
            {
              "effective_date" => period_start.to_date,
              "expiration_date" => period_end.to_date
            }
          end
        end

        def date_pairs(effective_date:, expiration_date:)
          sorted_sequence = date_sequence(effective_date: effective_date, expiration_date: expiration_date)
            .uniq
            .sort
          sorted_sequence << (sorted_sequence.first + 1.day) if sorted_sequence.length == 1
          sorted_sequence.each_cons(2).to_a
        end

        def date_sequence(effective_date:, expiration_date:)
          unique_periods_from_frame.flat_map(&:values)
            .uniq
            .select { |date| Range.new(effective_date, expiration_date).cover?(date) }
            .sort.each_with_object([]) do |date, res|
            res << date_row["effective_date"] if date_row["effective_date"] > date
            res << date_row["expiration_date"] if date_row["expiration_date"] < date
            res << date if period.cover?(date)
          end
        end

        def unique_periods_from_frame
          dates[%w[effective_date expiration_date]].to_a.uniq
        end

        def date_row
          { "effective_date" => period.first.to_date, "expiration_date" => period.last.to_date }
        end
      end
    end
  end
end
