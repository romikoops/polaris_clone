# frozen_string_literal: true

require 'bigdecimal'

module DataInserter
  module Schryver
    class FtlInserter < DataInserter::BaseInserter
      attr_reader :path, :user, :rates, :tenant,
                  :direction, :cargo_class, :truck_type, :rate_hash, :rate

      def post_initialize(args)
        @rates = args[:rates]
        @tenant = args[:tenant]
        @courier = Courier.find_or_create_by!(name: 'IGS Intermodal', tenant_id: @tenant.id)
        @missing_geometries = []
      end

      def perform
        insert_rates
      end

      private

      def find_geometry(destination_key)
        geometry = Geometry.find_by_name_1(
          destination_key
        )

        if geometry.nil?
          begin
            geocoder_results = Geocoder.search(destination_key)
            coordinates = geocoder_results.first.geometry['location']
            geometry = Geometry.find_by_coordinates(coordinates['lat'], coordinates['lng'])
          rescue StandardError
            geometry = nil
          end
        end

        @missing_geometries << destination_key if geometry.nil?

        geometry
      end

      def scoping_attributes(cargo_class, direction)
        TruckingPricingScope.find_or_create_by!(
          load_type: 'container',
          cargo_class: cargo_class,
          carriage: direction,
          courier_id: @courier.id,
          truck_type: 'chassis'
        )
      end

      def find_hub(abv)
        case abv
        when 'HH'
          @tenant.hubs.find_by_name('Hamburg Port')
        when 'BHV'
          @tenant.hubs.find_by_name('Bremerhaven Port')
        end
      end

      def create_pricing_rates(rate)
        results = {
          kg: []
        }
        weight_keys = {}
        weight_pairs = {}
        rate_keys = rate.keys
        rate_keys.each_with_index do |w_key, index|
          w_value = w_key.to_s.sub('under_', '').sub('_', '.').to_d * 1000
          weight_keys[w_key] = w_value
          weight_pairs[w_key] = [(weight_keys[rate_keys[index - 1]] || 0), w_value]
        end
        weight_pairs.each do |rate_key, weights|
          results[:kg] << {
            rate: {
              base: 1,
              value: rate[rate_key],
              currency: @rate_hash[:currency],
              rate_basis: 'PER_CONTAINER'
            },
            min_kg: weights.first,
            max_kg: weights.last,
            min_value: rate[rate_key]
          }
        end
        results
      end

      def build_trucking_pricing(cargo_class, rate, direction)
        TruckingPricing.find_or_create_by!(
          load_meterage: {
            ratio: nil,
            area_limit: nil,
            height_limit: nil
          },
          fees: {},
          trucking_pricing_scope: scoping_attributes(cargo_class, direction),
          rates: create_pricing_rates(rate),
          tenant: @tenant,
          identifier_modifier: nil,
          modifier: 'kg'
        )
      end

      def build_trucking_destination(destination)
        geometry = find_geometry(destination)
        return nil unless geometry
        TruckingDestination.find_or_create_by(
          country_code: 'DE',
          geometry: geometry
        )
      end

      def build_hub_trucking(trucking_destination, trucking_pricing, hub)
        HubTrucking.find_or_create_by!(
          trucking_destination: trucking_destination,
          hub: hub,
          trucking_pricing: trucking_pricing
        )
      end

      def insert_rates
        @rates.each do |origin, destinations|
          @hub = find_hub(origin)
          destinations.each do |destination, rate_hash|
            @rate_hash = rate_hash
            %w(pre on).each do |direction|
              @rate_hash[:rates].each do |cargo_class, rate|
                trucking_destination = build_trucking_destination(destination)
                next unless trucking_destination
                trucking_pricing = build_trucking_pricing(cargo_class, rate, direction)
                hub_trucking = build_hub_trucking(trucking_destination, trucking_pricing, @hub)
                # p hub_trucking
              end
            end
          end
        end
        p @missing_geometries
      end
    end
  end
end
