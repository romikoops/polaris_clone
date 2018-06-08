# frozen_string_literal: true

class CargoItem < ApplicationRecord
  EFFECTIVE_TONNAGE_PER_CUBIC_METER = {
    air:      "0.167",
    rail:     "0.550",
    ocean:    "1.000",
    trucking: "0.333",
    truck:    "0.333"
  }.map_values { |v| BigDecimal(v) }

  DIMENSIONS = %i[dimension_x dimension_y dimension_z payload_in_kg chargeable_weight].freeze

  belongs_to :shipment
  delegate :tenant, to: :shipment

  belongs_to :cargo_item_type

  before_validation :set_chargeable_weight!

  CustomValidations.cargo_item_max_dimensions(self)

  # Class Methods
  def self.extract(cargo_items_attributes)
    cargo_items_attributes.map do |cargo_item_attributes|
      new(cargo_item_attributes)
    end
  end

  # Instance Methods
  def volume
    dimension_x * dimension_y * dimension_z / 1_000_000
  end

  def payload_in_tons
    payload_in_kg / 1000
  end

  def set_chargeable_weight!
    return nil if shipment.itinerary.nil?

    self.chargeable_weight = calc_chargeable_weight(shipment.itinerary.mode_of_transport)
  end

  def calc_chargeable_weight(mot)
    [volume * EFFECTIVE_TONNAGE_PER_CUBIC_METER[mot.to_sym] * 1000, payload_in_kg].max
  end

  def valid_for_itinerary?(itinerary)
    # This method determines whether the cargo_item would be valid, should the itinerary
    # supplied as argument become the shipment's itinerary.

    # Creates and auxiliary class, cloned from CargoItem, with one aditional
    # validation, which depends on this itinerary's mode of transport.
    klass = CustomValidations.cargo_item_max_dimensions(CargoItem.clone, itinerary)
    Module.const_set("AuxCargoItem", klass)

    # Instantiates the auxiliary class, sets the chargeable weight,
    # and checks if the item is still valid, thereby applying the new validation.
    aux_cargo_item = Module::AuxCargoItem.new(given_attributes)
    aux_cargo_item.chargeable_weight = calc_chargeable_weight(itinerary.mode_of_transport)
    aux_cargo_item.valid?
  end
end
