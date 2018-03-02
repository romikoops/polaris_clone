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
  def self.extract(params)
    cargos = []
    byebug
    params.each do |value|  
      payload_in_kg = value["payload_in_kg"].to_d
      dimension_x = value["dimension_x"].to_d
      dimension_y = value["dimension_y"].to_d
      dimension_z = value["dimension_z"].to_d
      quantity = value["quantity"].to_i
      cargo_group_id = SecureRandom.uuid
      
      unless value["_destroy"] == "1"
        quantity.times do
          cargos << CargoItem.new(payload_in_kg: payload_in_kg, dimension_x: dimension_x, dimension_y: dimension_y, dimension_z: dimension_z, cargo_item_type_id: value["colliType"], cargo_group_id: cargo_group_id)
        end
      end
    end
    cargos
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
