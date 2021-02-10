# frozen_string_literal: true

module Api
  module V1
    class ResultDecorator < ResultFormatter::ResultDecorator
      delegate_all

      delegate :organization, :cargo_units, to: :query

      decorates_association :user, with: UserDecorator
      decorates_association :query, with: QueryDecorator

      def legacy_json
        {
          "id": id,
          "status": "quoted",
          "load_type": load_type,
          "planned_pickup_date": selected_date,
          "has_pre_carriage": query.has_pre_carriage?,
          "has_on_carriage": query.has_on_carriage?,
          "destination_nexus": legacy_destination_hub.nexus.as_json,
          "origin_nexus": legacy_origin_hub.nexus.as_json,
          "origin_hub": legacy_origin_hub,
          "destination_hub": legacy_destination_hub,
          "planned_eta": query.delivery_date,
          "planned_etd": query.cargo_ready_date,
          "cargo_count": cargo_units.count,
          "client_name": client.profile.full_name,
          "booking_placed_at": query.created_at,
          "imc_reference": imc_reference
        }
      end

      def client
        Api::V1::UserDecorator.new(query.client)
      end

      def legacy_address_json
        legacy_json.merge(
          pickup_address: pickup_address_with_country,
          delivery_address: delivery_address_with_country,
          selected_offer: selected_offer
        )
      end

      def legacy_index_json
        legacy_json.merge(
          pickup_address: pickup_address_with_country,
          delivery_address: delivery_address_with_country
        )
      end

      def pickup_address_with_country
        query.pickup_address.as_json(include: :country)
      end

      def delivery_address_with_country
        query.delivery_address.as_json(include: :country)
      end

      def selected_date
        query.cargo_ready_date
      end

      def charges
        ResultFormatter::FeeTableService.new(result: self, scope: context[:scope]).perform
      end

      def carrier
        @carrier ||= main_freight_section.carrier
      end

      def service
        @service ||= main_freight_section.service
      end

      def pre_carriage_carrier
        @pre_carriage_carrier ||= pre_carriage_section&.carrier
      end

      def pre_carriage_service
        @pre_carriage_service ||= pre_carriage_section&.service
      end

      def on_carriage_carrier
        @on_carriage_carrier ||= on_carriage_section&.carrier
      end

      def on_carriage_service
        @on_carriage_service ||= on_carriage_section&.service
      end

      def remarks
        Notes::Service.new(itinerary: itinerary, tenant_vehicle: legacy_service, remarks: true)
          .fetch
          .to_a
          .pluck(:body)
          .compact
      end

      def vessel
        ""
      end

      def route
        itinerary.name
      end

      private

      def user
        query.client
      end

      def scope
        context.dig(:scope) || {}
      end

      def selected_offer
        Api::LegacyQuote.quote(result: object, scope: context[:scope], admin: context[:admin]).as_json
      end

      def chargeable_weight(section:)
        wm_ratio = section.line_items.first.wm_rate
        cargo_units.sum(0) do |cargo, sum|
          Api::V1::CargoUnitDecorator.new(cargo, context: {wm_ratio: wm_ratio}).chargeable_weight
        end
      end
    end
  end
end
