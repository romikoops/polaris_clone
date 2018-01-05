class Container < ApplicationRecord
  belongs_to :shipment

  validates :size_class,    presence: true
  validates :weight_class,  presence: true
  validates :payload_in_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tare_weight,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :gross_weight,  presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Class methods
  def self.extract_containers(params)
    containers = []
    contWeights = {
        'fcl_20f' => 2370,
        'fcl_40f' => 3750,
        'fcl_40f_hq' => 4000,
        
    }

    params.each do |value|
      
      size_class = value["sizeClass"]
      payload_in_kg = value["payload_in_kg"].to_d
      tare_weight = contWeights[size_class].to_d
      gross_weight = tare_weight + payload_in_kg
      weight_class = get_weight_class(size_class, payload_in_kg)
      quantity = value["quantity"].to_i
      unless value["_destroy"] == "1"
        quantity.times do
          containers << Container.new(size_class: size_class, tare_weight: tare_weight, payload_in_kg: payload_in_kg, gross_weight: gross_weight, weight_class: weight_class)
        end
      end
    end
    containers
  end

  def self.get_weight_class(size_class, payload_in_kg)
    size = size_class.split("_").first
    which_weight_step = nil
    PRICING_WEIGHT_STEPS[1..-1].each_with_index do |weight_step, i|
      if payload_in_kg / 1000 > weight_step
        which_weight_step = PRICING_WEIGHT_STEPS[i]
      end
    end
    if which_weight_step.nil?
      which_weight_step = PRICING_WEIGHT_STEPS[-1]
    end
    which_weight_step = which_weight_step.to_d
    "<= #{which_weight_step}t"
  end

  # Instance Methods
  def size
    self.size_class.split("_")[0]
  end
end
