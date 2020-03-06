# frozen_string_literal: true

module Wheelhouse
  class QuotationService
    def initialize(quotation_details:, shipping_info:)
      @user_id = quotation_details.fetch(:user_id)
      @tenant_id = quotation_details.fetch(:tenant_id)
      @origin = quotation_details.fetch(:origin)
      @destination = quotation_details.fetch(:destination)
      @load_type = quotation_details.fetch(:load_type)
      @selected_date = quotation_details.fetch(:selected_date)
      @shipping_info = shipping_info.to_h.deep_symbolize_keys
      @user = Legacy::User.find(@user_id)
      @shipment = Legacy::Shipment.new(user_id: @user_id, load_type: @load_type, tenant_id: @tenant_id)
      update_faux_shipment
    end

    def results
      @trucking_data = trucking_data_builder.perform(@hubs)
      detailed_schedules = get_detailed_schedules(routes)
      detailed_schedules.flatten
    end

    def tenders
      results.map do |result|
        JSON.parse(result.to_json, object_class: ::Wheelhouse::OpenStruct)
      end
    end

    private

    attr_reader :shipment, :shipping_info, :selected_date

    def get_detailed_schedules(routes)
      schedules = schedule_finder.perform(routes, @delay, @hubs)
      detailed_schedule_finder.perform(schedules, @trucking_data, @user)
    end

    def update_faux_shipment
      shipment_update_handler.update_nexuses
      shipment_update_handler.update_selected_day
      shipment_update_handler.update_cargo_units
      shipment_update_handler.update_trucking
    end

    def hub_finder
      @hub_finder ||= OfferCalculator::Service::HubFinder.new(shipment: shipment)
    end

    def trucking_data_builder
      @trucking_data_builder ||= OfferCalculator::Service::TruckingDataBuilder.new(shipment: shipment)
    end

    def route_finder
      @route_finder ||= OfferCalculator::Service::RouteFinder.new(shipment: shipment)
    end

    def route_filter
      @route_filter ||= OfferCalculator::Service::RouteFilter.new(shipment: shipment)
    end

    def schedule_finder
      @schedule_finder ||= OfferCalculator::Service::ScheduleFinder.new(shipment: shipment)
    end

    def detailed_schedule_finder
      @detailed_schedule_finder ||= OfferCalculator::Service::DetailedSchedulesBuilder.new(shipment: shipment)
    end

    def shipment_update_handler
      params = ActionController::Parameters.new(shipment: shipping_params, sandbox: nil)
      @shipment_update_handler ||= OfferCalculator::Service::ShipmentUpdateHandler.new(shipment: shipment,
                                                                                       params: params,
                                                                                       sandbox: nil)
    end

    def routes
      hubs = hub_finder.perform
      itinerary_hash = {
        origin: @origin[:hub_ids].present? ? Hub.where(id: @origin[:hub_ids]) : hubs[:origin],
        destination: @destination[:hub_ids].present? ? Hub.where(id: @destination[:hub_ids]) : hubs[:destination]
      }
      available_routes = route_finder.perform(itinerary_hash)
      route_filter.perform(available_routes)
    end

    def trucking_info
      trucking_data = shipping_info.delete(:trucking_info)&.to_h || {}
      { pre_carriage: { truck_type: '' }, on_carriage: { truck_type: '' } }.merge(trucking_data)
    end

    def shipping_params
      {
        **cargo_units,
        selected_day: selected_date.to_s,
        origin: @origin,
        destination: @destination,
        trucking: trucking_info
      }.merge(shipping_info)
    end

    def cargo_units
      cargo_item_default = {
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
      }
      container_default = {
        containers_attributes: [{
          cargo_class: 'fcl_20',
          payload_in_kg: 1,
          quantity: 1,
          size_class: 'fcl_20'
        }]
      }

      case @load_type
      when 'cargo_item'
        cargo_item_default
      when 'container'
        container_default
      end
    end

    def default_cargo_item_type
      shipment.tenant.cargo_item_types.take
    end
  end
end
