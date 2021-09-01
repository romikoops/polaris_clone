# frozen_string_literal: true

module Api
  module V2
    class QueryDecorator < ApplicationDecorator
      delegate_all

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

      def modes_of_transport
        route_sections.where.not(mode_of_transport: %w[relay carriage]).pluck(:mode_of_transport).uniq # Query can have  multiple MOT's
      end

      def reference
        Journey::LineItemSet.where(result: results).first&.reference # Not sure what to do here as we do not have Ref numbers for queries, maybe we should?
      end

      def offer_id
        Wheelhouse::OfferBuilder.new(results: results).existing_offer&.id # so the pdf can be downloaded easily
      end

      def client
        Api::V1::UserDecorator.new(object.client.presence || Api::Client.new)
      end

      private

      def route_sections
        @route_sections ||= Journey::RouteSection.where(result: results)
      end

      def results
        @results ||= Journey::Result.where(result_set: result_sets.order(:created_at).last)
      end

      def scope
        context[:scope] || {}
      end
    end
  end
end
