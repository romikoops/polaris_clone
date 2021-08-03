# frozen_string_literal: true

module Api
  module V2
    class ChargeSerializer < Api::ApplicationSerializer
      attributes %i[id fee_code description original_value value order section unit_price units]

      attribute :value do |charge|
        {
          value: charge.total.cents / 100.0,
          currency: charge.total.currency.iso_code
        }
      end

      attribute :unit_price do |charge|
        {
          value: charge.unit_price.cents / 100.0,
          currency: charge.unit_price.currency.iso_code
        }
      end
    end
  end
end
