# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Margins
        EXPANSION_VALUE = "All"

        def initialize(applicables:, fee_codes:, period:, type:, cargo_classes:)
          @applicables = applicables
          @fee_codes = fee_codes
          @period = period
          @type = type
          @cargo_classes = cargo_classes
        end

        def perform
          fee_level_margins.concat(divided_margins).concat(replicable_margins).tap do |margin_frame|
            margin_frame.delete("expansion_value")
          end
        end

        private

        attr_reader :applicables, :period, :fee_codes, :type, :cargo_classes

        def applicable_margin_frame
          @applicable_margin_frame ||= ApplicableMargins.new(
            applicables: applicables,
            period: period,
            type: type,
            cargo_classes: cargo_classes,
            expansion_value: EXPANSION_VALUE
          ).frame
        end

        def divided_margins
          @divided_margins ||= divisable_margins.left_join(fee_code_frame, on: { "code" => "expansion_value" }).tap do |expand_frame|
            expand_frame["rate"].map! { |val| val / fee_codes.count }
          end
        end

        def divisable_margins
          @divisable_margins ||= top_level_margins.filter("operator" => "+")
        end

        def replicable_margins
          @replicable_margins ||= top_level_margins[top_level_margins["operator"].in?(["&", "%"])].left_join(fee_code_frame, on: { "code" => "expansion_value" })
        end

        def top_level_margins
          @top_level_margins ||= applicable_margin_frame.filter("code" => EXPANSION_VALUE)
        end

        def fee_level_margins
          @fee_level_margins ||= applicable_margin_frame.reject("code" => EXPANSION_VALUE)
        end

        def fee_code_frame
          @fee_code_frame ||= Rover::DataFrame.new(
            fee_codes.concat(fee_level_margins[["code"]]).to_a.uniq.map { |row| row.merge("expansion_value" => EXPANSION_VALUE) }
          )
        end
      end
    end
  end
end
