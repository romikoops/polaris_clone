# frozen_string_literal: true

module Api
  module V2
    class CargoUnitSerializer < Api::ApplicationSerializer
      attributes %i[
        cargo_class
        colli_type
        height
        length
        stackable
        quantity
        weight
        width
        volume
        commodities
      ]

      attribute :commodities do |cargo_unit|
        cargo_unit.commodity_infos.map do |commodity_info|
          commodity_info.as_json.transform_keys { |key| key.camelize(:lower) }
        end
      end
    end
  end
end
