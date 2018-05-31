class CargoItem < ApplicationRecord
  EFFECTIVE_TONNAGE_PER_CUBIC_METER = {
    air:      "0.167",
    rail:     "0.550",
    ocean:    "1.000",
    trucking: "0.333"
  }.map_values { |v| BigDecimal.new(v) }

  MAX_DIMENSIONS = {
    general: {
      dimension_x:       "590.0",
      dimension_y:       "234.2",
      dimension_z:       "228.0",
      payload_in_kg:     "21_770.0"
    },
    air: {
      dimension_x:       "120.0",
      dimension_y:       "80.0",
      dimension_z:       "158.0",
      payload_in_kg:     "1_500.0"
    }
  }.map_deep_values { |v| BigDecimal.new(v) }
  
  MAX_AGGREGATE_DIMENSIONS = {
    general: {
      dimension_x:       "0",
      dimension_y:       "0",
      dimension_z:       "0",
      payload_in_kg:     "0",
      chargeable_weight: "0"
    },
    air: {
      dimension_x:       "0",
      dimension_y:       "0",
      dimension_z:       "0",
      payload_in_kg:     "1_500.0",
      chargeable_weight: "1_500.0"
    }
  }.map_deep_values { |v| BigDecimal.new(v) }

  belongs_to :shipment
  belongs_to :cargo_item_type

  before_validation :set_chargeable_weight!

  MAX_DIMENSIONS.each do |mot, max_dimensions|
    CustomValidations.cargo_item_max_dimensions(self, mot, max_dimensions)
  end

  # Class Methods
  def self.extract(cargo_items_attributes)
    cargo_items_attributes.map do |cargo_item_attributes|
      new(cargo_item_attributes)
    end
  end

  # Instance Methods
  def volume
    dimension_x * dimension_y * dimension_z / 1000000    
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
    klass = CustomValidations.cargo_item_max_dimensions(
      CargoItem.clone,
      :air,
      CargoItem::MAX_DIMENSIONS[:air],
      itinerary
    )
    Module.const_set('AuxCargoItem', klass)
    
    # Instantiates the auxiliary class and checks if the item is still valid,
    # thereby applying the new validation.
    Module::AuxCargoItem.new(self.given_attributes).valid?
  end
end
