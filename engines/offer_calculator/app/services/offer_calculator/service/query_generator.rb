# frozen_string_literal: true

module OfferCalculator
  module Service
    class QueryGenerator
      attr_reader :source, :client, :creator, :params, :persist

      def initialize(source:, client:, creator:, params:, persist: true)
        @client = client
        @creator = creator
        @source = source
        @params = params.with_indifferent_access
        @persist = persist
      end

      alias persist? persist

      def query
        @query ||= Journey::Query.new(
          cargo_ready_date: cargo_ready_date,
          delivery_date: delivery_date,
          origin: origin_string,
          origin_coordinates: origin_coordinates,
          destination_coordinates: destination_coordinates,
          destination: destination_string,
          client: client,
          creator: creator,
          company: company,
          source_id: source.id,
          load_type: load_type,
          organization: organization,
          billable: billable?
        ).tap do |new_query|
          new_query.save! if persist?
        end
      end

      private

      def load_type
        params[:load_type] == "container" ? :fcl : :lcl
      end

      def cargo_ready_date
        @cargo_ready_date ||= [Date.parse(selected_date_from_params), 1.hour.from_now].max
      end

      def selected_date_from_params
        params[:selected_day] || params[:selected_date] || Time.zone.now.to_s
      end

      def delivery_date
        @delivery_date ||= params[:selected_collection_day] ||
          cargo_ready_date + OfferCalculator::Schedule::DURATION.days
      end

      def origin_string
        @origin_string ||= params.dig(:origin, :address).presence ||
          (pre_carriage? ? origin.geocoded_address : origin.name)
      end

      def destination_string
        @destination_string ||= params.dig(:destination, :address).presence ||
          (on_carriage? ? destination.geocoded_address : destination.name)
      end

      def origin_coordinates
        @origin_coordinates ||= origin_latitude.present? &&
          RGeo::Geos.factory(srid: 4326).point(origin_longitude, origin_latitude)
      end

      def destination_coordinates
        @destination_coordinates ||= destination_latitude.present? &&
          RGeo::Geos.factory(srid: 4326).point(destination_longitude, destination_latitude)
      end

      def origin
        @origin ||= nexus(target: :origin) || address(target: :origin)
      end

      def destination
        @destination ||= nexus(target: :destination) || address(target: :destination)
      end

      def company
        Companies::Membership.find_by(client: client)&.company
      end

      def pre_carriage?
        params.dig(:origin, :nexus_id).blank?
      end

      def on_carriage?
        params.dig(:destination, :nexus_id).blank?
      end

      def origin_latitude
        (params.dig(:origin, :latitude) || origin.latitude).to_f
      end

      def origin_longitude
        (params.dig(:origin, :longitude) || origin.longitude).to_f
      end

      def destination_latitude
        (params.dig(:destination, :latitude) || destination.latitude).to_f
      end

      def destination_longitude
        (params.dig(:destination, :longitude) || destination.longitude).to_f
      end

      def nexus(target:)
        Legacy::Nexus.find_by(id: params.dig(target, :nexus_id))
      end

      def address(target:)
        Legacy::Address.new(
          latitude: params.dig(target, :latitude),
          longitude: params.dig(target, :longitude)
        ).reverse_geocode
      end

      def billable?
        organization.live && !blacklisted?
      end

      def blacklisted?
        blacklisted_emails.include?(creator&.email) || blacklisted_emails.include?(client&.email)
      end

      def organization
        @organization ||= Organizations::Organization.find(Organizations.current_id)
      end

      def blacklisted_emails
        @blacklisted_emails ||= OrganizationManager::ScopeService.new(
          target: client,
          organization: organization
        ).fetch(:blacklisted_emails)
      end
    end
  end
end
