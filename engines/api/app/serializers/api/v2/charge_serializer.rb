# frozen_string_literal: true

module Api
  module V2
    class ChargeSerializer < Api::ApplicationSerializer
      attributes [:id, :fee_code, :description, :original_value, :value, :order, :section]

      attribute :value do |charge|
        {
          value: charge.total.cents / 100.0,
          currency: charge.total.currency.iso_code
        }
      end
    end
  end
end
