# frozen_string_literal: true

module Api
  module V2
    class QueryDecorator < ApplicationDecorator
      delegate_all

      decorates_association :client, with: Api::V1::UserDecorator

      def aggregated
        cargo_units.exists?(cargo_class: "aggregated_lcl")
      end

      def completed
        results.present?
      end

      def origin_route_point
        route_sections.order(:order).first&.from
      end

      def load_type
        super == "lcl" ? "cargo_item" : "container"
      end

      def destination_route_point
        route_sections.order(:order).last&.to
      end

      def items
        cargo_units.map do |cargo_unit|
          Api::V1::CargoUnitDecorator.new(cargo_unit, context: context)
        end
      end

      private

      def route_sections
        @route_sections ||= Journey::RouteSection.where(result: results)
      end

      def results
        @results ||= Journey::Result.where(result_set: result_sets.order(:created_at).last)
      end

      def scope
        context.dig(:scope) || {}
      end
    end
  end
end
