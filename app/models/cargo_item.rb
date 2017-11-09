class CargoItem < ApplicationRecord
  belongs_to :shipment
  def self.extract_cargos(params)
    cargos = []
    params.each_key do |key|
      value = params["#{key}"]
      payload_in_kg = value["payload_in_kg"].to_d
      dimension_x = value["dimension_x"].to_d
      dimension_y = value["dimension_y"].to_d
      dimension_z = value["dimension_z"].to_d
      unless value["_destroy"] == "1"
        cargos << CargoItem.new(payload_in_kg: payload_in_kg, dimension_x: dimension_x, dimension_y: dimension_y, dimension_z: dimension_z)
      end
    end
    cargos
  end

  def volume
    dimension_x * dimension_y * dimension_z / 1000000    
  end

  def payload_in_tons
    payload_in_kg / 1000    
  end

  def weight_or_volume
    if volume > payload_in_tons
      volume
    else
      payload_in_tons
    end
  end
end
