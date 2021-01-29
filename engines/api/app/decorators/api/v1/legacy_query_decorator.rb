# frozen_string_literal: true

module Api
  module V1
    class LegacyQueryDecorator < Api::V1::QueryDecorator
      def legacy_json
        {
          quotationId: object.id,
          completed: true,
          shipment: legacy_shipment,
          results: decorated_results,
          originHubs: results.map(&:origin_hub),
          destinationHubs: results.map(&:destination_hub),
          cargoUnits: legacy_cargo_units,
          aggregatedCargo: legacy_aggregated_cargo
        }
      end

      def decorated_results
        results.map(&:legacy_format)
      end

      def results
        @results ||= Journey::Result.where(result_set: current_result_set).map { |result|
          LegacyResultDecorator.new(result, context: context)
        }
      end

      def legacy_shipment
        {
          id: id,
          load_type: load_type,
          trucking: {}
        }
      end

      def legacy_cargo_units
        Api::V1::LegacyCargoUnitDecorator.decorate_collection(cargo_units, context: {scope: scope}).map(&:legacy_format)
      end

      def legacy_aggregated_cargo
        return {} if aggregated_cargo.nil?

        Api::V1::LegacyCargoUnitDecorator.new(
          aggregated_cargo,
          context: {scope: scope}
        ).aggregate_format
      end

      def aggregated_cargo
        @aggregated_cargo ||= cargo_units.find_by(cargo_class: "aggregated_lcl")
      end
    end
  end
end
