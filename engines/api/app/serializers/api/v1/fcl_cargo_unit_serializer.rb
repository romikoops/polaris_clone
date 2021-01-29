# frozen_string_literal: true

module Api
  module V1
    class FclCargoUnitSerializer < Api::ApplicationSerializer
      attributes %i[shipment_id size_class weight_class payload_in_kg tare_weight gross_weight
        dangerous_goods cargo_class hs_codes customs_text quantity unit_price contents]

      attribute :shipment_id, &:query_id
      attribute :equipment_type, &:cargo_class
      attribute :size_class, &:cargo_class

      attribute :payload_in_kg do |cargo_item|
        cargo_item.weight_value.to_f
      end
    end
  end
end
