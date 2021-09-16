# frozen_string_literal: true

module Api
  module V1
    class ItineraryDecorator < ApplicationDecorator
      delegate_all
      decorates_association :origin_hub, with: ResultFormatter::HubDecorator
      decorates_association :destination_hub, with: ResultFormatter::HubDecorator

      def legacy_json
        {
          origin: origin_hub.name,
          destination: destination_hub.name,
          transshipment: transshipment,
          mode_of_transport: mode_of_transport,
          last_expiry: last_expiry,
          name: name,
          id: id
        }
      end

      private

      def last_expiry
        rates.current
          .where("expiration_date > ?", DateTime.now)
          .order(:expiration_date)
          .limit(1)
          .pluck(:expiration_date)
          .first
      end
    end
  end
end
