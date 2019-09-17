# frozen_string_literal: true

module OfferCalculatorService
  class TruckingDataBuilder < Base
    MissingTruckingData = Class.new(StandardError)

    def perform(hubs)
      { origin: 'pre', destination: 'on' }
        .select { |_, carriage| @shipment.has_carriage?(carriage) }
        .each_with_object({}) do |(target, carriage), obj|
          obj[carriage] = data_for_hubs(hubs[target], carriage)
        end
    end

    private

    def data_for_hubs(hub_ids, carriage) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      trucking_details = @shipment.trucking["#{carriage}_carriage"]
      address          = Address.find(trucking_details['address_id'])
      errors = []
      trucking_pricing_finder = TruckingPricingFinder.new(
        trucking_details: trucking_details,
        address: address,
        carriage: carriage,
        shipment: @shipment,
        user_id: @scope['base_pricing'] ? @shipment.user_id : @shipment.user.pricing_id,
        sandbox: @sandbox
      )

      data = Hub.where(id: hub_ids).each_with_object({}) do |hub, obj|
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
      raise ApplicationError::MissingTruckingData if valid_object.empty?

      valid_object
    rescue TruckingDataBuilder::MissingTruckingData
      raise ApplicationError::MissingTruckingData
    rescue TruckingTools::LoadMeterageExceeded
      raise ApplicationError::LoadMeterageExceeded
    rescue StandardError
      raise ApplicationError::MissingTruckingData
    end

    def validate_data_for_hubs(data)
      data.each_with_object({}) do |(hub_id, trucking_data), valid_data|
        no_fees = trucking_data[:trucking_charge_data].values.map do |cc_value|
          (cc_value['stackable'].keys | cc_value['non_stackable'].keys).empty?
        end
        valid = trucking_data[:trucking_charge_data].has_value?(nil) || no_fees.include?(true)
        valid_data[hub_id] = trucking_data unless valid
      end
    end

    def calc_distance(address, hub)
      GoogleDirections.new(
        address.lat_lng_string,
        hub.lat_lng_string,
        @shipment.desired_start_date.to_i
      ).distance_in_km || 0
    end

    def data_for_trucking_charges(trucking_pricings, distance)
      trucking_pricings.each_with_object({}) do |(cargo_class, trucking_pricing), trucking_charge_data|
        key = cargo_class
        trucking_charges = calc_trucking_charges(distance, trucking_pricing)
        trucking_charge_data[key] = trucking_charges
      end

    rescue TruckingDataBuilder::MissingTruckingData => e
      return { error: e }
    rescue TruckingTools::LoadMeterageExceeded => e
      return { error: e }
    rescue StandardError => e
      raise ApplicationError::MissingTruckingData
    end

    def calc_trucking_charges(distance, trucking_pricing)
      return nil if trucking_pricing.nil?

      cargo_class = trucking_pricing.cargo_class
      cargo_unit_array = @shipment.cargo_units.where(cargo_class: cargo_class)
      cargo_units = @shipment.aggregated_cargo ? [@shipment.aggregated_cargo] : cargo_unit_array
      return nil if cargo_units.empty?

      manipulated_trucking_pricing = if @scope['base_pricing']
                                       get_manipulated_trucking_pricing(trucking_pricing)
                                     else
                                      trucking_pricing
                                     end

      return nil if manipulated_trucking_pricing.nil?

      TruckingTools.new(
        manipulated_trucking_pricing,
        cargo_units,
        distance,
        trucking_pricing.carriage,
        @shipment.user
      ).perform
    end

    def get_manipulated_trucking_pricing(trucking_pricing)
      results = Pricings::Manipulator.new(
        type: "trucking_#{trucking_pricing.carriage}_margin".to_sym,
        user: ::Tenants::User.find_by(legacy_id: @shipment.user_id),
        args: {
          cargo_class: trucking_pricing.cargo_class,
          date: @shipment.desired_start_date,
          shipment: @shipment,
          trucking_pricing: trucking_pricing
        }
      ).perform
      results.first
    end
  end
end
