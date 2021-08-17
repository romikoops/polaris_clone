# frozen_string_literal: true

module Wheelhouse
  class PreviewService
    attr_reader :creator, :target, :client, :origin, :destination, :cargo_class, :source, :organization

    def initialize(creator:, target:, source:, origin:, destination:, cargo_class:)
      @creator = creator
      @target = target
      @client = client_from_target(target: target)
      @origin = origin
      @cargo_class = cargo_class
      @destination = destination
      @source = source
      @organization = Organizations::Organization.find(Organizations.current_id)
    end

    def perform
      offers.map do |offer|
        offer_to_result(offer: offer)
      end
    end

    private

    def client_from_target(target:)
      case target.class.to_s
      when "Users::Client"
        target
      when "Companies::Company"
        target.clients.first
      when "Groups::Group"
        target.memberships.first.member
      end
    end

    def offers
      @offers ||= OfferCalculator::Preview.new(
        params: query_request_params,
        client: client,
        creator: creator,
        source: source
      ).perform
    end

    def offer_to_result(offer:)
      offer.section_keys.each_with_object({}) do |section, result|
        result[section == "cargo" ? :freight : section.to_sym] = build_breakdowns(charges: offer.section(key: section))
      end
    end

    def query_request_params
      {
        selected_day: Time.zone.today.to_s,
        cargo_items_attributes: load_type == "cargo_item" ? cargo_items_attributes : [],
        containers_attributes: load_type == "container" ? container_attributes : [],
        load_type: load_type,
        trucking: {
          pre_carriage: {
            truck_type: load_type == "container" ? "chassis" : "default"
          },
          on_carriage: {
            truck_type: load_type == "container" ? "chassis" : "default"
          }
        },
        origin: preview_route_target_params(target: origin),
        destination: preview_route_target_params(target: destination),
        aggregated_cargo_attributes: nil,
        estimated: true,
        async: false
      }
    end

    def load_type
      cargo_class == "lcl" ? "cargo_item" : "container"
    end

    def cargo_items_attributes
      [{
        stackable: true,
        cargo_class: "lcl",
        colli_type: "pallet",
        quantity: 1,
        length: 1,
        width: 1,
        height: 1,
        payload_in_kg: 1,
        commodities: []
      }]
    end

    def container_attributes
      [{
        cargo_class: cargo_class,
        quantity: 1,
        payload_in_kg: 1,
        commodities: []
      }]
    end

    def build_breakdowns(charges:)
      {
        fees: build_breakdown_response(charges: charges),
        service_level: charges.first.tenant_vehicle.full_name
      }
    end

    def manipulate_breakdown(breakdown:)
      {
        data: breakdown.data,
        margin_value: breakdown.delta,
        operator: breakdown.operator,
        target_name: breakdown.target_name.to_s,
        source_id: breakdown.source&.id,
        source_type: breakdown.source&.class&.to_s,
        target_id: breakdown.applicable&.id,
        target_type: breakdown.applicable&.class&.to_s,
        url_id: breakdown.applicable&.id
      }
    end

    def build_breakdown_response(charges:)
      charges.each_with_object({}) do |charge, response|
        adjusted_breakdowns = charge.fee.breakdowns.map { |breakdown| manipulate_breakdown(breakdown: breakdown) }
        margin_breakdowns = adjusted_breakdowns.reject { |breakdown| breakdown[:operator] == "+" }
        flat_breakdowns = adjusted_breakdowns.select { |breakdown| breakdown[:operator] == "+" }
        original = adjusted_breakdowns.find { |breakdown| breakdown[:source].blank? }
        response[charge.code.to_sym] = {
          original: original[:data],
          margins: margin_breakdowns.reject { |breakdown| breakdown == original },
          flatMargins: flat_breakdowns,
          final: margin_breakdowns.last[:data],
          rate_origin: original[:data] || original[:metadata]
        }
      end
    end

    def preview_route_target_params(target:)
      if target[:hub_id].present?
        nexus = Legacy::Hub.find(target[:hub_id]).nexus
        {
          nexus_id: nexus.id,
          address: nexus.name,
          id: Carta::Client.suggest(query: nexus.locode).id
        }
      else
        {
          latitude: target[:lat],
          longitude: target[:lng]
        }
      end
    end
  end
end
