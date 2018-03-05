class CargoItem < ApplicationRecord
  EFFECTIVE_TONNAGE_PER_CUBIC_METER = {
    air: 0.167,
    rail: 0.55,
    ocean: 1.0,
    trucking: 0.333
  }
  belongs_to :shipment

  validates :payload_in_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :dimension_x,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :dimension_y,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :dimension_z,   presence: true, numericality: { greater_than_or_equal_to: 0 }

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
    chargeable_weight = [volume * EFFECTIVE_TONNAGE_PER_CUBIC_METER[mot.to_sym], payload_in_tons].max
    save!
  end

  def weight_or_volume
    # Keeping this alias method temporarily
    chargeable_weight
  end
end
