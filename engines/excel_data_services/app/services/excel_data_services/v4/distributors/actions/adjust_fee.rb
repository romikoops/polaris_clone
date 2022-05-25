# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Distributors
      module Actions
        class AdjustFee < ExcelDataServices::V4::Distributors::Actions::Base
          RATE_KEYS = ExcelDataServices::V4::Formatters::JsonFeeStructure::FeesHash::FEE_KEYS

          def perform
            frame.left_join(result_frame, on: join_keys)
          end

          private

          def result_frame
            @result_frame ||= affected_rows.tap do |affected_frame|
              rate_keys.each do |rate_key|
                affected_frame[rate_key].map! { |rate| manipulate_rate(rate: rate) }
              end
            end
          end

          def manipulate_rate(rate:)
            return rate if rate.blank?

            case operator
            when "%"
              rate.to_d * (1 + sanitized_percentage_value)
            when "+"
              rate.to_d + value
            when "*", "x"
              rate.to_d * value
            end
          end

          def operator
            @operator ||= arguments["operator"]
          end

          def value
            @value ||= arguments["value"].to_d
          end

          def join_keys
            keys_except_rate = (frame.keys - RATE_KEYS).grep_v(/_column|_row/)
            keys_except_rate.zip(keys_except_rate).to_h
          end

          def rate_keys
            @rate_keys ||= RATE_KEYS & frame.keys
          end

          def sanitized_percentage_value
            return value if value < 1

            value.to_d / 100
          end
        end
      end
    end
  end
end
