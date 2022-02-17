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
      @offers ||= science "quotation-calculation" do |experiment|
        experiment.run_if { false } # Only run in development until some basics are working

        experiment.context request: request

        # Original
        experiment.use do
          OfferCalculator::Service::OfferSorter.sorted_offers(
            request: request, charges: charges, schedules: schedules
          )
        end

        # New, Phoenix based
        experiment.try do
          # TODO: Phoenix Logic
          # Next steps:
          # - Cherry pick `Results` engine code from old branch. https://github.com/itsmycargo/imc-react-api/pull/1764
          # - Call `Results` engine process runner

          # Empty collection that satisfies the `experiment.clean` method for now.
          [{}]
        end

        # Prepare values to compare old to new
        experiment.clean do |value|
          # Control:   returns array of OfferCalculator::Service::OfferCreators::Offer
          # Candidate: returns array of ???

          # Compare hash representation of the class data for now
          value.map(&:as_json) # TODO: more complex comparison payload
        end
      end
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
