# frozen_string_literal: true

module OfferCalculator
  class Request
    def initialize(query:, params:, persist: true)
      @query = query
      @params = params.with_indifferent_access
      @persist = persist
    end

    attr_reader :params, :query

    delegate :source, :client, :creator, :organization, :cargo_ready_date, to: :query

    def cargo_units
      @cargo_units ||= OfferCalculator::Service::CargoCreator.new(
        query: query,
        params: params,
        persist: persist_cargo?
      ).perform
    end

    def has_pre_carriage?
      nexus_id(target: "origin").blank? && params.dig("origin", "latitude").present?
    end

    def has_on_carriage?
      nexus_id(target: "destination").blank? && params.dig("destination", "latitude").present?
    end

    def has_carriage?(carriage:)
      send("has_#{carriage}_carriage?")
    end

    def trucking_params
      @trucking_params ||= params.dig("trucking")
    end

    def pickup_address
      @pickup_address ||= address(target: "origin")
    end

    def delivery_address
      @delivery_address ||= address(target: "destination")
    end

    def address(target:)
      Legacy::Address.new(
        latitude: params.dig(target, "latitude"),
        longitude: params.dig(target, "longitude")
      ).reverse_geocode
    end

    def nexus_id(target:)
      params.dig(target, "nexus_id")
    end

    def estimated
      params.dig("estimated")
    end

    def delay
      params.dig("delay")
    end

    def async
      params.dig("async").present?
    end

    def load_type
      @load_type ||= query.load_type == "fcl" ? "container" : "cargo_item"
    end

    def cargo_classes
      @cargo_classes ||= cargo_units.pluck(:cargo_class).uniq
    end

    def persist_cargo?
      persist? || params["estimated"].present?
    end

    def geo_id(target:)
      params.dig(target, "id")
    end

    def currency
      client_currency = client.settings&.currency

      client_currency || scope.dig(:default_currency)
    end

    def persist?
      @persist
    end

    def scope
      @scope ||= OrganizationManager::ScopeService.new(target: client, organization: organization).fetch
    end

    def result_set
      @result_set ||= Journey::ResultSet.new(query: query, currency: currency, status: "running").tap do |new_result_set|
        new_result_set.save! if persist?
      end
    end
  end
end
