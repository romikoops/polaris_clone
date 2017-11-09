class Container < ApplicationRecord
  belongs_to :shipment

  # Class methods
  def self.extract_containers(params)
    containers = []
    params.each_key do |key|
      value = params["#{key}"]
      size_class = value["size_class"]
      payload_in_kg = value["payload_in_kg"].to_d
      tare_weight = CONTAINER_WEIGHTS[size_class].to_d
      gross_weight = tare_weight + payload_in_kg
      weight_class = get_weight_class(size_class, payload_in_kg)
      unless value["_destroy"] == "1"
        containers << Container.new(size_class: size_class, tare_weight: tare_weight, payload_in_kg: payload_in_kg, gross_weight: gross_weight, weight_class: weight_class)
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
