# frozen_string_literal: true

module Api
  module V2
    class ResultDecorator < ResultFormatter::ResultDecorator
      delegate_all

      delegate :organization, :cargo_units, :user, :client, :cargo_ready_date, to: :query
      decorates_association :client, with: Api::V1::UserDecorator
      decorates_association :query, with: QueryDecorator

      def carrier
        @carrier ||= main_freight_section.carrier
      end

      def carrier_logo
        @carrier_logo ||= logo.attached? ? Rails.application.routes.url_helpers.rails_blob_url(logo) : nil
      end

      def number_of_stops
        transshipment_count = transshipment.nil? || transshipment.casecmp("direct").zero? ? 1 : 0
        route_sections.where.not(mode_of_transport: "relay").count - transshipment_count
      end

      def cargo_delivery_date
        return if route_section_transit_time.blank?

        cargo_ready_date + route_section_transit_time.days
      end
    end
  end
end
