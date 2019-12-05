# frozen_string_literal: true

module Cargo
  class Creator
    attr_reader :legacy_shipment, :quotation, :errors

    CARGO_CLASS_LEGACY_MAPPER = {
      fcl_20: '22',
      fcl_40: '42',
      fcl_40_hq: '45',
      fcl_45: 'L2'
    }.freeze

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
        cargo_class = CARGO_CLASS_LEGACY_MAPPER[container.cargo_class.to_sym]
        cargo.units << Unit.new(
          tenant_id: quotation.tenant_id,
          quantity: container.quantity,
          cargo_class: cargo_class,
          cargo_type: 'GP',
          goods_value_cents: legacy_shipment.total_goods_value['value'] / container.quantity,
          goods_value_currency: legacy_shipment.total_goods_value['currency'],
          dangerous_goods: (container.dangerous_goods ? :unspecified : nil)
        )
      end

      cargo_items.find_each do |item|
        cargo.units << Unit.new(
          tenant_id: quotation.tenant_id,
          weight_value: item.payload_in_kg,
          width_value: item.dimension_x,
          length_value: item.dimension_y,
          height_value: item.dimension_z,
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
