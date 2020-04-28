# frozen_string_literal: true

module Cargo
  class Creator
    attr_reader :legacy_shipment, :quotation, :errors

    LEGACY_CARGO_MAP = YAML.load_file(File.expand_path('../../../data/cargo.yaml', __dir__)).freeze
    CARGO_CLASS_LEGACY_MAPPER = LEGACY_CARGO_MAP.map { |k, v| [k, v['class']] }.to_h
    CARGO_TYPE_LEGACY_MAPPER = LEGACY_CARGO_MAP.map { |k, v| [k, v['type']] }.to_h

    def initialize(legacy_shipment:)
      @legacy_shipment = legacy_shipment
      @quotation = Quotations::Tender.find(legacy_shipment.meta['tender_id']).quotation
      @errors = []
    end

    def perform
      containers = Legacy::Container.where(shipment: legacy_shipment)
      cargo_items = Legacy::CargoItem.where(shipment: legacy_shipment)

      cargo = ::Cargo::Cargo.new(
        quotation_id: quotation.id,
        tenant: quotation.tenant,
        total_goods_value_cents: legacy_shipment.total_goods_value['value'],
        total_goods_value_currency: legacy_shipment.total_goods_value['currency']
      )

      containers.find_each do |container|
        cargo_class = CARGO_CLASS_LEGACY_MAPPER[container.cargo_class]
        cargo_type = CARGO_TYPE_LEGACY_MAPPER[container.cargo_class]

        cargo.units << Unit.new(
          tenant_id: quotation.tenant_id,
          quantity: container.quantity,
          cargo_class: cargo_class,
          cargo_type: cargo_type,
          weight_value: container.payload_in_kg,
          goods_value_cents: legacy_shipment.total_goods_value['value'] / container.quantity,
          goods_value_currency: legacy_shipment.total_goods_value['currency'],
          dangerous_goods: (container.dangerous_goods ? :unspecified : nil)
        )
      end

      cargo_items.find_each do |item|
        cargo.units << Unit.new(
          tenant_id: quotation.tenant_id,
          weight_value: item.payload_in_kg,
          width_value: item.dimension_x.to_f / 100,
          length_value: item.dimension_y.to_f / 100,
          height_value: item.dimension_z.to_f / 100,
          quantity: item.quantity,
          cargo_class: '00',
          cargo_type: 'LCL',
          goods_value_cents: legacy_shipment.total_goods_value['value'] / item.quantity,
          goods_value_currency: legacy_shipment.total_goods_value['currency'],
          dangerous_goods: (item.dangerous_goods ? :unspecified : nil)
        )
      end

      if (aggregated_cargo = legacy_shipment.aggregated_cargo)
        cargo.units << Unit.new(
          tenant_id: quotation.tenant_id,
          weight_value: aggregated_cargo.weight,
          volume_value: aggregated_cargo.volume,
          quantity: 1,
          cargo_class: '00',
          cargo_type: 'AGR',
          goods_value_cents: legacy_shipment.total_goods_value['value'],
          goods_value_currency: legacy_shipment.total_goods_value['currency'],
          dangerous_goods: (aggregated_cargo.dangerous_goods? ? :unspecified : nil)
        )
      end

      if cargo.units.empty?
        @errors << 'empty cargo'
      elsif cargo.invalid?
        @errors << cargo.errors.messages
      else
        cargo.save
      end

      self
    end
  end
end
