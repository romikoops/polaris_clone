# frozen_string_literal: true

module Api
  module V2
    class ShipmentRequestIndexSerializer < Api::ApplicationSerializer
      attributes %i[result_id
        company_id
        client_id
        with_insurance
        with_customs_handling
        status
        preferred_voyage
        notes
        origin_hub
        destination_hub
        origin_pickup
        destination_dropoff]

      attribute :requestedAt, &:created_at
      attribute :reference, &:imc_reference

      has_many :addendums
    end
  end
end
