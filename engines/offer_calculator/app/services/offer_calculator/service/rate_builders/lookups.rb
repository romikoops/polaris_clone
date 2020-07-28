# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class Lookups
        STANDARD_RATE_BASES = %w[
          PER_SHIPMENT
          PER_BILL
          PER_ITEM
          PER_UNIT
          PER_CONTAINER
          PER_CBM
          PER_KG
          PER_X_KG_FLAT
          PER_X_KG
          PER_X_KM
          PER_TON
          PER_WM
          PERCENTAGE
        ].freeze

        MODIFIERS_BY_RATE_BASIS = {
          kg: %w[PER_KG PER_KG_FLAT PER_X_KG_FLAT PER_X_KG PER_KG_RANGE PER_KG_RANGE_FLAT PER_UNIT_KG],
          wm: %w[PER_WM PER_WM_RANGE PER_WM_RANGE_FLAT],
          cbm: %w[PER_CBM PER_CBM_RANGE PER_CBM_RANGE_FLAT],
          unit: %w[PER_UNIT PER_UNIT_RANGE PER_UNIT_RANGE_FLAT PER_ITEM PER_CONTAINER],
          km: %w[PER_KM PER_KM_RANGE PER_KM_RANGE_FLAT PER_X_KM],
          ton: %w[PER_TON],
          shipment: %w[PER_SHIPMENT PER_BILL],
          percentage: %w[PERCENTAGE]
        }.freeze

        STANDARD_RANGE_KEYS = %w[cbm wm kg].freeze

        MODIFIER_LOOKUP = {
          cbm_kg: %w[cbm kg],
          unit_per_km: %w[unit km],
          unit_and_kg: %w[kg unit_in_kg],
          unit: ["unit"],
          cbm: ["cbm"],
          wm: ["wm"],
          kg: ["kg"]
        }.freeze

        UNIT_RATE_BASES = %w[
          PER_UNIT
          PER_CONTAINER
          PER_ITEM
        ].freeze

        NON_STANDARD_RATE_BASIS_MODIFIER_LOOKUP = {
          'PER_CBM_TON': %w[cbm ton]
        }.freeze

        SHIPMENT_LEVEL_RATE_BASES = %w[PER_SHIPMENT PER_BILL PERCENTAGE].freeze
      end
    end
  end
end
