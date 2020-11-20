# frozen_string_literal: true

module Api
  module V1
    class ContainerSerializer < Api::ApplicationSerializer
      attributes %i[shipment_id size_class weight_class payload_in_kg tare_weight gross_weight
        dangerous_goods cargo_class hs_codes customs_text quantity unit_price contents]

      attribute :equipment_type, &:cargo_class
      attribute :weight, &:payload_in_kg
      attribute :size_class, &:cargo_class
      attribute :dangerous, &:dangerous_goods
    end
  end
end
