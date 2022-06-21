# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Separator
        DATE_KEYS = %w[effective_date expiration_date].freeze
        MARGIN_KEYS = DATE_KEYS + %w[code]
        MARGIN_EXPANSION_KEYS = DATE_KEYS + %w[cargo_class context_id]
        CONTEXT_KEYS = MARGIN_EXPANSION_KEYS + %w[code]

        def initialize(fee_frame:, margin_frame:)
          @fee_frame = fee_frame
          @margin_frame = margin_frame
        end

        def perform
          fee_contexts + expanded_margin_contexts
        end

        private

        attr_reader :date_frame, :margin_frame, :fee_frame

        def fee_contexts
          @fee_contexts ||= fee_frame[CONTEXT_KEYS].to_a.uniq
        end

        def margin_contexts
          @margin_contexts ||= margin_frame[!margin_frame["code"].in?(fee_frame["code"].to_a.uniq)][MARGIN_KEYS]
        end

        def expanded_margin_contexts
          @expanded_margin_contexts ||= margin_contexts.left_join(fee_contexts_without_code, on: DATE_KEYS.zip(DATE_KEYS).to_h).to_a.uniq
        end

        def fee_contexts_without_code
          @fee_contexts_without_code ||= fee_frame[MARGIN_EXPANSION_KEYS].uniq
        end
      end
    end
  end
  end
