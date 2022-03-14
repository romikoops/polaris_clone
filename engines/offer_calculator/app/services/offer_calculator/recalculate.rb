# frozen_string_literal: true

module OfferCalculator
  class Recalculate < Calculator
    def initialize(original_query:)
      @original_query = original_query
      super(source: Doorkeeper::Application.find(original_query.source_id), client: original_query.client, creator: original_query.creator, params: { async: true })
    end

    private

    attr_reader :original_query

    def query
      @query ||= original_query.dup.tap do |new_query|
        new_query.cargo_units = original_query.cargo_units.map { |old_cargo_unit| clone_cargo(cargo: old_cargo_unit) }
        new_query.status = "running"
        new_query.parent_id = original_query.id
        new_query.cargo_ready_date = [original_query.cargo_ready_date, tomorrow].max
        new_query.delivery_date = [original_query.delivery_date, (tomorrow + OfferCalculator::Schedule::DURATION.days)].max
        raise OfferCalculator::Errors::InvalidQuery unless new_query.save
      end
    end

    def clone_cargo(cargo:)
      cargo.dup.tap do |new_cargo|
        new_cargo.query_id = nil
        new_cargo.commodity_infos = cargo.commodity_infos.map do |old_commodity_info|
          old_commodity_info.dup.tap { |oci| oci.cargo_unit_id = nil }
        end
      end
    end

    def tomorrow
      @tomorrow ||= Time.zone.tomorrow
    end
  end
end
