# frozen_string_literal: true

Dir["#{Rails.root}/app/classes/offer_calculator_service/*.rb"].each { |file| require file }

class OfferCalculator
  attr_reader :shipment, :detailed_schedules, :hubs
  include OfferCalculatorService

  def initialize(shipment:, params:, user:, sandbox: nil)
    @user           = user
    @shipment       = shipment
    @delay          = params['delay']
    @quotation_tool = params['shipment'].delete('isQuote') || @user.tenant.quotation_tool?
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
    @shipment_update_handler    = ShipmentUpdateHandler.new(shipment: @shipment, params: params, sandbox: @sandbox)
    @hub_finder                 = HubFinder.new(shipment: @shipment, sandbox: @sandbox)
    @trucking_data_builder      = TruckingDataBuilder.new(shipment: @shipment, sandbox: @sandbox)
    @route_finder               = RouteFinder.new(shipment: @shipment, sandbox: @sandbox)
    @route_filter               = RouteFilter.new(shipment: @shipment, sandbox: @sandbox)
    @schedule_finder            = ScheduleFinder.new(shipment: @shipment, sandbox: @sandbox)
    @quote_route_builder        = QuoteRouteBuilder.new(shipment: @shipment, sandbox: @sandbox)
    @detailed_schedules_builder = DetailedSchedulesBuilder.new(shipment: @shipment, sandbox: @sandbox)
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
    @quotation_tool
  end
end
