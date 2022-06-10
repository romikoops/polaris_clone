# frozen_string_literal: true

module Api
  module V2
    module Admin
      class ShipmentRequestIndexSerializer < Api::ApplicationSerializer
        CLIENT_ATTRIBUTES = %w[email first_name last_name phone last_activity_at].freeze

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
        attribute :client do |shipment_request|
          shipment_request.client.slice(*CLIENT_ATTRIBUTES).transform_keys { |key| key.camelize(:lower) }
        end
      end
    end
  end
end
