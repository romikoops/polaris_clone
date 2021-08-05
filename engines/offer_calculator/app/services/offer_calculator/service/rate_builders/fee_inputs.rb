# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      FeeInputs = Struct.new(
        :charge_category,
        :rate_basis,
        :min_value,
        :max_value,
        :measures,
        :targets,
        keyword_init: true
      )
    end
  end
end
