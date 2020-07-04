# frozen_string_literal: true

module OfferCalculator
  module Service
    class TruckingDataBuilder < Base # rubocop:disable Metrics/ClassLength
      MissingTruckingData = Class.new(StandardError)

      def perform(hubs:)
        @trucking_pricings_metadata = []
        @all_selected_fees = {}
        trucking_pricings = { origin: 'pre', destination: 'on' }
                            .select { |_, carriage| @shipment.has_carriage?(carriage) }
                            .each_with_object({}) do |(target, carriage), obj|
          obj[carriage] = data_for_hubs(hubs[target], carriage)
        end

        { trucking_pricings: trucking_pricings, metadata: @trucking_pricings_metadata, selected_fees: @all_selected_fees }
      end

      private

      def data_for_hubs(hub_ids, carriage) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
        trucking_details = @shipment.trucking["#{carriage}_carriage"]
        address          = Legacy::Address.find(trucking_details['address_id'])
        errors = []
        trucking_pricing_finder = TruckingPricingFinder.new(
          trucking_details: trucking_details,
          address: address,
          carriage: carriage,
          shipment: @shipment,
          user_id: @shipment.user_id,
          sandbox: @sandbox
        )

        data = Legacy::Hub.where(id: hub_ids).each_with_object(Hash.new { |h, k| h[k] = [] }) do |hub, obj|
          distance = calc_distance(address, hub)
          trucking_pricings = trucking_pricing_finder.perform(hub.id, distance)

          trucking_charge_data = data_for_trucking_charges(trucking_pricings, distance)
          if trucking_charge_data[:error]

            errors << trucking_charge_data[:error]
            next
          end
          next if trucking_charge_data.empty?

          obj[hub.id] = { trucking_charge_data: trucking_charge_data }
        end
        valid_object = validate_data_for_hubs(data)

        raise errors.first if errors.length == hub_ids.length

        raise OfferCalculator::Calculator::MissingTruckingData if valid_object.empty?

        valid_object
      rescue OfferCalculator::Calculator::MissingTruckingData
        raise OfferCalculator::Calculator::MissingTruckingData
      rescue OfferCalculator::TruckingTools::LoadMeterageExceeded
        raise OfferCalculator::TruckingTools::LoadMeterageExceeded
      rescue StandardError => e
        Raven.capture_exception(e)
        raise OfferCalculator::Calculator::MissingTruckingData
      end

      def validate_data_for_hubs(data)
        data.each_with_object({}) do |(hub_id, trucking_data), valid_data|
          no_fees = trucking_data[:trucking_charge_data].values.map do |cc_value|
            cc_value.nil? || cc_value.except('metadata_id').values.flat_map(&:keys).empty?
          end
          valid = trucking_data[:trucking_charge_data].value?(nil) || no_fees.include?(true)
          valid_data[hub_id] = trucking_data unless valid
        end
      end

      def calc_distance(address, hub)
        OfferCalculator::GoogleDirections.new(
          address.lat_lng_string,
          hub.lat_lng_string,
          @shipment.desired_start_date.to_i
        ).distance_in_km || 0
      end

      def data_for_trucking_charges(trucking_pricings, distance)
        trucking_pricings.each_with_object({}) do |(cargo_class, trucking_pricing), trucking_charge_data|
          key = cargo_class
          trucking_charges, selected_fees = calc_trucking_charges(distance, trucking_pricing)
          trucking_charge_data[key] = trucking_charges
          all_selected_fees[key] = selected_fees
        end
      rescue OfferCalculator::TruckingTools::LoadMeterageExceeded => e
        { error: e }
      rescue StandardError => e
        Raven.capture_exception(e)
        raise OfferCalculator::Calculator::MissingTruckingData
      end

      def calc_trucking_charges(distance, trucking_pricing)
        return nil if trucking_pricing.nil?

        cargo_class = trucking_pricing.cargo_class
        cargo_unit_array = @shipment.cargo_units.where(cargo_class: cargo_class)
        cargo_units = @shipment.aggregated_cargo ? [@shipment.aggregated_cargo] : cargo_unit_array
        return nil if cargo_units.empty?

        manipulated_trucking_pricing = get_manipulated_trucking_pricing(trucking_pricing)

        return nil if manipulated_trucking_pricing.nil?

        calculation_result = OfferCalculator::TruckingTools.new(
          manipulated_trucking_pricing,
          cargo_units,
          distance,
          trucking_pricing.carriage,
          @shipment.user,
          @trucking_pricings_metadata
        ).perform

        calculation_result.merge('metadata_id' => manipulated_trucking_pricing['metadata_id'])
      end

      def get_manipulated_trucking_pricing(trucking_pricing)
        manipulated_trucking_pricings, trucking_pricing_meta = Pricings::Manipulator.new(
          type: "trucking_#{trucking_pricing.carriage}_margin".to_sym,
          target: ::Organizations::User.find_by(id: @shipment.user_id),
          organization: ::Organizations::Organization.find(@shipment.organization_id),
          args: {
            cargo_class: trucking_pricing.cargo_class,
            date: @shipment.desired_start_date,
            cargo_class_count: @shipment.cargo_classes.count,
            trucking_pricing: trucking_pricing
          }
        ).perform

        @trucking_pricings_metadata |= trucking_pricing_meta

        manipulated_trucking_pricings.first
      end

      attr_accessor :all_selected_fees, :schedules
    end
  end
end
