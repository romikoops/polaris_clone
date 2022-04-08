# frozen_string_literal: true

module Wheelhouse
  class QueryService
    attr_reader :creator, :client, :params, :source, :organization

    def initialize(creator:, client:, source:, params:)
      @creator = creator
      @client = client
      @params = params
      @source = source
      @organization = Organizations::Organization.find(Organizations.current_id)
    end

    def perform
      OfferCalculator::Calculator.new(
        params: query_request_params,
        client: client,
        creator: creator,
        source: source
      ).perform
    end

    private

    def query_request_params
      Wheelhouse::QueryParamTransformationService.new(params: params).perform
    end
  end
end
