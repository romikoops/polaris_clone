# frozen_string_literal: true

module OfferCalculatorService
  class ShipmentUpdateHandler < Base
    def initialize(shipment, params)
      @params = params
      super(shipment)
    end

    def clear_previous_itinerary
      return if @shipment.itinerary.nil?

      @shipment.itinerary = nil
      @shipment.trip      = nil
      @shipment.save
    end

    def update_nexuses
      @shipment.origin_nexus_id      = @params[:shipment][:origin][:nexus_id]
      @shipment.destination_nexus_id = @params[:shipment][:destination][:nexus_id]
    end

    def update_trucking
      # Setting trucking also sets has_on_carriage and has_pre_carriage
      @shipment.trucking = trucking_params.to_h

      { origin: "pre", destination: "on" }.each do |target, carriage|
        next unless @shipment.has_carriage?(carriage)
        address = Address.create_from_raw_params!(address_params(target))
        raise_trucking_address_error(target) if trucking_address_invalid?(address)
        @shipment.trucking["#{carriage}_carriage"]["address_id"] = address.id
      end
    end

    def update_cargo_units
      destroy_previous_cargo_units
      if aggregated_cargo_shipment?
        @shipment.aggregated_cargo = AggregatedCargo.new(aggregated_cargo_params)
        @shipment.aggregated_cargo.set_chargeable_weight!
      else
        @shipment.cargo_units = cargo_unit_const.extract(cargo_units_params)
      end
    end

    def update_incoterm
      @shipment.incoterm_id = @params[:shipment][:incoterm]
    end

    def update_selected_day
      date = Chronic.parse(@params[:shipment][:selected_day], endian_precedence: :little)
      date_limit = Date.today + 5.days
      @shipment.desired_start_date = [date, date_limit].max
    end

    private

    def cargo_unit_const
      @shipment.load_type.camelize.constantize
    end

    def plural_load_type
      @shipment.load_type.pluralize
    end

    def cargo_items_params
      @params.require(:shipment).permit(
        cargo_items_attributes: %i(
          payload_in_kg dimension_x dimension_y dimension_z
          quantity cargo_item_type_id dangerous_goods stackable
        )
      )[:cargo_items_attributes]
    end

    def containers_params
      @params.require(:shipment).permit(
        containers_attributes: %i(
          payload_in_kg sizeClass tareWeight quantity dangerous_goods
        )
      )[:containers_attributes].map do |container_attributes|
        container_attributes.to_h.deep_transform_keys { |k| k.to_s.underscore }
      end
    end

    def aggregated_cargo_shipment?
      @params[:shipment][:aggregated_cargo_attributes]
    end

    def aggregated_cargo_params
      @params.require(:shipment).require(:aggregated_cargo_attributes).permit(:weight, :volume)
    end

    def cargo_units_params
      send("#{plural_load_type}_params")
    end

    def destroy_previous_cargo_units
      @shipment.aggregated_cargo.try(:destroy)
      @shipment.aggregated_cargo = nil
      @shipment.cargo_items.destroy_all
      @shipment.containers.destroy_all
    end

    def trucking_address_invalid?(address)
      address.nil? || address.zip_code.blank?
    end

    def address_params(target)
      unsafe_address_hash = @params.require(:shipment).require(target).to_unsafe_hash
      snakefied_address_hash = unsafe_address_hash.deep_transform_keys { |k| k.to_s.underscore }
      snakefied_address_hash.deep_symbolize_keys!
      snakefied_address_hash[:geocoded_address] = snakefied_address_hash.delete(:full_address)
      snakefied_address_hash[:street_number] = snakefied_address_hash.delete(:number)
      ActionController::Parameters.new(snakefied_address_hash)
    end

    def raise_trucking_address_error(target)
      raise ApplicationError::InvalidPickupAddress   if target == "origin"
      raise ApplicationError::InvalidDeliveryAddress if target == "destination"
    end

    def trucking_params
      @params.require(:shipment).require(:trucking).permit(
        on_carriage: :truck_type, pre_carriage: :truck_type
      )
    end
  end
end
