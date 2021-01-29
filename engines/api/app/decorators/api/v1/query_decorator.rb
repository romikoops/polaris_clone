# frozen_string_literal: true

module Api
  module V1
    class QueryDecorator < ApplicationDecorator
      delegate_all

      decorates_association :client, with: UserDecorator
      decorates_association :origin_route_point, with: RoutePointDecorator
      decorates_association :destination_route_point, with: RoutePointDecorator
      decorates_association :results, with: ResultDecorator

      def legacy_json
        {
          "id": id,
          "status": "quoted",
          "load_type": load_type,
          "planned_pickup_date": selected_date,
          "has_pre_carriage": has_pre_carriage?,
          "has_on_carriage": has_on_carriage?,
          "destination_nexus": destination_nexus.as_json,
          "origin_nexus": origin_nexus.as_json,
          "pickup_address": pickup_address&.as_json,
          "delivery_address": delivery_address&.as_json,
          "origin_hub": results.first.origin_hub,
          "destination_hub": results.first.destination_hub
        }
      end

      def selected_date
        cargo_ready_date
      end

      def completed
        results.present?
      end

      def load_type
        super == "lcl" ? "cargo_item" : "container"
      end

      def origin_route_point
        route_sections.where.not(mode_of_transport: :carriage).order(:order).first&.from
      end

      def destination_route_point
        route_sections.where.not(mode_of_transport: :carriage).order(:order).last&.to
      end

      def containers
        cargo_units.where.not(cargo_class: ["lcl", "aggregated_lcl"]).map do |cargo_unit|
          Api::V1::CargoUnitDecorator.new(cargo_unit, context: context)
        end
      end

      def cargo_items
        cargo_units.where(cargo_class: "lcl").map do |cargo_unit|
          Api::V1::CargoUnitDecorator.new(cargo_unit, context: context)
        end
      end

      def aggregated_cargo
        Api::V1::CargoUnitDecorator.new(cargo_units.find_by(cargo_class: "aggregated_lcl"), context: context)
      end

      def results
        @results ||= Journey::Result.where(result_set: current_result_set)
      end

      def has_pre_carriage?
        Journey::RouteSection.exists?(
          result: results,
          mode_of_transport: :carriage,
          order: 0
        )
      end

      def has_on_carriage?
        Journey::RouteSection.where(result: results, mode_of_transport: :carriage)
          .where.not(order: 0).present?
      end

      def pickup_address
        return unless has_pre_carriage?

        Legacy::Address.new(
          id: SecureRandom.uuid,
          latitude: origin_coordinates.y,
          longitude: origin_coordinates.x
        ).reverse_geocode
      end

      def delivery_address
        return unless has_on_carriage?

        Legacy::Address.new(
          id: SecureRandom.uuid,
          latitude: destination_coordinates.y,
          longitude: destination_coordinates.x
        ).reverse_geocode
      end

      def origin_nexus
        nexus = if origin_route_point&.locode.present?
          Legacy::Nexus.find_by(
            locode: origin_route_point.locode,
            organization: organization
          )
        else
          Legacy::Nexus.find_by(
            name: origin,
            organization: organization
          )
        end
        nexus && Api::V1::NexusDecorator.new(nexus)
      end

      def destination_nexus
        nexus = if destination_route_point&.locode.present?
          Legacy::Nexus.find_by(
            locode: destination_route_point.locode,
            organization: organization
          )
        else
          Legacy::Nexus.find_by(
            name: destination,
            organization: organization
          )
        end
        nexus && Api::V1::NexusDecorator.new(nexus)
      end

      private

      def route_sections
        @route_sections ||= Journey::RouteSection.where(result: results)
      end

      def current_result_set
        @current_result_set ||= result_sets.where(status: "completed").order(:created_at).last
      end

      def scope
        context.dig(:scope) || {}
      end
    end
  end
end
