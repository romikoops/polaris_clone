# frozen_string_literal: true

module Api
  module V2
    class CargoUnitSerializer < Api::ApplicationSerializer
      attributes %i[cargoItemTypeId
        default
        height
        length
        stackable
        quantity
        weight
        width
        valid
        dangerous
        commodityCodes]

      attribute :commodityCodes do |cargo_unit|
        Journey::CommodityInfo.where(cargo_unit: cargo_unit).where.not(hs_code: nil).pluck(:hs_code)
      end

      attribute :dangerous do |cargo_unit|
        Journey::CommodityInfo.where(cargo_unit: cargo_unit).where.not(imo_class: "").present?
      end

      attribute :valid do |cargo_unit|
        true
      end

      attribute :default do |cargo_unit|
        false
      end

      attribute :height do |cargo_unit|
        cargo_unit.height_value * 100.0
      end

      attribute :length do |cargo_unit|
        cargo_unit.length_value * 100.0
      end

      attribute :width do |cargo_unit|
        cargo_unit.width_value * 100.0
      end

      attribute :cargoItemTypeId do |cargo_unit|
        cargo_unit.cargo_item_type_id
      end
    end
  end
end
