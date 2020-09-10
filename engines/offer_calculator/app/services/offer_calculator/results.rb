# frozen_string_literal: true

module OfferCalculator
  class Results
    attr_reader :shipment, :quotation, :wheelhouse, :user, :detailed_schedules, :async, :mailer

    def initialize(shipment:, quotation:, **kwargs)
      @shipment = shipment
      @quotation = quotation
      @user = kwargs[:user]
      @wheelhouse = kwargs[:wheelhouse]
      @async = kwargs[:async]
      @mailer = kwargs[:mailer] || nil
    end

    def perform
      shipment_update_handler.set_trucking_nexuses(hubs: hubs)
      @detailed_schedules = OfferCalculator::Service::OfferCreator.offers(
        shipment: shipment, quotation: quotation, offers: sorted_offers, wheelhouse: wheelhouse, async: async
      )
      handle_quoted_shipments
    rescue => e
      quotation.update(error_class: e.class.to_s)
      raise e unless async
    end

    def hubs
      @hubs ||= OfferCalculator::Service::HubFinder.new(shipment: shipment, quotation: quotation).perform
    end

    private

    def sorted_offers
      @sorted_offers ||= OfferCalculator::Service::OfferSorter.sorted_offers(
        shipment: shipment, quotation: quotation, charges: charges, schedules: schedules
      )
    end

    def charges
      @charges ||= OfferCalculator::Service::ChargeCalculator.charges(
        shipment: shipment, quotation: quotation, fees: fees
      )
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

    def fees
      @fees ||= OfferCalculator::Service::RateBuilder.fees(
        shipment: shipment, quotation: quotation, inputs: manipulated_rates
      )
    end

    def manipulated_rates
      @manipulated_rates ||= OfferCalculator::Service::PricingManipulator.manipulated_pricings(
        shipment: shipment, quotation: quotation, schedules: schedules, associations: valid_rates
      )
    end

    def routes
      @routes ||= OfferCalculator::Service::RouteFilter.new(
        shipment: shipment, quotation: quotation
      ).perform(unfiltered_routes)
    end

    def valid_rates
      @valid_rates ||= OfferCalculator::Service::PricingFinder.pricings(
        shipment: shipment, quotation: quotation, schedules: schedules
      )
    end

    def unfiltered_routes
      OfferCalculator::Service::RouteFinder.routes(
        shipment: shipment, quotation: quotation, hubs: hubs, date_range: date_range
      )
    end

    def quotation_tool?
      @isQuote || scope["open_quotation_tool"] || scope["closed_quotation_tool"]
    end

    def scope
      @scope ||= ::OrganizationManager::ScopeService.new(
        target: @user || @creator, organization: shipment.organization
      ).fetch
    end

    def shipment_update_handler
      @shipment_update_handler ||= OfferCalculator::Service::ShipmentUpdateHandler.new(shipment: shipment,
                                                                                       params: {},
                                                                                       quotation: quotation,
                                                                                       wheelhouse: wheelhouse)
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

    def send_admin_email
      send_email = scope.fetch(:email_all_quotes) && shipment.billing == "external"
      return if mailer.blank? || send_email.blank?

      mailer.to_s.constantize.new_quotation_admin_email(quotation: quotation, shipment: shipment).deliver_later
    end

    def handle_quoted_shipments
      return unless scope["open_quotation_tool"] || scope["closed_quotation_tool"]
      send_admin_email

      OfferCalculator::QuotedShipmentsJob.perform_later(shipment_id: shipment.id)
    end
  end
end
