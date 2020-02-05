# frozen_string_literal: true

module Legacy
  class CargoItem < ApplicationRecord
    self.table_name = 'cargo_items'

    EFFECTIVE_TONNAGE_PER_CUBIC_METER = {
      air: 0.167,
      rail: 0.500,
      ocean: 1.000,
      trucking: 0.333,
      truck: 0.333
    }.freeze

    DIMENSIONS = %i(dimension_x dimension_y dimension_z payload_in_kg chargeable_weight).freeze

    has_paper_trail

    belongs_to :shipment, class_name: 'Legacy::Shipment'
    delegate :tenant, to: :shipment
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    belongs_to :cargo_item_type

    before_validation :set_default_cargo_class!, on: :create
    before_validation :set_chargeable_weight!

    def self.calc_chargeable_weight_from_values(volume, payload_in_kg, mot)
      [volume * EFFECTIVE_TONNAGE_PER_CUBIC_METER[mot.to_sym] * 1000, payload_in_kg].max
    end

    def self.extract(cargo_items_attributes)
      cargo_items_attributes.map do |cargo_item_attributes|
        new(cargo_item_attributes)
      end
    end

    # Instance Methods
    def volume
      dimension_x * dimension_y * dimension_z / 1_000_000
    end

    def with_cargo_type
      as_json(
        include: [
          {
            cargo_item_type: {
              only: %i(description)
            }
          }
        ]
      )
    end

    def payload_in_tons
      payload_in_kg / 1000
    end

    def set_chargeable_weight!
      return nil if shipment.itinerary.nil?

      self.chargeable_weight = calc_chargeable_weight(shipment.itinerary.mode_of_transport)
    end

    def calc_chargeable_weight(mot)
      Legacy::CargoItem.calc_chargeable_weight_from_values(volume, payload_in_kg, mot)
    end

    def valid_for_mode_of_transport?(mode_of_transport)
      mode_of_transport ||= shipment.itinerary.try(:mode_of_transport)
      self.chargeable_weight = calc_chargeable_weight(mode_of_transport)
      max_dimensions = max_dimension(tenant_id: tenant.id, mode_of_transport: mode_of_transport)
      exceeded_dimensions = DIMENSIONS.reject do |dimension|
        self[dimension] <= max_dimensions[dimension]
      end
      self.chargeable_weight = nil

      exceeded_dimensions.empty?
    end

    private

    def set_default_cargo_class!
      self.cargo_class ||= 'lcl'
    end

    def max_dimension(tenant_id:, mode_of_transport:)
      bundle = MaxDimensionsBundle.find_by(tenant_id: tenant_id, mode_of_transport: mode_of_transport, aggregate: false)
      bundle || MaxDimensionsBundle.find_by(tenant_id: tenant_id, mode_of_transport: 'general', aggregate: false)
    end
  end
end

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint           not null, primary key
#  cargo_class        :string
#  chargeable_weight  :decimal(, )
#  customs_text       :string
#  dangerous_goods    :boolean
#  dimension_x        :decimal(, )
#  dimension_y        :decimal(, )
#  dimension_z        :decimal(, )
#  hs_codes           :string           default([]), is an Array
#  payload_in_kg      :decimal(, )
#  quantity           :integer
#  stackable          :boolean          default(TRUE)
#  unit_price         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_item_type_id :integer
#  sandbox_id         :uuid
#  shipment_id        :integer
#
# Indexes
#
#  index_cargo_items_on_sandbox_id  (sandbox_id)
#
