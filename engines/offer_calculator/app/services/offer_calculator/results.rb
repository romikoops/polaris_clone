# frozen_string_literal: true

module OfferCalculator
  class Results
    include Scientist

    attr_reader :query, :wheelhouse, :params, :offer, :on_carriage, :pre_carriage, :query_calculation

    def initialize(query:, params:, pre_carriage:, on_carriage:)
      @query = query
      @params = params
      @pre_carriage = pre_carriage
      @on_carriage = on_carriage
      @query_calculation = query_calculation_with_updated_status
    end

    def perform
      return if query_calculation.nil?

      results = offers.map do |offer|
        OfferCalculator::Service::OfferCreators::ResultBuilder.result(
          request: request, offer: offer
        )
      end
      update_status(status: "completed") if query.persisted?
      results || []
    rescue OfferCalculator::Errors::Failure => e
      if query.persisted?
        persist_error(error: e)
        update_status(status: "failed")
      end
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
        params: params,
        pre_carriage: pre_carriage,
        on_carriage: on_carriage
      )
    end

    delegate :async, :organization, :client, :creator, :delay, :cargo_ready_date, to: :request

    def schedules
      @schedules ||= OfferCalculator::Service::QuoteRouteBuilder.new(request: request).perform(routes, hubs)
    end

    def charges
      @charges ||= OfferCalculator::Service::FeeExperiment.new(
        request: request, schedules: schedules, associations: valid_rates
      ).perform
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
      Journey::Error.create(code: error.code, property: error.message, query: query, query_calculation: query_calculation)
    end

    def update_status(status:)
      query_calculation.update(status: status)
    end

    def query_calculation_with_updated_status
      return unless query.persisted? && query_calculation_for_carriage.present?

      query_calculation_for_carriage.tap do |query_calc|
        query_calc.update(status: "running")
      end
    end

    def query_calculation_for_carriage
      @query_calculation_for_carriage ||= Journey::QueryCalculation.find_by(
        query: query,
        status: "queued",
        pre_carriage: pre_carriage,
        on_carriage: on_carriage
      )
    end
  end
end
