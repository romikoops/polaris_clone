# frozen_string_literal: true

module OfferCalculator
  class Calculator
    attr_reader :shipment, :detailed_schedules, :quotation, :wheelhouse, :organization, :params

    def initialize(shipment:, params:, user:, wheelhouse: false)
      @user           = user
      @shipment       = shipment
      @delay          = params['delay']
      @isQuote = params['shipment'].delete('isQuote')
      @wheelhouse = wheelhouse
      @organization = @shipment.organization
      @quotation = create_quotations_quotations
      @params = params
      update_shipment
    end

    def perform
      shipment_update_handler.set_trucking_nexuses(hubs: hubs)
      @detailed_schedules = OfferCalculator::Service::OfferCreator.offers(
        shipment: shipment, quotation: quotation, offers: sorted_offers, wheelhouse: wheelhouse
      )
    end

    def hubs
      @hubs ||= OfferCalculator::Service::HubFinder.new(shipment: shipment, quotation: quotation).perform
    end

    private

    def valid_rates
      @valid_rates ||= OfferCalculator::Service::PricingFinder.pricings(
        shipment: shipment, quotation: quotation, schedules: schedules
      )
    end

    def manipulated_rates
      @manipulated_rates ||= OfferCalculator::Service::PricingManipulator.manipulated_pricings(
        shipment: shipment, quotation: quotation, schedules: schedules, associations: valid_rates
      )
    end

    def fees
      @fees ||= OfferCalculator::Service::RateBuilder.fees(
        shipment: shipment, quotation: quotation, inputs: manipulated_rates
      )
    end

    def charges
      @charges ||= OfferCalculator::Service::ChargeCalculator.charges(
        shipment: shipment, quotation: quotation, fees: fees
      )
    end

    def sorted_offers
      @sorted_offers ||= OfferCalculator::Service::OfferSorter.sorted_offers(
        shipment: shipment, quotation: quotation, charges: charges, schedules: schedules
      )
    end

    def routes
      @routes ||= OfferCalculator::Service::RouteFilter.new(
        shipment: shipment, quotation: quotation
      ).perform(unfiltered_routes)
    end

    def unfiltered_routes
      OfferCalculator::Service::RouteFinder.routes(
        shipment: shipment,
        quotation: quotation,
        hubs: hubs,
        date_range: date_range
      )
    end

    def shipment_update_handler
      @shipment_update_handler ||= OfferCalculator::Service::ShipmentUpdateHandler.new(shipment: shipment,
                                                                                       params: params,
                                                                                       quotation: quotation,
                                                                                       wheelhouse: @wheelhouse)
    end

    def update_shipment
      shipment_update_handler.update_nexuses
      shipment_update_handler.update_trucking
      shipment_update_handler.update_incoterm
      shipment_update_handler.update_cargo_units
      shipment_update_handler.update_selected_day
      shipment_update_handler.destroy_previous_charge_breakdowns
      shipment_update_handler.update_billing

      raise OfferCalculator::Errors::InvalidShipmentError unless @shipment.save
      raise OfferCalculator::Errors::InvalidQuotationError unless @quotation.save
    end

    def create_quotations_quotations
      Quotations::Quotation.new(organization: organization,
                                user: @user,
                                completed: false,
                                legacy_shipment_id: shipment.id)
    end

    def schedules
      @schedules ||=
        if quotation_tool?
          OfferCalculator::Service::QuoteRouteBuilder.new(shipment: shipment, quotation: quotation)
            .perform(routes, hubs)
        else
          OfferCalculator::Service::ScheduleFinder.new(shipment: shipment, quotation: quotation)
            .perform(routes, @delay, hubs)
        end
    end

    def quotation_tool?
      scope = ::OrganizationManager::ScopeService.new(
        target: @user || @creator,
        organization: shipment.organization
      ).fetch

      @isQuote || scope['open_quotation_tool'] || scope['closed_quotation_tool']
    end

    def date_range
      (shipment.desired_start_date..(shipment.desired_start_date + sanitized_delay_in_days))
    end

    def sanitized_delay_in_days
      (@delay ? @delay.try(:to_i) : default_delay_in_days).days
    end

    def default_delay_in_days
      60
    end
  end
end
