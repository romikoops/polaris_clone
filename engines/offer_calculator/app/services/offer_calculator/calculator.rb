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
      raise OfferCalculator::Errors::DangerousGoodsProhibited if dangerous_good_prohibited_error.present?
      return async_calculation if async?

      results.perform
      query_with_updated_status
    rescue OfferCalculator::Errors::Failure => e
      if async?
        query_with_updated_status
      elsif query_with_updated_status
        raise e
      end
    end

    private

    attr_reader :source, :organization, :params, :client, :creator

    def results
      @results ||= OfferCalculator::Results.new(
        query: query,
        params: params,
        pre_carriage: sync_query_calculation.pre_carriage,
        on_carriage: sync_query_calculation.on_carriage
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
      params[:async].present?
    end

    def async_calculation
      query_calculations.each do |query_calculation|
        async_calculation_for_permutation(pre_carriage: query_calculation.pre_carriage, on_carriage: query_calculation.on_carriage)
      end
      query
    end

    def carriage_permutations
      [true, false].product([false, true]).to_a
    end

    def synchronous_pre_carriage?
      params.dig(:origin, :nexus_id).blank?
    end

    def synchronous_on_carriage?
      params.dig(:destination, :nexus_id).blank?
    end

    def sync_carriage_permutation
      [synchronous_pre_carriage?, synchronous_on_carriage?]
    end

    def sorted_carriage_permutations
      return [sync_carriage_permutation] unless async?

      [sync_carriage_permutation] + (carriage_permutations - [sync_carriage_permutation])
    end

    def async_calculation_for_permutation(pre_carriage:, on_carriage:)
      OfferCalculator::AsyncCalculationJob.perform_later(
        query: query,
        params: params,
        pre_carriage: pre_carriage,
        on_carriage: on_carriage
      )
    end

    def query_with_updated_status
      return query unless query.persisted?

      new_status = if Journey::QueryCalculation.where(query: query).exists?(status: "completed")
        "completed"
      else
        "failed"
      end

      query.update(status: new_status)
      query
    end

    def query_calculations
      @query_calculations ||= sorted_carriage_permutations.map do |pre_carriage, on_carriage|
        Journey::QueryCalculation.new(query: query, pre_carriage: pre_carriage, on_carriage: on_carriage, status: "queued").tap do |query_calc|
          query_calc.save! if query.persisted?
        end
      end
    end

    def sync_query_calculation
      @sync_query_calculation ||= query_calculations.first
    end

    def dangerous_goods_present_and_prohibited?
      query.cargo_units
        .flat_map(&:commodity_infos)
        .any? { |commodity_info| commodity_info.imo_class.present? } && organization.scope.dangerous_goods.blank?
    end

    def dangerous_good_prohibited_error
      return unless dangerous_goods_present_and_prohibited?

      Journey::Error.create(
        code: OfferCalculator::Errors::DangerousGoodsProhibited.new.code,
        property: "imo_class",
        query: query,
        query_calculation: sync_query_calculation
      )
    end
  end
end
