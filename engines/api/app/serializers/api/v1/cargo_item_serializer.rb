# frozen_string_literal: true

module Api
  module V1
    class CargoItemSerializer < Api::ApplicationSerializer
      attributes %i[payload_in_kg dimension_y dimension_x dimension_z dangerous_goods cargo_class contents
                    hs_codes cargo_item_type_id customs_text chargeable_weight stackable quantity unit_price]

      attribute :height, &:dimension_z
      attribute :length, &:dimension_y
      attribute :width, &:dimension_x

      attribute :cargo_item_type do |cargo_item|
        CargoItemTypeSerializer.new(cargo_item.cargo_item_type)
      end
    end
  end
end
