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

      attribute :commodities, &:commodity_infos
    end
  end
end
