# frozen_string_literal: true

module Wheelhouse
  class QuotationService
    CARGO_ITEM_CARGO_CLASS = 'lcl'
    CONAINER_CARGO_CLASS = 'fcl_20'
    CARGO_ITEM_TYPE = "Pallet"

    attr_reader :estimated, :organization
    include Wheelhouse::ErrorHandler

    def initialize(organization:, quotation_details:, shipping_info:)
      @user_id = quotation_details[:user_id]
      @creator = quotation_details[:creator]
      @user = Organizations::User.find_by(id: @user_id)
      @origin = quotation_details.fetch(:origin)
      @destination = quotation_details.fetch(:destination)
      @load_type = quotation_details.fetch(:load_type)
      @selected_date = quotation_details.fetch(:selected_date)
      @shipping_info = shipping_info.to_h.deep_symbolize_keys
      @organization = organization
      @shipment = Legacy::Shipment.new(user_id: @user_id, load_type: @load_type, organization_id: @organization.id)
      @estimated = false
    end

    def result
      params = ActionController::Parameters.new(shipment: shipping_params, sandbox: nil)
      offer_calculator = OfferCalculator::Calculator.new(
        shipment: @shipment,
        params: params,
        user: @user,
        wheelhouse: true,
        sandbox: nil
      )
      offer_calculator.perform
      offer_calculator.quotation
    rescue OfferCalculator::Errors::Failure => error
      handle_error(error: error)
    rescue ArgumentError
      raise ApplicationError::InternalError
    end

    def tenders
      result.tenders.map do |tender|
        Wheelhouse::TenderDecorator.new(tender, context: {estimated: estimated})
      end
    end

    private

    attr_reader :shipment, :shipping_info, :selected_date, :user, :origin, :destination

    def shipping_params
      {
        **cargo_units,
        selected_day: selected_date.to_s,
        origin: @origin,
        destination: @destination,
        trucking: trucking_info,
        creator: @creator
      }
    end

    def trucking_info
      trucking_data = shipping_info.delete(:trucking_info)&.to_h || {}
      default_trucking_params.merge(trucking_data)
    end

    def default_trucking_params
      [
        {carriage: :pre_carriage, hub: @origin},
        {carriage: :on_carriage, hub: @destination}
      ].each_with_object({}) do |carriage_hub, hash|
        truck_type = @load_type == "cargo_item" ? "default" : "chassis"
        hash[carriage_hub[:carriage]] = {truck_type: carriage_hub[:hub][:nexus_id] ? "" : truck_type}
      end
    end

    def cargo_units
      case @load_type
      when "cargo_item"
        cargo_item_default
      when "container"
        container_default
      end
    end

    def container_default
      requested_containers = @shipping_info.slice(:containers_attributes)
      default_containers = {
        containers_attributes: [
          {
            cargo_class: default_equipment,
            payload_in_kg: 1,
            quantity: 1,
            size_class: default_equipment
          }
        ]
      }
      if requested_containers[:containers_attributes].blank?
        @estimated = true
        return default_containers
      end

      default_containers.merge(requested_containers)
    end

    def cargo_item_default
      requested_cargo_items = @shipping_info.slice(:cargo_items_attributes)
      default_cargo_items = {
        cargo_items_attributes: [{
          payload_in_kg: 1,
          width: 1,
          length: 1,
          height: 1,
          quantity: 1,
          total_weight: 1,
          total_volume: 1,
          stackable: true,
          cargo_item_type_id: default_cargo_item_type&.id,
          cargo_class: CARGO_ITEM_CARGO_CLASS,
          dangerous_goods: false
        }]
      }
      if requested_cargo_items[:cargo_items_attributes].blank?
        @estimated = true
        return default_cargo_items
      end

      default_cargo_items.merge(requested_cargo_items)
    end

    def default_equipment
      @default_equipment ||= Wheelhouse::EquipmentService.new(
        user: user,
        organization: organization,
        origin: origin,
        destination: destination,
        dedicated_pricings_only: dedicated_pricings_only
      ).perform.first || CONAINER_CARGO_CLASS
    end

    def default_cargo_item_type
      org_cargo_item_types = Legacy::TenantCargoItemType.where(organization_id: @organization.id).select(:cargo_item_type_id)
      cargo_item_types = Legacy::CargoItemType.where(id: org_cargo_item_types)
      cargo_item_types.find_by(description: CARGO_ITEM_TYPE) || cargo_item_types.take
    end

    def dedicated_pricings_only
      OrganizationManager::ScopeService.new(target: user || @creator, organization: organization).fetch(:dedicated_pricings_only)
    end
  end
end
