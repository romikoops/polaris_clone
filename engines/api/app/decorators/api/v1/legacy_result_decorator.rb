# frozen_string_literal: true

module Api
  module V1
    class LegacyResultDecorator < Api::V1::ResultDecorator
      delegate_all

      def legacy_format
        {
          quote: Api::LegacyQuote.quote(
            result: object,
            scope: scope
          ),
          schedules: [],
          meta: legacy_meta,
          notes: Notes::Service.new(itinerary: itinerary,
                                    tenant_vehicle: legacy_service,
                                    remarks: false).fetch
        }
      end

      def legacy_meta
        {
          mode_of_transport: mode_of_transport,
          service_level: service,
          carrier_name: carrier,
          pre_carriage_service: pre_carriage_service,
          pre_carriage_carrier: pre_carriage_carrier,
          on_carriage_service: on_carriage_service,
          on_carriage_carrier: on_carriage_carrier,
          origin_hub: origin_hub,
          destination_hub: destination_hub,
          load_type: load_type,
          exchange_rates: exchange_rates,
          validUntil: expiration_date,
          pricing_rate_data: OfferCalculator::Service::OfferCreators::RateOverview.overview(result: self),
          remarkNotes: remarks,
          transshipmentVia: transshipment,
          tender_id: id
        }.merge(chargeable_weights)
      end

      def transit_time
        route_sections.sum(&:transit_time)
      end

      def metadatum
        @metadatum ||= Pricings::Metadatum.find_by(result_id: id)
      end

      def metadata_pricing_id
        @metadata_pricing_id ||= begin
          target_breakdown = metadatum.breakdowns.where(order: 0).find do |breakdown|
            breakdown.rate_origin["type"] == "Pricings::Pricing"
          end
          target_breakdown.present? ? target_breakdown.rate_origin["id"] : nil
        end
      end

      def legacy_service
        @legacy_service ||= freight_pricing.tenant_vehicle
      end

      def legacy_carrier
        @legacy_carrier ||= begin
          Legacy::Carrier.find_by(name: carrier) if carrier != organization.slug
        end
      end

      def base_currency
        return scope[:default_currency] if query.client_id.nil?

        client.settings.currency
      end

      def chargeable_weights
        weights = {
          ocean_chargeable_weight: total_chargeable_weight(section: main_freight_section).value.to_f
        }
        weights[:pre_carriage_chargeable_weight] = total_chargeable_weight(section: pre_carriage_section).value.to_f if pre_carriage_section.present?
        weights[:on_carriage_chargeable_weight] = total_chargeable_weight(section: on_carriage_section).value.to_f if on_carriage_section.present?
        weights
      end
    end
  end
end
