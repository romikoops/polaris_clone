# frozen_string_literal: true

module OfferCalculator
  class Preview < Calculator
    def perform
      results.offers
    end

    def query
      @query ||= OfferCalculator::Service::QueryGenerator.new(
        source: source,
        client: client,
        creator: creator,
        params: params,
        persist: false
      ).query
    end
  end
end
