# frozen_string_literal: true

Dir["#{Rails.root}/app/classes/offer_calculator_service/*.rb"].each { |file| require file }

class OfferCalculator
  attr_reader :shipment, :detailed_schedules, :hubs
  include OfferCalculatorService

  def initialize(shipment, params, user)
    @user           = user
    @shipment       = shipment
    @delay          = params['delay']
    @quotation_tool = params['shipment'].delete('isQuote') || @user.tenant.quotation_tool?

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
    @shipment_update_handler    = ShipmentUpdateHandler.new(@shipment, params)
    @hub_finder                 = HubFinder.new(@shipment)
    @trucking_data_builder      = TruckingDataBuilder.new(@shipment)
    @route_finder               = RouteFinder.new(@shipment)
    @route_filter               = RouteFilter.new(@shipment)
    @schedule_finder            = ScheduleFinder.new(@shipment)
    @quote_route_builder        = QuoteRouteBuilder.new(@shipment)
    @detailed_schedules_builder = DetailedSchedulesBuilder.new(@shipment)
  end

  def update_shipment
    @shipment_update_handler.update_nexuses
    @shipment_update_handler.update_trucking
    @shipment_update_handler.update_incoterm
    @shipment_update_handler.update_cargo_units
    @shipment_update_handler.update_selected_day
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
