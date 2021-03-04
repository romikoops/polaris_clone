# frozen_string_literal: true

module Api
  module V1
    class LclCargoUnitSerializer < Api::ApplicationSerializer
      attributes %i[payload_in_kg length width height dangerous_goods cargo_class contents
        hs_codes cargo_item_type_id customs_text chargeable_weight stackable quantity
        unit_price]

      attribute :cargo_item_type do |cargo_item|
        { id: cargo_item.cargo_item_type_id, description: cargo_item.colli_type.humanize }
      end

      attribute :contents do
        ""
      end
    end
  end
end
