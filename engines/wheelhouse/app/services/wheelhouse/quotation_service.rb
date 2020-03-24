# frozen_string_literal: true

module Wheelhouse
  class QuotationService
    def initialize(quotation_details:, shipping_info:)
      @user_id = quotation_details.fetch(:user_id)
      @origin = quotation_details.fetch(:origin)
      @destination = quotation_details.fetch(:destination)
      @load_type = quotation_details.fetch(:load_type)
      @selected_date = quotation_details.fetch(:selected_date)
      @shipping_info = shipping_info.to_h.deep_symbolize_keys
      @user = Tenants::User.find(@user_id)
      @legacy_user = @user.legacy
      @legacy_tenant_id = @legacy_user.tenant_id
      @shipment = Legacy::Shipment.new(user_id: @user.legacy_id, load_type: @load_type, tenant_id: @legacy_tenant_id)
    end

    def result
      params = ActionController::Parameters.new(shipment: shipping_params, sandbox: nil)
      offer_calculator = OfferCalculator::Calculator.new(
        shipment: @shipment,
        params: params,
        user: @legacy_user,
        wheelhouse: true,
        sandbox: nil
      )
      offer_calculator.perform
    rescue OfferCalculator::TruckingTools::LoadMeterageExceeded
      raise ApplicationError::LoadMeterageExceeded
    rescue OfferCalculator::Calculator::MissingTruckingData
      raise ApplicationError::MissingTruckingData
    rescue OfferCalculator::Calculator::InvalidPickupAddress
      raise ApplicationError::InvalidPickupAddress
    rescue OfferCalculator::Calculator::InvalidDeliveryAddress
      raise ApplicationError::InvalidDeliveryAddress
    rescue OfferCalculator::Calculator::InvalidLocalChargeResult
      raise ApplicationError::InvalidLocalChargeResult
    rescue OfferCalculator::Calculator::InvalidFreightResult
      raise ApplicationError::InvalidFreightResult
    rescue OfferCalculator::Calculator::NoDirectionsFound
      raise ApplicationError::NoDirectionsFound
    rescue OfferCalculator::Calculator::NoRoute
      raise ApplicationError::NoRoute
    rescue OfferCalculator::Calculator::InvalidRoutes
      raise ApplicationError::InvalidRoutes
    rescue OfferCalculator::Calculator::NoValidPricings
      raise ApplicationError::NoValidPricings
    rescue OfferCalculator::Calculator::NoValidSchedules
      raise ApplicationError::NoValidSchedules
    rescue ArgumentError
      raise ApplicationError::InternalError
    end

    def tenders
      result.tenders.map do |tender|
        Wheelhouse::TenderDecorator.new(tender)
      end
    end

    private

    attr_reader :shipment, :shipping_info, :selected_date

    def shipping_params
      {
        **cargo_units,
        selected_day: selected_date.to_s,
        origin: @origin,
        destination: @destination,
        trucking: trucking_info
      }.merge(shipping_info)
    end

    def trucking_info
      trucking_data = shipping_info.delete(:trucking_info)&.to_h || {}
      default_trucking_params.merge(trucking_data)
    end

    def default_trucking_params
      [
        { carriage: :pre_carriage, hub: @origin },
        { carriage: :on_carriage, hub: @destination }
      ].each_with_object({}) do |carriage_hub, hash|
        truck_type = @load_type == 'cargo_item' ? 'default' : 'chassis'
        hash[carriage_hub[:carriage]] = { truck_type: carriage_hub[:hub][:nexus_id] ? '' : truck_type }
      end
    end

    def cargo_units
      case @load_type
      when 'cargo_item'
        cargo_item_default
      when 'container'
        container_default
      end
    end

    def container_default
      {
        containers_attributes: [
          {
            cargo_class: 'fcl_20',
            payload_in_kg: 1,
            quantity: 1,
            size_class: 'fcl_20'
          }
        ]
      }.merge(@shipping_info.slice(:containers_attributes))
    end

    def cargo_item_default
      {
        cargo_items_attributes: [{
          payload_in_kg: 1,
          dimension_x: 1,
          dimension_y: 1,
          dimension_z: 1,
          quantity: 1,
          total_weight: 1,
          total_volume: 1,
          stackable: true,
          cargo_item_type_id: default_cargo_item_type&.id,
          cargo_class: 'lcl',
          dangerous_goods: false
        }]
      }.merge(@shipping_info.slice(:cargo_items_attributes))
    end

    def default_cargo_item_type
      shipment.tenant.cargo_item_types.take
    end
  end
end
