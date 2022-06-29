# frozen_string_literal: true

module Api
  module V2
    class ShipmentRequestSerializer < Api::ApplicationSerializer
      attributes %i[result_id company_id client_id with_insurance
        with_customs_handling status preferred_voyage notes]

      attribute :commercial_value do |shipment_request|
        {
          value: shipment_request.commercial_value_cents,
          currency: shipment_request.commercial_value_currency
        }
      end

      has_many :contacts
      has_many :documents
      has_many :addendums
    end
  end
end
