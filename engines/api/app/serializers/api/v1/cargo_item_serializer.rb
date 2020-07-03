# frozen_string_literal: true

module Api
  module V1
    class CargoItemSerializer < Api::ApplicationSerializer
      attributes %i[payload_in_kg length width height dangerous_goods cargo_class contents
                    hs_codes cargo_item_type_id customs_text chargeable_weight stackable quantity
                    unit_price]

      attribute :height do |cargo_item|
        cargo_item.height.to_f
      end

      attribute :length do |cargo_item|
        cargo_item.length.to_f
      end

      attribute :width do |cargo_item|
        cargo_item.width.to_f
      end

      attribute :cargo_item_type do |cargo_item|
        CargoItemTypeSerializer.new(cargo_item.cargo_item_type)
      end
    end
  end
end
