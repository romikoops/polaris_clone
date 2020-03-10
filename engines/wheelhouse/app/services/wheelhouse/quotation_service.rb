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

    def results
      params = ActionController::Parameters.new(shipment: shipping_params, sandbox: nil)
      offer_calculator = OfferCalculator::Calculator.new(
        shipment: @shipment,
        params: params,
        user: @legacy_user,
        wheelhouse: true,
        sandbox: nil
      )
      offer_calculator.perform
    end

    def tenders
      results.map do |result|
        JSON.parse(result.to_json, object_class: ::Wheelhouse::OpenStruct)
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
      { pre_carriage: { truck_type: '' }, on_carriage: { truck_type: '' } }.merge(trucking_data)
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
        containers_attributes: [{
          cargo_class: 'fcl_20',
          payload_in_kg: 1,
          quantity: 1,
          size_class: 'fcl_20'
        }]
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
