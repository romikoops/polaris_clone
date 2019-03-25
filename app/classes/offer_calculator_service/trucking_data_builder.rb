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

    def data_for_hubs(hub_ids, carriage)
      trucking_details = @shipment.trucking["#{carriage}_carriage"]
      address          = Address.find(trucking_details['address_id'])

      trucking_pricing_finder = TruckingPricingFinder.new(
        trucking_details: trucking_details,
        address: address,
        carriage: carriage,
        shipment: @shipment,
        user_id: @shipment.user_id
      )
      data = Hub.where(id: hub_ids).each_with_object({}) do |hub, obj|
        distance = calc_distance(address, hub)

        trucking_pricings = trucking_pricing_finder.perform(hub.id, distance)

        trucking_charge_data = data_for_trucking_charges(trucking_pricings, distance)
        next if trucking_charge_data.empty?

        obj[hub.id] = { trucking_charge_data: trucking_charge_data }
      end
      valid_object = validate_data_for_hubs(data)
      raise ApplicationError::MissingTruckingData if valid_object.empty?

      valid_object
    end

    def validate_data_for_hubs(data)
      data.each_with_object({}) do |(hub_id, trucking_data), valid_data|
        valid_data[hub_id] = trucking_data unless trucking_data[:trucking_charge_data].value?(nil)
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
    rescue TruckingDataBuilder::MissingTruckingData
      raise ApplicationError::MissingTruckingData
    rescue TruckingTools::LoadMeterageExceeded
      raise ApplicationError::LoadMeterageExceeded
    rescue StandardError
      raise ApplicationError::MissingTruckingData
    end

    def calc_trucking_charges(distance, trucking_pricing)
      return nil if trucking_pricing.nil?
      cargo_class = trucking_pricing.cargo_class
      cargo_unit_array = @shipment.cargo_units.where(cargo_class: cargo_class)
      cargo_units = @shipment.aggregated_cargo ? [@shipment.aggregated_cargo] : cargo_unit_array
      return nil if cargo_units.empty?

      TruckingTools.calc_trucking_price(
        trucking_pricing,
        cargo_units,
        distance,
        trucking_pricing.carriage
      )
    end
  end
end
