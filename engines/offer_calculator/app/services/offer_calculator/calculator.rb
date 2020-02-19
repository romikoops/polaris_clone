# frozen_string_literal: true

module OfferCalculator
  class Calculator
    attr_reader :shipment, :detailed_schedules, :hubs

    NoDrivingTime = Class.new(StandardError)
    NoValidPricings = Class.new(StandardError)
    NoValidSchedules = Class.new(StandardError)
    InvalidRoutes = Class.new(StandardError)
    NoRoute = Class.new(StandardError)
    NoDirectionsFound = Class.new(StandardError)
    InvalidPickupAddress = Class.new(StandardError)
    InvalidDeliveryAddress = Class.new(StandardError)
    MissingTruckingData = Class.new(StandardError)
    InvalidTruckingMatch = Class.new(StandardError)
    InvalidLocalCharges = Class.new(StandardError)
    InvalidFreightResult = Class.new(StandardError)
    InvalidLocalChargeResult = Class.new(StandardError)

    def initialize(shipment:, params:, user:, sandbox: nil)
      @user           = user
      @shipment       = shipment
      @delay          = params['delay']
      @isQuote = params['shipment'].delete('isQuote')
      @sandbox = sandbox
      instantiate_service_classes(params)
      update_shipment
    end

    def perform
      @hubs               = @hub_finder.perform
      @trucking_data      = @trucking_data_builder.perform(@hubs)
      @routes             = @route_finder.perform(@hubs)
      @routes             = @route_filter.perform(@routes)
      @detailed_schedules = @detailed_schedules_builder.perform(schedules, @trucking_data, @user)
    end

    private

    def instantiate_service_classes(params)
      @shipment_update_handler = OfferCalculator::Service::ShipmentUpdateHandler.new(shipment: @shipment,
                                                                                     params: params,
                                                                                     sandbox: @sandbox)
      @hub_finder = OfferCalculator::Service::HubFinder.new(shipment: @shipment, sandbox: @sandbox)
      @trucking_data_builder = OfferCalculator::Service::TruckingDataBuilder.new(shipment: @shipment,
                                                                                 sandbox: @sandbox)
      @route_finder = OfferCalculator::Service::RouteFinder.new(shipment: @shipment,
                                                                sandbox: @sandbox)
      @route_filter = OfferCalculator::Service::RouteFilter.new(shipment: @shipment,
                                                                sandbox: @sandbox)
      @schedule_finder = OfferCalculator::Service::ScheduleFinder.new(shipment: @shipment, sandbox: @sandbox)

      @quote_route_builder = OfferCalculator::Service::QuoteRouteBuilder.new(shipment: @shipment,
                                                                             sandbox: @sandbox)
      @detailed_schedules_builder = OfferCalculator::Service::DetailedSchedulesBuilder.new(shipment: @shipment,
                                                                                           sandbox: @sandbox)
    end

    def update_shipment
      @shipment_update_handler.update_nexuses
      @shipment_update_handler.update_trucking
      @shipment_update_handler.update_incoterm
      @shipment_update_handler.update_cargo_units
      @shipment_update_handler.update_selected_day
      @shipment_update_handler.update_updated_at
    end

    def schedules
      if quotation_tool?
        @quote_route_builder.perform(@routes)
      else
        @schedule_finder.perform(@routes, @delay, @hubs)
      end
    end

    def quotation_tool?
      scope = ::Tenants::ScopeService.new(
        target: Tenants::User.find_by(legacy_id: @shipment.user_id),
        tenant: Tenants::Tenant.find_by(legacy_id: @shipment.tenant_id)
      ).fetch

      @isQuote || scope['open_quotation_tool'] || scope['closed_quotation_tool']
    end
  end
end
