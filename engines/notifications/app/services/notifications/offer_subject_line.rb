# frozen_string_literal: true

module Notifications
  class OfferSubjectLine
    attr_reader :offer, :scope
    CHARACTER_COUNT = 90

    include ActionView::Helpers::TextHelper

    def initialize(offer:, scope:)
      @offer = offer
      @scope = scope
    end

    delegate :query, :results, to: :offer
    delegate :origin, :destination, :origin_coordinates, :destination_coordinates, :cargo_units, :client, to: :query
    delegate :profile, to: :client

    def subject_line
      liquid_string = liquid.render(context)
      grapheme_clusters = liquid_string.each_grapheme_cluster
      return liquid_string if grapheme_clusters.count < CHARACTER_COUNT

      grapheme_clusters.take(CHARACTER_COUNT).join + "..."
    end

    def context
      {
        imc_reference: imc_references.first,
        external_id: profile&.external_id,
        origin_locode: origin_locode,
        origin_city: origin_city,
        origin: dynamic_origin,
        destination_locode: destination_locode,
        destination_city: destination_city,
        destination: dynamic_destination,
        total_weight: total_weight,
        total_volume: total_volume,
        client_name: profile&.full_name,
        load_type: load_type,
        references: truncate("Refs: #{imc_references.join(", ")}", length: 23, separator: " "),
        routing: routing,
        noun: "Quotation"
      }.deep_stringify_keys
    end

    private

    def liquid
      Liquid::Template.parse(scope.dig(:email_subject_template))
    end

    def imc_references
      results.map { |result| Journey::ImcReference.new(date: result.created_at).reference }
    end

    def dynamic_origin
      pickup_postal_code || origin_locode || origin_city
    end

    def dynamic_destination
      delivery_postal_code || destination_locode || destination_city
    end

    def origin_city
      has_pre_carriage ? pickup_address.city : origin
    end

    def origin_locode
      main_route_sections
        .map(&:from)
        .map(&:locode)
        .compact
        .first
    end

    def destination_city
      has_on_carriage ? delivery_address.city : destination
    end

    def destination_locode
      main_route_sections
        .map(&:to)
        .map(&:locode)
        .compact
        .last
    end

    def pickup_postal_code
      return unless has_pre_carriage

      pickup_address&.zip_code.present? ? "#{pickup_address.country.code}-#{pickup_address&.zip_code}" : nil
    end

    def delivery_postal_code
      return unless has_on_carriage

      delivery_address&.zip_code.present? ? "#{delivery_address.country.code}-#{delivery_address&.zip_code}" : nil
    end

    def total_weight
      @total_weight ||= cargo_units.inject(Measured::Weight.new(0, "kg")) { |memo, unit|
        memo + unit.total_weight
      }.value
    end

    def total_volume
      @total_volume ||= cargo_units.inject(Measured::Volume.new(0, "m3")) { |memo, unit|
        memo + unit.total_volume
      }.value
    end

    def routing
      [
        has_pre_carriage ? pickup_address.city : origin,
        has_on_carriage ? delivery_address.city : destination
      ].join(" - ")
    end

    def load_type
      cargo_units.exists?(cargo_class: ["aggregated_lcl", "lcl"]) ? "LCL" : "FCL"
    end

    def pickup_address
      Legacy::Address.new(
        latitude: origin_coordinates.y,
        longitude: origin_coordinates.x
      ).reverse_geocode
    end

    def delivery_address
      Legacy::Address.new(
        latitude: destination_coordinates.y,
        longitude: destination_coordinates.x
      ).reverse_geocode
    end

    def has_pre_carriage
      @has_pre_carriage ||= route_sections.any? do |route_section|
        route_section.mode_of_transport == "carriage" &&
          route_section.order == 0
      end
    end

    def route_sections
      @route_sections ||= results.flat_map(&:route_sections)
    end

    def has_on_carriage
      @has_on_carriage ||= route_sections.any? do |route_section|
        route_section.mode_of_transport == "carriage" &&
          route_section.order != 0
      end
    end

    def main_route_sections
      @main_route_sections ||= route_sections.reject { |route_section|
        route_section.mode_of_transport == "carriage" && route_section.to != route_section.from
      }
    end
  end
end
