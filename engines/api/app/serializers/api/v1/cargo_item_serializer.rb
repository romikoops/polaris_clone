# frozen_string_literal: true

module Api
  module V1
    class CargoItemSerializer < Api::ApplicationSerializer
      attributes %i[payload_in_kg dimension_y dimension_x dimension_z dangerous_goods cargo_class
                    hs_codes cargo_item_type_id customs_text chargeable_weight stackable quantity unit_price]
    end
  end
end
