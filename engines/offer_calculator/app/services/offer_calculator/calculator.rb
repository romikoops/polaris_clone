# frozen_string_literal: true

module OfferCalculator
  class Calculator
    def initialize(source:, client:, creator:, params:)
      @source = source
      @client = client
      @creator = creator
      @params = params
      @organization = Organizations::Organization.find(Organizations.current_id)
    end

    def perform
      return async_calculation if async?

      results.perform
      query
    end

    private

    attr_reader :source, :organization, :params, :client, :creator

    def results
      @results ||= OfferCalculator::Results.new(
        query: query,
        params: params
      )
    end

    def query
      @query ||= OfferCalculator::Service::QueryGenerator.new(
        source: source,
        client: client,
        creator: creator,
        params: params
      ).query
    end

    def async?
      params.dig(:async).present?
    end

    def async_calculation
      OfferCalculator::AsyncCalculationJob.perform_later(
        query: query,
        params: params
      )
      results.query
    end

    def wheelhouse
      @wheelhouse ||= source.name.match?(/wheelhouse/)
    end
  end
end
