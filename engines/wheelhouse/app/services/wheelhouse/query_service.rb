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
      {
        selected_day: Time.zone.today.to_s,
        cargo_items_attributes: cargo_items_attributes,
        containers_attributes: container_attributes,
        load_type: params[:load_type],
        trucking: {
          pre_carriage: {
            truck_type: params[:load_type] == "container" ? "chassis" : "default"
          },
          on_carriage: {
            truck_type: params[:load_type] == "container" ? "chassis" : "default"
          }
        },
        origin: route_target_params(target: origin),
        destination: route_target_params(target: destination),
        aggregated_cargo_attributes: aggregated_cargo_attributes,
        async: true
      }
    end

    def cargo_items_attributes
      attributes_payload(
        items: params[:items].select { |item| item[:colli_type].present? }
      )
    end

    def container_attributes
      attributes_payload(
        items: params[:items].select { |item| item[:cargo_class].match?('fcl') }
      )
    end

    def attributes_payload(items:)
      items.map do |item|
        item[:payload_in_kg] = item.delete(:weight)
        item
      end
    end

    def route_target_params(target:)
      if target.type == "address"
        {
          latitude: target.latitude,
          longitude: target.longitude,
          country: target.country,
          full_address: target.address,
          address: target.address,
          id: target.id
        }
      else
        {
          nexus_id: nexus_id(locode: target.address),
          address: target.address,
          id: target.id
        }
      end
    end

    def nexus_id(locode:)
      target = Legacy::Nexus.find_by(organization: organization, locode: locode)
      return if target.blank?

      target.id
    end

    def origin
      @origin ||= Carta::Client.lookup(id: params[:origin_id])
    end

    def destination
      @destination ||= Carta::Client.lookup(id: params[:destination_id])
    end

    def aggregated_cargo_attributes
      return [] if params[:aggregated].blank?

      item = params[:items].first
      {
        total_weight: item[:weight],
        total_volume: item[:volume],
        stackable: true,
        dangerous: {},
        commodities: item[:commodities]
      }
    end
  end
end
