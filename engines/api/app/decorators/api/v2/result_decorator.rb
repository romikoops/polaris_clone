# frozen_string_literal: true

module Api
  module V2
    class ResultDecorator < ResultFormatter::ResultDecorator
      delegate_all

      delegate :organization, :cargo_units, :user, :client, :cargo_ready_date, :cargo_delivery_date, to: :query
      decorates_association :client, with: Api::V1::UserDecorator
      decorates_association :query, with: QueryDecorator

      def routing
        route_sections_in_order.reject { |route_section| route_section.mode_of_transport == "relay" }.map do |route_section|
          routing_from_route_section(route_section: route_section)
        end
      end

      def carrier
        @carrier ||= main_freight_section.carrier
      end

      def carrier_logo
        @carrier_logo ||= logo.attached? ? Rails.application.routes.url_helpers.rails_blob_url(logo) : nil
      end

      private

      def routing_from_route_section(route_section:)
        route_section.slice(:id, :service, :carrier, :mode_of_transport, :transit_time).merge(
          origin: route_point_info(route_point: route_section.from),
          destination: route_point_info(route_point: route_section.to)
        )
      end

      def route_point_info(route_point:)
        route_point.slice(:name, :locode, :city, :coordinates).tap do |data|
          data[:address] = data.delete(:name)
        end
      end
    end
  end
end
