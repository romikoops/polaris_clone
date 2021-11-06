# frozen_string_literal: true

module Notifications
  class SubjectLine
    attr_reader :results, :scope, :noun

    CHARACTER_COUNT = 90

    include ActionView::Helpers::TextHelper

    def initialize(results:, scope:, noun:)
      @results = results
      @scope = scope
      @noun = noun
    end

    def query
      @query ||= Journey::Query.find(results.pluck(:query_id).first)
    end

    def line_item_sets
      @line_item_sets ||= Journey::LineItemSet
        .where(result: results)
        .order(:result_id, created_at: :desc)
        .group_by(&:result_id)
        .values
        .map(&:first)
    end

    delegate :origin, :destination, :origin_coordinates, :destination_coordinates, :cargo_units, :client, to: :query

    def subject_line
      liquid_string = liquid.render(context)
      grapheme_clusters = liquid_string.each_grapheme_cluster
      return liquid_string if grapheme_clusters.count < CHARACTER_COUNT

      "#{grapheme_clusters.take(CHARACTER_COUNT).join}..."
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
        references: truncate("Refs: #{imc_references.join(', ')}", length: 23, separator: " "),
        routing: routing,
        noun: noun
      }.deep_stringify_keys
    end

    private

    def liquid
      Liquid::Template.parse(scope[:email_subject_template])
    end

    def imc_references
      line_item_sets.map(&:reference)
    end

    def dynamic_origin
      pickup_postal_code || origin_locode || origin_city
    end

    def dynamic_destination
      delivery_postal_code || destination_locode || destination_city
    end

    def origin_city
      pre_carriage? ? pickup_address.city : origin
    end

    def origin_locode
      main_route_sections
        .map(&:from)
        .map(&:locode)
        .compact
        .first
    end

    def destination_city
      on_carriage? ? delivery_address.city : destination
    end

    def destination_locode
      main_route_sections
        .map(&:to)
        .map(&:locode)
        .compact
        .last
    end

    def pickup_postal_code
      return unless pre_carriage?

      pickup_address&.zip_code.present? ? "#{pickup_address.country.code}-#{pickup_address&.zip_code}" : nil
    end

    def delivery_postal_code
      return unless on_carriage?

      delivery_address&.zip_code.present? ? "#{delivery_address.country.code}-#{delivery_address&.zip_code}" : nil
    end

    def total_weight
      @total_weight ||= cargo_units.inject(Measured::Weight.new(0, "kg")) do |memo, unit|
        memo + unit.total_weight
      end.value
    end

    def total_volume
      @total_volume ||= cargo_units.inject(Measured::Volume.new(0, "m3")) do |memo, unit|
        unit.total_volume.present? ? memo + unit.total_volume : memo
      end.value
    end

    def routing
      [
        pre_carriage? ? pickup_address.city : origin,
        on_carriage? ? delivery_address.city : destination
      ].join(" - ")
    end

    def load_type
      query.load_type.upcase
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

    def pre_carriage?
      @pre_carriage ||= route_sections.any? do |route_section|
        route_section.mode_of_transport == "carriage" &&
          route_section.order.zero?
      end
    end

    def route_sections
      @route_sections ||= results.flat_map(&:route_sections)
    end

    def on_carriage?
      @on_carriage ||= route_sections.any? do |route_section|
        route_section.mode_of_transport == "carriage" &&
          route_section.order != 0
      end
    end

    def main_route_sections
      @main_route_sections ||= route_sections.reject do |route_section|
        %w[carriage relay].include?(route_section.mode_of_transport)
      end
    end

    def profile
      @profile ||= client ? client.profile : Users::ClientProfile.new
    end
  end
end
