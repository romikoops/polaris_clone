# frozen_string_literal: true

module Cargo
  class Creator
    Failure = Class.new(StandardError)
    InvalidCargo = Class.new(Failure)
    EmptyCargo = Class.new(Failure)

    attr_reader :legacy_shipment, :quotation, :errors, :organization, :cargo

    LEGACY_CARGO_MAP = YAML.load_file(File.expand_path("../../../data/cargo.yaml", __dir__)).freeze
    CARGO_CLASS_LEGACY_MAPPER = LEGACY_CARGO_MAP.map { |k, v| [k, v["class"]] }.to_h
    CARGO_TYPE_LEGACY_MAPPER = LEGACY_CARGO_MAP.map { |k, v| [k, v["type"]] }.to_h

    def initialize(legacy_shipment:, quotation:)
      @legacy_shipment = legacy_shipment
      @errors = []
      @quotation = quotation
      @organization = legacy_shipment.organization
      @scope = ::OrganizationManager::ScopeService.new(
        target: legacy_shipment.user,
        organization: @organization
      )
      @cargo = ::Cargo::Cargo.new(
        quotation_id: quotation&.id,
        organization: organization,
        total_goods_value_cents: shipment_total_goods_value,
        total_goods_value_currency: shipment_total_goods_currency
      )
    end

    def perform
      cargo.units = cargo_units

      raise EmptyCargo if cargo.units.empty?
      raise InvalidCargo unless cargo.save

      cargo
    end

    def shipment_total_goods_value
      @shipment_total_goods_value ||= legacy_shipment.total_goods_value&.dig("value") || 0
    end

    def shipment_total_goods_currency
      @shipment_total_goods_currency ||=
        legacy_shipment.total_goods_value&.dig("currency") ||
        Users::Settings.find_by(user_id: legacy_shipment.user_id)&.currency ||
        @scope.fetch(:default_currency)
    end

    def cargo_units
      if legacy_shipment.fcl?
        fcl_units
      elsif legacy_shipment.aggregated_cargo.present?
        aggregated_unit
      else
        lcl_units
      end
    end

    def fcl_units
      containers.map do |container|
        cargo_class = CARGO_CLASS_LEGACY_MAPPER[container.cargo_class]
        cargo_type = CARGO_TYPE_LEGACY_MAPPER[container.cargo_class]

        Unit.new(
          organization_id: quotation.organization_id,
          quantity: container.quantity,
          legacy: container,
          cargo_class: cargo_class,
          cargo_type: cargo_type,
          weight_value: container.payload_in_kg,
          goods_value_cents: shipment_total_goods_value / container.quantity,
          goods_value_currency: shipment_total_goods_currency,
          dangerous_goods: (container.dangerous_goods ? :unspecified : nil)
        )
      end
    end

    def lcl_units
      cargo_items.map do |item|
        Unit.new(
          item_attributes(item: item)
        )
      end
    end

    def aggregated_unit
      if (aggregated_cargo = legacy_shipment.aggregated_cargo)
        [Unit.new(
          organization_id: quotation.organization_id,
          weight_value: aggregated_cargo.weight,
          volume_value: aggregated_cargo.volume,
          quantity: 1,
          legacy: aggregated_cargo,
          cargo_class: "00",
          cargo_type: "AGR",
          goods_value_cents: shipment_total_goods_value,
          goods_value_currency: shipment_total_goods_currency,
          dangerous_goods: (aggregated_cargo.dangerous_goods? ? :unspecified : nil)
        )]
      end
    end

    def item_attributes(item:)
      {
        organization_id: quotation.organization_id,
        weight_value: item.payload_in_kg,
        width_value: item.width.to_f / 100,
        length_value: item.length.to_f / 100,
        height_value: item.height.to_f / 100,
        quantity: item.quantity,
        cargo_class: "00",
        cargo_type: "LCL",
        legacy: item,
        stackable: item.stackable,
        goods_value_cents: shipment_total_goods_value / item.quantity,
        goods_value_currency: shipment_total_goods_currency,
        dangerous_goods: (item.dangerous_goods ? :unspecified : nil)
      }
    end

    def cargo_items
      @cargo_items ||= Legacy::CargoItem.where(shipment: legacy_shipment)
    end

    def containers
      @containers ||= Legacy::Container.where(shipment: legacy_shipment)
    end
  end
end
