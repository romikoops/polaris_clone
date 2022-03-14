# frozen_string_literal: true

module OfferCalculator
  class Request
    def initialize(query:, params:, pre_carriage:, on_carriage:, persist: true)
      @query = query
      @params = params.with_indifferent_access
      @persist = persist
      @pre_carriage = pre_carriage
      @on_carriage = on_carriage
    end

    attr_reader :params, :query, :on_carriage, :pre_carriage

    delegate :source, :creator, :organization, :cargo_ready_date, :currency, :origin_geo_id, :destination_geo_id, to: :query

    def cargo_units
      @cargo_units ||= query.cargo_units.presence || OfferCalculator::Service::CargoCreator.new(
        query: query,
        params: params,
        persist: persist_cargo?
      ).perform
    end

    def client
      query.client.presence || Users::Client.new
    end

    def pre_carriage?
      pre_carriage
    end

    def on_carriage?
      on_carriage
    end

    def carriage?(carriage:)
      send("#{carriage}_carriage?")
    end

    def trucking_params
      @trucking_params ||= params["trucking"]
    end

    def pickup_address
      if pre_carriage?
        @pickup_address ||= address(
          latitude: query.origin_coordinates.y,
          longitude: query.origin_coordinates.x
        )
      end
    end

    def delivery_address
      if on_carriage?
        @delivery_address ||= address(
          latitude: query.destination_coordinates.y,
          longitude: query.destination_coordinates.x
        )
      end
    end

    def address(latitude:, longitude:)
      Legacy::Address.new(
        latitude: latitude,
        longitude: longitude
      ).reverse_geocode
    end

    def nexus_id(target:)
      params.dig(target, "nexus_id") || nexus_id_from_carta(target: target)
    end

    def truck_type
      load_type == "container" ? "chassis" : "default"
    end

    def estimated
      params["estimated"]
    end

    def delay
      params["delay"]
    end

    def async
      params["async"].present?
    end

    def load_type
      @load_type ||= query.load_type == "fcl" ? "container" : "cargo_item"
    end

    def cargo_classes
      @cargo_classes ||= cargo_units.pluck(:cargo_class).uniq.map { |string| string.gsub("aggregated_", "") }
    end

    def persist_cargo?
      params.key?("estimated") ? !params["estimated"] : persist?
    end

    def currency
      client_currency = client.settings&.currency

      client_currency || scope[:default_currency]
    end

    def persist?
      @persist
    end

    def scope
      @scope ||= OrganizationManager::ScopeService.new(target: client, organization: organization).fetch
    end

    def origin
      @origin ||= Carta::Client.lookup(id: query.origin_geo_id)
    end

    def destination
      @destination ||= Carta::Client.lookup(id: query.destination_geo_id)
    end

    def nexus_id_from_carta(target:)
      carta_result = target == :origin ? origin : destination
      Legacy::Nexus.where(organization: query.organization, locode: carta_result.address).pluck(:id).first
    end
  end
end
