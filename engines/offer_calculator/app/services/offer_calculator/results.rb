# frozen_string_literal: true

module OfferCalculator
  class Results
    attr_reader :query, :wheelhouse, :params, :offer

    def initialize(query:, params:)
      @query = query
      @params = params
    end

    def perform
      OfferCalculator::Service::OfferCreators::ResultSetBuilder.results_set(
        request: request, offers: offers
      ).tap do |_offer|
        update_status(status: "completed")
      end
    rescue OfferCalculator::Errors::Failure => e
      persist_error(error: e)
      update_status(status: "failed")
      raise e unless async
    end

    def offers
      @offers ||= OfferCalculator::Service::OfferSorter.sorted_offers(
        request: request, charges: charges, schedules: schedules
      )
    end

    def hubs
      @hubs ||= OfferCalculator::Service::HubFinder.new(request: request).perform
    end

    private

    def request
      @request ||= OfferCalculator::Request.new(
        query: query,
        params: params
      )
    end

    delegate :async, :organization, :client, :creator, :delay, :cargo_ready_date, :result_set, to: :request

    def charges
      @charges ||= OfferCalculator::Service::ChargeCalculator.charges(
        request: request, fees: fees
      )
    end

    def schedules
      @schedules ||= OfferCalculator::Service::QuoteRouteBuilder.new(request: request).perform(routes, hubs)
    end

    def fees
      @fees ||= OfferCalculator::Service::RateBuilder.fees(
        request: request, inputs: manipulated_rates
      )
    end

    def manipulated_rates
      @manipulated_rates ||= OfferCalculator::Service::PricingManipulator.manipulated_pricings(
        request: request, schedules: schedules, associations: valid_rates
      )
    end

    def routes
      @routes ||= OfferCalculator::Service::RouteFilter.new(
        request: request, date_range: date_range
      ).perform(routes: unfiltered_routes)
    end

    def valid_rates
      @valid_rates ||= OfferCalculator::Service::PricingFinder.pricings(
        request: request, schedules: schedules
      )
    end

    def unfiltered_routes
      OfferCalculator::Service::RouteFinder.routes(
        request: request, hubs: hubs, date_range: date_range
      )
    end

    def quotation_tool?
      scope["open_quotation_tool"] || scope["closed_quotation_tool"]
    end

    def scope
      @scope ||= ::OrganizationManager::ScopeService.new(
        target: client, organization: organization
      ).fetch
    end

    def date_range
      (cargo_ready_date..(cargo_ready_date + default_delay_in_days))
    end

    def default_delay_in_days
      60.days
    end

    def persist_error(error:)
      Journey::Error.create(result_set: request.result_set, code: error.code, property: error.message)
    end

    def update_status(status:)
      request.result_set.update(status: status)
    end
  end
end
