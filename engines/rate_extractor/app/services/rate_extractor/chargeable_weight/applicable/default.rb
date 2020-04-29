# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module Applicable
      class Default < Base
        def chargeable_weight
          [cargo.volumetric_weight, cargo.total_weight].max
        end
      end
    end
  end
end
