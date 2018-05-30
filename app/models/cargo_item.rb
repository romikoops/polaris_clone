class CargoItem < ApplicationRecord
  EFFECTIVE_TONNAGE_PER_CUBIC_METER = {
    air:      "0.167",
    rail:     "0.550",
    ocean:    "1.000",
    trucking: "0.333"
  }.map_values { |v| BigDecimal.new(v) }

  MAX_DIMENSIONS = {
    general: {
      dimension_x:   "590.0",
      dimension_y:   "234.2",
      dimension_z:   "228.0",
      payload_in_kg: "21_770.0"
    }.map_values { |v| BigDecimal.new(v) },
    air: {
      dimension_x:   "120.0",
      dimension_y:   "80.0",
      dimension_z:   "158.0",
      payload_in_kg: "0"
    }.map_values { |v| BigDecimal.new(v) }
  }
  
  MAX_AGGREGATE_DIMENSIONS = {
    general: {
      dimension_x:   "0",
      dimension_y:   "0",
      dimension_z:   "0",
      payload_in_kg: "0"
    }.map_values { |v| BigDecimal.new(v) },
    air: {
      dimension_x:   "0",
      dimension_y:   "0",
      dimension_z:   "0",
      payload_in_kg: "1_500.0"
    }.map_values { |v| BigDecimal.new(v) }
  }

  belongs_to :shipment
  belongs_to :cargo_item_type

  MAX_DIMENSIONS.each do |mot, max_dimensions|
    max_dimensions.each do |attribute, max_dimension|
      validates attribute,
        presence: true,
        numericality: {
          greater_than_or_equal_to: 0,
          less_than_or_equal_to: max_dimension
        },
        if: -> obj {
          itinerary = obj.shipment.itinerary
          max_dimension > 0 &&
          ((mot == :general) || (mot == (itinerary && itinerary.mode_of_transport.to_sym)))
        }
    end
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

  def set_chargeable_weight!(mot = "ocean")
    self.chargeable_weight =
      [volume * EFFECTIVE_TONNAGE_PER_CUBIC_METER[mot.to_sym] * 1000, payload_in_kg].max
    
    save!
  end

end
