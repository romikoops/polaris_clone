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
      # This method determines whether the cargo_item would be valid, should the shipment's itinerary
      # have the mode of transport supplied as argument.

      # Creates and auxiliary class, cloned from CargoItem, with one aditional
      # validation, which depends on the mode of transport.
      klass = ::Legacy::CustomValidations.cargo_item_max_dimensions(CargoItem.clone, mode_of_transport)
      Module.const_set('AuxCargoItem', klass)

      # Instantiates the auxiliary class, sets the chargeable weight,
      # and checks if the item is still valid, thereby applying the new validation.
      aux_cargo_item = Module::AuxCargoItem.new(given_attributes)
      aux_cargo_item.chargeable_weight = calc_chargeable_weight(mode_of_transport)
      aux_cargo_item.valid?
    end

    private

    def set_default_cargo_class!
      self.cargo_class ||= 'lcl'
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
